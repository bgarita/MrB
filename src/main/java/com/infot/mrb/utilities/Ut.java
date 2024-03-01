package com.infot.mrb.utilities;

import com.infot.mrb.constants.SystemConstants;
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Path;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author bgarita, 31/12/2023
 */
public class Ut {
    public static final int DAY = 1;
    public static final int MONTH = 2;
    public static final int YEAR = 3;
    public static final int WEEK = 4;
    public static final int HOUR = 5;
    public static final int MINUTE = 6;
    public static final int SECOND = 7;
    
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
    
    /**
     * Devuelve varias características que son prácticas a la hora de
     * desarrollar aplicaciones. Algunas de ellas son de uso exclusivo en
     * Windows XP.
     *
     * @param prop Característica (ver las constantes de Utilitarios)
     * @return String característica deseada
     */
    public static String getProperty(int prop) {
        String name = null;
        switch (prop) {
            case SystemConstants.USER_NAME ->
                name = System.getProperty("user.name");
            case SystemConstants.USER_DIR ->
                name = System.getProperty("user.dir");
            case SystemConstants.USER_HOME ->
                name = System.getProperty("user.home");
            case SystemConstants.TMPDIR ->
                name = System.getProperty("java.io.tmpdir");
            case SystemConstants.OS_NAME ->
                name = System.getProperty("os.name");
            case SystemConstants.OS_VERSION ->
                name = System.getProperty("os.version");
            case SystemConstants.FILE_SEPARATOR ->
                name = System.getProperty("file.separator");
            case SystemConstants.PATH_SEPARATOR ->
                name = System.getProperty("path.separator");
            case SystemConstants.LINE_SEPARATOR ->
                name = System.getProperty("line.separator");
            case SystemConstants.WINDIR -> {
                if (System.getProperty("os.name").equalsIgnoreCase("Windows XP")) {
                    name = System.getenv("windir");
                } // end if
            }
            case SystemConstants.SYSTEM32 -> {
                if (System.getProperty("os.name").equalsIgnoreCase("Windows XP")) {
                    name = System.getenv("windir") + "\\system32";
                } // end if
            }
            case SystemConstants.COMPUTERNAME ->
                name = System.getenv("COMPUTERNAME");
            case SystemConstants.PROCESSOR_IDENTIFIER ->
                name = System.getenv("PROCESSOR_IDENTIFIER");
            case SystemConstants.JAVA_VERSION ->
                name = System.getenv("java.version");
        } // end switch
        return name;
    } // end getProperty
    
    /**
     * Calcular la diferencia entre dos fechas (en días, meses o años).
     *
     * @param sinceDate Date fecha inicio
     * @param toDate Date fecha final
     * @param part int parte de la fecha solicitada (Ut.DAY, Ut.MONTH, ect)
     * @return int diferencia
     */
    public static int dateDiff(Date sinceDate, Date toDate, int part) {
        long diff;

        Calendar sinceCal = GregorianCalendar.getInstance();
        Calendar thruCal = GregorianCalendar.getInstance();
        sinceCal.setTime(sinceDate);
        thruCal.setTime(toDate);

        int day = sinceCal.get(Calendar.DAY_OF_MONTH);
        int month = sinceCal.get(Calendar.MONTH);
        int year = sinceCal.get(Calendar.YEAR);

        // LocalDate si empieza el mes en 1
        LocalDate startLocalDate = LocalDate.of(year, month + 1, day);

        day = thruCal.get(Calendar.DAY_OF_MONTH);
        month = thruCal.get(Calendar.MONTH);
        year = thruCal.get(Calendar.YEAR);

        LocalDate endLocalDate = LocalDate.of(year, month + 1, day);

        switch (part) {
            case DAY -> {
                diff = ChronoUnit.DAYS.between(startLocalDate, endLocalDate);
            }
            case MONTH -> {
                diff = ChronoUnit.MONTHS.between(startLocalDate, endLocalDate);
            }
            case YEAR -> {
                diff = ChronoUnit.YEARS.between(startLocalDate, endLocalDate);
            }
            case WEEK -> {
                diff = ChronoUnit.WEEKS.between(startLocalDate, endLocalDate);
            }
            default -> {
                diff = 0;
            }
        } // end switch

        return (int) diff;
    }
}
