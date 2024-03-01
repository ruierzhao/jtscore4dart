// javac ruier/DoubleBitsTest.java
// java ruier.DoubleBitsTest

package ruier;



public class DoubleBitsTest {

    public static void main(String args[]) {
            int bits = 2023 << 52;
    System.out.println(Double.longBitsToDouble(bits)); // 1.048046261E-314
    }
}
