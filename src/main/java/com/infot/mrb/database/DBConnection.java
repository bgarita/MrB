package com.infot.mrb.database;

import com.infot.mrb.backup.ConnectionRecord;
import com.infot.mrb.backup.Encryption;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 *
 * @author Bosco Garita, Enero 2023
 */
public class DBConnection {

    /*
    Every encrypted text could be different each time then we cannot test against an encrypted text, 
    inestead we must compare the decrypted text.
    */
    private static ConnectionRecord getConnectionRecord(String serverName) throws Exception {
        boolean retrieveAllRecords = (serverName == null || serverName.isBlank());
        ConnectionRecord connectionRecord = new ConnectionRecord();
        Encryption encryption = new Encryption();
        String sql = "Select * from `bk`.`connection` " + (retrieveAllRecords ? "" : "where server_name = ?");
        try (java.sql.Connection bkCon = DBConnection.getBkConnection(); PreparedStatement ps = bkCon.prepareStatement(sql, ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_READ_ONLY)) {
            if (!retrieveAllRecords) {
                ps.setString(1, serverName);
            }

            ResultSet rs = ps.executeQuery();
            if (rs != null && rs.first()) {
                // All columns, except id and server_name, are encryped, decrypt them.
                connectionRecord.setId(Integer.parseInt(rs.getString("id")));
                connectionRecord.setServerName(rs.getString("server_name"));
                connectionRecord.setIp(encryption.decryptText(rs.getString("ip")));
                connectionRecord.setPort(encryption.decryptText(rs.getString("port")));
                connectionRecord.setDefaultSchema(encryption.decryptText(rs.getString("default_schema")));
                connectionRecord.setUser(encryption.decryptText(rs.getString("user")));
                connectionRecord.setPassword(encryption.decryptText(rs.getString("password")));
            }
        }
        return connectionRecord;
    }

    
    public static Connection getConnection(
            String user, char passwordArray[], String serverName, String schema) throws Exception {

        // Get a connection record from local database
        Connection bkCon = getBkConnection();
        if (bkCon == null) {
            throw new SQLException("Unable to connect to local host");
        }
        ConnectionRecord connectionRecord = getConnectionRecord(serverName);

        if (connectionRecord.getId() < 0) {
            connectionRecord.setUser(user);
            String p = "";
            for (int i = 0; i < passwordArray.length; i++) {
                p += String.valueOf(passwordArray[i]);
            }
            connectionRecord.setPassword(user);
            connectionRecord.setPassword(p);
            connectionRecord.setIp("//127.0.0.1");
            connectionRecord.setPort("3308");
            connectionRecord.setDefaultSchema("bk");
        }

        String jdbcUrl = "jdbc:mariadb://" + connectionRecord.getIp() + ":" + connectionRecord.getPort() + "/" + connectionRecord.getDefaultSchema();
        System.out.println("Trying connection...");
        Connection connection;

        // Set (remote) connection to extract data
        connection = DriverManager.getConnection(jdbcUrl, user, connectionRecord.getPassword());

        if (connection != null) {
            System.out.println("Connection successfull.");
        }

        String msg = "Connected to (" + connectionRecord.getServerName() + ") " + connectionRecord.getIp();

        System.out.println(msg);

        return connection;
    }

    public static Connection getConnection(String IP, String port, String user, String password, String schema) throws ClassNotFoundException, SQLException {

        String database = schema;

        String jdbcUrl = "jdbc:mariadb://127.0.0.1:" + port + "/" + database;

        System.out.println("Trying connection...");
        Connection connection;

        // Set connection
        connection = DriverManager.getConnection(jdbcUrl, user, password);

        if (connection != null) {
            System.out.println("Connection successfull.");
        }

        return connection;
    }

    /**
     * This connection is used by the system only. Creates a connection to a
     * local MySQL instance to maintain its database.
     *
     * @return
     * @throws ClassNotFoundException
     * @throws SQLException
     */
    public static Connection getBkConnection() throws ClassNotFoundException, SQLException {

        String user = "bk";
        String password = "KSWGkq01&MLu*";

        String jdbcUrl = "jdbc:mariadb://127.0.0.1:3308/bk";

        Connection connection;

        //Class.forName("com.mysql.cj.jdbc.Driver");
        // Set connection
        connection = DriverManager.getConnection(jdbcUrl, user, password);

        return connection;
    }

}
