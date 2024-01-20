package com.infot.mrb.backup;

import com.infot.mrb.database.DBConnection;
import com.infot.mrb.database.MySQL;
import com.infot.mrb.utilities.Bitacora;
import java.awt.HeadlessException;
import java.io.BufferedWriter;
import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.List;
import javax.swing.JOptionPane;

/**
 * Executes the backup process in a separate thread.
 *
 * @author AA07SZZ, 2023-09-20
 */
public class Backup extends Thread {

    private String user;
    private char[] password;
    private BackupUI backupUI;
    private String database;
    private Bitacora b = new Bitacora();

    @Override
    public void run() {
        createBackup();
    }

    public void createBackup() {
        FileParts fileParts = new FileParts();

        String schema = backupUI.getSchema();
        String serverName = backupUI.getServerName();
        Connection conn;

        try {
            conn = DBConnection.getConnection(user, password, serverName, schema);
        } catch (Exception ex) {
            if (!backupUI.isStandalone()) {
                JOptionPane.showInternalMessageDialog(
                        null,
                        ex.getMessage(),
                        "Error",
                        JOptionPane.ERROR_MESSAGE);
            } else {
                backupUI.sendMailAlert(ex.getMessage() + "\nTesting connection", false);
            }

            backupUI.setBackupInProgress(false);
            return;
        }

        // Double check connection.
        if (conn == null) {
            return;
        }

        b.writeToLog("Backup in progres..");
        File folder;

        try {
            MySQL engine = new MySQL(conn, schema, 12); // Connection, schema & records per page

            // Create a directory with the name of the database
            folder = new File(database);
            if (!folder.exists() || !folder.isDirectory()) {
                folder.mkdir();
            }

            List<String> databaseTables = engine.getDatabaseTables("TABLE");
            List<String> databaseViews = engine.getDatabaseTables("VIEW");
            List<String> storedFunctions = engine.getRoutines("FUNCTION");
            List<String> storedProcedures = engine.getRoutines("PROCEDURE");
            List<String> triggers = engine.getTriggers();

            /*
            Points for progress bar
            For each...                     Add (points)
            Item in table list              10           each Item in this list represents a .json file that is compressed
            Processed record                1
            Processed view                  1
            Processed function              1
            Stored procedure                1
            Trigger processed               1
             */
            int records = engine.getRecordCount(databaseTables);
            int count = records
                    + databaseViews.size()
                    + storedFunctions.size()
                    + storedProcedures.size()
                    + triggers.size()
                    + databaseTables.size() * 10;

            this.backupUI.getProgressBar().setMaximum(count);

            engine.createConfigurationFiles();

            // Backup data
            for (String table : databaseTables) {

                //System.out.println("Backing-up table " + table + "..");
                b.writeToLog("Backing-up table " + table + "..");
                engine.setTable(table);
                engine.exportData(this.backupUI.getProgressBar());
                //System.out.println("Backing-up table " + table + ".. complete!");
                b.writeToLog("Backing-up table " + table + ".. complete!");
            }

            // Backup routines
            //System.out.println("Backing-up functions and procedures..");
            b.writeToLog("Backing-up functions and procedures..");
            // Create dump file for routines
            BufferedWriter bufferedWriter = fileParts.createFileWriter(conn.getCatalog(), "routines.sql", true);

            fileParts.setFileHeader(bufferedWriter, conn);

            for (String routine : storedFunctions) {
                engine.exportRoutine(routine, "FUNCTION", bufferedWriter);
                this.backupUI.getProgressBar().setValue(this.backupUI.getProgressBar().getValue() + 1);
            }
            for (String routine : storedProcedures) {
                engine.exportRoutine(routine, "PROCEDURE", bufferedWriter);
                this.backupUI.getProgressBar().setValue(this.backupUI.getProgressBar().getValue() + 1);
            }

            fileParts.setFileFooter(bufferedWriter);

            bufferedWriter.close();

            //System.out.println("Backing-up functions and procedures.. complete!");
            b.writeToLog("Backing-up functions and procedures.. complete!");

            // Backup views
            //System.out.println("Backing-up views..");
            b.writeToLog("Backing-up views..");

            bufferedWriter = fileParts.createFileWriter(conn.getCatalog(), "views.sql", true);

            fileParts.setFileHeader(bufferedWriter, conn);

            for (String view : databaseViews) {
                engine.exportView(view, bufferedWriter);
                this.backupUI.getProgressBar().setValue(this.backupUI.getProgressBar().getValue() + 1);
            }

            fileParts.setFileFooter(bufferedWriter);

            bufferedWriter.close();

            //System.out.println("Backing-up views.. complete!");
            b.writeToLog("Backing-up views.. complete!");

            // Backup triggers
            //System.out.println("Backing-up triggers..");
            b.writeToLog("Backing-up triggers..");

            bufferedWriter = fileParts.createFileWriter(conn.getCatalog(), "triggers.sql", true);

            fileParts.setFileHeader(bufferedWriter, conn);

            for (String trigger : triggers) {
                engine.exportTrigger(trigger, bufferedWriter);
                this.backupUI.getProgressBar().setValue(this.backupUI.getProgressBar().getValue() + 1);
            }

            fileParts.setFileFooter(bufferedWriter);

            bufferedWriter.close();

            //System.out.println("Backing-up triggers.. complete!");
            b.writeToLog("Backing-up triggers.. complete!");

            // The zip process contains the required options to encryp or not
            // but if the user chooses not to compress then we have to verify
            // if encryption was selected or not.
            if (!this.backupUI.getIsCompressed() && this.backupUI.getIsEncrypted()) {
                // Encrypt every file in the working directory.
                encryptFile(folder);
            }

            // Decide if compress files or not
            if (this.backupUI.getIsCompressed()) {
                // Insert condition to remove files after zip or not.
                ZipFiles zip = new ZipFiles(true); // remove files after zipping

                zip.setProgressBar(this.backupUI.getProgressBar());
                zip.setEncrypted(this.backupUI.getIsEncrypted());

                // Compress all files in the working directory
                String zipFileName = zip.zipFile(folder);

                // This is intended for testing purposes.
                // We don't want to insert data in our database when testing.
                String backupDescription = backupUI.getBackupDescription();

                if (backupDescription != null && !backupDescription.isBlank()) {

                    // Update database
                    String sql = "INSERT INTO `bk`.`backup` "
                            + "	(`created_on`, "
                            + "	`user_created`, "
                            + "	`description`, "
                            + "	`database`, "
                            + "	`zip_file_name`) "
                            + "	VALUES"
                            + "	(CURRENT_TIMESTAMP, "
                            + "	?, "
                            + "	?, "
                            + "	?, "
                            + "	?)";
                    try (java.sql.Connection bkCon = DBConnection.getBkConnection(); PreparedStatement ps = bkCon.prepareStatement(sql)) {
                        ps.setString(1, System.getenv("USERNAME")); // Windows only (must change for other OS)
                        ps.setString(2, backupUI.getBackupDescription());
                        ps.setString(3, database);
                        ps.setString(4, zipFileName);
                        ps.executeUpdate();
                    }
                }
            }

            // Set 100% in case the the user selected no compressing or no encrypting
            this.backupUI.getProgressBar().setValue(this.backupUI.getProgressBar().getMaximum());

            conn.close();
        } catch (IOException | ClassNotFoundException | SQLException ex) {
            if (!backupUI.isStandalone()) {
                JOptionPane.showInternalMessageDialog(null, ex.getMessage(),
                        "Error", JOptionPane.ERROR_MESSAGE);
            } else {
                backupUI.sendMailAlert(ex.getMessage() + "\nBackup progress", false);
            }
            this.backupUI.setBackupInProgress(false);
            return;
        }

        //System.out.println("Backup complete!");
        b.writeToLog("Backup complete!");

        if (!backupUI.isStandalone()) {
            JOptionPane.showMessageDialog(null,
                    "Backup complete",
                    "Message",
                    JOptionPane.INFORMATION_MESSAGE);
        } else {
            backupUI.sendMailAlert("Backup complete for " + schema, true);
            b.setConsoleOnly(true);
            //System.out.println("\n\n---- WARNING: Do not close this window ----");
            b.writeToLog("\n\n---- WARNING: Do not close this window ----");
            b.setConsoleOnly(false);
        }

        this.backupUI.setBackupInProgress(false);

        // Reset progress bar
        this.backupUI.getProgressBar().setValue(0);

        try {
            if (!this.backupUI.getIsCompressed() && !backupUI.isStandalone()) {
                JOptionPane.showMessageDialog(null,
                        """
                        This backup is temporary and it will not be reflected in the restore tab.
                        It's located here: """ + folder.getCanonicalPath() + "\n"
                        + "If you want to protect it, move that folder to an external device drive.",
                        "ADVICE",
                        JOptionPane.WARNING_MESSAGE);
            }
        } catch (HeadlessException | IOException ex) {
            //System.out.println("ERROR: " + ex);
            b.writeToLog("ERROR: " + ex);
        }

        this.backupUI.loadData();
    }

    public void setUser(String user) {
        this.user = user;
    }

    public void setPassword(char[] password) {
        this.password = password;
    }

    public void setBackupUI(BackupUI backupUI) {
        this.backupUI = backupUI;
    }

    public BackupUI getBackupUI() {
        return backupUI;
    }

    private void encryptFile(File source) throws IOException {
        Encryption encryption = new Encryption();

        // Encrypt file
        if (!source.isDirectory()) {
            //System.out.println("Encrypting " + source.getAbsolutePath());
            b.writeToLog("Encrypting " + source.getAbsolutePath());
            encryption.encryptFile(source);
            if (source.getAbsolutePath().endsWith(".json")) {
                this.backupUI.getProgressBar().setValue(this.backupUI.getProgressBar().getValue() + 10);
            }
            return;
        }

        // Encrypt directory
        File[] files = source.listFiles();
        for (File f : files) {
            // Recursive call
            if (f.isDirectory()) {
                encryptFile(f);
                continue;
            }

            //System.out.println("Encrypting " + f.getAbsolutePath());
            b.writeToLog("Encrypting " + f.getAbsolutePath());
            encryption.encryptFile(f);
            // Update progress bar if file is json
            if (f.getAbsolutePath().endsWith(".json")) {
                this.backupUI.getProgressBar().setValue(this.backupUI.getProgressBar().getValue() + 10);
            }
        }
    }

    public void setDatabase(String database) {
        this.database = database;
    }
}
