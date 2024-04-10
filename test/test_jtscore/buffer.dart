import 'package:jtscore4dart/src/geom/Coordinate.dart';
import 'package:jtscore4dart/src/geom/GeometryFactory.dart';
import 'package:jtscore4dart/src/geom/Point.dart';
import 'package:jtscore4dart/src/operation/buffer/BufferOp.dart';

void main() {
  var gf = GeometryFactory();
  Point p = gf.createPoint(Coordinate(13, 30));
  var g = BufferOp.bufferOp(p, 5);
  print(g.getCoordinates());
}