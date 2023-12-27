package com.infot.mrb.Files;

import com.infot.mrb.backup.ZipFiles;
import java.io.File;
import java.io.IOException;

/**
 *
 * @author AA07SZZ
 */
public class TestZipFiles {

    /**
     * @param args the command line arguments
     * @throws java.io.IOException
     */
    public static void main(String[] args) throws IOException, Exception {
        ZipFiles zip = new ZipFiles(true); // remove files after zipping
        String folder = "tmp";
        zip.zipFile(new File(folder));
        
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
