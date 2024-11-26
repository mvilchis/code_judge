
public class Test09 {

    public static void main(String[] args) {
        int[] enteros = new int[1000];
        for (int i = 0; i < 1000; i++) {
            enteros[i] = i;
        }
        int suma = 0 ;
        for (int i = 0; i < 1000; i++) {
            suma+=enteros[i];
        }
        System.out.println(suma);
    }
}
