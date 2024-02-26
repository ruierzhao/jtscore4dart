import "dart:math" as Math;


import "package:jtscore4dart/src/geom/Coordinate.dart";


class TestAngle {
  // LINESTRING (560 380, 800 500)
  // LINESTRING (560 380, 680 200)
  static Coordinate p0 = Coordinate(560, 380);
  static Coordinate p1 = Coordinate(800, 500);
  static Coordinate p2 = Coordinate(680, 200);
  
  static double angle(Coordinate p0, Coordinate p1) {
      double dx = p1.x - p0.x;
      double dy = p1.y - p0.y;
      return Math.atan2(dy, dx);
  }
  static bool isAcute(Coordinate p0, Coordinate p1, Coordinate p2)
  {
    // relies on fact that A dot B is positive if A ang B is acute
    double dx0 = p0.x - p1.x;
    double dy0 = p0.y - p1.y;
    double dx1 = p2.x - p1.x;
    double dy1 = p2.y - p1.y;
    double dotprod = dx0 * dx1 + dy0 * dy1;
    return dotprod > 0;
  }

// ==========================test===========================
  static void test_angle() {
    var c1 = TestAngle.angle(p1, p0);
    print('==============$c1====================='); //0.4636476090008061
    var cc = TestAngle.angle(p0, p1);
    print('==============$cc====================='); //0.4636476090008061
    var ccd = TestAngle.angle(p0, p2);
    print('==============$ccd====================='); //-0.982793723247329
  }

  static void test_isAcute() {
    var cc = TestAngle.isAcute(p0, p1,p2);
    print('==============$cc====================='); // true
  }

}

void main() {
  TestAngle.test_angle(); 
  // TestAngle.test_isAcute();
}
