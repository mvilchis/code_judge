
public class Test18 {

    private static long count = 0;

    public static void main(String[] args) {
        infiniteRecursiveMethod(1);
    }

    public static void infiniteRecursiveMethod(long a) {
        count++;
        infiniteRecursiveMethod(a);
    }
}
