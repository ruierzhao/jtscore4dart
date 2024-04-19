import "dart:math" as Math;

import "package:jtscore4dart/src/algorithm/Angle.dart";
import "package:jtscore4dart/src/geom/Coordinate.dart";
import "package:jtscore4dart/src/geom/CoordinateSequenceFactory.dart";
import "package:jtscore4dart/src/geom/GeometryFactory.dart";
import "package:jtscore4dart/src/shape/random/RandomPointsBuilder.dart";

/**
 * @version 1.7
 */
class AngleTest {

 /**private */static final double TOLERANCE = 1E-5;
  
  AngleTest(String name);
  assertEquals(dynamic a, dynamic b,[num tol=0]){
    print('>>>>>>>>> $a == $b: ${ a == b } <<<<<<<<<<<<<<<<<<<<');
  }
  assertTrue(dynamic a){
    if (a) {
      print('>>>>>>>>> $a <<<<<<<<<<<<<<<<<<<<');
    }else{
      print("fail");
    }
  }

  void testAngle()
  {
		assertEquals(Angle.angleTozero(p(10,0)), 0.0, TOLERANCE);
		assertEquals(Angle.angleTozero(p(10,10)), Math.pi/4, TOLERANCE);
		assertEquals(Angle.angleTozero(p(0,10)), Math.pi/2, TOLERANCE);
		assertEquals(Angle.angleTozero(p(-10,10)), 0.75*Math.pi, TOLERANCE);
		assertEquals(Angle.angleTozero(p(-10,0)), Math.pi, TOLERANCE);
		assertEquals(Angle.angleTozero(p(-10,-0.1)), -3.131592986903128, TOLERANCE);
		assertEquals(Angle.angleTozero(p(-10,-10)), -0.75*Math.pi, TOLERANCE);
  }
  
  void testIsAcute()
  {
  	assertEquals(Angle.isAcute(p(10,0), p(0,0), p(5,10)), true);
  	assertEquals(Angle.isAcute(p(10,0), p(0,0), p(5,-10)), true);
  	// angle of 0
  	assertEquals(Angle.isAcute(p(10,0), p(0,0), p(10,0)), true);
  	
  	assertEquals(Angle.isAcute(p(10,0), p(0,0), p(-5,10)), false);
  	assertEquals(Angle.isAcute(p(10,0), p(0,0), p(-5,-10)), false);
  }
  
  void testNormalizePositive()
  {
		assertEquals(Angle.normalizePositive(0.0), 0.0, TOLERANCE);
		
		assertEquals(Angle.normalizePositive(-0.5*Math.pi), 1.5*Math.pi, TOLERANCE);
		assertEquals(Angle.normalizePositive(-Math.pi), Math.pi, TOLERANCE);
		assertEquals(Angle.normalizePositive(-1.5*Math.pi), .5*Math.pi, TOLERANCE);
		assertEquals(Angle.normalizePositive(-2*Math.pi), 0.0, TOLERANCE);
		assertEquals(Angle.normalizePositive(-2.5*Math.pi), 1.5*Math.pi, TOLERANCE);
		assertEquals(Angle.normalizePositive(-3*Math.pi), Math.pi, TOLERANCE);	
		assertEquals(Angle.normalizePositive(-4 * Math.pi), 0.0, TOLERANCE);
		
		assertEquals(Angle.normalizePositive(0.5*Math.pi), 0.5*Math.pi, TOLERANCE);
		assertEquals(Angle.normalizePositive(Math.pi), Math.pi, TOLERANCE);
		assertEquals(Angle.normalizePositive(1.5*Math.pi), 1.5*Math.pi, TOLERANCE);
		assertEquals(Angle.normalizePositive(2*Math.pi), 0.0, TOLERANCE);
		assertEquals(Angle.normalizePositive(2.5*Math.pi), 0.5*Math.pi, TOLERANCE);
		assertEquals(Angle.normalizePositive(3*Math.pi), Math.pi, TOLERANCE);	
		assertEquals(Angle.normalizePositive(4 * Math.pi), 0.0, TOLERANCE);
  }

  void testNormalize()
  {
		assertEquals(Angle.normalize(0.0), 0.0, TOLERANCE);
		
		assertEquals(Angle.normalize(-0.5*Math.pi), -0.5*Math.pi, TOLERANCE);
		assertEquals(Angle.normalize(-Math.pi), Math.pi, TOLERANCE);
		assertEquals(Angle.normalize(-1.5*Math.pi), .5*Math.pi, TOLERANCE);
		assertEquals(Angle.normalize(-2*Math.pi), 0.0, TOLERANCE);
		assertEquals(Angle.normalize(-2.5*Math.pi), -0.5*Math.pi, TOLERANCE);
		assertEquals(Angle.normalize(-3*Math.pi), Math.pi, TOLERANCE);	
		assertEquals(Angle.normalize(-4 * Math.pi), 0.0, TOLERANCE);
		
		assertEquals(Angle.normalize(0.5*Math.pi), 0.5*Math.pi, TOLERANCE);
		assertEquals(Angle.normalize(Math.pi), Math.pi, TOLERANCE);
		assertEquals(Angle.normalize(1.5*Math.pi), -0.5*Math.pi, TOLERANCE);
		assertEquals(Angle.normalize(2*Math.pi), 0.0, TOLERANCE);
		assertEquals(Angle.normalize(2.5*Math.pi), 0.5*Math.pi, TOLERANCE);
		assertEquals(Angle.normalize(3*Math.pi), Math.pi, TOLERANCE);	
		assertEquals(Angle.normalize(4 * Math.pi), 0.0, TOLERANCE);
  }

  void testInteriorAngle() {
		Coordinate p1 = p(1, 2);
		Coordinate p2 = p(3, 2);
		Coordinate p3 = p(2, 1);

		// Tests all interior angles of a triangle "POLYGON ((1 2, 3 2, 2 1, 1 2))"
		// assertEquals(45, Math.toDegrees(Angle.interiorAngle(p1, p2, p3)), 0.01);
		// assertEquals(90, Math.toDegrees(Angle.interiorAngle(p2, p3, p1)), 0.01);
		// assertEquals(45, Math.toDegrees(Angle.interiorAngle(p3, p1, p2)), 0.01);
		// // Tests interior angles greater than 180 degrees
		// assertEquals(315, Math.toDegrees(Angle.interiorAngle(p3, p2, p1)), 0.01);
		// assertEquals(270, Math.toDegrees(Angle.interiorAngle(p1, p3, p2)), 0.01);
		// assertEquals(315, Math.toDegrees(Angle.interiorAngle(p2, p1, p3)), 0.01);
  }

  /**
   * Tests interior angle calculation using a number of random triangles
   */
  // void testInteriorAngle_randomTriangles() {
	// 	GeometryFactory geometryFactory = new GeometryFactory();
	// 	CoordinateSequenceFactory coordinateSequenceFactory = geometryFactory.getCoordinateSequenceFactory();
	// 	for (int i = 0; i < 100; i++){
	// 		RandomPointsBuilder builder = new RandomPointsBuilder();
	// 		builder.setNumPoints(3);
	// 		Geometry threeRandomPoints = builder.getGeometry();
	// 		Polygon triangle = geometryFactory.createPolygon(
	// 				CoordinateSequences.ensureValidRing(
	// 						coordinateSequenceFactory,
	// 						coordinateSequenceFactory.create(threeRandomPoints.getCoordinates())
	// 				)
	// 		);
	// 		// Triangle coordinates in clockwise order
	// 		Coordinate[] c = Orientation.isCCW(triangle.getCoordinates())
	// 				? triangle.reverse().getCoordinates()
	// 				: triangle.getCoordinates();
	// 		double sumOfInteriorAngles = Angle.interiorAngle(c[0], c[1], c[2])
	// 				+ Angle.interiorAngle(c[1], c[2], c[0])
	// 				+ Angle.interiorAngle(c[2], c[0], c[1]);
	// 		assertEquals(
	// 				i + ": The sum of the angles of a triangle is not equal to two right angles for points: " + Arrays.toString(c),
	// 				Math.pi,
	// 				sumOfInteriorAngles,
	// 				0.01
	// 		);
	// 	}
  // }
  
  // void testAngleBisector() {
  //   assertEquals(45,    Math.toDegrees( Angle.bisector(p(0,1), p(0,0), p(1,0))), 0.01);
  //   assertEquals(22.5,  Math.toDegrees( Angle.bisector(p(1,1), p(0,0), p(1,0))), 0.01);
  //   assertEquals(67.5,    Math.toDegrees( Angle.bisector(p(-1,1), p(0,0), p(1,0))), 0.01);
  //   assertEquals(-45,   Math.toDegrees( Angle.bisector(p(0,-1), p(0,0), p(1,0))), 0.01);
  //   assertEquals(180,    Math.toDegrees( Angle.bisector(p(-1,-1), p(0,0), p(-1,1))), 0.01);
    
  //   assertEquals(45, Math.toDegrees(Angle.bisector(p(13,10), p(10,10), p(10,20))), 0.01);
  // }

  void testSinCosSnap() {

    // -720 to 720 degrees with 1 degree increments
    for (int angdeg = -720; angdeg <= 720; angdeg++) {
      double ang = Angle.toRadians(angdeg.toDouble());

      double rSin = Angle.sinSnap(ang);
      double rCos = Angle.cosSnap(ang);

      double cSin = Math.sin(ang);
      double cCos = Math.cos(ang);
      if ( (angdeg % 90) == 0 ) {
        // not always the same for multiples of 90 degrees
        assertTrue((rSin - cSin).abs() < 1e-15);
        assertTrue((rCos - cCos).abs() < 1e-15);
      } else {
        assertEquals(rSin, cSin);
        assertEquals(rCos, cCos);
      }

    }

    // use radian increments that don't snap to exact degrees or zero
    for (double angrad = -6.3; angrad < 6.3; angrad += 0.013) {

      double rSin = Angle.sinSnap(angrad);
      double rCos = Angle.cosSnap(angrad);

      assertEquals(rSin, Math.sin(angrad));
      assertEquals(rCos, Math.cos(angrad));

    }
  }

 /**private */static Coordinate p(double x, double y) {
    return new Coordinate(x, y);
  }
}


void main() {
  AngleTest
}
