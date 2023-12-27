package com.infot.mrb.backup;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Properties;

/**
 *
 * @author AA07SZZ, 2023-09-22
 * @deprecated 2023-11-20
 * This class is not used any more but will be kept in case we need something 
 * similar for other scenarios.
 */
@Deprecated
public class Config {

    private static final String PROPS_FILE_NAME = "config.properties";

    public void loadProperties(User user) throws FileNotFoundException, IOException, Exception {
        Properties props = new Properties();

        String environmentPrefix = "prod"; //DBConnection.getEnvironmentPrefix(user.getEnvironment());

        try (FileInputStream propsFile = new FileInputStream(PROPS_FILE_NAME)) {
            props.load(propsFile);
            
            // Prevent null pointer and set default user
            user.setUserName("root");

            if (props.getProperty(environmentPrefix + "UserName") != null){
                String userName = new ZipFiles().AESDecrypt(props.getProperty(environmentPrefix + "UserName"));
                String password = new ZipFiles().AESDecrypt(props.getProperty(environmentPrefix + "Password"));
            
                char[] passwordArray = new char[password.length()];

                for (int i = 0; i < password.length(); i++) {
                    passwordArray[i] = password.charAt(i);
                }

                user.setUserName(userName);
                user.setPassword(passwordArray);
            }
        }
    }

    public void saveProperties(User user) throws FileNotFoundException, IOException, Exception {
        
        // Load properties so that we can add new ones.
        Properties props = new Properties();
        try (FileInputStream propsFile = new FileInputStream(PROPS_FILE_NAME)) {
            props.load(propsFile);
        }
        
        String environmentPrefix = "prod";//DBConnection.getEnvironmentPrefix(user.getEnvironment());

        String password = "";
        for (char c : user.getPassword()) {
            password += Character.toString(c);
        }
        
        // Encrypt user and password before saving.
        props.setProperty(environmentPrefix + "UserName", new ZipFiles().AESEncrypt(user.getUserName()));
        props.setProperty(environmentPrefix + "Password", new ZipFiles().AESEncrypt(password));

        try (FileOutputStream propsFile = new FileOutputStream(PROPS_FILE_NAME)) {
            // Save props file
            props.store(propsFile, "Configuration file - last update.");
        }
    }

}
