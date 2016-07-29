public class Cgo {
    public static native int add(int a, int b);

    static class AddAndSubResult {
        int add;
        int sub;
    }

    public static native AddAndSubResult addAndSub(int a, int b);
    public static native void addAndSub(int a, int b, AddAndSubResult result);
    public static native int div(int a, int b) throws ArithmeticException;
    public static native int divPtrs(int a, int b) throws ArithmeticException;
    public static native double sqrt(double x);
    public static native String echo(String s);

    static class Foo {
        String str;
        byte[] arr;
        int num;
    }
    public static native Foo echoFoo(Foo foo) throws Exception;

    interface IntCallback {
        void onValue(int value);
    }
    // Blocking function that will call the handler.onValue for all the values in the stream.
    public static native void streamInts(int x, IntCallback callback);

    interface IntStreamCallbacks {
        void onValue(int value);
        void onDone();
    }
    // Non-blocking equivalent of the function from above.
    public static native void streamInts(int x, IntStreamCallbacks callbacks);

    public static native void addAsync(int a, int b, IntCallback callback);

    static {
        System.loadLibrary("glue");
    }
}
