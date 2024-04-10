// import 'package:jtscore4dart/geometry.dart';
import 'package:jtscore4dart/io.dart';
// import 'package:dart_jts/dart_jts.dart';
void main() {
  String point = "POINT (24 103)";
  var reader = WKTReader();
  var gpoint = reader.read(point);
  print(gpoint!.getCoordinates());
}