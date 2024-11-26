import java.io.PrintWriter;
import java.io.FileNotFoundException;

public class Test07 {
	public static void  main(String[] args){
		try{
			PrintWriter escritor = new PrintWriter("prueba.txt");
			escritor.println("cadena en archivo");
			System.out.println("Si ves esto esta mal el programa");
			escritor.close();
		}catch(FileNotFoundException e){}
	}
}
