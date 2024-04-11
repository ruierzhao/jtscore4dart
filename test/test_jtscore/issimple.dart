import 'package:jtscore4dart/src/operation/valid/IsSimpleOp.dart';
import 'package:jtscore4dart/io.dart';
import 'package:jtscore4dart/src/geom/Geometry.dart';

test1(){
  String wktstr = "";
  WKTReader reader = WKTReader();
  WKTWriter writer = WKTWriter();
  Geometry g = reader.read(wktstr)!;
  bool newg = IsSimpleOp.of(g);
  print('>>>>>>>>> ${ newg } <<<<<<<<<<<<<<<<<<<<');
}

void main() {
  test1();
}
