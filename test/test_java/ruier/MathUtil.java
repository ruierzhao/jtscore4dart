package ruier;

class MathUtil {
    public static int ceil(int num, int denom) {
        int div = num / denom;
        return div * denom >= num ? div : div + 1;
    }

    public static void D2I() {
        double cc = 15.87;
        int cci = (int) cc;
        double cc2 = 15.35;
        int cci2 = (int) cc2;
        System.out.println(cci);
        System.out.println(cci2);
    }

    public static void main(String[] args) {
        D2I();
    }

}
