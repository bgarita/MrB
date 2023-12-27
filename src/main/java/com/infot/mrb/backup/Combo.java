package com.infot.mrb.backup;

import com.infot.mrb.database.DBConnection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

/**
 *
 * @author bgarita, 03/12/2023
 */
public class Combo {

    /**
     * @param isEncrypted boolean indicates if data is comming encrypted or not.
     * @throws java.sql.SQLException
     * @Author: Bosco Garita 04/01/2011. Carga un comboBox con los datos de un
     * ResultSet
     * @param combo comboBox que se llenará
     * @param replace true=sustituye los datos del combo, false=los agrega
     * @return true=el proceso fue exitoso, false=el proceso falló Nota 1: el
     * ResultSet que reciba este método debe venir con el atributo de
     * ResultSet.TYPE_SCROLL_SENSITIVE. Nota 2: Si el parámetro replace viene en
     * true debe asegurarse de que el evento ActionPerformed o algún otro que
     * esté asociado al comboBox no se dispare durante la ejecución de este
     * método porque causará un error de Null Pointer.
     */
    public static boolean populate(
            javax.swing.JComboBox combo,
            boolean replace,
            boolean isEncrypted) throws Exception {

        String sql = "Select server_name from `bk`.`connection`";

        Encryption encryption = new Encryption();
        boolean loadedData = false;
        int registros;

        try (java.sql.Connection bkCon = DBConnection.getBkConnection(); PreparedStatement ps = bkCon.prepareStatement(sql, ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_READ_ONLY)) {
            ResultSet rs = ps.executeQuery();

            if (rs != null && rs.first()) {

                if (replace) {
                    combo.removeAllItems();
                } // end if

                rs.last();
                registros = rs.getRow();
                for (int i = 1; i <= registros; i++) {
                    rs.absolute(i);
                    combo.addItem(isEncrypted ? encryption.decryptText(rs.getString(1)) : rs.getString(1));
                } // end for
                loadedData = true;
            } // end if
        }

        return loadedData;

    } // end populate
}
