package com.infot.mrb.Files;

import com.infot.mrb.utilities.Bitacora;
import java.io.IOException;
import static org.junit.Assert.assertTrue;
import org.junit.Test;

/**
 *
 * @author bgarita
 */
public class BitacoraTest {

    
    @Test
    public void testLog() throws IOException {
        Bitacora log = new Bitacora();
        assertTrue(log.getRuta() != null && !log.getRuta().isBlank());
        
        log.setConsoleOnly(true);
        log.info("System path: " + log.getRuta());
        log.info("Log file: " + log.getLogFile().getCanonicalPath());
    }
    
}
