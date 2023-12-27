package com.infot.mrb.database;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.infot.mrb.backup.FileParts;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Base64;
import java.util.List;
import org.json.JSONArray;
import org.json.JSONObject;

/**
 *
 * @author AA07SZZ, 08-11-2023
 */
public class MySQL {

    private String schema;              // Database or schema
    private String table;               // Database table name
    private final Connection conn;      // Database connection
    private final int rows;             // Number of rows per select
    private List<String> columnNames;   // Table column names
    private List<String> columnTypes;   // Table column types
    private List<String> columnValues;  // Table column values
    private final FileParts fileParts;  // Sets file headear & footer info

    /**
     * Retrieve data from MySQL/MariaDB.
     *
     * @param schema String default database
     * @param table String MySQL table
     * @param conn Connection to the database
     * @param rows int number of rows per page
     * @throws java.sql.SQLException
     */
    public MySQL(String schema, String table, Connection conn, int rows) throws SQLException {
        this.schema = schema;
        this.table = table;
        this.conn = conn;
        this.rows = rows;
        this.columnNames = new ArrayList<>();
        this.columnTypes = new ArrayList<>();
        this.columnValues = new ArrayList<>();
        this.fileParts = new FileParts();
        useDefaultSchema();
    }

    public MySQL(Connection conn, String schema, int rows) throws SQLException {
        this.schema = schema; // Default database
        this.table = "";
        this.conn = conn;
        this.rows = rows;
        this.columnNames = new ArrayList<>();
        this.columnTypes = new ArrayList<>();
        this.columnValues = new ArrayList<>();
        this.fileParts = new FileParts();
        useDefaultSchema();
    }

    public void setTable(String table) {
        this.table = table;
    }

    public void setSchema(String schema) throws SQLException {
        this.schema = schema;
        if (this.conn != null) {
            useDefaultSchema();
        }
    }

    public String getSchema() {
        return schema;
    }

    public String getTable() {
        return table;
    }

    public void exportData(javax.swing.JProgressBar progresBar) throws SQLException, IOException {

        // Create init sql file
        BufferedWriter bufferedWriter = fileParts.createFileWriter(this.schema, table + "_init.sql", true);

        // Set sql sentences for creating the database
        Statement statement = conn.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
        ResultSet rs = statement.executeQuery("SHOW CREATE TABLE " + table);
        rs.next();
        String createTable = rs.getString(2) + ";";
        rs.close();

        fileParts.setFileHeader(bufferedWriter, conn);
        fileParts.writeContent(bufferedWriter, createTable);
        fileParts.setFileFooter(bufferedWriter);
        bufferedWriter.close();

        // Lock table before reading to prevent incomplete data sets
        statement.execute("LOCK TABLES " + table + " WRITE;");

        // Get maximum number of records
        rs = statement.executeQuery("SELECT COUNT(*) FROM " + table);
        rs.next();

        int maxRecords = rs.getInt(1);
        int currentRecord = 0;
        rs.close();
        int records = rows;

        // Create the json file with all records
        bufferedWriter = fileParts.createFileWriter(this.schema, table + ".json", true);

        fileParts.writeContent(bufferedWriter, "[");

        //maxRecords = maxRecords < 20 ? maxRecords : 20; // Testing purposes, comment this line for production
        while (currentRecord <= maxRecords) {
            if (maxRecords - currentRecord < records) {
                records = maxRecords - currentRecord;
                if (records == 0) {
                    break;
                }
            }

            rs = statement.executeQuery("SELECT * FROM " + table + " LIMIT " + currentRecord + ", " + rows);

            rs.last();
            int lastRecord = rs.getRow();

            // Iterate thru resultSet
            for (int i = 1; i <= lastRecord; i++) {
                currentRecord++;
                progresBar.setValue(progresBar.getValue() + 1);
                rs.absolute(i);
                String json = createJson(rs);
                if (rs.getRow() <= lastRecord && currentRecord < maxRecords) {
                    json += ",";
                }
                fileParts.writeContent(bufferedWriter, json);
            }
            System.out.println("Processing " + currentRecord + " out of " + maxRecords);
        }

        rs.close();

        // Unlock tables
        statement.execute("UNLOCK TABLES;");

        fileParts.writeContent(bufferedWriter, "]");
        bufferedWriter.close();

    }

    private String createJson(ResultSet resultSet) throws SQLException, IOException {
        JSONArray jsonArray = new JSONArray();

        for (int column = 1; column <= resultSet.getMetaData().getColumnCount(); column++) {
            String columName = resultSet.getMetaData().getColumnName(column);
            String columnType = resultSet.getMetaData().getColumnTypeName(column);
            String value = "";
            JSONObject innerJson = new JSONObject();

            switch (columnType) {
                case "TINYINT":
                case "SMALLINT":
                case "MEDIUMINT":
                case "INT":
                    value += resultSet.getInt(column);
                    break;
                case "BIGINT":
                    value += resultSet.getLong(column);
                    break;
                case "FLOAT":
                case "DOUBLE":
                    value += resultSet.getDouble(column);
                    break;
                case "DECIMAL":
                    value += resultSet.getBigDecimal(column);
                    break;
                case "BLOB":
                case "LONGBLOB":
                    byte[] binaryData = resultSet.getBytes(column);
                    String base64Data = Base64.getEncoder().encodeToString(binaryData);
                    value += base64Data;
                    break;
                case "JSON":
                    if (resultSet.getString(column) != null) {
                        String temp = resultSet.getString(column);
                        innerJson = new JSONObject(temp);
                    }
                    break;
                default: //DATE, DATETIME, TIMESTAMP, VARCHAR, etc
                    value += resultSet.getString(column);
            }

            JSONObject jsonObject = new JSONObject();
            jsonObject.put("columnName", columName);
            jsonObject.put("columnType", columnType);
            jsonObject.put("columnValue", columnType.equals("JSON") ? innerJson : value);

            jsonArray.put(jsonObject);

        }

        return jsonArray.toString();
    }

    /**
     * Create the start-up.sql and end-up.sql which will run at the begining and
     * ending (respectively) at restoring time.
     *
     * @throws SQLException
     * @throws IOException
     */
    public void createConfigurationFiles() throws SQLException, IOException {
        System.out.println("Creating configuration files..");

        String fileName = "start-up.sql";
        File file = fileParts.createFile(schema, fileName, true);   // Delete existing file
        FileWriter fileWriter = new FileWriter(file, StandardCharsets.UTF_8, true);
        BufferedWriter bufferedWriter = new BufferedWriter(fileWriter);

        fileParts.setFileHeader(bufferedWriter, conn, false);           // Don't include the USE statement

        String content = "CREATE DATABASE " + schema + ";";
        fileParts.writeContent(bufferedWriter, content);

        // Temporarily disable key constraints
        fileParts.writeContent(bufferedWriter, "SET UNIQUE_CHECKS=0;");
        fileParts.writeContent(bufferedWriter, "SET FOREIGN_KEY_CHECKS=0;");

        // Allow the creation of functions (DETERMINISTIC, NO SQL, or READS SQL DATA)
        // when binary logging is enabled.
        fileParts.writeContent(bufferedWriter, "SET GLOBAL log_bin_trust_function_creators = 1;");

        fileParts.setFileFooter(bufferedWriter);
        bufferedWriter.close();

        // Create last .sql file to restore settings
        fileName = "end-up.sql";
        bufferedWriter = fileParts.createFileWriter(schema, fileName, true);

        fileParts.setFileHeader(bufferedWriter, conn);

        // Enable key constraints
        fileParts.writeContent(bufferedWriter, "SET UNIQUE_CHECKS=1;");
        fileParts.writeContent(bufferedWriter, "SET FOREIGN_KEY_CHECKS=1;");

        fileParts.setFileFooter(bufferedWriter);
        bufferedWriter.close();
    }

    /**
     * Executes all SQL sentences included in a SQL file.
     *
     * @param fileName String Name of the dump file. It is asumed that it is
     * localted in a folder that has the name of the database.
     * @param folderName String folder where the file is stored
     * @param targetDatabase String database to be used for restoring
     * @throws SQLException
     * @throws IOException
     */
    public void executeDumpFile(String fileName, String folderName, String targetDatabase) throws SQLException, IOException {
        System.out.println("Reading " + fileName + "..");
        fileName = folderName + System.getProperty("file.separator") + fileName;
        
        // Double check file location.
        if (!(new File(fileName).exists())) {
            throw new IOException("Files to restore must be in the systems's intallation directory.");
        }
        
        boolean hasDelimiter = false;   // Used for routines

        try (BufferedReader reader = new BufferedReader(new FileReader(fileName, StandardCharsets.UTF_8))) {
            String line;
            String cmd = "";
            while ((line = reader.readLine()) != null) {

                // Skip delimiter line
                if (line.equals("delimiter $")) {
                    hasDelimiter = true;
                    continue;
                }

                // Skip coments for none-routine lines
                if (line.startsWith("--") && !hasDelimiter) {
                    continue;
                }

                // Skip ending delimiter
                if (line.trim().equals("delimiter ;")) {
                    hasDelimiter = false;
                    continue;
                }

                // Add line feed when creating routines.
                cmd += line + (hasDelimiter ? " \n" : "");

                // Go to next line (none-routine lines)
                if (!cmd.endsWith(";") && !hasDelimiter) {
                    continue;
                }

                // Excecute multi-line command.
                if (cmd.trim().endsWith("$") && hasDelimiter) {
                    /*
                    If the user that created the backup does not have enough permissions
                    we will find a 'null' text here.  That means we must not execute it.
                     */
                    if (cmd.endsWith("null$")) {
                        continue;
                    }

                    cmd = cmd.replace("$", "");
                    try (Statement statement = conn.createStatement()) {
                        statement.executeUpdate(cmd);
                        cmd = "";
                        hasDelimiter = false;
                        continue;
                    }
                }

                // Go to next line (routine code)
                if (hasDelimiter) {
                    continue;
                }
                // Execute single line command.
                try (Statement statement = conn.createStatement()) {
                    // If target database is not empty, replace the database name with the new one
                    if (!targetDatabase.isEmpty()) {
                        if (cmd.startsWith("USE ")) {
                            cmd = "USE " + targetDatabase + ";";
                        } else if (cmd.contains("CREATE DATABASE ")) {
                            cmd = "CREATE DATABASE " + targetDatabase + ";";
                        }
                    }
                    statement.executeUpdate(cmd);
                    cmd = "";
                }
            }
        } catch (IOException e) {
            throw e;
        }
    }

    /**
     * Creates all tables.
     *
     * @param folderName
     * @param newDatabase
     * @throws SQLException
     * @throws IOException
     */
    public void runInitFiles(String folderName, String newDatabase) throws SQLException, IOException {
        File folder = new File(folderName);
        File[] files = folder.listFiles();

        // Only file names ending by _init.sql are processed
        for (File file : files) {
            if (!file.getName().endsWith("_init.sql")) {
                continue;
            }
            executeDumpFile(file.getName(), folderName, newDatabase);
        }
    }

    public void importJsonFiles(String folderName, javax.swing.JProgressBar progresBar, int maxPoints) throws SQLException, IOException {

        File folder = new File(folderName);
        File[] files = folder.listFiles();
        int totalFiles = 0;
        for (File file : files) {
            if (file.getName().endsWith(".json")) {
                totalFiles++;
            }
        }

        double valueForEachJson = (double) maxPoints / (double) totalFiles;
        int pointsApplied = 0;

        for (File jsonFile : files) {
            if (!jsonFile.getName().endsWith(".json")) {
                continue;
            }
            System.out.println("Restoring table " + jsonFile.getName().replace(".json", "") + "..");

            columnNames = new ArrayList<>();
            columnTypes = new ArrayList<>();
            columnValues = new ArrayList<>();

            loadJsonData(jsonFile);

            System.out.println("Restoring table " + jsonFile.getName().replace(".json", "") + ".. complete!");
            progresBar.setValue(progresBar.getValue() + (int) valueForEachJson);
            pointsApplied += (int) valueForEachJson;
        }

        progresBar.setValue(progresBar.getValue() + (maxPoints - pointsApplied));
    }

    private void loadJsonData(File jsonFile) throws SQLException, IOException {
        ObjectMapper objectMapper = new ObjectMapper();
        JsonNode rootNode = objectMapper.readTree(jsonFile);
        
        // If json is empty won't continue.
        if (rootNode.isArray() && rootNode.size() == 0) {
            System.out.println(jsonFile.getCanonicalPath() + " does not contain any data.");
            return;
        }

        pupulateListsFromJson(rootNode);

        String sqlTable = jsonFile.getName().replace(".json", "");

        String firstColumn = columnNames.get(0);

        // Crate the sql INSERT sentence
        String sql = prepareSQL(sqlTable);

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int i = 0; i < columnNames.size(); i++) {

                if (!columnNames.get(i).equals(firstColumn)) {
                    // Skip column
                    continue;
                }

                setValues(ps, i);
                ps.executeUpdate();
            }
        }
    }

    private void pupulateListsFromJson(JsonNode jsonNode) {
        if (jsonNode.isObject()) {
            jsonNode.fields().forEachRemaining(entry -> {
                switch (entry.getKey()) {
                    case "columnName": {
                        columnNames.add(entry.getValue().toString());
                        break;
                    }
                    case "columnType": {
                        columnTypes.add(entry.getValue().toString());
                        break;
                    }
                    case "columnValue": {
                        columnValues.add(entry.getValue().toString());
                        break;
                    }
                }
            });
        } else if (jsonNode.isArray()) {
            jsonNode.forEach(element -> {
                pupulateListsFromJson(element);
            });
        }
    }

    private String prepareSQL(String table) throws SQLException {
        StringBuilder sql = new StringBuilder();
        sql.append("INSERT INTO `").append(table).append("` VALUES (");
        int numberOfColumns = countColumns();
        for (int i = 0; i < numberOfColumns; i++) {
            sql.append("?").append(i + 1 < numberOfColumns ? "," : "");
        }

        sql.append(");");

        return sql.toString();
    }

    private int countColumns() {
        String column = columnNames.get(0);
        int count = 0;
        for (int i = 0; i < columnNames.size(); i++) {

            // Skip first iteration
            if (i == 0) {
                count = 1;
                continue;
            }

            // Stop counting when column name is equals to the first one.
            if (columnNames.get(i).equals(column)) {
                break;
            }

            count++;
        }

        return count;
    }

    /**
     * Set values according to their type.
     *
     * @param ps PreparedStatement
     * @param listsIndex int number of index in the lists, denotes the begining
     * of every column group.
     * @throws SQLException
     */
    private void setValues(PreparedStatement ps, int listsIndex) throws SQLException {

        int parameterPosition = 1;
        String firstColumnNameInGroup = columnNames.get(listsIndex);

        // Cycle until next group of columns is reached
        do {
            // Determine value & value type
            String columnType = columnTypes.get(listsIndex).replace("\"", "").replace("\\", "");

            String value = columnValues.get(listsIndex).replace("\"", "").replace("\\", "");
            if (columnType.equals("JSON")) {
                value = columnValues.get(listsIndex);
            }

            switch (columnType) {
                case "BIT":
                    boolean bValue = value.equals("1");
                    ps.setBoolean(parameterPosition, bValue);
                    break;
                case "TINYINT":
                case "SMALLINT":
                case "MEDIUMINT":
                case "INT":
                    ps.setInt(parameterPosition, Integer.parseInt(value));
                    break;
                case "BIGINT":
                    if (value.equalsIgnoreCase("NULL")) {
                        ps.setNull(parameterPosition, java.sql.Types.NULL);
                    } else {
                        ps.setLong(parameterPosition, Long.parseLong(value));
                    }
                    break;

                case "FLOAT":
                case "DOUBLE":
                case "DECIMAL":
                    if (value.equalsIgnoreCase("NULL")) {
                        ps.setNull(parameterPosition, java.sql.Types.NULL);
                    } else {
                        ps.setDouble(parameterPosition, Double.parseDouble(value));
                    }
                    break;

                case "BLOB":
                case "LONGBLOB":
                    if (value.equalsIgnoreCase("NULL")) {
                        ps.setNull(parameterPosition, java.sql.Types.NULL);
                    } else {
                        byte[] binaryData = Base64.getDecoder().decode(value);
                        ps.setBytes(parameterPosition, binaryData);
                    }
                    break;

                default: //JSON, DATE, DATETIME, TIMESTAMP, VARCHAR, etc
                    if (value.equalsIgnoreCase("NULL")) {
                        ps.setNull(parameterPosition, java.sql.Types.NULL);
                    } else {
                        ps.setString(parameterPosition, value);
                    }
            }
            parameterPosition++;
            listsIndex++;
        } while (listsIndex < columnNames.size() && !firstColumnNameInGroup.equals(columnNames.get(listsIndex)));
    }

    public List<String> getDatabaseTables(String type) throws SQLException {
        String tableType = type.equals("TABLE") ? "'BASE TABLE'" : "'VIEW'";
        Statement statement = conn.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
        List<String> databaseTables = new ArrayList<>();
        String sqlSent
                = "Select table_name from information_schema.tables "
                + "where table_schema = '" + schema + "' and table_type = " + tableType;
        try (ResultSet rs = statement.executeQuery(sqlSent)) {
            while (rs.next()) {
                databaseTables.add(rs.getString(1));
            }
        }
        return databaseTables;
    }

    public List<String> getRoutines(String type) throws SQLException {
        Statement statement = conn.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
        List<String> routines = new ArrayList<>();
        String sqlSent
                = "SELECT * FROM information_schema.routines "
                + "WHERE routine_schema = '" + schema + "' AND "
                + "ROUTINE_TYPE = '" + type + "'";
        try (ResultSet rs = statement.executeQuery(sqlSent)) {
            while (rs.next()) {
                routines.add(rs.getString("ROUTINE_NAME"));
            }
        }
        return routines;
    }

    public void exportRoutine(String routine, String type, BufferedWriter bufferedWriter) throws SQLException, IOException {
        String content = "DROP " + type + " IF EXISTS " + routine + ";";
        fileParts.writeContent(bufferedWriter, content);

        content = "delimiter $";
        fileParts.writeContent(bufferedWriter, content);

        String sql = "SHOW CREATE " + type + " " + routine;
        PreparedStatement ps = conn.prepareStatement(sql);
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                content = rs.getString(3) + "$";
                fileParts.writeContent(bufferedWriter, content);
            }
        }

        content = "delimiter ;";
        fileParts.writeContent(bufferedWriter, content);

        content = "--";
        fileParts.writeContent(bufferedWriter, content);
    }

    public void exportView(String view, BufferedWriter bufferedWriter) throws SQLException, IOException {
        String content = "DROP VIEW" + " IF EXISTS " + view + ";";
        fileParts.writeContent(bufferedWriter, content);

        String sql = "SHOW CREATE VIEW " + view;
        PreparedStatement ps = conn.prepareStatement(sql);
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                content = rs.getString(2) + ";";
                fileParts.writeContent(bufferedWriter, content);
            }
        }

        content = "--";
        fileParts.writeContent(bufferedWriter, content);
    }

    public List<String> getTriggers() throws SQLException {
        Statement statement = conn.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
        List<String> triggers = new ArrayList<>();
        String sqlSent
                = "SELECT * FROM information_schema.triggers "
                + "WHERE trigger_schema = '" + schema + "'";
        try (ResultSet rs = statement.executeQuery(sqlSent)) {
            while (rs.next()) {
                triggers.add(rs.getString("TRIGGER_NAME"));
            }
        }
        return triggers;
    }

    public void exportTrigger(String trigger, BufferedWriter bufferedWriter) throws IOException, SQLException {
        String content = "DROP TRIGGER" + " IF EXISTS " + trigger + ";";
        fileParts.writeContent(bufferedWriter, content);

        content = "delimiter $";
        fileParts.writeContent(bufferedWriter, content);

        String sql = "SHOW CREATE TRIGGER " + trigger;
        PreparedStatement ps = conn.prepareStatement(sql);
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                content = rs.getString(3) + "$";
                fileParts.writeContent(bufferedWriter, content);
            }
        }

        content = "delimiter ;";
        fileParts.writeContent(bufferedWriter, content);

        content = "--";
        fileParts.writeContent(bufferedWriter, content);
    }

    /**
     * Counts the total records for a list of tables.
     *
     * @param tables List of tables.
     * @return int total records
     * @throws SQLException
     */
    public int getRecordCount(List<String> tables) throws SQLException {

        int records = 0;
        try (Statement statement = conn.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY)) {
            for (String t : tables) {
                String sqlSent = "SELECT COUNT(*) FROM " + t;

                try (ResultSet rs = statement.executeQuery(sqlSent)) {
                    while (rs.next()) {
                        records += rs.getInt(1);
                    }
                }
            }
        }
        return records;
    }

    private void useDefaultSchema() throws SQLException {
        Statement statement = conn.createStatement();
        statement.execute("Use " + this.schema);
    }
}
