package com.infot.mrb.MySQL;

import com.fasterxml.jackson.core.JsonFactory;
import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.core.JsonToken;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author bgarita, 08/06/2025
 */
public class ProcessJsonFile {

    /**
     * @param args the command line arguments
     * @throws Exception
     */
    public static void main(String[] args) throws Exception {
        JsonFactory factory = new JsonFactory();
        File jsonFile = new File("G:\\Backups\\MrB\\zip\\Restored 20241126\\producto.json");
        JsonParser parser = factory.createParser(jsonFile);

        // Usar el número de columnas para preparar el SQL
        int columns = getCount(jsonFile, "columns");

        // Usar el número de filas para actualizar el progressBar
        int rows = getCount(jsonFile, "rows");

        if (parser.nextToken() != JsonToken.START_ARRAY) {
            throw new IllegalStateException("Se esperaba un arreglo en el JSON");
        }

        // Iterar sobre cada registro (array interno)
        while (parser.nextToken() == JsonToken.START_ARRAY) {
            List<String> nombresColumnas = new ArrayList<>();
            List<String> tiposDatos = new ArrayList<>();
            List<String> valores = new ArrayList<>();

            // Iterar sobre cada objeto (columna)
            while (parser.nextToken() == JsonToken.START_OBJECT) {
                String nombre = null, tipo = null, valor = null;

                // Iterar sobre los campos dentro del objeto
                while (parser.nextToken() != JsonToken.END_OBJECT) {
                    String fieldName = parser.getCurrentName();
                    parser.nextToken(); // movernos al valor del campo

                    switch (fieldName) {
                        case "columnName" -> nombre = parser.getText();
                        case "columnType" -> tipo = parser.getText();
                        case "columnValue" -> valor = parser.getText();
                    }
                }

                if (nombre != null && tipo != null && valor != null) {
                    nombresColumnas.add(nombre);
                    tiposDatos.add(tipo);
                    valores.add(valor);
                }
            }

            // Aquí puedes trabajar con las 3 listas para cada registro
            System.out.println("Registro:");
            System.out.println("Columnas: " + nombresColumnas);
            System.out.println("Tipos:    " + tiposDatos);
            System.out.println("Valores:  " + valores);
            System.out.println("------------------------");
        }

        parser.close();

    }

    private static int getCount(File jsonFile, String type) throws IOException {
        int count = 0;
        JsonFactory factory = new JsonFactory();
        JsonParser parser = factory.createParser(jsonFile);
        while (!parser.isClosed()) {
            JsonToken token = parser.nextToken();
            if (type.equals("rows") && JsonToken.START_ARRAY.equals(token)) {
                count++;
            } else if (type.equals("columns") && JsonToken.START_OBJECT.equals(token)) {
                count++;
            }
        }
        String msg = "Total ";
        // Remove 1 since first array contains the other arrays
        if (type.equals("rows")) {
            count--;
            msg += " filas en JSON: " + count;
        } else {
            msg += " columnas en JSON: " + count;
        }

        System.out.println(msg);
        return count;
    }
}
