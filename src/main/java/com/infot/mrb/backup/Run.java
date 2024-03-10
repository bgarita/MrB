package com.infot.mrb.backup;

import com.infot.mrb.utilities.Bitacora;
import com.infot.mrb.utilities.Props;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.Calendar;
import java.util.Properties;
import java.util.Timer;
import java.util.TimerTask;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author bgarita, 01/01/2024
 */
public class Run {

    private static final Calendar STARTTIME = Calendar.getInstance();

    /**
     * @param args the command line arguments
     * @throws java.lang.Exception
     */
    public static void main(String[] args) throws Exception {

        // Default running mode=Interactive
        if (args == null || args.length == 0) {
            BackupUI.main(args);
            return;
        }

        Bitacora log = new Bitacora();
        
        boolean runOnce = false;
        // Expected parameter -runOnce=true/false
        // true=Run only once
        // false=Runs in schedulle (every <period of time>)
        if (args.length > 0) {
            String[] param1 = args[0].split("=");
            runOnce = param1[1].trim().equals("true");
        }

        // Si se recibió el parámetro de correr solo una vez
        // se ejecuta de inmediato y termina la sesión.
        // Caso contrario se programa con el tiempo establecido en las propiedades.
        if (runOnce) {
            /* Create and display the form */
            BackupUI backupUI = new BackupUI(true);
            backupUI.setVisible(false);
            backupUI.dispose();
            System.exit(0);
            return;
        }

        TimerTask tasknew;
        final long interval = getInterval();
        setStartTime();

        // b.writeToLog("Backup scheduled to run at " + getStartTime());

        tasknew = new TimerTask() {
            // this method performs the task
            @Override
            public void run() {
                BackupUI backupUI = new BackupUI(true);
                backupUI.setVisible(false);
                
                try {
                    log.info("Backup scheduled to run at " + getStartTime());
                    log.setConsoleOnly(true);
                    log.info("Do not close this window...");
                    log.setConsoleOnly(false);
                } catch (IOException ex) {
                    Logger.getLogger(Run.class.getName()).log(Level.SEVERE, null, ex);
                }
            } // end run
        };

        // El proceso iniciará si la hora configurada es igual o menor a la
        // hora del sistema.
        Timer timer = new Timer();
        timer.scheduleAtFixedRate(tasknew, STARTTIME.getTime(), interval);
    }

    private static long getInterval() throws FileNotFoundException, IOException {
        long interval;
        int min = 60;
        int seg = 60;
        int mil = 1000;

        Properties scheduleProp = Props.getProps(new File("schedule.properties"));

        String[] temp = scheduleProp.getProperty("interval").split("-");
        switch (temp[1]) {
            case "H" -> { // Horas
                interval = Integer.parseInt(temp[0]) * min * seg * mil;
            }
            case "M" -> { // Minutos
                interval = Integer.parseInt(temp[0]) * seg * mil;
            }
            case "S" -> { // Segundos
                interval = Integer.parseInt(temp[0]) * mil;
            }
            default -> {
                interval = Integer.parseInt(temp[0]);
            }
        } // end switch

        return interval;
    } // end getInterval

    private static void setStartTime() throws FileNotFoundException, IOException {
        int hour;
        int min;
        Properties scheduleProp = Props.getProps(new File("schedule.properties"));

        String[] temp = scheduleProp.getProperty("startTime").split(":");
        hour = Integer.parseInt(temp[0]);
        min = Integer.parseInt(temp[1]);

        STARTTIME.set(Calendar.HOUR_OF_DAY, hour);
        STARTTIME.set(Calendar.MINUTE, min);
        STARTTIME.set(Calendar.SECOND, 0);
        STARTTIME.set(Calendar.MILLISECOND, 0);

    } // end setStartTime

    private static String getStartTime() throws IOException {
        int hour;
        int min;
        Properties scheduleProp = Props.getProps(new File("schedule.properties"));

        String[] temp = scheduleProp.getProperty("startTime").split(":");
        hour = Integer.parseInt(temp[0]);
        min = Integer.parseInt(temp[1]);

        return hour + ":" + min;
    }
}
