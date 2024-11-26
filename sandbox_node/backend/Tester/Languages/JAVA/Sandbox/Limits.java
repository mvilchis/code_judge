
import java.io.PrintStream;
import java.lang.management.ManagementFactory;
import java.lang.management.ThreadMXBean;
import java.lang.management.MemoryMXBean;
import java.lang.management.ThreadInfo;

public class Limits {

    private final MemoryMXBean memoryBean;
    private final ThreadMXBean threadBean;
    private final int wallclockLimit;
    private final int timeLimit;
    private final int memoryLimit;
    private final int outputLimit;
    private long beginWallclock;
    private int timeConsumption;
    private int memoryConsumption;
    private int outputRemain;
    private long baseHeapMemoryConsumption;
    private final DangerousThread targetThread;
    private final PrintStream STDERR;
    private final SandboxSecurityManager sm;

    /**
     * @param wallclockLimit En segundos
     * @param timeLimit En segundos
     * @param memoryHeapLimit En Kilobytes
     * @param outputLimit En Kilobytes
     * @param targetThread
     */
    public Limits(int wallclockLimit, int timeLimit, int memoryLimit, int outputLimit, DangerousThread targetThread) {
        this.memoryBean = ManagementFactory.getMemoryMXBean();
        this.threadBean = ManagementFactory.getThreadMXBean();
        this.threadBean.setThreadCpuTimeEnabled(true);
        this.wallclockLimit = wallclockLimit * 1000;
        this.timeLimit = timeLimit * 1000;
        this.memoryLimit = memoryLimit;
        this.outputLimit = outputLimit * 1024;
        this.outputRemain = outputLimit;
        this.targetThread = targetThread;
        this.STDERR = System.err;
        System.setOut(new PrintStream(new LimitOutputStream(this)));
        System.setErr(System.out);

        sm = new SandboxSecurityManager(targetThread);
        System.setSecurityManager(sm);
    }

    public void init() {
        System.gc();
        baseHeapMemoryConsumption = memoryBean.getHeapMemoryUsage().getUsed();
        beginWallclock = System.currentTimeMillis();
    }

    private long timeMilisecondsThread(long id) {
        long t = threadBean.getThreadCpuTime(id);
        if (t < 0) {
            t = 0;
        }
        t /= 1000000; //Milisegundos
        return t;
    }

    public synchronized void updateConsumptions() {
        int m = (int) ((memoryBean.getHeapMemoryUsage().getUsed() - baseHeapMemoryConsumption) / 1024);
        long t_CPU = timeMilisecondsThread(targetThread.getId());

        if (t_CPU > timeConsumption) {
            timeConsumption = (int) t_CPU;
        }
        if (m > memoryConsumption) {
            memoryConsumption = m;
        }
    }

    public void checkLimits() {
        if (timeConsumption > timeLimit || (System.currentTimeMillis() - beginWallclock) > wallclockLimit) {
            halt(Reply.TL);
        }

        if (memoryConsumption > memoryLimit) {
            halt(Reply.ML);
        }

        if (outputRemain <= 0) {
            halt(Reply.OL);
        }
    }

    public synchronized void halt(Reply result) {
        sm.deleteSecurity();
        STDERR.println("result: " + result.getCode() + "\n"
                + "cpu: " + timeConsumption + "ms" + "\n"
                + "mem: " + memoryConsumption + "kB");
        Runtime.getRuntime().exit(result.getId());
    }

    public void setMaxMemory() {
        memoryConsumption = memoryLimit + 1;
    }

    public int getOutputRemain() {
        return outputRemain;
    }

    public ThreadInfo getThreadInfo() {
        return threadBean.getThreadInfo(targetThread.getId());
    }

    public void decreseOutputRemain(int tam) {
        if (tam > 0) {
            outputRemain -= tam;
        }
    }

}
