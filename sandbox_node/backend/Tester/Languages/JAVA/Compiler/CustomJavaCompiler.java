import java.io.File;
import java.io.IOException;
import javax.tools.FileObject;
import javax.tools.ForwardingJavaFileManager;
import javax.tools.JavaCompiler;
import javax.tools.JavaFileManager;
import javax.tools.JavaFileObject;
import javax.tools.StandardJavaFileManager;
import javax.tools.ToolProvider;
import javax.tools.JavaFileObject.Kind;

public class CustomJavaCompiler {

    private static class CustomJavaFileManager extends ForwardingJavaFileManager<StandardJavaFileManager> {
        public static final int MAX_OUTPUT_FILES = 15;
        private int outputFileCount = 0;

        @Override
        public JavaFileObject getJavaFileForOutput(Location location, String className, Kind kind, FileObject sibling) throws IOException {
            if (++outputFileCount > MAX_OUTPUT_FILES) {
                throw new IOException("Too many output files");
            }
            return super.getJavaFileForOutput(location, className, kind, sibling);
        }

        public CustomJavaFileManager(StandardJavaFileManager fileManager) {
            super(fileManager);
        }
    }

    public static void main(String[] args) {
        if (args.length != 1) {
            System.err.println("Invalid arg length " + args.length);
            System.exit(-1);
        }
        JavaCompiler compiler = ToolProvider.getSystemJavaCompiler();
        StandardJavaFileManager stdFileManager = compiler.getStandardFileManager(null, null, null);
        JavaFileManager fileManager = new CustomJavaFileManager(stdFileManager);

        if(compiler.getTask(null, fileManager, null, null, null, stdFileManager.getJavaFileObjects(args[0])).call()){
            System.exit(0);
        }else{
            System.exit(-1);
        }
    }
};
