package com.infot.mrb.backup;

/**
 *
 * @author bgarita
 */
public class ConnectionRecord {
    private int id;
    private String serverName;
    private String ip;
    private String port;
    private String defaultSchema;
    private String user;
    private String password;

    public ConnectionRecord() {
        id = -1; // Means no connection
    }

    
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getServerName() {
        return serverName;
    }

    public void setServerName(String serverName) {
        this.serverName = serverName;
    }

    public String getIp() {
        return ip;
    }

    public void setIp(String ip) {
        this.ip = ip;
    }

    public String getPort() {
        return port;
    }

    public void setPort(String port) {
        this.port = port;
    }

    public String getDefaultSchema() {
        return defaultSchema;
    }

    public void setDefaultSchema(String defaultSchema) {
        this.defaultSchema = defaultSchema;
    }

    public String getUser() {
        return user;
    }

    public void setUser(String user) {
        this.user = user;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    @Override
    public String toString() {
        return "ConnectionRecord{" + "id=" + id + ", serverName=" + serverName + ", ip=" + ip + ", port=" + port + ", defaultSchema=" + defaultSchema + '}';
    }
    
    
}
