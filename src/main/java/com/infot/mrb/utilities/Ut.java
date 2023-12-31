package com.infot.mrb.utilities;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Path;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author bgarita, 31/12/2023
 */
public class Ut {
    
    public static String fileToString(Path path) {
        StringBuilder sb = new StringBuilder();
        try {
            if (path.toFile().exists()) {

                BufferedReader br = new BufferedReader(new FileReader(path.toFile(), StandardCharsets.ISO_8859_1));
                String line = br.readLine();
                while (line != null) {
                    sb.append(line);
                    sb.append("\n");
                    line = br.readLine();
                }

            } else {
                sb.append("Archivo no encontrado.");
            } // end if-else
        } // end fileToString
        catch (IOException ex) {
            Logger.getLogger(Ut.class.getName()).log(Level.SEVERE, null, ex);
            sb.append(ex.getMessage());
        }
        return sb.toString();
    } // end fileToString
}
