
public class Test08 {

    public static void main(String[] args) {
        Thread t = new Thread(new Runnable() {
            @Override
            public void run() {
                System.out.println("Thread hijo");
            }
        });
        t.start();

        try {
            t.join();
        } catch (InterruptedException e) {
        }
        System.out.println("Thread padre");
    }

}
