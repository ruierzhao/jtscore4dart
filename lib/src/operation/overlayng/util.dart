//  /**private */String format(double x, double y) {
//     return OrdinateFormat.DEFAULT.format(x) + " " + OrdinateFormat.DEFAULT.format(y);
//   }
import 'package:intl/intl.dart';
import 'package:jtscore4dart/src/geom/Coordinate.dart';
import 'package:jtscore4dart/src/geom/PrecisionModel.dart';

NumberFormat formatter = _createFormatter();

String formatXY(double x, double y) {
  return "${formatter.format(x)} ${formatter.format(y)}";
}
String format(Coordinate coord) {
  return "${formatter.format(coord.x)} ${formatter.format(coord.y)} " ;
}

///  Creates the <code>NumberFormat</code> used to write <code>double</code>s
///  with a sufficient number of decimal places.
///
///@param  [precisionModel]  the <code>PrecisionModel</code> used to determine
///      the number of decimal places to write.
///@return                 a <code>NumberFormat</code> that write <code>double</code>
///      s without scientific notation.
NumberFormat _createFormatter([PrecisionModel? precisionModel]) {
  precisionModel ??= PrecisionModel();
  // the default number of decimal places is 16, which is sufficient
  // to accommodate the maximum precision of a double.
  int decimalPlaces = precisionModel.getMaximumSignificantDigits();
  // specify decimal separator explicitly to avoid problems in other locales
  // NumberFormatSymbols symbols = NumberFormatSymbols();
  // symbols.setDecimalSeparator('.');
  String fmtString =
      "0" + (decimalPlaces > 0 ? "." : "") + _stringOfChar('#', decimalPlaces);
  return NumberFormat(fmtString);
}

String _stringOfChar(String ch, int count) {
  StringBuffer buf = StringBuffer();
  for (int i = 0; i < count; i++) {
    buf.write(ch);
  }
  return buf.toString();
}
