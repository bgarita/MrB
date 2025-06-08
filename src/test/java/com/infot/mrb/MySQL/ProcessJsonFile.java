package com.infot.mrb.MySQL;

import com.fasterxml.jackson.core.JsonFactory;
import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.core.JsonToken;
import java.io.File;
import java.io.IOException;

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
        
        // Usar el número de columnas para preparar el SQL
        int columns = getCount(jsonFile, "columns");
        
        // Usar el número de filas para actualizar el progressBar
        int rows = getCount(jsonFile, "rows");

        JsonParser parser = factory.createParser(jsonFile);

        // Recorrer todo el archivo mediante tokens, no todo de un solo.
        // Este permite hacer un uso eficiente de la memoria.
        while (!parser.isClosed()) {
            JsonToken token = parser.nextToken();

            // Saltar al siguiten token si se da alguna de esta condiciones
            if (JsonToken.START_OBJECT.equals(token)
                    || JsonToken.START_ARRAY.equals(token)
                    || JsonToken.END_OBJECT.equals(token)
                    || JsonToken.END_ARRAY.equals(token)
                    || JsonToken.FIELD_NAME.equals(token)
                    || token == null) {
                continue;
            }

            String columnName = null, columnType = null, columnValue = null;
            do {
                String fieldName = parser.getCurrentName();
                String value = parser.getValueAsString();
                if (fieldName.equals(value)) {
                    continue;
                }
                switch (fieldName) {
                    case "columnName" ->
                        columnName = value;
                    case "columnType" ->
                        columnType = value;
                    case "columnValue" ->
                        columnValue = value;
                    default -> {
                    }
                }
                if (columnName != null) {
                    System.out.println("Column name=" + columnName);
                    System.out.println("Column type=" + columnType);
                    System.out.println("Column value=" + columnValue);
                }
            } while (parser.nextToken() != JsonToken.END_OBJECT);

            // Llegado a este punto ya las tres variables tienen el dato
            // necesario para enviar el insert a la base de datos.
        }

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
