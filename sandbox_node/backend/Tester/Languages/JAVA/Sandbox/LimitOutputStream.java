
import java.io.FileDescriptor;
import java.io.FileOutputStream;
import java.io.IOException;

public class LimitOutputStream extends FileOutputStream {

    private final Limits limits;

    public LimitOutputStream(Limits limits) {
        super(FileDescriptor.out);
        this.limits = limits;
    }

    @Override
    public void write(int b) throws IOException {
        if (limits.getOutputRemain() <= 0) {
            return;
        }
        limits.decreseOutputRemain(1);
        super.write(b);
    }

    @Override
    public void write(byte[] b, int off, int len) throws IOException {
        int left = Math.min(len, limits.getOutputRemain());
        if (left <= 0) {
            return;
        }
        limits.decreseOutputRemain(left);
        super.write(b, off, (int) left);
    }
}
