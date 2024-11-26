
import java.lang.management.ThreadInfo;

public class Sandbox {

    private static final int UPDATE_TIME_THRESHOLD = 200;

    /**
     *arg[0] - FILE_PATH
     *args[1] - FILE_NAME
     *args[2] - WALLCLOCK
     *args[3] - CPU-TIME
     *args[4] - MEMORY
     *args[5] - DISK
     **/
    public static void main(String[] args) {
        boolean estaTerminado = false;
        ThreadInfo info;
        Thread.State state;
        DangerousThread targetThread = new DangerousThread();
        Limits limits = new Limits(Integer.parseInt(args[2]), Integer.parseInt(args[3]), Integer.parseInt(args[4]), Integer.parseInt(args[5]), targetThread);
        targetThread.init(args[0], args[1], limits);
        limits.init();

        try {
            targetThread.start();
            do {
                try {
                    targetThread.join(UPDATE_TIME_THRESHOLD);
                } catch (InterruptedException e) {
                    limits.halt(Reply.IE);
                }

                info = limits.getThreadInfo();
                state = (info == null) ? Thread.State.TERMINATED : info.getThreadState();

                if (state == Thread.State.TERMINATED) {
                    estaTerminado = true;
                }
                limits.updateConsumptions();
                limits.checkLimits();
            } while (!estaTerminado);
            limits.halt(Reply.OK);
        } catch (Exception e) {
            limits.halt(Reply.IE);
        }
    }
}
