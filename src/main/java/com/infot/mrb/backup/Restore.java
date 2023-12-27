package com.infot.mrb.backup;

import com.infot.mrb.database.DBConnection;
import com.infot.mrb.database.MySQL;
import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.swing.JOptionPane;

/**
 *
 * @author AA07SZZ, 2023-09-21
 */
public class Restore extends Thread {
    private final boolean overrideExistingDatabase;
    private final BackupUI backupUI;
    private final Connection conn;
    private final File zippedFile;
    private String newDatabase;
    private final Encryption encryption = new Encryption();
    private boolean restoreFromFolder;
    private File sourceFolder;

    /**
     * Restore a database in a separate thread.
     * @param overrideExistingDatabase boolean decides if deleting or not the original database before restoring
     * @param backupUI Swing class that contains the progress bar.
     * @param conn Connection Establised connection to the database.
     * @param zippedFile File file that conains all data to be restored.
     * @param newDatabase String new database name.
     */
    public Restore(boolean overrideExistingDatabase, BackupUI backupUI, Connection conn, File zippedFile, String newDatabase) {
        this.overrideExistingDatabase = overrideExistingDatabase;
        this.backupUI = backupUI;
        this.conn = conn;
        this.zippedFile = zippedFile;
        this.newDatabase = newDatabase;
        this.restoreFromFolder = zippedFile == null;
    }

    @Override
    public void run() {
        if (this.restoreFromFolder) {
            restoreFromDirectory();
        } else {
            restoreFromZipFile();
        }
    }

    /**
     * Deletes a file or folder and all its contents.
     * @param directory String can be a file or a folder name.
     * @throws IOException 
     */
    private void delete(String directory) throws IOException {
        File file = new File(directory);
        if (file.isFile()) {
            file.delete();
            return;
        }

        // Remove files recursibly
        if (file.isDirectory()) {
            File[] files = file.listFiles();
            for (File f : files) {
                delete(f.getCanonicalPath());
            }
            file.delete(); // Remove parent directory
        }
    }

    public boolean isRestoreFromFolder() {
        return restoreFromFolder;
    }

    public void setRestoreFromFolder(boolean restoreFromFolder) {
        this.restoreFromFolder = restoreFromFolder;
    }
    
    
    private void restoreFromZipFile() {
        backupUI.setRestoreInProgress(true);
        /*
        Values for the progress bar:
        Create database          1 point
        Unzip files             25 points
        Decrypt files           35 points
        start-up.sql             1 point
        Init files               5 points
        Json files              40 points
        views.sql                1 point
        routines.sql             3 points
        triggers.sql             1 point
        end-up.sql               1 point
        
        Total                   113 points
        */
        int totalPoints = 113;
        
        backupUI.getProgressBar().setMaximum(totalPoints);
        
        System.out.println("Restore in progress..");

        ZipFiles zip = new ZipFiles(false);
        zip.setProgressBar(backupUI.getProgressBar());
        
        try {
            
            MySQL engine = new MySQL(conn, backupUI.getSchema(), 12);

            // Get server info
            Statement statement = conn.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
            String server;
            String sqlSent = "Select @@hostname as serverName;";
            try (ResultSet rs = statement.executeQuery(sqlSent)) {
                rs.next();
                server = rs.getString(1);
            }
            
            if (overrideExistingDatabase) {
                //String originalDatabase = zippedFile.getName().split("_")[0];
                statement = conn.createStatement();
                statement.executeUpdate("DROP DATABASE IF EXISTS " + this.backupUI.getOriginalDatabase());
                newDatabase = this.backupUI.getOriginalDatabase(); // use the original name.
            }
            
            backupUI.getProgressBar().setValue(1);

            int maxPoints = 25;
            
            // Temporary directory for processing files.
            String directory = zip.unzipFile(zippedFile, maxPoints);
            
            // Decrypt files
            File folder = new File(directory);
            File[] files = folder.listFiles();
            maxPoints = 35;
            int pointsApplied = 0;
            double points = (double)maxPoints / (double)files.length;
            for (File f : files) {
                encryption.decryptFile(f);
                backupUI.getProgressBar().setValue(backupUI.getProgressBar().getValue() + (int) points);
                pointsApplied += (int) points;
            }
            backupUI.getProgressBar().setValue(backupUI.getProgressBar().getValue() + (maxPoints - pointsApplied));

            engine.executeDumpFile("start-up.sql", directory, newDatabase);
            backupUI.getProgressBar().setValue(backupUI.getProgressBar().getValue() + 1);
            
            engine.runInitFiles(directory, newDatabase);
            backupUI.getProgressBar().setValue(backupUI.getProgressBar().getValue() + 5);
            
            maxPoints = 40;
            engine.importJsonFiles(directory, backupUI.getProgressBar(), maxPoints);
            
            engine.executeDumpFile("views.sql", directory, newDatabase);
            backupUI.getProgressBar().setValue(backupUI.getProgressBar().getValue() + 1);
            
            engine.executeDumpFile("routines.sql", directory, newDatabase);
            backupUI.getProgressBar().setValue(backupUI.getProgressBar().getValue() + 3);
            
            engine.executeDumpFile("triggers.sql", directory, newDatabase);
            backupUI.getProgressBar().setValue(backupUI.getProgressBar().getValue() + 1);
            
            engine.executeDumpFile("end-up.sql", directory, newDatabase);
            backupUI.getProgressBar().setValue(backupUI.getProgressBar().getValue() + 1);
            
            backupUI.setRestoreInProgress(false);

            System.out.println("Restore successful.");

            JOptionPane.showMessageDialog(null, "Restore complete", "Message", JOptionPane.INFORMATION_MESSAGE);
            
            // Post restore tasks
            String sql = "UPDATE `bk`.`backup` "
                    + "SET "
                    + "	`restored_on` = CURRENT_TIMESTAMP, "
                    + "	`last_user_restored` = ?, "
                    + "	`last_server_restored` = ?, "
                    + "	`last_target_db_restored` = ? "
                    + "WHERE `id` = ?;";
            try (java.sql.Connection bkConn = DBConnection.getBkConnection(); PreparedStatement ps = bkConn.prepareStatement(sql)) {
                ps.setString(1, System.getenv("USERNAME")); // Windows only (must change for other OS)
                ps.setString(2, server);
                ps.setString(3, newDatabase);
                ps.setInt(4, this.backupUI.getDBId());
                ps.executeUpdate();
            }
            
            // Refresh UI (Grid table)
            this.backupUI.loadData();
            
            // Removing files is a post restoration task.  No matter if it fails.
            // If you, developer, need to check any file, do it before closing the message window.
            delete(directory);

        } catch (Exception ex) {
            JOptionPane.showMessageDialog(null, ex.getMessage(), "Error", JOptionPane.ERROR_MESSAGE);
            Logger.getLogger(this.getClass().getName()).log(Level.SEVERE, null, ex);
        }
    }

    private void restoreFromDirectory() {
        backupUI.setRestoreInProgress(true);
        /*
        Values for the progress bar:
        Create database          1 point
        Decrypt files           35 points
        start-up.sql             1 point
        Init files               5 points
        Json files              40 points
        views.sql                1 point
        routines.sql             3 points
        triggers.sql             1 point
        end-up.sql               1 point
        
        Total                   88 points
        */
        int totalPoints = 88;
        
        backupUI.getProgressBar().setMaximum(totalPoints);
        
        System.out.println("Restore in progress..");
        
        try {
            
            MySQL engine = new MySQL(conn, backupUI.getSchema(), 12);

            backupUI.getProgressBar().setValue(1);
            
            // Decrypt files
            File[] files = sourceFolder.listFiles();
            int maxPoints = 35;
            int pointsApplied = 0;
            double points = (double)maxPoints / (double)files.length;
            for (File f : files) {
                encryption.decryptFile(f);
                backupUI.getProgressBar().setValue(backupUI.getProgressBar().getValue() + (int) points);
                pointsApplied += (int) points;
            }
            backupUI.getProgressBar().setValue(backupUI.getProgressBar().getValue() + (maxPoints - pointsApplied));

            engine.executeDumpFile("start-up.sql", sourceFolder.getName(), newDatabase);
            backupUI.getProgressBar().setValue(backupUI.getProgressBar().getValue() + 1);
            
            engine.runInitFiles(sourceFolder.getName(), newDatabase);
            backupUI.getProgressBar().setValue(backupUI.getProgressBar().getValue() + 5);
            
            maxPoints = 40;
            engine.importJsonFiles(sourceFolder.getName(), backupUI.getProgressBar(), maxPoints);
            
            engine.executeDumpFile("views.sql", sourceFolder.getName(), newDatabase);
            backupUI.getProgressBar().setValue(backupUI.getProgressBar().getValue() + 1);
            
            engine.executeDumpFile("routines.sql", sourceFolder.getName(), newDatabase);
            backupUI.getProgressBar().setValue(backupUI.getProgressBar().getValue() + 3);
            
            engine.executeDumpFile("triggers.sql", sourceFolder.getName(), newDatabase);
            backupUI.getProgressBar().setValue(backupUI.getProgressBar().getValue() + 1);
            
            engine.executeDumpFile("end-up.sql", sourceFolder.getName(), newDatabase);
            backupUI.getProgressBar().setValue(backupUI.getProgressBar().getValue() + 1);
            
            backupUI.setRestoreInProgress(false);

            System.out.println("Restore successful.");

            JOptionPane.showMessageDialog(
                    null, 
                    "Restore complete", 
                    "Message", 
                    JOptionPane.INFORMATION_MESSAGE);
            
        } catch (Exception ex) {
            JOptionPane.showMessageDialog(
                    null, 
                    ex.getMessage(), 
                    "Error", 
                    JOptionPane.ERROR_MESSAGE);
            Logger.getLogger(this.getClass().getName()).log(Level.SEVERE, null, ex);
        }
    }

    public void setSourceFolder(File canonicalFile) {
        this.sourceFolder = canonicalFile;
    }
}
