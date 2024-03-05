/*
 * Copyright (c) 2021 Martin Davis.
 *
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License 2.0
 * and Eclipse Distribution License v. 1.0 which accompanies this distribution.
 * The Eclipse Public License is available at http://www.eclipse.org/legal/epl-v20.html
 * and the Eclipse Distribution License is available at
 *
 * http://www.eclipse.org/org/documents/edl-v10.php.
 */
package org.locationtech.jts.geom.util;

import org.locationtech.jts.geom.Coordinate;
import org.locationtech.jts.geom.CoordinateArrays;
import org.locationtech.jts.geom.Geometry;
import org.locationtech.jts.geom.Point;

import junit.textui.TestRunner;
import org.locationtech.jts.io.WKTReader;
import test.jts.GeometryTestCase;

public class GeometryFixerTest extends GeometryTestCase {

  public static void main(String args[]) {
    TestRunner.run(GeometryFixerTest.class);
  }

	public GeometryFixerTest(String name) {
		super(name);
	}

  public void testPoint() {
    checkFix("POINT (0 0)", "POINT (0 0)");
  }

  public void testPointNaN() {
    checkFix("POINT (0 Nan)", "POINT EMPTY");
  }

  public void testPointEmpty() {
    checkFix("POINT EMPTY", "POINT EMPTY");
  }

  public void testPointPosInf() {
    checkFix( createPoint(0, Double.POSITIVE_INFINITY), "POINT EMPTY");
  }

  public void testPointNegInf() {
    checkFix( createPoint(0, Double.POSITIVE_INFINITY), "POINT EMPTY");
  }

 /**private */Point createPoint(double x, double y) {
    Coordinate p = new Coordinate(x, y);
    Point pt = getGeometryFactory().createPoint(p);
    return pt;
  }

  //----------------------------------------

  public void testMultiPointNaN() {
    checkFix("MULTIPOINT ((0 Nan))",
        "MULTIPOINT EMPTY");
  }

  public void testMultiPoint() {
    checkFix("MULTIPOINT ((0 0), (1 1))",
        "MULTIPOINT ((0 0), (1 1))");
  }

  public void testMultiPointWithEmptyKeepMulti() {
    checkFix("MULTIPOINT ((0 0), EMPTY)",
        "MULTIPOINT ((0 0))", true);
  }

  public void testMultiPointWithEmpty() {
    checkFix("MULTIPOINT ((0 0), EMPTY)",
      "POINT (0 0)", false);
  }
  public void testMultiPointWithMultiEmpty() {
    checkFix("MULTIPOINT (EMPTY, EMPTY)",
        "MULTIPOINT EMPTY");
  }

  //----------------------------------------

  public void testLineStringEmpty() {
    checkFix("LINESTRING EMPTY",
        "LINESTRING EMPTY");
  }

  public void testLineStringCollapse() {
    checkFix("LINESTRING (0 0, 1 NaN, 0 0)",
        "LINESTRING EMPTY");
  }

  public void testLineStringCollapseMultipleRepeated() {
    checkFix("LINESTRING (0 0, 0 0, 0 0)",
        "LINESTRING EMPTY");
  }

  public void testLineStringKeepCollapse() {
    checkFixKeepCollapse("LINESTRING (0 0, 0 0, 0 0)",
        "POINT (0 0)");
  }

  public void testLineStringRepeated() {
    checkFix("LINESTRING (0 0, 0 0, 0 0, 0 0, 0 0, 1 1)",
        "LINESTRING (0 0, 1 1)");
  }

  /**
   * Checks that self-crossing are valid, and that entire geometry is copied
   */
  public void testLineStringSelfCross() {
    checkFix("LINESTRING (0 0, 9 9, 9 5, 0 5)",
        "LINESTRING (0 0, 9 9, 9 5, 0 5)");
  }

  //----------------------------------------

  public void testLinearRingEmpty() {
    checkFix("LINEARRING EMPTY",
        "LINEARRING EMPTY");
  }

  public void testLinearRingCollapsePoint() {
    checkFix("LINEARRING (0 0, 1 NaN, 0 0)",
        "LINEARRING EMPTY");
  }

  public void testLinearRingCollapseLine() {
    checkFix("LINEARRING (0 0, 1 NaN, 1 0, 0 0)",
        "LINEARRING EMPTY");
  }

  public void testLinearRingKeepCollapsePoint() {
    checkFixKeepCollapse("LINEARRING (0 0, 1 NaN, 0 0)",
        "POINT (0 0)");
  }

  public void testLinearRingKeepCollapseLine() {
    checkFixKeepCollapse("LINEARRING (0 0, 1 NaN, 1 0, 0 0)",
        "LINESTRING (0 0, 1 0, 0 0)");
  }

  public void testLinearRingValid() {
    checkFix("LINEARRING (10 10, 10 90, 90 90, 90 10, 10 10)",
        "LINEARRING (10 10, 10 90, 90 90, 90 10, 10 10)");
  }

  public void testLinearRingFlat() {
    checkFix("LINEARRING (10 10, 10 90, 90 90, 10 90, 10 10)",
        "LINESTRING (10 10, 10 90, 90 90, 10 90, 10 10)");
  }

  /**
   * Checks that invalid self-crossing ring is returned as a LineString
   */
  public void testLinearRingSelfCross() {
    checkFix("LINEARRING (10 10, 10 90, 90 10, 90 90, 10 10)",
        "LINESTRING (10 10, 10 90, 90 10, 90 90, 10 10)");
  }

  //----------------------------------------

  /**
   * Self-crossing LineStrings are valid, so are unchanged
   */
  public void testMultiLineStringSelfCross() {
    checkFix("MULTILINESTRING ((10 90, 90 10, 90 90), (90 50, 10 50))",
        "MULTILINESTRING ((10 90, 90 10, 90 90), (90 50, 10 50))");
  }

  public void testMultiLineStringWithCollapse() {
    checkFix("MULTILINESTRING ((10 10, 90 90), (10 10, 10 10, 10 10))",
        "LINESTRING (10 10, 90 90))", false);
  }

  public void testMultiLineStringWithCollapseKeepMulti() {
    checkFix("MULTILINESTRING ((10 10, 90 90), (10 10, 10 10, 10 10))",
      "MULTILINESTRING ((10 10, 90 90)))", true);
  }

  public void testMultiLineStringKeepCollapse() {
    checkFixKeepCollapse("MULTILINESTRING ((10 10, 90 90), (10 10, 10 10, 10 10))",
        "GEOMETRYCOLLECTION (POINT (10 10), LINESTRING (10 10, 90 90))");
  }

  public void testMultiLineStringWithEmpty() {
    checkFix("MULTILINESTRING ((10 10, 90 90), EMPTY)",
        "MULTILINESTRING ((10 10, 90 90))");
  }

  public void testMultiLineStringWithMultiEmpty() {
    checkFix("MULTILINESTRING (EMPTY, EMPTY)",
        "MULTILINESTRING EMPTY");
  }

  //----------------------------------------

  public void testPolygonEmpty() {
    checkFix("POLYGON EMPTY",
        "POLYGON EMPTY");
  }

  public void testPolygonBowtie() {
    checkFix("POLYGON ((10 90, 90 10, 90 90, 10 10, 10 90))",
        "MULTIPOLYGON (((10 90, 50 50, 10 10, 10 90)), ((50 50, 90 90, 90 10, 50 50)))");
  }

  public void testPolygonHolesZeroAreaOverlapping() {
    checkFix("POLYGON ((10 90, 90 90, 90 10, 10 10, 10 90), (80 70, 30 70, 30 20, 30 70, 80 70), (70 80, 70 30, 20 30, 70 30, 70 80))",
        "POLYGON ((90 90, 90 10, 10 10, 10 90, 90 90))");
  }

  public void testPolygonPosAndNegOverlap() {
    checkFix("POLYGON ((10 90, 50 90, 50 30, 70 30, 70 50, 30 50, 30 70, 90 70, 90 10, 10 10, 10 90))",
        "POLYGON ((10 90, 50 90, 50 70, 90 70, 90 10, 10 10, 10 90), (50 50, 50 30, 70 30, 70 50, 50 50))");
  }

  public void testHolesTouching() {
    checkFix("POLYGON ((0 0, 0 5, 6 5, 6 0, 0 0), (3 1, 4 1, 4 2, 3 2, 3 1), (3 2, 1 4, 5 4, 4 2, 4 3, 3 2, 2 3, 3 2))",
        "MULTIPOLYGON (((0 0, 0 5, 6 5, 6 0, 0 0), (1 4, 2 3, 3 2, 3 1, 4 1, 4 2, 5 4, 1 4)), ((3 2, 4 3, 4 2, 3 2)))");
  }

  public void testPolygonNaN() {
    checkFix("POLYGON ((10 90, 90 NaN, 90 10, 10 10, 10 90))",
        "POLYGON ((10 10, 10 90, 90 10, 10 10))");
  }

  public void testPolygonRepeated() {
    checkFix("POLYGON ((10 90, 90 10, 90 10, 90 10, 90 10, 90 10, 10 10, 10 90))",
        "POLYGON ((10 10, 10 90, 90 10, 10 10))");
  }

  public void testPolygonShellCollapse() {
    checkFix("POLYGON ((10 10, 10 90, 90 90, 10 90, 10 10), (20 80, 60 80, 60 40, 20 40, 20 80))",
        "POLYGON EMPTY");
  }

  public void testPolygonShellCollapseNaN() {
    checkFix("POLYGON ((10 10, 10 NaN, 90 NaN, 10 NaN, 10 10))",
        "POLYGON EMPTY");
  }

  public void testPolygonShellKeepCollapseNaN() {
    checkFixKeepCollapse("POLYGON ((10 10, 10 NaN, 90 NaN, 10 NaN, 10 10))",
        "POINT (10 10)");
  }

  public void testPolygonShellKeepCollapse() {
    checkFixKeepCollapse("POLYGON ((10 10, 10 90, 90 90, 10 90, 10 10), (20 80, 60 80, 60 40, 20 40, 20 80))",
        "LINESTRING (10 10, 10 90, 90 90, 10 90, 10 10)");
  }

  public void testPolygonHoleCollapse() {
    checkFix("POLYGON ((10 90, 90 90, 90 10, 10 10, 10 90), (80 80, 20 80, 20 20, 20 80, 80 80))",
        "POLYGON ((10 10, 10 90, 90 90, 90 10, 10 10))");
  }

  public void testPolygonHoleKeepCollapse() {
    checkFixKeepCollapse("POLYGON ((10 90, 90 90, 90 10, 10 10, 10 90), (80 80, 20 80, 20 20, 20 80, 80 80))",
        "POLYGON ((10 10, 10 90, 90 90, 90 10, 10 10))");
  }

  public void testPolygonHoleOverlapAndOutsideOverlap() {
    checkFix("POLYGON ((50 90, 80 90, 80 10, 50 10, 50 90), (70 80, 90 80, 90 20, 70 20, 70 80), (40 80, 40 50, 0 50, 0 80, 40 80), (30 40, 10 40, 10 60, 30 60, 30 40), (60 70, 80 70, 80 30, 60 30, 60 70))",
        "MULTIPOLYGON (((10 40, 10 50, 0 50, 0 80, 40 80, 40 50, 30 50, 30 40, 10 40)), ((70 80, 70 70, 60 70, 60 30, 70 30, 70 20, 80 20, 80 10, 50 10, 50 90, 80 90, 80 80, 70 80)))");
  }

  //----------------------------------------

  public void testMultiPolygonEmpty() {
    checkFix("MULTIPOLYGON EMPTY",
        "MULTIPOLYGON EMPTY");
  }

  public void testMultiPolygonMultiEmpty() {
    checkFix("MULTIPOLYGON (EMPTY, EMPTY)",
        "MULTIPOLYGON EMPTY");
  }

  public void testMultiPolygonWithEmpty() {
    checkFix("MULTIPOLYGON (((10 40, 40 40, 40 10, 10 10, 10 40)), EMPTY, ((50 40, 80 40, 80 10, 50 10, 50 40)))",
        "MULTIPOLYGON (((10 40, 40 40, 40 10, 10 10, 10 40)), ((50 40, 80 40, 80 10, 50 10, 50 40)))");
  }

  public void testMultiPolygonWithCollapseKeepMulti() {
    checkFix("MULTIPOLYGON (((10 40, 40 40, 40 10, 10 10, 10 40)), ((50 40, 50 40, 50 40, 50 40, 50 40)))",
        "MULTIPOLYGON (((10 10, 10 40, 40 40, 40 10, 10 10)))", true);
  }

  public void testMultiPolygonWithCollapse() {
    checkFix("MULTIPOLYGON (((10 40, 40 40, 40 10, 10 10, 10 40)), ((50 40, 50 40, 50 40, 50 40, 50 40)))",
      "POLYGON ((10 10, 10 40, 40 40, 40 10, 10 10))", false);
  }

  public void testMultiPolygonKeepCollapse() {
    checkFixKeepCollapse("MULTIPOLYGON (((10 40, 40 40, 40 10, 10 10, 10 40)), ((50 40, 50 40, 50 40, 50 40, 50 40)))",
        "GEOMETRYCOLLECTION (POINT (50 40), POLYGON ((10 10, 10 40, 40 40, 40 10, 10 10)))");
  }

  //----------------------------------------

  public void testGCEmpty() {
    checkFix("GEOMETRYCOLLECTION EMPTY",
        "GEOMETRYCOLLECTION EMPTY");
  }

  public void testGCWithAllEmpty() {
    checkFix("GEOMETRYCOLLECTION (POINT EMPTY, LINESTRING EMPTY, POLYGON EMPTY)",
        "GEOMETRYCOLLECTION (POINT EMPTY, LINESTRING EMPTY, POLYGON EMPTY)");
  }

  public void testGCKeepCollapse() {
    checkFixKeepCollapse("GEOMETRYCOLLECTION (LINESTRING ( 0 0, 0 0), POINT (1 1))",
        "GEOMETRYCOLLECTION (POINT (0 0), POINT (1 1))");
  }

  //----------------------------------------

  public void testPolygonZBowtie() {
    checkFixZ("POLYGON Z ((10 90 1, 90 10 9, 90 90 9, 10 10 1, 10 90 1))",
        "MULTIPOLYGON Z (((10 10 1, 10 90 1, 50 50 5, 10 10 1)), ((50 50 5, 90 90 9, 90 10 9, 50 50 5)))");
  }

  public void testPolygonZHoleOverlap() {
    checkFixZ("POLYGON Z ((10 90 1, 60 90 6, 60 10 6, 10 10 1, 10 90 1), (20 80 2, 90 80 9, 90 20 9, 20 20 2, 20 80 2))",
        "POLYGON Z ((10 10 1, 10 90 1, 60 90 6, 60 80 6, 20 80 2, 20 20 2, 60 20 6, 60 10 6, 10 10 1))");
  }

  public void testMultiLineStringZKeepCollapse() {
    checkFixZKeepCollapse("MULTILINESTRING Z ((10 10 1, 90 90 9), (10 10 1, 10 10 2, 10 10 3))",
        "GEOMETRYCOLLECTION Z (POINT (10 10 1), LINESTRING (10 10 1, 90 90 9))");
  }

  //----------------------------------------
  
  // see https://github.com/locationtech/jts/issues/852
  public void testIssue852Case1() {
    checkFix("POLYGON ((42.565844354657436 -72.61247966084643, 42.56484510561062 -72.61202938126273, 42.56384585656381 -72.61247966084643, 42.563637679679054 -72.61276108558623, 42.562055535354936 -72.61366164475362, 42.5631796905326 -72.61259223074235, 42.565844354657436 -72.61214195115866, 42.566510520688645 -72.61259223074235, 42.565844354657436 -72.61247966084643))");
  }

  public void testIssue852Case2() {
    checkFix("POLYGON ((50.69544005538049 4.587126197745181, 50.699035986722194 4.592752502415541, 50.699395579856365 4.592049214331746, 50.699125885005735 4.590501980547397, 50.69867639358802 4.591064611014433, 50.69795720731968 4.591064611014433, 50.69759761418551 4.590501980547397, 50.69759761418551 4.589376719613325, 50.69831680045385 4.588251458679252, 50.69723802105134 4.586563567278144, 50.69579964851466 4.586563567278144, 50.69544005538049 4.587126197745181))");
  }

  //----------------------------------------
  public void testDimensionConsistence(){
    // test 2d case
    WKTReader reader = new WKTReader();
    reader.setIsOldJtsCoordinateSyntaxAllowed(false);
    Geometry geom2d = read(reader, "POLYGON((0 0, 1 0.1, 1 1, 0.5 1, 0.5 1.5, 1 1, 1.5 1.5, 1.5 1, 1 1, 1.5 0.5, 1 0.1, 2 0, 2 2,0 2, 0 0))");
    assertEquals(2, CoordinateArrays.dimension(geom2d.getCoordinates()));

    Geometry fix2d = GeometryFixer.fix(geom2d);
    assertEquals(2, CoordinateArrays.dimension(fix2d.getCoordinates()));

    // test 3d case
    Geometry geom3d = read(reader, "POLYGON Z ((10 90 1, 60 90 6, 60 10 6, 10 10 1, 10 90 1), (20 80 2, 90 80 9, 90 20 9, 20 20 2, 20 80 2))");
    assertEquals(3, CoordinateArrays.dimension(geom3d.getCoordinates()));

    Geometry fix3d = GeometryFixer.fix(geom3d);
    assertEquals(3, CoordinateArrays.dimension(fix3d.getCoordinates()));
  }

  //================================================

 /**private */void checkFix(String wkt) {
    Geometry geom = read(wkt);
    Geometry fix = GeometryFixer.fix(geom);
    assertTrue("Result is invalid", fix.isValid());
  }

 /**private */void checkFix(String wkt, String wktExpected) {
    Geometry geom = read(wkt);
    checkFix(geom, false, true, wktExpected);
  }

 /**private */void checkFix(String wkt, String wktExpected, boolean keepMulti) {
    Geometry geom = read(wkt);
    checkFix(geom, false, keepMulti, wktExpected);
  }

 /**private */void checkFixKeepCollapse(String wkt, String wktExpected) {
    Geometry geom = read(wkt);
    checkFix(geom, true, true, wktExpected);
  }

 /**private */void checkFix(Geometry input, String wktExpected) {
    checkFix(input, false, true, wktExpected);
  }

 /**private */void checkFixKeepCollapse(Geometry input, String wktExpected) {
    checkFix(input, true, true, wktExpected);
  }

 /**private */void checkFix(Geometry input, boolean keepCollapse, boolean keepMulti, String wktExpected) {
    Geometry actual;
    if (keepCollapse) {
      GeometryFixer fixer = new GeometryFixer(input);
      fixer.setKeepCollapsed(true);
      fixer.setKeepMulti(keepMulti);
      actual = fixer.getResult();
    }
    else {
      actual= GeometryFixer.fix(input, keepMulti);
    }

    assertTrue("Result is invalid", actual.isValid());
    assertTrue("Input geometry was not copied", input != actual);
    assertTrue("Result has aliased coordinates", checkDeepCopy(input, actual));

    Geometry expected = read(wktExpected);
    checkEqual(expected, actual);
  }

 /**private */boolean checkDeepCopy(Geometry geom1, Geometry geom2) {
    Coordinate[] pts1 = geom1.getCoordinates();
    Coordinate[] pts2 = geom2.getCoordinates();
    for (Coordinate p2 : pts2) {
      if (isIn(p2, pts1)) {
        return false;
      }
    }
    return true;
  }

 /**private */boolean isIn(Coordinate p, Coordinate[] pts) {
    for (int i = 0; i < pts.length; i++) {
      if (p == pts[i]) return true;
    }
    return false;
  }

 /**private */void checkFixZ(String wkt, String wktExpected) {
    Geometry geom = read(wkt);
    checkFixZ(geom, false, wktExpected);
  }

 /**private */void checkFixZKeepCollapse(String wkt, String wktExpected) {
    Geometry geom = read(wkt);
    checkFixZ(geom, true, wktExpected);
  }

 /**private */void checkFixZ(Geometry input, boolean keepCollapse, String wktExpected) {
    Geometry actual;
    if (keepCollapse) {
      GeometryFixer fixer = new GeometryFixer(input);
      fixer.setKeepCollapsed(true);
      actual = fixer.getResult();
    }
    else {
      actual= GeometryFixer.fix(input);
    }

    assertTrue("Result is invalid", actual.isValid());

    Geometry expected = read(wktExpected);
    checkEqualXYZ(expected, actual);
  }


}
