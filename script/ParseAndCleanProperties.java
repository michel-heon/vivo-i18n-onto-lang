
import java.io.BufferedWriter;
import java.util.Set;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.lang.reflect.Method;
import java.nio.charset.Charset;
import java.util.Properties;
import java.io.BufferedWriter;

/*
 * Sert au traitement des valeurs des propriétés dont notamment
 * la suppression des caractères "\" de saut de ligne pour mettre la valeur sur une seule ligne
 *  
 * Used for the treatment of the values of the properties of which in particular the suppression 
 * of the characters "\" of line break to put the value on only one line
 */
public class ParseAndCleanProperties {

    public static void main(String[] args) {
        Properties properties = new Properties();
        BufferedWriter writer = new BufferedWriter(new OutputStreamWriter(System.out));

        try {
            //System.out.println("Allo");
            properties.load(new InputStreamReader(System.in, Charset.forName("UTF-8")));
            //File initialFile = new File("/home/ubuntu/VIVO_LYRAIS_DEV/00-GIT/Vitro-languages/de_DE/webapp/src/main/webapp/i18n/all_de_DE.properties");
            //InputStream inStream = new FileInputStream(initialFile);
            //properties.load(inStream);
//            properties.store(new OutputStreamWriter(System.out, Charset.forName("UTF-8")), null);
            Set<String> keys = properties.stringPropertyNames();
            for (String key : keys) {
                writer.write(key + "=" + properties.getProperty(key).replace("\n", "\\n"));
                writer.write("\n");
            }            
        } catch (Exception e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
            System.exit(0);
        }
        try {
            writer.flush();
            
        } catch (Exception e) {
            // TODO: handle exception
        }
    }

}
