package com.infot.mrb.Files;

import com.infot.mrb.backup.Encryption;
import com.infot.mrb.backup.ZipFiles;

/**
 *
 * @author AA07SZZ, 2023-09-25
 */
public class EncryptDecryptTextTest {

    /**
     * @param args the command line arguments
     * @throws java.lang.Exception
     */
    public static void main(String[] args) throws Exception {
        String text = "Local Host";
        System.out.println("Original text: " + text);
        ZipFiles zipFiles = new ZipFiles();
        String encryptedText = zipFiles.AESEncrypt(text);
        System.out.println("Encrypted text: " + encryptedText);
        
        String decryptedText = zipFiles.AESDecrypt(encryptedText);
        System.out.println("Decrypted text: " + decryptedText);
        System.out.println();
        
        Encryption encryption = new Encryption();
        System.out.println("Original text2: " + text);
        encryptedText = encryption.encryptText(text);
        System.out.println("Encrypted text2: " + encryptedText);
        decryptedText = encryption.decryptText(encryptedText);
        System.out.println("Decrypted text2: " + decryptedText);
        
        System.out.println();
        System.out.println(encryption.decryptText("ClyAkJdGCPc6TAtOn/YjrwCo7XhS3rec"));
        System.out.println(encryption.decryptText("LUxfQhpG07GNRYLPSNVSwImSiFjYNsP6"));
    }
    
}
