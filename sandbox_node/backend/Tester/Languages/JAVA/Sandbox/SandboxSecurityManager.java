
import java.security.Permission;
import java.util.PropertyPermission;
import java.io.FilePermission;
import java.net.NetPermission;
import java.lang.reflect.ReflectPermission;

public class SandboxSecurityManager extends SecurityManager {

    private Thread targetThread;

    public SandboxSecurityManager(Thread targetThread) {
        super();
        this.targetThread = targetThread;
    }

    public void deleteSecurity() {
        targetThread = null;
    }

    @Override
    public void checkPermission(Permission perm) {
        this.internalCheckPermision(perm);
    }

    @Override
    public void checkPermission(Permission perm, Object context) {
        this.internalCheckPermision(perm);
    }

    private void internalCheckPermision(Permission perm) {
        if (Thread.currentThread() == targetThread) {
            String name = perm.getName();
            if (perm instanceof PropertyPermission) {
                if (perm.getActions().equals("read")) {
                    return;
                }
            } else if (perm instanceof FilePermission) {
                if (perm.getActions().equals("read") && name.length() > 1 && name.charAt(0) != '.') {
                    return;
                }
            } else if (perm instanceof NetPermission) {
                if (name.equals("specifyStreamHandler")) {
                    return;
                }
            } else if (perm instanceof RuntimePermission) {
                if (name.equals("createClassLoader") || name.equals("accessClassInPackage.sun.util.resources") || 
			name.equals("accessClassInPackage.sun.text.resources.es")) {
                    return;
                }
            } else if (perm instanceof ReflectPermission) {
                if (name.equals("suppressAccessChecks")) {
                    return;
                }
            }
	    throw new SecurityException(perm.toString());
        }
    }
}
