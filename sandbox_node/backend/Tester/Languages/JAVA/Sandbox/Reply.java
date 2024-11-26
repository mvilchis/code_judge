
public class Reply {

    private final int id;
    private final String description;
    private final String code;

    public Reply(int id, String description, String code) {
        this.id = id;
        this.description = description;
        this.code = code;
    }

    public int getId() {
        return id;
    }

    public String getDescription() {
        return description;
    }

    public String getCode() {
        return code;
    }

    public final static Reply PD = new Reply(0, "Pending", "PD");
    public final static Reply OK = new Reply(1, "Okay", "OK");
    public final static Reply RF = new Reply(2, "Restricted Function", "RF");
    public final static Reply ML = new Reply(3, "Memory Limit Exceed", "ML");
    public final static Reply OL = new Reply(4, "Output Limit Exceed", "OL");
    public final static Reply TL = new Reply(5, "Time Limit Exceed", "TL");
    public final static Reply RT = new Reply(6, "Run Time Error", "RT");
    public final static Reply AT = new Reply(7, "Abnormal Termination", "AT");
    public final static Reply IE = new Reply(8, "Internal Error", "IE");
    public final static Reply BP = new Reply(9, "Bad Police", "BP");
    public final static Reply CE = new Reply(10, "Compilation Error", "CE");
}
