
public class Utils {

    public static Reply ReplyExitVM(String message) {
        if (message!=null && message.contains("(\"java.lang.RuntimePermission\" \"exitVM.")) {
            message = message.replaceAll("[^-?0-9]+", "");
            return (message.length() > 0 && Integer.parseInt(message) == 0) ? Reply.OK : Reply.AT;
        }
        return null;
    }
}
