package com.infot.mrb.Files;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

public class CreateAndWriteToFile {

    public static void main(String[] args) {
        String fileName = "example.txt"; // Nombre del archivo
        String content = "Este es el contenido que se agregará al archivo.";

        try {
            // Crear una instancia de la clase File
            File file = new File(fileName);

            // Si el archivo no existe, se creará
            if (!file.exists()) {
                file.createNewFile();
            }

            // Crear una instancia de FileWriter para escribir en el archivo
            FileWriter fileWriter = new FileWriter(file, true); // 'true' indica que se agregará al final del archivo
            
            // Agregar el contenido al archivo
            // Crear una instancia de BufferedWriter para mejorar el rendimiento de escritura
            try (BufferedWriter bufferedWriter = new BufferedWriter(fileWriter)) {
                // Agregar el contenido al archivo
                bufferedWriter.write(content);
                bufferedWriter.newLine(); // Agregar una nueva línea al final
                // Cerrar el BufferedWriter
            }

            System.out.println("Contenido agregado al archivo exitosamente.");
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
