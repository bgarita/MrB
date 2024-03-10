package com.infot.mrb.utilities;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.nio.file.Files;
import java.nio.file.LinkOption;
import java.nio.file.Paths;
import java.nio.file.attribute.FileTime;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.Properties;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;
import net.lingala.zip4j.ZipFile;
import net.lingala.zip4j.exception.ZipException;
import net.lingala.zip4j.model.ZipParameters;
import net.lingala.zip4j.model.enums.AesKeyStrength;
import net.lingala.zip4j.model.enums.EncryptionMethod;

/**
 * @author: Crysfel Villa Created: Friday, June 03, 2005 4:54:59 PM Modified:
 * Friday, June 03, 2005 4:54:59 PM Bosco Garita Modified: Sunday, Sept 08, 2013
 * 6:52:00 PM Bosco Garita Modified: Saturday, Sept 09, 2023 6:37:00 AM Bosco
 * Garita
 */
public class Archivos {

    private boolean error;
    private String mensaje_error;
    private static String PASSWORD; // This key must be 16, 24 or 32 length for AES-128, AES-192 or AES-256, respectively
    private final Bitacora log = new Bitacora();

    public Archivos() {
        try {
            Properties props = Props.getProps(new File("encrypt.properties"));
            if (props == null | props.isEmpty()) {
                PASSWORD = "G-A*ga*311266$"; // Default key
            } else {
                PASSWORD = props.getProperty("encrypt.key");
            }
        } catch (IOException ex) {
            log.error(ex.getMessage());
        }
    }

    public boolean isError() {
        return error;
    }

    public String getMensaje_error() {
        return mensaje_error;
    }

    /**
     * Copia un directorio con todo y su contendido
     *
     * @param srcDir
     * @param dstDir
     */
    public void copyDirectory(File srcDir, File dstDir) {
        if (srcDir.isDirectory()) {
            if (!dstDir.exists()) {
                dstDir.mkdir();
            } // end if

            String[] children = srcDir.list();
            for (String children1 : children) {
                copyDirectory(new File(srcDir, children1), new File(dstDir, children1));
            } // end for
        } else {
            copyFilex(srcDir, dstDir);
        } // end if-else
    } // copyDirectory

    /**
     * Copia un solo archivo
     *
     * @param src
     * @param dst
     * @throws IOException
     */
    public void copyFile(File src, File dst) throws IOException {
        OutputStream out;
        try (InputStream in = new FileInputStream(src)) {
            out = new FileOutputStream(dst);
            byte[] buf = new byte[1024];
            int len;
            while ((len = in.read(buf)) > 0) {
                out.write(buf, 0, len);
            } // end while
            in.close();
        } // end try with resources
        out.close();
    } // end copyFile

    /**
     * Archivos un archivo.
     *
     * @param in
     * @param out
     */
    public void copyFilex(File in, File out) {

        try {
            try (
                    BufferedInputStream fileIn = new BufferedInputStream(new FileInputStream(in)); BufferedOutputStream fileOut = new BufferedOutputStream(new FileOutputStream(out))) {
                byte[] buf = new byte[2048];
                int i;
                while ((i = fileIn.read(buf)) != -1) {
                    fileOut.write(buf, 0, i);
                } // end while
            } // end try with resources        
        } catch (IOException ex) {
            this.error = true;
            this.mensaje_error = ex.getMessage();
            log.error(this.getClass().getName() + "--> " + ex.getMessage());
        } // end try-catch
    }  // end copyFilex

    /**
     * Cuenta la cantidad de archivos y carpetas contenidas en una ruta específica.
     *
     * @author Bosco Garita
     * @param folder
     * @return
     */
    public int countFiles(File folder) {
        int cuenta = 0;

        if (!folder.exists()) {
            return cuenta;
        } // end if

        if (!folder.isDirectory()) {
            return 1;
        } // end if

        String[] children = folder.list();

        for (String f : children) {
            cuenta += countFiles(new File(folder, f));
        } // end for

        return cuenta;
    } // end countFiles

    /**
     * Guardar texto en un archivo ASCII
     *
     * @param text String - texto a almacenar
     * @param path String - nombre del archivo a guardar (incluye la ruta completa)
     * @param append boolean - true=Agrega el texto, false=Reemplaza el texto existente
     * @throws IOException
     * @author Bosco Garita Azofeifa, 13/07/2019
     */
    public void stringToFile(String text, String path, boolean append) throws IOException {
        FileWriter write = new FileWriter(path, append);
        try (PrintWriter pw = new PrintWriter(write)) {
            pw.printf("%s" + "%n", text);
            pw.close();
        } // end try
    } // end stringToFile

    /**
     * Comprime un archivo o carpeta y todos sus archivos y subcarpetas.
     *
     * @author Bosco Garita Azofeifa
     * @since 20/03/2020
     * @param sourceFile File puede ser un archivo o una carpeta.
     * @param targetFile File debe ser el nombre de un archivo que es donde se
     * guardarán los archivos comprimidos. No debe incluir la extensión ya que
     * ésta le será agregada por default (.zip). Si el targetFile viene nulo el
     * sistema asumirá el mismo nombre que el origen.
     * @throws FileNotFoundException
     * @throws IOException
     */
    public void zipFile(File sourceFile, File targetFile) throws FileNotFoundException, IOException {
        FileOutputStream fos;
        String targetFileName;
        if (targetFile == null) {
            targetFileName = sourceFile.getAbsolutePath() + ".zip";
        } else {
            targetFileName = targetFile.getAbsolutePath() + ".zip";
        } // end if-else

        fos = new FileOutputStream(targetFileName);

        try (ZipOutputStream zos = new ZipOutputStream(fos)) {
            addZipFile(sourceFile, zos);
            zos.closeEntry();
        }
        System.out.println("\nZipped file: " + targetFileName);
    } // end zipFile

    private void addZipFile(File sourceFile, ZipOutputStream zos) throws IOException {
        /*
        Este mensaje aparecerá solo una vez por cada carpeta que se respalde.
        Y si fuera solo un archivo lo que recibe como sourceFile sería ese
        nombre el que se muestre.
         */
        System.out.println("Compressing " + sourceFile.getAbsolutePath());
        // Si el origen es una carpeta, agrego cada uno de los archivos.
        if (sourceFile.isDirectory()) {
            File[] files = sourceFile.listFiles();
            for (File f : files) {
                // Llamado recursivo
                if (f.isDirectory()) {
                    addZipFile(f, zos);
                    continue;
                }
                zos.putNextEntry(new ZipEntry(f.getCanonicalPath()));
                byte[] bytes = Files.readAllBytes(Paths.get(f.getAbsolutePath()));
                zos.write(bytes, 0, bytes.length);
            } // end for
        } else {
            zos.putNextEntry(new ZipEntry(sourceFile.getCanonicalPath()));
            byte[] bytes = Files.readAllBytes(Paths.get(sourceFile.getAbsolutePath()));
            zos.write(bytes, 0, bytes.length);
        } // end if
    } // end addZipFile

    // Librería: https://github.com/srikanth-lingala/zip4j
    public void zipCryptFile(File sourceFile, File targetFile) throws ZipException {
        if (!sourceFile.exists()) {
            throw new ZipException(sourceFile.getAbsolutePath() + " does not exist.");
        }

        System.out.println("Zipping " + sourceFile.getAbsolutePath() + " ..");

        ZipParameters zipParameters = new ZipParameters();
        zipParameters.setEncryptFiles(true);
        zipParameters.setEncryptionMethod(EncryptionMethod.AES);
        // Below line of code is optional. 
        // AES 256 is used by default. 
        // You can override it to use AES 128. AES 192 is supported only for extracting.
        zipParameters.setAesKeyStrength(AesKeyStrength.KEY_STRENGTH_256);

        ZipFile zipFile = new ZipFile(targetFile, PASSWORD.toCharArray());

        if (sourceFile.isDirectory()) {
            zipFile.addFolder(sourceFile, zipParameters);
        } else if (sourceFile.isFile()) {
            zipFile.addFile(sourceFile, zipParameters);
        }

        System.out.println("Zipping " + sourceFile.getAbsolutePath() + " .. complete.");
    }

    public long getAge(File file) throws IOException {

        Calendar cal = GregorianCalendar.getInstance();
        FileTime date = Files.getLastModifiedTime(file.toPath(), LinkOption.NOFOLLOW_LINKS);
        cal.setTimeInMillis(date.toMillis());
        Date sinceDate = cal.getTime();
        cal.setTimeInMillis(System.currentTimeMillis());
        Date toDate = cal.getTime();

        return Ut.dateDiff(sinceDate, toDate, Ut.DAY);
    }
} // end class
