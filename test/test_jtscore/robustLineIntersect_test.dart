import 'package:jtscore4dart/src/algorithm/LineIntersector.dart';
import 'package:jtscore4dart/src/algorithm/Orientation.dart';
import 'package:jtscore4dart/src/algorithm/PointLocation.dart';
import 'package:jtscore4dart/src/algorithm/RobustLineIntersector.dart';
import 'package:jtscore4dart/src/geom/Coordinate.dart';
import 'package:jtscore4dart/src/geom/GeometryFactory.dart';
import 'package:jtscore4dart/src/geom/LineString.dart';
import 'package:jtscore4dart/src/geom/Point.dart';

import 'test.dart';

RobustLineIntersector i = new RobustLineIntersector();
void test2Lines() {
  Coordinate p1 = new Coordinate(10, 10);
  Coordinate p2 = new Coordinate(20, 20);
  Coordinate q1 = new Coordinate(20, 10);
  Coordinate q2 = new Coordinate(10, 20);
  Coordinate x = new Coordinate(15, 15);
  i.computeIntersection4Coord(p1, p2, q1, q2);
  assertEquals(LineIntersector.POINT_INTERSECTION, i.getIntersectionNum());
  assertEquals(1, i.getIntersectionNum());
  assertEquals(x, i.getIntersection(0));
  assertTrue(i.isProper);
  assertTrue(i.hasIntersection());
}

void testCollinear1() {
  RobustLineIntersector i = new RobustLineIntersector();
  Coordinate p1 = new Coordinate(10, 10);
  Coordinate p2 = new Coordinate(20, 10);
  Coordinate q1 = new Coordinate(22, 10);
  Coordinate q2 = new Coordinate(30, 10);
  i.computeIntersection4Coord(p1, p2, q1, q2);
  assertEquals(LineIntersector.NO_INTERSECTION, i.getIntersectionNum());
  assertTrue(!i.isProper);
  assertTrue(!i.hasIntersection());
}

void testCollinear2() {
  RobustLineIntersector i = new RobustLineIntersector();
  Coordinate p1 = new Coordinate(10, 10);
  Coordinate p2 = new Coordinate(20, 10);
  Coordinate q1 = new Coordinate(20, 10);
  Coordinate q2 = new Coordinate(30, 10);
  i.computeIntersection4Coord(p1, p2, q1, q2);
  assertEquals(LineIntersector.POINT_INTERSECTION, i.getIntersectionNum());
  assertTrue(!i.isProper);
  assertTrue(i.hasIntersection());
}

void testCollinear3() {
  RobustLineIntersector i = new RobustLineIntersector();
  Coordinate p1 = new Coordinate(10, 10);
  Coordinate p2 = new Coordinate(20, 10);
  Coordinate q1 = new Coordinate(15, 10);
  Coordinate q2 = new Coordinate(30, 10);
  i.computeIntersection4Coord(p1, p2, q1, q2);
  assertEquals(LineIntersector.COLLINEAR_INTERSECTION, i.getIntersectionNum());
  assertTrue(!i.isProper);
  assertTrue(i.hasIntersection());
}

void testCollinear4() {
  RobustLineIntersector i = new RobustLineIntersector();
  Coordinate p1 = new Coordinate(30, 10);
  Coordinate p2 = new Coordinate(20, 10);
  Coordinate q1 = new Coordinate(10, 10);
  Coordinate q2 = new Coordinate(30, 10);
  i.computeIntersection4Coord(p1, p2, q1, q2);
  assertEquals(LineIntersector.COLLINEAR_INTERSECTION, i.getIntersectionNum());
  assertTrue(i.hasIntersection());
}

void testEndpointIntersection() {
  i.computeIntersection4Coord(new Coordinate(100, 100), new Coordinate(10, 100),
      new Coordinate(100, 10), new Coordinate(100, 100));
  assertTrue(i.hasIntersection());
  assertEquals(1, i.getIntersectionNum());
}

void testEndpointIntersection2() {
  i.computeIntersection4Coord(new Coordinate(190, 50), new Coordinate(120, 100),
      new Coordinate(120, 100), new Coordinate(50, 150));
  assertTrue(i.hasIntersection());
  assertEquals(1, i.getIntersectionNum());
  assertEquals(new Coordinate(120, 100), i.getIntersection(1));
}

void testOverlap() {
  i.computeIntersection4Coord(
      new Coordinate(180, 200),
      new Coordinate(160, 180),
      new Coordinate(220, 240),
      new Coordinate(140, 160));
  assertTrue(i.hasIntersection());
  assertEquals(2, i.getIntersectionNum());
}

void testIsProper1() {
  i.computeIntersection4Coord(new Coordinate(30, 10), new Coordinate(30, 30),
      new Coordinate(10, 10), new Coordinate(90, 11));
  assertTrue(i.hasIntersection());
  assertEquals(1, i.getIntersectionNum());
  assertTrue(i.isProper);
}

void testIsProper2() {
  i.computeIntersection4Coord(new Coordinate(10, 30), new Coordinate(10, 0),
      new Coordinate(11, 90), new Coordinate(10, 10));
  assertTrue(i.hasIntersection());
  assertEquals(1, i.getIntersectionNum());
  assertTrue(!i.isProper);
}

void testIsCCW() {
  assertEquals(
      1,
      Orientation.index(new Coordinate(-123456789, -40), new Coordinate(0, 0),
          new Coordinate(381039468754763, 123456789)));
}

void testIsCCW2() {
  assertEquals(
      0,
      Orientation.index(new Coordinate(10, 10), new Coordinate(20, 20),
          new Coordinate(0, 0)));
}

void testA() {
  Coordinate p1 = new Coordinate(-123456789, -40);

  Coordinate p2 = new Coordinate(381039468754763, 123456789);
  Coordinate q = new Coordinate(0, 0);
  LineString l = new GeometryFactory().createLineString([p1, p2]);
  Point p = new GeometryFactory().createPoint(q);
  assertEquals(false, l.intersects(p));
  assertEquals(false, PointLocation.isOnLine(q, [p1, p2]));
  assertEquals(-1, Orientation.index(p1, p2, q));
}

void main() {
  // test2Lines();
  testCollinear1();
  print('>>>>>>>>>  <<<<<<<<<<<<<<<<<<<<');
  testCollinear2();
  print('>>>>>>>>>  <<<<<<<<<<<<<<<<<<<<');
  testCollinear3();
  print('>>>>>>>>>  <<<<<<<<<<<<<<<<<<<<');
  testCollinear4();
}
