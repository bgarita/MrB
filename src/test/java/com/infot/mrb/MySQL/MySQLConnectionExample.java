package com.infot.mrb.MySQL;

import com.infot.mrb.utilities.Props;
import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

public class MySQLConnectionExample {

    public static void main(String[] args) {
        // Datos de conexión
        String jdbcUrl = "jdbc:mariadb://127.0.0.1:3308/bk";
        String username = "root";
        
        try {
            File propsFile = new File("privateKeys.properties");
            Properties props = Props.getProps(propsFile);
            String password = props.getProperty("mrb.root.password");
            
            // Registrar el controlador JDBC
            //Class.forName("com.mysql.cj.jdbc.Driver"); 

            // Establecer la conexión
            //Connection connection = DriverManager.getConnection(jdbcUrl, username, password);
            Connection connection = DriverManager.getConnection(jdbcUrl, username, password);

            if (connection != null) {
                System.out.println("Conexión exitosa a la base de datos.");
                // Realizar operaciones en la base de datos aquí
                // ...
                // Cerrar la conexión
                connection.close();
            }
        } catch (IOException | SQLException e) {
            System.out.println("Error: No se pudo conectar a la base de datos.");
            e.printStackTrace();
        }
    }
}
