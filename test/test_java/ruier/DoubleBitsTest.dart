
// dart ruier/DoubleBitsTest.dart

main() {
    int bits = 2023 << 52;
    print(bits); // 91 1078 2046 17051 3408

    var cc = BigInt.from(2023);
    var ccc = cc<<55; // 72886256369364107264
    print(ccc);
  }
