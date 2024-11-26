
import java.io.IOException;
import java.io.PrintWriter;
import java.net.ServerSocket;
import java.net.Socket;

public class Test14 {

    public static void main(String[] args) {
        try {
            ServerSocket listener = new ServerSocket(9090);
            int x = 0;
            while (x < 10) {
                Socket socket = listener.accept();
                PrintWriter out = new PrintWriter(socket.getOutputStream(), true);
                out.println("hola");
                socket.close();
                x++;
            }
            listener.close();
        } catch (IOException ex) {
        }
    }
}
