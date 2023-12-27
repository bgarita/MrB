package com.infot.mrb.Files;

import com.infot.mrb.backup.Encryption;
import java.io.File;

/**
 *
 * @author AA07SZZ
 */
public class TestDecryptFile {

    /**
     * @param args the command line arguments
     * @throws java.lang.Exception
     */
    public static void main(String[] args) throws Exception {
        File inputFile = new File("e:\\temp\\ahorros_cliente.json.cif");
        final Encryption encryption = new Encryption();
        encryption.decryptFile(inputFile);
    }
    
}
