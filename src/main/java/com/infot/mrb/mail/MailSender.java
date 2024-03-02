package com.infot.mrb.mail;

import com.infot.mrb.utilities.Props;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;
import javax.activation.DataHandler;
import javax.activation.FileDataSource;
import javax.mail.*;
import javax.mail.internet.*;

/**
 * Esta clase tiene los métodos necesarios para enviar correos de TEXTO, HTML y
 * con archivo adjunto.
 *
 * @author bgarita
 */
public class MailSender {

    private final String mailHost;
    private String remitente;
    private String errorMessage = "";
    private boolean error;

    private final Properties gmailProps;

    public boolean isError() {
        return error;
    }

    public MailSender() throws IOException {
        gmailProps = getMailConfig();
        mailHost = gmailProps.getProperty("mail.smtp.host");
        remitente = gmailProps.getProperty("mail.smtp.user");

        error = false;
        errorMessage = "";
    } // end initGMail

    // Cambiar el emisor de correo
    public void setRemitente(String remitente) {
        this.remitente = remitente;
    } // end setsCorreoOrigen

    /**
     * Método público que envía un correo (HTML o texto) a las direcciones
     * indicadas en el archivo de propiedades, desde la dirección indicada en
     * ese mismo archivo con el asunto y el contenido que se pasan como
     * parámetros.
     *
     * @param mailAddress String dirección de correo electrónico
     * @param asunto String título del correo
     * @param textoHTML String mensaje del correo
     * @return boolean true=Exitoso, false=fallido
     * @throws java.lang.Exception
     */
    public boolean sendHTMLMail(String mailAddress, String asunto, String textoHTML) throws Exception {
        if (this.malformado(mailAddress)) {
            this.errorMessage
                    = """
                      Esta dirección de correo tiene 
                      caracteres o repetición de caracteres 
                      que se pueden interpretar como spam 
                      o está mal formada '""" + mailAddress + "'";
            this.error = true;
            return false;
        }

        try {
            Session session = Session.getDefaultInstance(this.gmailProps,
                    new javax.mail.Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(
                            gmailProps.getProperty("mail.smtp.user"), gmailProps.getProperty("mail.smtp.clave"));
                }
            });

            Message message = new MimeMessage(session);

            // Puede ser una máscara (por alguna razón en GMail este from lo está ignorando, usa el user de la session. 22/10/2018)
            message.setFrom(new InternetAddress(remitente));

            InternetAddress[] address = new InternetAddress[1];
            address[0] = new InternetAddress(mailAddress);

            message.setRecipients(Message.RecipientType.TO, address);
            message.setSubject(asunto);
            message.setSentDate(new java.util.Date());

            message.setContent(textoHTML, "text/html; charset=UTF-8");

            Transport.send(message);
        } catch (MessagingException ex) {
            System.out.println(ex);
            error = true;
            errorMessage = ex.getMessage();
            return false;
        } // end try-catch
        return true;

    } // sendHTMLMail

    public boolean sendAttachmentMail(String destinatario, String asunto, String bodyText, String[] archivos) {
        if (this.malformado(destinatario)) {
            this.errorMessage
                    = """
                      Esta dirección de correo tiene 
                      caracteres o repetición de caracteres 
                      que se pueden interpretar como spam 
                      o está mal formada '""" + destinatario + "'";
            this.error = true;
            return false;
        }

        MimeMultipart multiParte;
        BodyPart texto = new MimeBodyPart();

        try {
            Session session = Session.getDefaultInstance(this.gmailProps,
                    new javax.mail.Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(
                            gmailProps.getProperty("mail.smtp.user"), gmailProps.getProperty("mail.smtp.clave"));
                }
            });

            Message message = new MimeMessage(session);

            message.setFrom(new InternetAddress(remitente));

            InternetAddress address[] = new InternetAddress[1];
            address[0] = new InternetAddress(destinatario);

            message.setRecipients(Message.RecipientType.TO, address);
            message.setSubject(asunto);
            message.setSentDate(new java.util.Date());

            texto.setText(bodyText);

            multiParte = new MimeMultipart();
            multiParte.addBodyPart(texto);

            // Agregar los adjuntos
            for (String archivo : archivos) {
                File f = new File(archivo);
                BodyPart adj = new MimeBodyPart();
                adj.setDataHandler(new DataHandler(new FileDataSource(archivo)));
                adj.setFileName(f.getName()); // Transmitir el nombre original
                multiParte.addBodyPart(adj);
            } // end for

            message.setContent(multiParte);

            Transport.send(message);
        } catch (MessagingException ex) {
            System.out.println(ex);
            error = true;
            errorMessage = ex.getMessage();
            return false;
        } // end try-catch
        return true;
    } // sendAttachmentMail

    public String getRemitente() {
        return remitente;
    }

    public String getErrorMessage() {
        return errorMessage;
    }

    public Properties getProperties() {
        return this.gmailProps;
    }

    public String getMailHost() {
        return mailHost;
    }

    public Properties getGmailProps() {
        return gmailProps;
    }

    public void setErrorMessage(String errorMessage) {
        this.errorMessage = errorMessage;
    }

    public void setError(boolean error) {
        this.error = error;
    }

    private Properties getMailConfig() throws FileNotFoundException, IOException {

        // Properties file must be in the system installation folder.
        Properties props = Props.getProps(new File("mail.properties"));

        if (props == null | props.isEmpty()) {

            // Set default parameters
            props = new Properties();
            props.put("mail.smtp.host", "smtp.gmail.com");
            props.put("mail.smtp.ssl.trust", "smtp.gmail.com");
            props.put("mail.smtp.user", "userxxx@gmail.com");
            props.put("mail.smtp.clave", "Changeme");
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.starttls.enable", "true");
            props.put("mail.smtp.port", "587");
            
        }

        //System.out.println("\nUser: " + props.getProperty("mail.smtp.user"));
        //System.out.println("Pass: " + props.getProperty("mail.smtp.clave"));
        
        return props;
    } // end getMailConfig

    /**
     * Este método busca algunos patrones comunes para determinar si la
     * dirección de correo está mal formada o incluye secuencias de caracteres
     * que pueden ser detectadas como spam.
     *
     * @author Bosco Garita 15/01/2015
     * @param mail String dirección de correo a revisar
     * @return true=malformado, false=bien formado
     */
    private boolean malformado(String mail) {
        boolean mailmalformado = false;
        mail = mail.trim();

        if (!mail.contains("@")) {
            return true;
        } // end if

        List<String> posibleSpamContent;
        posibleSpamContent = new ArrayList<>();
        posibleSpamContent.add("aa@aa");
        posibleSpamContent.add("abuse");
        posibleSpamContent.add(" ");
        posibleSpamContent.add(",");
        posibleSpamContent.add("?");
        posibleSpamContent.add("..");
        posibleSpamContent.add("<");
        posibleSpamContent.add(">");
        posibleSpamContent.add("/");
        posibleSpamContent.add("\\");
        posibleSpamContent.add(":");
        posibleSpamContent.add(".@");
        posibleSpamContent.add("..com");
        posibleSpamContent.add(" com");
        posibleSpamContent.add(". ");
        posibleSpamContent.add("à");

        for (int i = 0; i < posibleSpamContent.size(); i++) {
            if (mail.contains(posibleSpamContent.get(i))) {
                mailmalformado = true;
                break;
            } // end if
        } // end if
        return mailmalformado;
    } // end malformado
} // end class
