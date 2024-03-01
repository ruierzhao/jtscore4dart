package ruier;

class MathUtil {
    public static int ceil(int num, int denom) {
        int div = num / denom;
        return div * denom >= num ? div : div + 1;
    }

    public static void main(String[] args) {
        System.out.println(ceil(5, 2));
        System.out.println(Math.ceil(5 / 2.0));
        System.out.println("==========================");
        System.out.println(ceil(5995, 34));
        System.out.println(Math.ceil(5995 / 34.0));
    }

}
