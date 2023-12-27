package com.infot.mrb.Files;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class JacksonExample {

    static List<String> columnNames = new ArrayList<>();
    static List<String> columnTypes = new ArrayList<>();
    static List<String> columnValues = new ArrayList<>();

    public static void main(String[] args) {
        ObjectMapper objectMapper = new ObjectMapper();

        try {
            File jsonFile = new File("C:\\temp\\barrio.json"); // Nombre del archivo JSON
            JsonNode rootNode = objectMapper.readTree(jsonFile);
            traverseJsonNode(rootNode);
            for (int i = 0; i < columnNames.size(); i++) {
                System.out.println("Column=" + columnNames.get(i) + ", Type=" + columnTypes.get(i) + ", Value=" + columnValues.get(i));
                // Con estos datos se puede generar el insert, pero los blob tienen que ser convertidos
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public static void traverseJsonNode(JsonNode jsonNode) {
        if (jsonNode.isObject()) {
            jsonNode.fields().forEachRemaining(entry -> {
                //System.out.println("Field: " + entry.getKey() + ", Value: " + entry.getValue());
                //Record record = new Record();
                switch (entry.getKey()) {
                    case "columnName": {
                        columnNames.add(entry.getValue().toString());
                        //record.setColumnName(entry.getValue().toString());
                        break;
                    }
                    case "columnType": {
                        columnTypes.add(entry.getValue().toString());
                        //record.setColumnType(entry.getValue().toString());
                        break;
                    }
                    case "columnValue": {
                        columnValues.add(entry.getValue().toString());
                        //record.setColumnType(entry.getValue().toString());
                        break;
                    }
                }
                //traverseJsonNode(entry.getValue());
            });
        } else if (jsonNode.isArray()) {
            jsonNode.forEach(element -> {
                //System.out.println("Array Element: " + element);
                traverseJsonNode(element);
            });
        } else if (jsonNode.isValueNode()) {
            System.out.println("Value: " + jsonNode);
        }
    }
}
