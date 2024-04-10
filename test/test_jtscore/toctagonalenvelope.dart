import 'package:jtscore4dart/io.dart';
import 'package:jtscore4dart/src/geom/Geometry.dart';
import 'package:jtscore4dart/src/geom/OctagonalEnvelope.dart';
import 'package:jtscore4dart/src/geom/Polygon.dart';

void test_octagonalenvelope(){
  String wktstr = "POLYGON ((100 100, 200 200, 160 240, 100 100))";
  var reader = WKTReader();
  var writer = WKTWriter();
  Geometry? g = reader.read(wktstr);
  print('>>>>>>>>> ${ g is Geometry } <<<<<<<<<<<<<<<<<<<<');
  var newg = OctagonalEnvelope.of(g!);
  print('>>>>>>>>> ${ writer.write(newg) } <<<<<<<<<<<<<<<<<<<<');
}
void test_octagonalenvelope2(){
  String wktstr = "POLYGON ((107 187, 121 196, 177 188, 188 160, 165 128, 138 114, 94 135, 42 159, 107 187))";
  var reader = WKTReader();
  var writer = WKTWriter();
  Geometry? g = reader.read(wktstr);
  print('>>>>>>>>> ${ g is Geometry } <<<<<<<<<<<<<<<<<<<<');
  var newg = OctagonalEnvelope.of(g!);
  print('>>>>>>>>> ${ writer.write(newg) } <<<<<<<<<<<<<<<<<<<<');
}
void test_octagonalenvelope3(){
  String wktstr = "POLYGON ((202 183, 208 190, 221 187, 225 179, 222 172, 215 172, 202 183))";
  var reader = WKTReader();
  var writer = WKTWriter();
  Geometry? g = reader.read(wktstr);
  print('>>>>>>>>> ${ g is Geometry } <<<<<<<<<<<<<<<<<<<<');
  var newg = OctagonalEnvelope.of(g!);
  print('>>>>>>>>> ${ writer.write(newg) } <<<<<<<<<<<<<<<<<<<<');
}
void test_octagonalenvelope4(){
  String wktstr = "POLYGON ((257 183, 266 192, 279 187, 280 170, 273 161, 259 169, 257 183))";
  var reader = WKTReader();
  var writer = WKTWriter();
  Geometry? g = reader.read(wktstr);
  print('>>>>>>>>> ${ g is Geometry } <<<<<<<<<<<<<<<<<<<<');
  var newg = OctagonalEnvelope.of(g!);
  print('>>>>>>>>> ${ writer.write(newg) } <<<<<<<<<<<<<<<<<<<<');
}
void test_octagonalenvelope11(){
  String wktstr = "LINESTRING (236.05 169.45, 244.55 183.35, 258.8 183.2)";
  var reader = WKTReader();
  var writer = WKTWriter();
  Geometry? g = reader.read(wktstr);
  print('>>>>>>>>> ${ g is Geometry } <<<<<<<<<<<<<<<<<<<<');
  var newg = OctagonalEnvelope.of(g!);
  print('>>>>>>>>> ${ writer.write(newg) } <<<<<<<<<<<<<<<<<<<<');
}
void test_octagonalenvelope22(){
  String wktstr = "LINESTRING (272.5 168.35, 284.25 174.45)";
  var reader = WKTReader();
  var writer = WKTWriter();
  Geometry? g = reader.read(wktstr);
  print('>>>>>>>>> ${ g is Geometry } <<<<<<<<<<<<<<<<<<<<');
  var newg = OctagonalEnvelope.of(g!);
  print('>>>>>>>>> ${ writer.write(newg) } <<<<<<<<<<<<<<<<<<<<');
}

void main() {
  // test_octagonalenvelope2();
  // test_octagonalenvelope3();
  // test_octagonalenvelope4();
  // print('>>>>>>>>> ${ Polygon is Geometry } <<<<<<<<<<<<<<<<<<<<');
  test_octagonalenvelope11();
  test_octagonalenvelope22();
}

