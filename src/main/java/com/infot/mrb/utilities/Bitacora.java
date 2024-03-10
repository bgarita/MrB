package com.infot.mrb.utilities;

import com.infot.mrb.constants.SystemConstants;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Date;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.fusesource.jansi.Ansi;


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
    
    public static final String ANSI_RED = "\\u001B[31m";
    public static final String ANSI_GREEN = "\\u001B[32m";
    public static final String ANSI_YELLOW = "\\u001B[33m";
    public static final String ANSI_BLUE = "\\u001B[34m";
    public static final String ANSI_PURPLE = "\\u001B[35m";
    public static final String ANSI_CYAN = "\\u001B[36m";
    public static final String ANSI_WHITE = "\\u001B[37m";
    public static final String ANSI_RESET = "\\u001B[0m";
    
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

    
    public void setError_message(String error_message) {
        this.error_message = error_message;
    }

    public String getError_message() {
        return error_message;
    }
    
    public String getRuta() {
        return Ut.getProperty(SystemConstants.USER_DIR);
    } // end getRuta

    public File getLogFile() {
        return logFile;
    }
    
    
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
        
        boolean colorInfo = (text.contains("complete") || text.contains("sucess")) && text.contains("[INFO]");
        
        Date d = new Date();
        text = d + " " + text + "\n";
        
        if (colorInfo) {
            System.out.println(Ansi.ansi().fg(Ansi.Color.GREEN).a(text).reset());
        } else if (text.contains("[WARNING]")){
            System.out.println(Ansi.ansi().fg(Ansi.Color.YELLOW).a(text).reset());
        } else if (text.contains("[ERROR]") || text.contains("fail")) {
            System.out.println(Ansi.ansi().fg(Ansi.Color.RED).a(text).reset());
        } else {
            System.err.println(text);
        }
        
        if (this.consoleOnly) {
            return;
        }
        
        FileOutputStream log;
        byte[] bytes;
        bytes = text.getBytes();
        
        try {
            log = new FileOutputStream(this.logFile,true);
            log.write(bytes);
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
    
    /**
     * Displays a messages on the console and writes it to the log.
     * If the user sets the consoleOnly to true then the write to the 
     * log file will be disabled.
     * @param text 
     */
    public void info(String text) {
        text = "[INFO] " + text;
        this.writeToLog(text);
    }
    
    /**
     * Displays warning on the console and writes it to the log file.
     * @param text String message to be logged
     */
    public void warn(String text) {
        text = "[WARNING] " + text;
        boolean logMode = this.consoleOnly;
        this.consoleOnly = false;
        this.writeToLog(text);
        this.consoleOnly = logMode;
    }
    
    /**
     * Displays error on the console and writes it to the log file.
     * @param text String message to be logged
     */
    public void error(String text) {
        text = "[ERROR] " + text;
        boolean logMode = this.consoleOnly;
        this.consoleOnly = false;
        this.writeToLog(text);
        this.consoleOnly = logMode;
    }
} // end class