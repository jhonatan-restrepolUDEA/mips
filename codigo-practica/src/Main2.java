public class Main2 {
    static int x, y;
    public static void main(String[] args) {
        x = 7;
        y = func1(x) + 4 * x;
        System.out.println(x + "----" + y);
    }

    private static int func1(int x) {
        int a = func2(x);
        return a*2;
    }

    private static int func2(int x) {
        return 257*y;
    }
}
