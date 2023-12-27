package com.infot.mrb.Files;

import org.jasypt.util.text.BasicTextEncryptor;

import java.io.*;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

public class EncryptAndCompress {

    public static void main(String[] args) throws Exception {
        // Archivo original
        File inputFile = new File("C:\\temp\\routines.sql");
        
        // Archivo cifrado y comprimido
        File outputFile = new File("archivo_cifrado_comprimido.zip");
        
        // Contraseña para cifrar
        String password = "prueba-123";
        
        // Cifrado del archivo original
        encryptFile(inputFile, outputFile, password);
    }

    public static void encryptFile(File inputFile, File outputFile, String password) throws Exception {
        // Cifrado del archivo
        BasicTextEncryptor textEncryptor = new BasicTextEncryptor();
        textEncryptor.setPassword(password);
        
        try (FileInputStream fis = new FileInputStream(inputFile);
             FileOutputStream fos = new FileOutputStream(outputFile);
             ZipOutputStream zipOut = new ZipOutputStream(fos)) {
            
            zipOut.putNextEntry(new ZipEntry(inputFile.getName()));
            
            // Comprimir y cifrar el contenido
            try (BufferedOutputStream bos = new BufferedOutputStream(zipOut);
                Writer out = new OutputStreamWriter(bos, "UTF-8")) {
                
                String plaintext = new String(fis.readAllBytes());
                String encryptedText = textEncryptor.encrypt(plaintext);
                out.write(encryptedText);
                //System.out.println(textEncryptor.decrypt(encryptedText));
            }
            
            //zipOut.closeEntry();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
