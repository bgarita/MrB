package com.infot.mrb.backup;

import com.infot.mrb.utilities.Bitacora;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;
import java.util.zip.ZipOutputStream;
import javax.swing.JProgressBar;

import javax.crypto.Cipher;
import javax.crypto.SecretKey;
import java.util.Base64;
import javax.crypto.spec.SecretKeySpec;

/**
 * This class creates zip encrypted files. Thouse files can be extracted but not understood.
 * This class includes methods for decrypting passwords and files.
 * The zipped files will be stored in a zip folder on the application installation directoy.
 * @author AA07SZZ, 09-05-2023
 */
public class ZipFiles {

    //private static final String PASSWORD = "dotcom-2023%09*05-{1.!$}"; // Must be 16, 24 or 32 length for AES-128, AES-192 or AES-256, respectively
    private final boolean removeAfterZip;
    private JProgressBar progressBar;
    private boolean encrypted;
    private final Encryption encryption = new Encryption();
    private final Bitacora log = new Bitacora();

    public ZipFiles() {
        this.removeAfterZip = false;
    }

    public ZipFiles(boolean removeAfterZip) {
        this.removeAfterZip = removeAfterZip;
    }

    public boolean isRemoveAfterZip() {
        return removeAfterZip;
    }

    public JProgressBar getProgressBar() {
        return progressBar;
    }

    public boolean isEncrypted() {
        return encrypted;
    }
    
    public void setEncryptFiles(boolean encrypt) {
        this.encrypted = encrypt;
    }

    
    /**
     * Zips a file directory with all its files and subdirectories.The zipped
     * file will be stored in the zip directory.
     *
     * @author Bosco Garita Azofeifa
     * @return String Zipped file name
     * @throws java.lang.ClassNotFoundException
     * @throws java.sql.SQLException
     * @since 09-05-2023
     * @param sourceFile File can be a file or a folder.
     * @throws FileNotFoundException
     * @throws IOException
     *
     */
    public String zipFile(File sourceFile) throws FileNotFoundException, IOException, ClassNotFoundException, SQLException {

        // If zip folder does not exist, create it.
        File zipFolder = new File("zip");
        if (!zipFolder.exists()) {
            zipFolder.mkdir();
        }

        FileOutputStream fos;
        String targetFileName;

        // Create a unique file name
        String uniqueFileName = generateUniqueFileName(sourceFile.getName());
        targetFileName = zipFolder.getName() + System.getProperty("file.separator") + uniqueFileName + ".zip";

        fos = new FileOutputStream(targetFileName);

        try (ZipOutputStream zos = new ZipOutputStream(fos)) {
            addZipFile(sourceFile, zos);
            zos.closeEntry();
        }

        if (this.removeAfterZip) {
            delete(sourceFile); // removes files and folders
        }
        log.info("\nZipped file: " + targetFileName);
        File file = new File(targetFileName);

        return file.getCanonicalPath();
    } // end zipFile

    /**
     * Encrypts files and adds them to the archive. Original files will be deleted
     * after compressing.
     *
     * @param sourceFile File File or directory to be zipped.
     * @param zos ZipOutputStream Stream where all files will be zipped.
     * @throws IOException
     */
    private void addZipFile(File sourceFile, ZipOutputStream zos) throws IOException {

        // If source is a directory, add every file which is inside it.
        if (sourceFile.isDirectory()) {
            File[] files = sourceFile.listFiles();

            for (File f : files) {
                // Recursive call
                if (f.isDirectory()) {
                    addZipFile(f, zos);
                    continue;
                }
                
                File fileToZip = new File(f.getCanonicalPath());
                
                if (this.encrypted) {
                    // Encrypt file before compressing and then delete it.
                    fileToZip = encryption.encryptFile(fileToZip);
                }

                log.info("Compressing " + fileToZip.getAbsolutePath());
                
                zos.putNextEntry(new ZipEntry(fileToZip.getCanonicalPath()));
                byte[] bytes = Files.readAllBytes(Paths.get(fileToZip.getAbsolutePath()));
                zos.write(bytes, 0, bytes.length);

                // Update progress bar if file is json
                if (f.getAbsolutePath().endsWith(".json")) {
                    this.progressBar.setValue(this.progressBar.getValue() + 10);
                }

            } // end for

        } else {
            File fileToZip = new File(sourceFile.getAbsolutePath());
            if (this.encrypted) {
                fileToZip = encryption.encryptFile(sourceFile);
            }

            log.info("Compressing " + sourceFile.getAbsolutePath());
            zos.putNextEntry(new ZipEntry(fileToZip.getCanonicalPath()));
            byte[] bytes = Files.readAllBytes(Paths.get(fileToZip.getAbsolutePath()));
            zos.write(bytes, 0, bytes.length);

            // Update progress bar if file is json
            if (sourceFile.getAbsolutePath().endsWith(".json")) {
                this.progressBar.setValue(this.progressBar.getValue() + 10);
            }
        } // end if

    } // end addZipFile


    private void delete(File file) {
        // Check if .cif file exists and remove it too
        if (file.isFile()) {
            File cifFile = new File(file.getAbsolutePath() + ".cif");
            if (cifFile.exists()) {
                cifFile.delete();
            }
            file.delete();
            return;
        }

        // Remove files recursibly
        if (file.isDirectory()) {
            File[] files = file.listFiles();
            for (File f : files) {
                delete(f);
            }
            file.delete(); // Remove parent directory
        }
    }

    private String generateUniqueFileName(String baseName) {
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyyMMddHHmmss");
        String timestamp = dateFormat.format(new Date());
        String uniqueFileName = baseName + "_" + timestamp;
        return uniqueFileName;
    }

    /**
     * Uncompress all files contained in a zip file.A new folder with all
     * charaters before the "_" character will be created to extract all files.
     *
     * @param zipFile File file to uncompress.
     * @param maxPoints int points for the progress bar
     * @return String folder containing the extracted files.
     * @throws java.io.FileNotFoundException
     */
    public String unzipFile(File zipFile, int maxPoints) throws FileNotFoundException, IOException {
        // Prevent divided by zero error
        if (maxPoints <= 0) {
            maxPoints = 1;
        }

        log.info("Extracting files..");
        String sourceFile = zipFile.getName();
        String outputFolder = sourceFile.split("_")[0];

        File folder = new File(outputFolder);

        if (folder.exists()) {
            delete(folder);
        }

        folder.mkdir();

        FileInputStream is = new FileInputStream(zipFile);
        int entries = 0;
        try (ZipInputStream zis = new ZipInputStream(is)) {
            ZipEntry ze;
            while ((ze = zis.getNextEntry()) != null) {
                entries++;
            }
        }

        // Prevent divided by zero error
        if (entries == 0) {
            entries = 1;
        }

        double valueForEachEntry = (double) maxPoints / (double) entries;
        int pointsApplied = 0;

        FileInputStream fis = new FileInputStream(zipFile);
        try (ZipInputStream zis = new ZipInputStream(fis)) {
            ZipEntry ze;

            while ((ze = zis.getNextEntry()) != null) {
                String fileName = getFileName(ze.getName());
                File newFile = new File(outputFolder + File.separator + fileName);

                try (FileOutputStream fos = new FileOutputStream(newFile)) {
                    int len;
                    byte[] buffer = new byte[1024];

                    while ((len = zis.read(buffer)) > 0) {
                        fos.write(buffer, 0, len);
                    }
                }
                zis.closeEntry();
                if (this.progressBar != null) {
                    this.progressBar.setValue(this.progressBar.getValue() + (int) valueForEachEntry);
                    pointsApplied += (int) valueForEachEntry;
                }

            }
        }
        log.info("Extracting files.. complete!");

        // Set max points for this task without calculaing in case the rounding process was not exact
        if (this.progressBar != null) {
            this.progressBar.setValue(this.progressBar.getValue() + (maxPoints - pointsApplied));
        }

        return outputFolder;
    }

    private String getFileName(String absoluteName) {
        String sep = File.separator;
        if ("\\".equals(File.separator)) {
            sep = "\\\\";
        }
        absoluteName = absoluteName.replaceAll(sep, "@@");
        String[] pathParts = absoluteName.split("@@");
        String fileName = pathParts[pathParts.length - 1];
        return fileName;
    }

    public void setProgressBar(JProgressBar progressBar) {
        this.progressBar = progressBar;
    }


    public String AESEncrypt(String text) throws Exception {
        SecretKey password = new SecretKeySpec(Encryption.getPASSWORD().getBytes(), "AES");
        Cipher cipher = Cipher.getInstance("AES");
        cipher.init(Cipher.ENCRYPT_MODE, password);
        byte[] encryptedText = cipher.doFinal(text.getBytes());
        return Base64.getEncoder().encodeToString(encryptedText);
    }

    public String AESDecrypt(String encryptedText) throws Exception {
        SecretKey password = new SecretKeySpec(Encryption.getPASSWORD().getBytes(), "AES");
        Cipher cipher = Cipher.getInstance("AES");
        cipher.init(Cipher.DECRYPT_MODE, password);
        byte[] decryptedText = cipher.doFinal(Base64.getDecoder().decode(encryptedText));
        return new String(decryptedText);
    }

    
    void setEncrypted(boolean isEncrypted) {
        this.encrypted = isEncrypted;
    }
}
