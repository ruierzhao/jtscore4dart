import 'package:jtscore4dart/io.dart';
import 'package:jtscore4dart/src/geom/Geometry.dart';
import 'package:jtscore4dart/src/operation/union/UnaryUnionOp.dart';
test1(){
  String wktstr = "GEOMETRYCOLLECTION (POLYGON ((247.3 174, 253.3 177.3, 258 174.9, 258.4 170.8, 253.6 167.6, 248.4 170.4, 247.3 174)), POLYGON ((240.5 175.1, 242.8 177.3, 245.4 176.5, 244 171.2, 240.5 175.1)))";
  WKTReader reader = WKTReader();
  WKTWriter writer = WKTWriter();
  Geometry g = reader.read(wktstr)!;
  Geometry newg = g.union();
  print('>>>>>>>>> ${ writer.write(newg) } <<<<<<<<<<<<<<<<<<<<');
}
test2(){
  String wktstr = "GEOMETRYCOLLECTION (POLYGON ((247.3 174, 253.3 177.3, 258 174.9, 258.4 170.8, 253.6 167.6, 248.4 170.4, 247.3 174)), POLYGON ((240.5 175.1, 242.8 177.3, 245.4 176.5, 244 171.2, 240.5 175.1)))";
  WKTReader reader = WKTReader();
  WKTWriter writer = WKTWriter();
  Geometry g = reader.read(wktstr)!;
  Geometry newg = UnaryUnionOp.union(g);
  print('>>>>>>>>> ${ writer.write(newg) } <<<<<<<<<<<<<<<<<<<<');
}

void main() {
  test2();
}
