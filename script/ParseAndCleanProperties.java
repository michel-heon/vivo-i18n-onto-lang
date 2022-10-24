
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.Enumeration;
import java.util.Iterator;
import java.util.Properties;
/*
 * Sert au traitement des valeurs des propriétés dont notamment
 * la suppression des caractères "\" de saut de ligne pour mettre la valeur sur une seule ligne
 *  
 * Used for the treatment of the values of the properties of which in particular the suppression 
 * of the characters "\" of line break to put the value on only one line
 */
public class LIST_PROPERTIES {

    public static void main(String[] args) {
        Properties prop = new Properties();
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        try {
            prop.load(br);
        } catch (IOException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
            System.exit(0);
        }
        Iterator<Object> keys = prop.keys().asIterator();
        for (Iterator iterator = keys; iterator.hasNext();) {
            String key = (String) iterator.next();
            System.out.println(key+"="+prop.get(key));
        }
    }
}
