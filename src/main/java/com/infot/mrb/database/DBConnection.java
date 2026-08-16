package com.infot.mrb.database;

import com.infot.mrb.backup.ConnectionRecord;
import com.infot.mrb.backup.Encryption;
import com.infot.mrb.utilities.Props;
import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Properties;
import log.Bitacora;

/**
 *
 * @author Bosco Garita, Enero 2023
 */
public class DBConnection {

    private final static Bitacora log = new Bitacora();

    private static String normalizeHost(String host) {
        if (host == null) {
            return "";
        }

        String normalizedHost = host.trim();
        if (normalizedHost.startsWith("jdbc:mariadb://")) {
            normalizedHost = normalizedHost.substring("jdbc:mariadb://".length());
        }

        if (normalizedHost.startsWith("//")) {
            normalizedHost = normalizedHost.substring(2);
        }

        return normalizedHost;
    }

    private static boolean isIpLiteral(String host) {
        if (host == null || host.isBlank()) {
            return false;
        }

        String normalizedHost = host.trim();
        if (normalizedHost.startsWith("[") && normalizedHost.endsWith("]")) {
            normalizedHost = normalizedHost.substring(1, normalizedHost.length() - 1);
        }

        return normalizedHost.matches("^\\d{1,3}(\\.\\d{1,3}){3}$")
                || normalizedHost.matches("(?i)^[0-9a-f:]+$") && normalizedHost.contains(":");
    }

    private static boolean shouldUseSsl(String host) {
        if (host == null || host.isBlank()) {
            return false;
        }

        String normalizedHost = normalizeHost(host).toLowerCase();

        if (normalizedHost.equals("localhost")
                || normalizedHost.equals("127.0.0.1")
                || normalizedHost.equals("::1")
                || normalizedHost.equals("0:0:0:0:0:0:0:1")) {
            return false;
        }

        return normalizedHost.contains(".") && !isIpLiteral(normalizedHost);
    }

    private static String buildJdbcUrl(String host, String port, String schema) {
        String normalizedHost = normalizeHost(host);
        StringBuilder jdbcUrl = new StringBuilder("jdbc:mariadb://")
                .append(normalizedHost)
                .append(":")
                .append(port)
                .append("/")
                .append(schema);

        if (shouldUseSsl(normalizedHost)) {
            jdbcUrl.append("?sslMode=verify-full");
        }

        return jdbcUrl.toString();
    }

    /*
    Every encrypted text could be different each time then we cannot test against an encrypted text, 
    instead we must compare the decrypted text.
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
                // All columns, except id and server_name, are encrypted, decrypt them.
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

        String jdbcUrl = buildJdbcUrl(connectionRecord.getIp(), connectionRecord.getPort(), connectionRecord.getDefaultSchema());
        log.info("Trying connection...");

        Connection connection = null;
        int maxRetries = 3; // Número máximo de intentos
        int currentAttempt = 1;
        int waitTimeMs = 5000; // Esperar 5 segundos (5000 ms) entre intentos

        // 1. Aumentar el tiempo de espera del Driver (por ejemplo, a 30 segundos)
        // Nota: Esto establece el límite máximo de espera para el login.
        DriverManager.setLoginTimeout(30);

        while (connection == null && currentAttempt <= maxRetries) {
            try {
                log.info("Intentando conectar a la base de datos (Intento " + currentAttempt + " de " + maxRetries + ")...");

                // Intento de conexión
                // Set (remote) connection to extract data
                connection = DriverManager.getConnection(jdbcUrl, user, connectionRecord.getPassword());

                log.info("¡Conexión establecida con éxito!");

            } catch (SQLException e) {
                log.error("Fallo al conectar: " + e.getMessage());

                if (currentAttempt == maxRetries) {
                    log.error("Se alcanzó el número máximo de reintentos. Abortando..");
                    throw e;
                }

                log.info("La base de datos tardó en responder. Reintentando en " + (waitTimeMs / 1000) + " segundos...");

                try {
                    // Pausar la ejecución antes del siguiente intento
                    Thread.sleep(waitTimeMs);
                } catch (InterruptedException ie) {
                    // Restaurar el estado de interrupción del hilo
                    Thread.currentThread().interrupt();
                    log.error("El hilo de espera fue interrumpido.");
                    break;
                }

                currentAttempt++;
            }
        }

        String msg = "Connected to (" + connectionRecord.getServerName() + ") " + connectionRecord.getIp();

        log.info(msg);

        return connection;
    }

    public static Connection getConnection(String databaseServerName, String port, String user, String password, String schema) throws SQLException {

        String jdbcUrl = buildJdbcUrl(databaseServerName, port, schema);

        log.info("Trying connection...");
        Connection connection;

        // Set connection
        connection = DriverManager.getConnection(jdbcUrl, user, password);

        if (connection != null) {
            log.info("Connection successfully.");
        }

        return connection;
    }

    /**
     * This connection is used by the system only. Creates a connection to a
     * local MySQL instance to maintain its database.
     *
     * @return
     * @throws java.io.IOException
     * @throws SQLException
     */
    public static Connection getBkConnection() throws IOException, SQLException {

        File propsFile = new File("privateKeys.properties");
        Properties props = Props.getProps(propsFile);
        
        String user = props.getProperty("mr.bk.user");
        String password = props.getProperty("mr.bk.password");

        // Se asume que el servidor de base de datos es local
        String jdbcUrl = "jdbc:mariadb://127.0.0.1:3308/bk";

        Connection connection;

        //Class.forName("com.mysql.cj.jdbc.Driver");
        // Set connection
        connection = DriverManager.getConnection(jdbcUrl, user, password);

        return connection;
    }

}
