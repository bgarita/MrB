package com.infot.mrb.Files;

/**
 *
 * @author bgari
 */
public class Colores {
    public static final String ANSI_RED = "\\u001B[31m";
    public static final String ANSI_GREEN = "\\u001B[32m";
    public static final String ANSI_YELLOW = "\\u001B[33m";
    public static final String ANSI_BLUE = "\\u001B[34m";
    public static final String ANSI_PURPLE = "\\u001B[35m";
    public static final String ANSI_CYAN = "\\u001B[36m";
    public static final String ANSI_WHITE = "\\u001B[37m";
    public static final String ANSI_RESET = "\\u001B[0m";

    public static void main(String[] args) {
        System.out.println(ANSI_RED + "Este texto saldrá en rojo" + ANSI_RESET);
        System.out.println(ANSI_GREEN + "Este texto saldrá en verde" + ANSI_RESET);
        // Y así sucesivamente para los demás colores
    }
}

