package com.infot.mrb.backup;

/**
 *
 * @author bgarita, 2023-09-22
 */
public class User {
    private String serverName;
    private String userName;
    private char[] password;

    public User() {
    }

    public User(String serverName, String userName, char[] password) {
        this.serverName = serverName;
        this.userName = userName;
        this.password = password;
    }

    public String getServerName() {
        return serverName;
    }

    public void setServerName(String serverName) {
        this.serverName = serverName;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public char[] getPassword() {
        return password;
    }

    public void setPassword(char[] password) {
        this.password = password;
    }
    
}
