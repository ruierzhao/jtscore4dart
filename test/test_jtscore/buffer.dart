import 'package:jtscore4dart/io.dart';
import 'package:jtscore4dart/src/geom/Coordinate.dart';
import 'package:jtscore4dart/src/geom/GeometryFactory.dart';
import 'package:jtscore4dart/src/geom/Point.dart';
import 'package:jtscore4dart/src/operation/buffer/BufferOp.dart';

void test_buffer0() {
  var gf = GeometryFactory();
  Point p = gf.createPoint(Coordinate(13, 30));
  var g = BufferOp.bufferOp(p, 5);
  print(g.getCoordinates());
  print(g.getCoordinates());
}

/// test pass
test_buffer1(){
  String polygonwkt = "POLYGON ((380 280, 500 420, 650 460, 710 300, 530 230, 380 280))";
  var reader = WKTReader();
  var writer = WKTWriter();
  var cc = reader.read(polygonwkt);
  // print('>>>>>>>>> ${ cc } <<<<<<<<<<<<<<<<<<<<');
  var vv = cc!.buffer(10);
  // print('>>>>>>>>> ${ writer.write(vv) } <<<<<<<<<<<<<<<<<<<<');
  
}

void main() {
  test_buffer1();
}
