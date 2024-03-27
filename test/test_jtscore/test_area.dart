
import 'package:jtscore4dart/src/algorithm/Area.dart';
import 'package:jtscore4dart/src/geom/Coordinate.dart';

void test1() {
  var ring = [
    Coordinate(0.0, 0.0),
    Coordinate(10.0, 0.0),
    Coordinate(10.0, 10.0),
    Coordinate(0.0, 10.0),
    Coordinate(0.0, 0.0),
  ];
  var cc = Area.ofRingSigned(ring);
  print('==============${cc}=====================');
   cc = Area.ofRing(ring);
  print('==============${cc}=====================');
}
void test2() {
  var ring = [
    Coordinate(0.0, 0.0),
    Coordinate(0.0, 10.0),
    Coordinate(10.0, 10.0),
    Coordinate(10.0, 0.0),
  ];
  var cc = Area.ofRingSigned(ring);
  print('==============${cc}=====================');
   cc = Area.ofRing(ring);
  print('==============${cc}=====================');
}

void main() {
  test1();
  test2();
}
