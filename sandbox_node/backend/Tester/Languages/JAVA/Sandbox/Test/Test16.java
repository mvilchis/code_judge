
public class Test16 {

    public static void main(String a[]) {
        int n = 9999999;
        double[] val = new double[n];
        val[0] = 1;
        for (int i = 1; i < n; i++) {
            val[i] = val[i - 1] + 1;
        }
        System.out.println(val[n - 1]);
    }
}
