
import java.lang.reflect.Method;
import java.lang.reflect.Modifier;
import java.io.File;
import java.net.URLClassLoader;
import java.net.URL;
import java.net.MalformedURLException;
import java.lang.reflect.InvocationTargetException;

public class DangerousThread extends Thread {

    private Method mainMethod;
    private final Object[] targetArguments;
    private Limits limits;

    public DangerousThread() {
        targetArguments = new Object[]{new String[0]};
    }

    public void init(String path, String className, Limits limits) {
        this.limits = limits;
        try {
            File f = new File(path);
            URL[] cp = {f.toURI().toURL()};
            URLClassLoader urlcl = new URLClassLoader(cp);
            Class<?> targetClass = urlcl.loadClass(className);
            mainMethod = targetClass.getMethod("main", String[].class);
        } catch (MalformedURLException | ClassNotFoundException e) {
            limits.halt(Reply.IE);
        } catch (NoSuchMethodException e) {
            limits.halt(Reply.RT);
        }

        if (!Modifier.isStatic(mainMethod.getModifiers())) {
            limits.halt(Reply.RT);
        }
        mainMethod.setAccessible(true);
    }

    @Override
    public void run() {
        try {
            mainMethod.invoke(null, targetArguments);
            limits.updateConsumptions();
        } catch (InvocationTargetException e) {
            Throwable targetException = e.getTargetException();
            if (targetException instanceof OutOfMemoryError || targetException instanceof StackOverflowError) {
                limits.setMaxMemory();
                limits.halt(Reply.ML);
            } else if (targetException instanceof SecurityException || targetException.getCause() instanceof SecurityException) {
                Reply exit = Utils.ReplyExitVM(targetException.getMessage());
                if (exit != null) {
                    if (exit == Reply.OK) {
                        limits.updateConsumptions();
                    }
                    limits.halt(exit);
                }
                limits.halt(Reply.RF);
            } else {
                limits.halt(Reply.RT);
            }
        } catch (IllegalAccessException | IllegalArgumentException e) {
            limits.halt(Reply.RT);
        }
    }
}
