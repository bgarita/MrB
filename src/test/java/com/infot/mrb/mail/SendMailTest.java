package com.infot.mrb.mail;

import java.util.logging.Level;
import java.util.logging.Logger;
import org.junit.After;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import static org.junit.Assert.*;


/**
 *
 * @author bgarita
 */
public class SendMailTest {
    
    public SendMailTest() {
    }
    
    @BeforeClass
    public static void setUpClass() {
    }
    
    @AfterClass
    public static void tearDownClass() {
    }
    
    @Before
    public void setUp() {
    }
    
    @After
    public void tearDown() {
    }

    @Test
    public void sendHtmlMail() {
        try {
            MailSender ms = new MailSender();
            ms.sendHTMLMail("bgarita@hotmail.com", "MrB Unit testing", "<h1>Hi Bosco</h1>");
            assertTrue(!ms.isError());
        } catch (Exception ex) {
            Logger.getLogger(SendMailTest.class.getName()).log(Level.SEVERE, null, ex);
        }
        
    }
}
