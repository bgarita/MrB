package com.infot.mrb.MySQL;

/**
 *
 * @author bgarita, 26/11/2024
 */
public class ReadBITTypes {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        String value = "b'1'";
        boolean bValue = (value.equals("1") || value.equals("b'1'"));
        System.out.println(bValue);
    }
    
}
