
public class Test12 {

    public static void main(String[] args) {
        int x = 0;
        while (x < 50) {
            System.out.println("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
            x *= 2;
            x %= 50;
        }
        System.out.println(x);
    }
}
