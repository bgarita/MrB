package com.infot.mrb.backup;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 *
 * @author bgarita, 09-12-2023
 */
public class FileParts {

    /**
     * Sets the SQL comments at the top of the file.
     *
     * @param bufferedWriter BufferedWriter that writes any kind of file.
     * @param conn Connection database connection already established
     * @param includeUseDB boolean true=Include the statement USE [database]
     * @throws IOException
     * @throws SQLException
     */
    public void setFileHeader(BufferedWriter bufferedWriter, Connection conn, boolean includeUseDB) throws IOException, SQLException {
        DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy/MM/dd HH:mm:ss");
        LocalDateTime now = LocalDateTime.now();
        writeContent(bufferedWriter, "--");
        String content = "-- Dump created on: " + dtf.format(now);
        writeContent(bufferedWriter, content);

        Statement statement = conn.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
        String sqlSent = "Select @@version_comment as software, @@hostname as serverName, version() as version;";
        try (ResultSet rs = statement.executeQuery(sqlSent)) {
            rs.next();
            content = "-- Application: " + rs.getString(1);
            writeContent(bufferedWriter, content);
            content =  "-- Host: " + rs.getString(2);
            writeContent(bufferedWriter, content);
            content = "-- Engine version: " + rs.getString(3);
            writeContent(bufferedWriter, content);
        }
        writeContent(bufferedWriter, "--");

        if (includeUseDB) {
            content = "USE " + conn.getCatalog() + ";";
            writeContent(bufferedWriter, content);
        }

    }
    
    public void setFileHeader(BufferedWriter bufferedWriter, Connection conn) throws IOException, SQLException {
        setFileHeader(bufferedWriter, conn, true);
    }

    /**
     * Sets the SQL comments at the bottom of the file.
     *
     * @param bufferedWriter BufferedWriter that writes any kind of file.
     * @throws IOException
     */
    public void setFileFooter(BufferedWriter bufferedWriter) throws IOException {
        DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy/MM/dd HH:mm:ss");
        LocalDateTime now = LocalDateTime.now();
        writeContent(bufferedWriter, "--");
        writeContent(bufferedWriter, "-- Dump completed on: " + dtf.format(now));
        writeContent(bufferedWriter, "--");
    }

    public BufferedWriter createFileWriter(String directory, String fileName, boolean override) throws IOException {
        File file = createFile(directory, fileName, override);
        FileWriter fileWriter = new FileWriter(file, StandardCharsets.UTF_8, override);
        BufferedWriter bufferedWriter = new BufferedWriter(fileWriter);
        return bufferedWriter;
    }

    public void writeContent(BufferedWriter bufferedWriter, String content) throws IOException {
        // Write content and add a new line at the end of the file
        bufferedWriter.write(content);
        bufferedWriter.newLine();
    }

    public File createFile(String folderName, String fileName, boolean override) throws IOException {
        File folder = new File(folderName);
        if (!folder.exists() || !folder.isDirectory()) {
            folder.mkdir();
        }

        fileName = folder + System.getProperty("file.separator") + fileName;
        File file = new File(fileName);

        if (file.exists() && override) {
            file.delete();
        }

        file.createNewFile();

        return file;
    }
}
