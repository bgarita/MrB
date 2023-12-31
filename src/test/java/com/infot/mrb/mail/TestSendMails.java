package com.infot.mrb.mail;

import java.io.IOException;

/**
 *
 * @author bgarita, 31/12/2023
 */
public class TestSendMails {

    /**
     * @param args the command line arguments
     * @throws java.io.IOException
     */
    public static void main(String[] args) throws IOException, Exception {
        SendMails testMail = new SendMails();
        testMail.sendMails();
    }
    
}
