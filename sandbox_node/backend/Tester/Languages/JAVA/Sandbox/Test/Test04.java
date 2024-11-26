import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
 
public class Test04 {
	public static void main(String[] args) {
		try{
			BufferedReader bufferRead = new BufferedReader(new InputStreamReader(System.in));
			System.out.println(bufferRead.readLine());
		}catch(IOException e){}
	}
}
