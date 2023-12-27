package com.infot.mrb.Files;

import com.infot.mrb.backup.ZipFiles;
import java.io.File;
import java.io.IOException;

/**
 *
 * @author AA07SZZ
 */
public class TestUnzipFiles {

    /**
     * @param args the command line arguments
     * @throws java.io.IOException
     */
    public static void main(String[] args) throws IOException {
        ZipFiles zip = new ZipFiles(false);
        File zipFile = new File("C:\\zip\\ecred_20230906084605.zip");
        String directory = zip.unzipFile(zipFile, 1);
        System.out.println("Unzipped files on: " + directory);
    }
    
}
