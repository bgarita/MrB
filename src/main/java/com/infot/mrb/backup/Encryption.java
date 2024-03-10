package com.infot.mrb.backup;

import com.infot.mrb.utilities.Bitacora;
import com.infot.mrb.utilities.Props;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Properties;
import org.jasypt.util.text.BasicTextEncryptor;

/**
 *
 * @author bgarita, 06/11/2023
 */
public class Encryption {

    private static String PASSWORD; // Must be 16, 24 or 32 length for AES-128, AES-192 or AES-256, respectively
    private final Bitacora log = new Bitacora();
    private boolean removeEncryptedFile;

    public Encryption() {
        this.removeEncryptedFile = true;    // Default behaviour.
        try {
            Properties props = Props.getProps(new File("encrypt.properties"));
            if (props == null || props.isEmpty()) {
                PASSWORD = "G-A*ga*311266$"; // Default key
            } else {
                PASSWORD = props.getProperty("encrypt.key");
            }
        } catch (IOException ex) {
            log.error(ex.getMessage());
        }
    }

    public File encryptFile(File inputFile) throws FileNotFoundException, IOException {

        log.info("Encrypting " + inputFile.getAbsolutePath());

        File outputFile = new File(inputFile.getAbsoluteFile() + ".cif");
        BasicTextEncryptor textEncryptor = new BasicTextEncryptor();
        textEncryptor.setPassword(PASSWORD);

        try (BufferedReader reader = new BufferedReader(new FileReader(inputFile)); BufferedWriter writer = new BufferedWriter(new FileWriter(outputFile))) {
            String line;
            while ((line = reader.readLine()) != null) {
                String encryptedLine = textEncryptor.encrypt(line);
                writer.write(encryptedLine);
                writer.newLine();
            }
        }

        // If everything goes well, delete the original file (not directory).
        if (inputFile.isFile()) {
            log.warn("Deleting " + inputFile.getAbsolutePath());
            inputFile.delete();
        }

        return outputFile;
    }

    public String encryptText(String text) throws FileNotFoundException, IOException {
        BasicTextEncryptor textEncryptor = new BasicTextEncryptor();
        textEncryptor.setPassword(PASSWORD);

        return textEncryptor.encrypt(text);
    }

    public void decryptFile(File inputFile) throws Exception {

        // If inputFile is not encrypted then return
        if (!inputFile.getCanonicalPath().endsWith(".cif")) {
            return;
        }

        log.info("Decrypting file " + inputFile.getName());

        // Remove the .cif extension
        File outputFile = new File(inputFile.getAbsolutePath().replace(".cif", ""));

        BasicTextEncryptor textEncryptor = new BasicTextEncryptor();
        textEncryptor.setPassword(PASSWORD);

        try (BufferedReader reader = new BufferedReader(new FileReader(inputFile)); BufferedWriter writer = new BufferedWriter(new FileWriter(outputFile))) {
            String line;
            while ((line = reader.readLine()) != null) {
                String decryptedLine = textEncryptor.decrypt(line);
                writer.write(decryptedLine);
                writer.newLine();
            }
        }

        // Delete the encrypted file
        if (this.removeEncryptedFile) {
            inputFile.delete();
        }
    }

    public String decryptText(String encryptedText) throws Exception {
        BasicTextEncryptor textEncryptor = new BasicTextEncryptor();
        textEncryptor.setPassword(PASSWORD);

        return textEncryptor.decrypt(encryptedText);
    }

    public static String getPASSWORD() {
        return PASSWORD;
    }

    public boolean isRemoveEncryptedFile() {
        return removeEncryptedFile;
    }

    public void setRemoveEncryptedFile(boolean removeEncryptedFile) {
        this.removeEncryptedFile = removeEncryptedFile;
    }
    
    
}
