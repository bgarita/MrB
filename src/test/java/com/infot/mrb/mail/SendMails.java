package com.infot.mrb.mail;

import com.infot.mrb.utilities.Ut;
import java.io.IOException;
import java.util.Properties;
import org.junit.jupiter.api.Assertions;
import java.nio.file.FileSystem;
import java.nio.file.FileSystems;
import java.nio.file.Path;

/**
 *
 * @author bgarita, 31/12/2023
 */

public class SendMails {

    private final MailSender mailSender;

    public SendMails() throws IOException {
        this.mailSender = new MailSender();
    }

    
    public void sendMails() throws Exception {
        Properties props = mailSender.getProperties();
        Assertions.assertTrue(props != null);
        Assertions.assertEquals("587", props.getProperty("mail.smtp.port"));
        
        // SEND HTML MAIL
        String html = "<h1>Hola</h1><h2>Esto es un H2<h2>";

        boolean sent = mailSender.sendHTMLMail("bgarita@hotmail.com", "Prueba - HTML", html);
        Assertions.assertTrue(sent);

        // SEND ATTACHMENT MAIL
        FileSystem fs = FileSystems.getDefault();
        Path path = fs.getPath("msg.html");
        String text = Ut.fileToString(path);
        text = text.replace("[msg]", "Test ended successfuly!");
        String archivos[] = {path.getFileName().toFile().getCanonicalPath()};
        sent = mailSender.sendAttachmentMail("bgarita@hotmail.com", "Prueba - Adjunto", text, archivos);
        Assertions.assertTrue(sent);
    }

}
