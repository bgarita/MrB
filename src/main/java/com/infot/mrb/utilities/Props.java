package com.infot.mrb.utilities;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

/**
 *
 * @author Bosco Garita, 2023-10-02
 */
public class Props {
    
    public static Properties getProps(File file) throws FileNotFoundException, IOException {
        InputStream inputStream = new FileInputStream(file);
        Properties props = new Properties();
        props.load(inputStream);
        return props;
    }
}
