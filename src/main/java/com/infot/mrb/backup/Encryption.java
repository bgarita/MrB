package com.infot.mrb.backup;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import org.jasypt.util.text.BasicTextEncryptor;

/**
 *
 * @author bgarita, 06/11/2023
 */
public class Encryption {
    private static final String PASSWORD = "dotcom-2023%09*05-{1.!$}"; // Must be 16, 24 or 32 length for AES-128, AES-192 or AES-256, respectively
    
    public File encryptFile(File inputFile) throws FileNotFoundException, IOException {

        System.out.println("Encrypting " + inputFile.getAbsolutePath());
        
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
            System.out.println("Deleting " + inputFile.getAbsolutePath());
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
        
        System.out.println("Decrypting file " + inputFile.getName());

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
        inputFile.delete();
    }
    
    public String decryptText(String encryptedText) throws Exception {
        BasicTextEncryptor textEncryptor = new BasicTextEncryptor();
        textEncryptor.setPassword(PASSWORD);
        
        return textEncryptor.decrypt(encryptedText);
    }
    
    public static String getPASSWORD() {
        return PASSWORD;
    }
}
