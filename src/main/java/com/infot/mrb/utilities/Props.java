package com.infot.mrb.utilities;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.Properties;

/**
 *
 * @author Bosco Garita, 2023-10-02
 */
public class Props {
    
    public static Properties getProps(File file) throws FileNotFoundException, IOException {
        Properties props = new Properties();
        if (file.exists()) {
            Bitacora log = new Bitacora();
            log.info("Using " + file.getAbsolutePath());
            try (FileInputStream fis = new FileInputStream(file)) {
                props.load(fis);
            }
        } // end if
        
        return props;
    }
}
