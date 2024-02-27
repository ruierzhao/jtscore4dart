import "dart:math" as Math;


// import "package:jtscore4dart/src/algorithm/Angle.dart";
import "package:jtscore4dart/src/geom/Coordinate.dart";


class TestAngle {
  // LINESTRING (560 380, 800 500)
  // LINESTRING (560 380, 680 200)
  static Coordinate p0 = Coordinate(560, 380);
  static Coordinate p1 = Coordinate(800, 500);
  static Coordinate p2 = Coordinate(680, 200);
  // LINESTRING (560 380, 830 380) 水平线
  static Coordinate p3 = Coordinate(830, 380);
  
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
    static double angleBetween(Coordinate tip1, Coordinate tail,
			Coordinate tip2) {
		double a1 = angle(tail, tip1);
		double a2 = angle(tail, tip2);

		return diff(a1, a2);
  }
  static double angleBetweenOriented(Coordinate tip1, Coordinate tail,
			Coordinate tip2) 
  {
		double a1 = angle(tail, tip1);
		double a2 = angle(tail, tip2);
		double angDel = a2 - a1;
		
		// normalize, maintaining orientation
		if (angDel <= -Math.pi)
			return angDel + PI_TIMES_2;
		if (angDel > Math.pi)
			return angDel - PI_TIMES_2;
		return angDel;
  }
  
  static double diff(double ang1, double ang2) {
    double delAngle;

    if (ang1 < ang2) {
      delAngle = ang2 - ang1;
    } else {
      delAngle = ang1 - ang2;
    }

    if (delAngle > Math.pi) {
      delAngle = PI_TIMES_2 - delAngle;
    }

    return delAngle;
  }
  static const double PI_TIMES_2 = 2.0 * Math.pi;
    static double sinSnap(double ang) {
    double res = Math.sin(ang);
    if (res.abs() < 5e-16) return 0.0;
    return res;
  }

  static double cosSnap(double ang) {
    double res = Math.cos(ang);
    if (res.abs() < 5e-16) return 0.0;
    return res;
  }
  static Coordinate project(Coordinate p, double angle, double dist) {
    double x = p.getX() + dist * cosSnap(angle);
    double y = p.getY() + dist * sinSnap(angle);
    return new Coordinate(x, y);
  }


// ==========================test===========================
  static void test_angle() {
    var c1 = TestAngle.angle(p1, p0);
    print('==============${c1}====================='); //0.4636476090008061
    var cc = TestAngle.angle(p0, p1);
    print('==============$cc====================='); //0.4636476090008061
    var ccd = TestAngle.angle(p0, p2);
    print('==============$ccd====================='); //-0.982793723247329
  }

  static void test_isAcute() {
    var cc = TestAngle.isAcute(p0, p1,p2);
    print('==============$cc====================='); // true
  }
  static void test_project() {
    var cc = TestAngle.project(p0, 1.5, 50);
    print('==============$cc====================='); // true
  }
  static void test_angleBetween(){
    var cc = angleBetween(p1, p0, p2);
    print(cc);
    var ccc = angleBetweenOriented(p1, p0, p2);
    print(ccc);
  }

}

void main() {
  // TestAngle.test_angle(); 
  // TestAngle.test_isAcute();
  // TestAngle.test_angleBetween();
  // TestAngle.test_project();
  var cc = TestAngle.angle(Coordinate(560, 380), Coordinate(563.5368600833851 , 429.87474933020275));
  print(cc);
}
