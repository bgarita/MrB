package com.infot.mrb.MySQL;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class MySQLConnectionExample {

    public static void main(String[] args) {
        // Datos de conexión
        String jdbcUrl = "jdbc:mariadb://127.0.0.1:3308/bk";
        String username = "root";
        String password = "bendicion";

        try {
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
        } catch (SQLException e) {
            System.out.println("Error: No se pudo conectar a la base de datos.");
            e.printStackTrace();
        }
    }
}
