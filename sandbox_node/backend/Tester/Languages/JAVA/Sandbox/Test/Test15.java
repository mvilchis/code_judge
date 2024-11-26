
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.net.Socket;

public class Test15 {

    public static void main(String a[]) throws Exception {
        String yahoo = "finance.yahoo.com";
        final int httpd = 80;
        Socket sock = new Socket(yahoo, httpd);

        BufferedWriter out = new BufferedWriter(new OutputStreamWriter(sock.getOutputStream()));

        String cmd = "GET /q?" + "s=12\n";
        out.write(cmd);
        out.flush();

        BufferedReader in = new BufferedReader(new InputStreamReader(sock.getInputStream()));
        String s = in.readLine();
        System.out.println(s);
    }
}
