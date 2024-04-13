// https://zhuanlan.zhihu.com/p/356991916
// https://juejin.cn/post/7107609505155776520

import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';


/// TODO: @ruier edit.需要完善。。。
class OrdinateFormat
{
  //  static final _ = initializeDateFormatting();
 /**private */
 static const String DECIMAL_PATTERN = "0";

  /// The output representation of {@link Double#POSITIVE_INFINITY}
  static const String REP_POS_INF = "Inf";

  /// The output representation of {@link Double#NEGATIVE_INFINITY}
  static const String REP_NEG_INF = "-Inf";

  /// The output representation of {@link Double#NaN}
  static const String REP_NAN = "NaN";

  /// The maximum number of fraction digits to support output of reasonable ordinate values.
  /// 
  /// The default is chosen to allow representing the smallest possible IEEE-754 double-precision value,
  /// although this is not expected to occur (and is not supported by other areas of the JTS code).
  static const int MAX_FRACTION_DIGITS = 325;
  
  /// The default formatter using the maximum number of digits in the fraction portion of a number.
  static OrdinateFormat DEFAULT = new OrdinateFormat();

  /// Creates a new formatter with the given maximum number of digits in the fraction portion of a number.
  /// 
  /// @param maximumFractionDigits the maximum number of fraction digits to output
  /// @return a formatter
  static OrdinateFormat create(int maximumFractionDigits) {
    return new OrdinateFormat(maximumFractionDigits);
  }
  
 /**private */ NumberFormat _format;

  /// Creates an OrdinateFormat using the default maximum number of fraction digits.
  // OrdinateFormat() {
  //   format = createFormat(MAX_FRACTION_DIGITS);
  // }

  /// Creates an OrdinateFormat using the given maximum number of fraction digits.
  /// 
  /// @param maximumFractionDigits the maximum number of fraction digits to output
  OrdinateFormat([int maximumFractionDigits=MAX_FRACTION_DIGITS]):
    _format = createFormat(maximumFractionDigits);


 /**private */
 static NumberFormat createFormat(int maximumFractionDigits) {
    // NumberFormat format;
    // format.applyPattern(DECIMAL_PATTERN);
    // format.setMaximumFractionDigits(maximumFractionDigits);
    // return format;

    // String fmtString =
    //   "0" + (maximumFractionDigits > 0 ? "." : "") + _stringOfChar('#', maximumFractionDigits);
  return NumberFormat();
  }
  
  /// Returns a string representation of the given ordinate numeric value.
  /// 
  /// @param ord the ordinate value
  /// @return the formatted number string
  /**synchronized */ String format(double ord)
  {
    /**
     * FUTURE: If it seems better to use scientific notation 
     * for very large/small numbers then this can be done here.
     */
    
    if ((ord).isNaN) return REP_NAN;
    if (ord.isInfinite) {
      // TODO:Infinite cmp。
      return ord > 0 ? REP_POS_INF : REP_NEG_INF;
    }
    return _format.format(ord);
  }

}
