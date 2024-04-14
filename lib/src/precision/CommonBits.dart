/*
 * Copyright (c) 2016 Vivid Solutions.
 *
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License 2.0
 * and Eclipse Distribution License v. 1.0 which accompanies this distribution.
 * The Eclipse Public License is available at http://www.eclipse.org/legal/epl-v20.html
 * and the Eclipse Distribution License is available at
 *
 * http://www.eclipse.org/org/documents/edl-v10.php.
 */

import 'dart:ffi';

/// TODO: @ruier edit.
/// geos 库中直接将 Double.doubleToLongBits 当作 int64_t 或者double 用,参考，但不知道对不对。
/// ```java
///   double a = 0.0022001;
///   double b = 0.0022;
///   System.out.println("a:" + Double.doubleToLongBits(a)); // 4567219507730883496
///   System.out.println("b:" + Double.doubleToLongBits(b)); // 4567219277146582575
/// ```
///
/// Determines the maximum number of common most-significant
/// bits in the mantissa of one or numbers.
/// Can be used to compute the double-precision number which
/// is represented by the common bits.
/// If there are no common bits, the number computed is 0.0.
///
/// @version 1.7
class CommonBits {
  /// Computes the bit pattern for the sign and exponent of a
  /// double-precision number.
  ///
  /// @param num
  /// @return the bit pattern for the sign and exponent
  static int signExpBits(int num) {
    return num >> 52;
  }

  /// This computes the number of common most-significant bits in the mantissas
  /// of two double-precision numbers.
  /// It does not count the hidden bit, which is always 1.
  /// It does not determine whether the numbers have the same exponent - if they do
  /// not, the value computed by this function is meaningless.
  ///
  /// @param [num1] the first number
  /// @param [num2] the second number
  /// @return the number of common most-significant mantissa bits
  static int numCommonMostSigMantissaBits(int num1, int num2) {
    int count = 0;
    for (int i = 52; i >= 0; i--) {
      if (getBit(num1, i) != getBit(num2, i)) {
        return count;
      }
      count++;
    }
    return 52;
  }

  /// Zeroes the lower n bits of a bitstring.
  ///
  /// @param bits the bitstring to alter
  /// @return the zeroed bitstring
  static int zeroLowerBits(int bits, int nBits) {
    /// TODO: @ruier edit.
    int invMask = (1 << nBits) - 1;
    int mask = ~invMask;
    int zeroed = bits & mask;
    return zeroed;
  }

  /// Extracts the i'th bit of a bitstring.
  ///
  /// @param bits the bitstring to extract from
  /// @param i the bit to extract
  /// @return the value of the extracted bit
  static int getBit(int bits, int i) {
    int mask = (1 << i);
    return (bits & mask) != 0 ? 1 : 0;
  }

  /**private */ bool isFirst = true;
  /**private */ int commonMantissaBitsCount = 53;
  /**private */ int commonBits = 0;
  /**private */ int commonSignExp = 0;

  // CommonBits() {
  // }

  void add(double num) {
    /// TODO: @ruier edit.
    // int numBits = Double.doubleToLongBits(num);
    int numBits = num.toInt();
    if (isFirst) {
      commonBits = numBits;
      commonSignExp = signExpBits(commonBits);
      isFirst = false;
      return;
    }

    int numSignExp = signExpBits(numBits);
    if (numSignExp != commonSignExp) {
      commonBits = 0;
      return;
    }

//    System.out.println(toString(commonBits));
//    System.out.println(toString(numBits));
    commonMantissaBitsCount = numCommonMostSigMantissaBits(commonBits, numBits);
    commonBits = zeroLowerBits(commonBits, 64 - (12 + commonMantissaBitsCount));
//    System.out.println(toString(commonBits));
  }

  double getCommon() {
    // return Double.longBitsToDouble(commonBits);
    return commonBits.toDouble();
  }

  /// A representation of the Double bits formatted for easy readability
  /// TODO: @ruier edit.稍后实现。
  // String toString(int bits)
  // {
  //   double x = Double.longBitsToDouble(bits);
  //   String numStr = Long.toBinaryString(bits);
  //   String padStr = "0000000000000000000000000000000000000000000000000000000000000000" + numStr;
  //   String bitStr = padStr.substring(padStr.length - 64);
  //   String str = bitStr.substring(0, 1) + "  "
  //       + bitStr.substring(1, 12) + "(exp) "
  //       + bitStr.substring(12)
  //       + " [ $x ]";
  //   return str;
  // }
}
