package com.infot.mrb.Files;

import com.infot.mrb.backup.ZipFiles;
import java.io.File;
import java.io.IOException;
import static org.junit.Assert.assertTrue;
import org.junit.Test;

/**
 *
 * @author AA07SZZ
 */
public class UnzipFilesTest {

    @Test
    public void UnzipFiles() throws IOException {
        ZipFiles zip = new ZipFiles(false);
        File zipFile = new File("testingData/credito_dev_20240302121541.zip");
        String directory = zip.unzipFile(zipFile, 1);
        System.out.println("Unzipped files on: " + directory);
        assertTrue(!directory.isBlank());
        File file = new File(directory);
        assertTrue(file.exists() && file.isDirectory());
        File archivos[] = file.listFiles();
        assertTrue(archivos.length > 0);
    }
    
}
