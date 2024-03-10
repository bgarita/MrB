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
 * @author bgarita, 2023-09-20
 */
public class Backup extends Thread {

    private String user;
    private char[] password;
    private BackupUI backupUI;
    private String database;
    private final Bitacora log = new Bitacora();

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
                log.error(ex.getMessage() + "\nTesting connection");
            }

            backupUI.setBackupInProgress(false);
            return;
        }

        // Double check connection.
        if (conn == null) {
            return;
        }

        log.info("Backup in progres..");
        File folder;

        try {
            MySQL engine = new MySQL(conn, database, 12); // Connection, schema & records per page

            // Create a directory with the name of the database
            folder = new File(database);
            if (!folder.exists() || !folder.isDirectory()) {
                folder.mkdir();
            }

            List<String> databaseTables = engine.getDatabaseTablesV2("TABLE");
            List<String> databaseViews = engine.getDatabaseTablesV2("VIEW");
            List<String> storedFunctions = engine.getRoutinesV2("FUNCTION");
            List<String> storedProcedures = engine.getRoutinesV2("PROCEDURE");
            List<String> triggers = engine.getTriggersV2();

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
            int records = engine.getRecordCountV2(databaseTables);
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

                log.info("Backing-up table " + table + "..");
                engine.setTable(table);
                engine.exportData(this.backupUI.getProgressBar());
                log.info("Backing-up table " + table + ".. complete!");
            }

            // Backup routines
            log.info("Backing-up functions and procedures..");
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

            log.info("Backing-up functions and procedures.. complete!");

            // Backup views
            log.info("Backing-up views..");

            bufferedWriter = fileParts.createFileWriter(conn.getCatalog(), "views.sql", true);

            fileParts.setFileHeader(bufferedWriter, conn);

            for (String view : databaseViews) {
                engine.exportView(view, bufferedWriter);
                this.backupUI.getProgressBar().setValue(this.backupUI.getProgressBar().getValue() + 1);
            }

            fileParts.setFileFooter(bufferedWriter);

            bufferedWriter.close();

            log.info("Backing-up views.. complete!");

            // Backup triggers
            log.info("Backing-up triggers..");

            bufferedWriter = fileParts.createFileWriter(conn.getCatalog(), "triggers.sql", true);

            fileParts.setFileHeader(bufferedWriter, conn);

            for (String trigger : triggers) {
                engine.exportTrigger(trigger, bufferedWriter);
                this.backupUI.getProgressBar().setValue(this.backupUI.getProgressBar().getValue() + 1);
            }

            fileParts.setFileFooter(bufferedWriter);

            bufferedWriter.close();

            log.info("Backing-up triggers.. complete!");

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
                log.error(ex.getMessage() + "\nBackup progress");
            }
            this.backupUI.setBackupInProgress(false);
            return;
        }

        log.info("Backup complete!");

        if (!backupUI.isStandalone()) {
            JOptionPane.showMessageDialog(null,
                    "Backup complete",
                    "Message",
                    JOptionPane.INFORMATION_MESSAGE);
        } else {
            backupUI.sendMailAlert("Backup complete for " + schema, true);
            log.setConsoleOnly(true);
            log.info("\n\n---- WARNING: Do not close this window ----");
            log.setConsoleOnly(false);
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
            log.error(ex.getMessage());
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
            log.info("Encrypting " + source.getAbsolutePath());
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

            log.info("Encrypting " + f.getAbsolutePath());
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
