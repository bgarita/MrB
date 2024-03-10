package com.infot.mrb.Files;

import com.infot.mrb.backup.ZipFiles;
import java.io.File;
import java.io.IOException;
import static org.junit.jupiter.api.Assertions.assertTrue;
import org.junit.jupiter.api.Test;

/**
 *
 * @author AA07SZZ
 */
public class ZipFilesTest {

    @Test
    public void zipFile() throws IOException, Exception {
        File file = new File("cabys_init.sql.cif");
        ZipFiles zip = new ZipFiles(false); // remove files after zipping
        String folder = zip.zipFile(file);
        assertTrue(!folder.isBlank());
        /* Uncoment this code to test decryption
        File cryptedFile = new File(folder + "\\routines.sql.cif");
        
        // Make sure the resulting file does not exist
        File existingFile = new File(folder + "\\routines.sql");
        existingFile.delete();
        
        // After decrypting, deleted file name will exist again
        zip.decryptFile(cryptedFile);
        */
    }
    
}
