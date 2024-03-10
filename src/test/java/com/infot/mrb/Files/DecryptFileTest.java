package com.infot.mrb.Files;

import com.infot.mrb.backup.Encryption;
import com.infot.mrb.utilities.Ut;
import java.io.File;
import static org.junit.Assert.assertTrue;
import org.junit.Test;

/**
 *
 * @author AA07SZZ
 */
public class DecryptFileTest {

    @Test
    public void decryptFiles() throws Exception {
        File encryptedFile = new File("cabys_init.sql.cif");
        final Encryption encryption = new Encryption();
        encryption.setRemoveEncryptedFile(false); // Do not remove encrypted file
        encryption.decryptFile(encryptedFile);
        File decryptedFile = new File("cabys_init.sql");
        assertTrue(decryptedFile.exists());
        
        // Check if file contains understandable text
        String expectedText = "Dump created on:";
        String fileContent = Ut.fileToString(decryptedFile.toPath());
        assertTrue(fileContent.contains(expectedText));
    }
    
}
