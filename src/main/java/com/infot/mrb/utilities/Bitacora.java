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
 * @author bgarita, Agosto 2014, actualizado 21/01/2024
 * Crear y/o actualizar un archivo de texto que servirá como bitácora.  Esta
 * bitácora puede ser usada para reportar errores de ejecución de algún proceso
 * y/o para escribir datos de la corrida como hora de inicio, hora de finalización
 * y código de finalización (exitoso, fallido).
 */
public class Bitacora {
    private File logFile;
    private String error_message;
    private boolean consoleOnly;
    
    public Bitacora(){
        this.error_message = "";
        this.logFile = new File("MrB.log");
        this.consoleOnly = false;
        
        // Establecer el archivo actual - permite un máximo de 10 archivos
        setLogFile();
        
        if (!logFile.exists()){
            try {
                logFile.createNewFile();
            } catch (IOException ex) {
                Logger.getLogger(Bitacora.class.getName()).log(Level.SEVERE, null, ex);
                this.error_message = ex.getMessage();
            } // end try-catch
        } // end if
    } // end constructor

    
    // Este método se deja sin efecto ya que el nombre del log no se debe cambiar
//    public void setLog(File logFile) {
//        this.logFile = logFile;
//    }

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
     * Muestra por consola y guarda la información de los distintos eventos 
     * ocurridos en una bitácora de texto.
     * @author Bosco Garita Azofeifa
     * @param text String mensaje del evento
     */
    private void writeToLog(String text){
        // Si existe error no continúo
        if (!this.error_message.isEmpty()){
            return;
        } // end if
        
        Date d = new Date();
        text = d + " " + text + "\n";
        
        System.out.println(text);
        
        if (this.consoleOnly) {
            return;
        }
        
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

    public boolean isConsoleOnly() {
        return consoleOnly;
    }

    public void setConsoleOnly(boolean consoleOnly) {
        this.consoleOnly = consoleOnly;
    }
    
    /**
     * Este método establece el tamaño de los archivos de log y el número
     * máximo de archivos, eliminando el archivo número 10 y reenumerando
     * los otros que quedan, dejando siempre el archivo de trabajo actual
     * sin alterar.
     */
    private void setLogFile() {
        // Si el archivo aún no ha sido creado el resto de este método 
        // no tiene sentido.
        if (!logFile.exists()) {
            return;
        }
        long size = logFile.length();
        long limit = (long) Math.pow(1024, 2);
        int maxFiles = 10;

        if (size < limit) {
            return;
        } // end if

        // Eliminar el archivo 10 (maxFiles)
        String file = this.logFile.getAbsolutePath() + maxFiles;
        File f = new File(file);
        if (f.exists()) {
            f.delete();
        } // end if

        // Iterar en reversa para renombrar los archivos que quedan
        for (int i = maxFiles; i-- > 1; ) {
            file = this.logFile.getAbsolutePath() + i;
            File newFile = new File(this.logFile.getAbsolutePath() + (i + 1));
            f = new File(file);
            if (f.exists()) {
                f.renameTo(newFile);
            } // end if
        } // end for
        
        // Renombrar también el archivo actual ya que si llegamos hata acá
        // es porque el tamaña máximo ya fue excedido.
        file = this.logFile.getAbsolutePath();
        f = new File(file);
        File newFile = new File(this.logFile.getAbsolutePath() + "1");
        f.renameTo(newFile);

    } // end setLogFile
    
    public void info(String text) {
        text = "[INFO] " + text;
        this.writeToLog(text);
    }
    
    public void warn(String text) {
        text = "[WARNING] " + text;
        this.writeToLog(text);
    }
    
    public void error(String text) {
        text = "[ERROR] " + text;
        this.writeToLog(text);
    }
} // end class