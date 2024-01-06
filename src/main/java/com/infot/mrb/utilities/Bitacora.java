package com.infot.mrb.utilities;

import com.infot.mrb.constants.SystemConstants;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Date;
import java.util.logging.Level;
import java.util.logging.Logger;


/**
 *
 * @author bgarita, Agosto 2014
 * Crear y/o actualizar un archivo de texto que servirá como bitácora.  Esta
 * bitácora puede ser usada para reportar errores de ejecución de algún proceso
 * y/o para escribir datos de la corrida como hora de inicio, hora de finalización
 * y código de finalización (exitoso, fallido).
 */
public class Bitacora {
    private File logFile;
    private String error_message;
    
    public Bitacora(){
        this.error_message = "";
        this.logFile = new File("MrB.log");
        
        if (!logFile.exists()){
            try {
                logFile.createNewFile();
            } catch (IOException ex) {
                Logger.getLogger(Bitacora.class.getName()).log(Level.SEVERE, null, ex);
                this.error_message = ex.getMessage();
            } // end try-catch
        } // end if
    } // end constructor

    
    public void setLog(File logFile) {
        this.logFile = logFile;
    }

    public void setError_message(String error_message) {
        this.error_message = error_message;
    }

    public String getError_message() {
        return error_message;
    }
    
    public String getRuta() {
        return Ut.getProperty(SystemConstants.USER_DIR);
    } // end getRuta
    
    
    
    /**
     * Guarda la información de los distintos eventos ocurridos en una
     * bitácora de texto.
     * @author Bosco Garita Azofeifa
     * @param text String mensaje del evento
     */
    public void writeToLog(String text){
        // Si existe error no continúo
        if (!this.error_message.isEmpty()){
            return;
        } // end if
        
        Date d = new Date();
        text = d + "\n" + text;
        FileOutputStream log;
        byte[] contentInBytes;
        contentInBytes = text.getBytes();
        
        try {
            log = new FileOutputStream(this.logFile,true);
            log.write(contentInBytes);
            log.flush();
            log.close();
        } catch (Exception ex) {
            Logger.getLogger(Bitacora.class.getName()).log(Level.SEVERE, null, ex);
            this.error_message = ex.getMessage();
        } // end try-catch
    } // end writeToLog
    
    
    /**
     * Carga todo el texto contenido en el archivo Log.txt
     * @return 
     */
    public String readFromLog(){
        // Si existe error no continúo
        if (!this.error_message.isEmpty()){
            return "";
        } // end if
        
        FileInputStream log;
        int content;
        
        StringBuilder text = new StringBuilder();
        
        try {
            log = new FileInputStream(this.logFile);
            while ((content = log.read()) != -1) {
                text.appendCodePoint(content);
            } // end while
            log.close();
        } catch (Exception ex) {
            Logger.getLogger(Bitacora.class.getName()).log(Level.SEVERE, null, ex);
            this.error_message = ex.getMessage();
        } // end try-catch
        
        return text.toString();
    } // end readFromLog
} // end class