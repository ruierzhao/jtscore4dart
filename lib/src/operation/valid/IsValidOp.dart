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


// import org.locationtech.jts.geom.Coordinate;
// import org.locationtech.jts.geom.Geometry;
// import org.locationtech.jts.geom.GeometryCollection;
// import org.locationtech.jts.geom.LineString;
// import org.locationtech.jts.geom.LinearRing;
// import org.locationtech.jts.geom.MultiPoint;
// import org.locationtech.jts.geom.MultiPolygon;
// import org.locationtech.jts.geom.Point;
// import org.locationtech.jts.geom.Polygon;

import 'package:jtscore4dart/geometry.dart';

import 'IndexedNestedHoleTester.dart';
import 'IndexedNestedPolygonTester.dart';
import 'PolygonTopologyAnalyzer.dart';
import 'TopologyValidationError.dart';

/**
 * Implements the algorithms required to compute the <code>isValid()</code> method
 * for {@link Geometry}s.
 * See the documentation for the various geometry types for a specification of validity.
 *
 * @version 1.7
 */
class IsValidOp
{
 /**private */static const int MIN_SIZE_LINESTRING = 2;
 /**private */static const int MIN_SIZE_RING = 4;

  /**
   * Tests whether a {@link Geometry} is valid.
   * @param geom the Geometry to test
   * @return true if the geometry is valid
   */
  static bool of(Geometry geom)
  {
    IsValidOp isValidOp = new IsValidOp(geom);
    return isValidOp.isValid();
  }

  @Deprecated("alias of #of")
  static bool ofGeom(Geometry geom)
  {
    IsValidOp isValidOp = new IsValidOp(geom);
    return isValidOp.isValid();
  }
  
  /**
   * Checks whether a coordinate is valid for processing.
   * Coordinates are valid if their x and y ordinates are in the
   * range of the floating point representation.
   *
   * @param coord the coordinate to validate
   * @return <code>true</code> if the coordinate is valid
   */
  static bool ofCoord(Coordinate coord)
  {
    if ((coord.x).isNaN) return false;
    if ((coord.x).isInfinite) return false;
    if ((coord.y).isNaN) return false;
    if ((coord.y).isInfinite) return false;
    return true;
  }
  
  /**
   * The geometry being validated
   */
 /**private */Geometry inputGeometry;  
  /**
   * If the following condition is TRUE JTS will validate inverted shells and exverted holes
   * (the ESRI SDE model)
   */
 /**private */bool isInvertedRingValid = false;
  
 /**private */late TopologyValidationError? validErr;

  /**
   * Creates a new validator for a geometry.
   * 
   * @param inputGeometry the geometry to validate
   */
  IsValidOp(this.inputGeometry);

  /**
   * Sets whether polygons using <b>Self-Touching Rings</b> to form
   * holes are reported as valid.
   * If this flag is set, the following Self-Touching conditions
   * are treated as being valid:
   * <ul>
   * <li><b>inverted shell</b> - the shell ring self-touches to create a hole touching the shell
   * <li><b>exverted hole</b> - a hole ring self-touches to create two holes touching at a point
   * </ul>
   * <p>
   * The default (following the OGC SFS standard)
   * is that this condition is <b>not</b> valid (<code>false</code>).
   * <p>
   * Self-Touching Rings which disconnect the 
   * the polygon interior are still considered to be invalid
   * (these are <b>invalid</b> under the SFS, and many other
   * spatial models as well).
   * This includes:
   * <ul>
   * <li>exverted ("bow-tie") shells which self-touch at a single point
   * <li>inverted shells with the inversion touching the shell at another point
   * <li>exverted holes with exversion touching the hole at another point
   * <li>inverted ("C-shaped") holes which self-touch at a single point causing an island to be formed
   * <li>inverted shells or exverted holes which form part of a chain of touching rings
   * (which disconnect the interior)
   * </ul>
   *
   * @param isValid states whether geometry with this condition is valid
   */
  void setSelfTouchingRingFormingHoleValid(bool isValid)
  {
    isInvertedRingValid = isValid;
  }

  /**
   * Tests the validity of the input geometry.
   * 
   * @return true if the geometry is valid
   */
  bool isValid()
  {
    return isValidGeometry(inputGeometry);
  }

  /**
   * Computes the validity of the geometry,
   * and if not valid returns the validation error for the geometry,
   * or null if the geometry is valid.
   * 
   * @return the validation error, if the geometry is invalid
   * or null if the geometry is valid
   */
  TopologyValidationError? getValidationError()
  {
    isValidGeometry(inputGeometry);
    return validErr;
  }
  
 /**private */void logInvalid(int code, Coordinate? pt) {
    validErr = new TopologyValidationError(code, pt);   
  }
  
 /**private */bool hasInvalidError() {
    return validErr != null;
    
  }
  
 /**private */bool isValidGeometry(Geometry g)
  {
    validErr = null;

    // empty geometries are always valid
    if (g.isEmpty()) return true;

    if (g is Point)              return isValidPoint( g as  Point);
    if (g is MultiPoint)         return isValidMPoint( g as  MultiPoint);
    if (g is LinearRing)         return isValidLR( g as  LinearRing);
    if (g is LineString)         return isValidLS( g as  LineString);
    if (g is Polygon)            return isValidP( g as  Polygon);
    if (g is MultiPolygon)       return isValidMP( g as  MultiPolygon);
    if (g is GeometryCollection) return isValidGC( g as  GeometryCollection);
    
    // geometry type not known
    // throw UnsupportedOperationException(g.getClass().getName());
    throw Exception("just never run to here");
  }

  /**
   * Tests validity of a Point.
   */
 /**private */bool isValidPoint(Point g)
  {
    checkCoordinatesValid(g.getCoordinates());
    if (hasInvalidError()) return false;
    return true;
  }
  
  /**
   * Tests validity of a MultiPoint.
   */
 /**private */bool isValidMPoint(MultiPoint g)
  {
    checkCoordinatesValid(g.getCoordinates());
    if (hasInvalidError()) return false;
    return true;
  }

  /**
   * Tests validity of a LineString.  
   * Almost anything goes for linestrings!
   */
 /**private */bool isValidLS(LineString g)
  {
    checkCoordinatesValid(g.getCoordinates());
    if (hasInvalidError()) return false;
    checkPointSize(g, MIN_SIZE_LINESTRING);
    if (hasInvalidError()) return false;
    return true;
  }
  
  /**
   * Tests validity of a LinearRing.
   */
 /**private */bool isValidLR(LinearRing g)
  {
    checkCoordinatesValid(g.getCoordinates());
    if (hasInvalidError()) return false;
    
    checkRingClosed(g);
    if (hasInvalidError()) return false;

    checkRingPointSize(g);
    if (hasInvalidError()) return false;

    checkRingSimple(g);
    return validErr == null;
  }

  /**
   * Tests the validity of a polygon.
   * Sets the validErr flag.
   */
 /**private */bool isValidP(Polygon g)
  {
    checkCoordinatesValidPolygon(g);
    if (hasInvalidError()) return false;
    
    checkRingsClosed(g);
    if (hasInvalidError()) return false;

    checkRingsPointSize(g);
    if (hasInvalidError()) return false;

    PolygonTopologyAnalyzer areaAnalyzer = new PolygonTopologyAnalyzer(g, isInvertedRingValid);

    checkAreaIntersections(areaAnalyzer);
    if (hasInvalidError()) return false;

    checkHolesInShell(g);
    if (hasInvalidError()) return false;
    
    checkHolesNotNested(g);
    if (hasInvalidError()) return false;
    
    checkInteriorConnected(areaAnalyzer);
    if (hasInvalidError()) return false;
    
    return true;
  }

  /**
   * Tests validity of a MultiPolygon.
   * 
   * @param g
   * @return
   */
 /**private */bool isValidMP(MultiPolygon g)
  {
    for (int i = 0; i < g.getNumGeometries(); i++) {
      Polygon p =  g.getGeometryN(i) as Polygon;
      checkCoordinatesValidPolygon(p);
      if (hasInvalidError()) return false;
      
      checkRingsClosed(p);
      if (hasInvalidError()) return false;
      checkRingsPointSize(p);
      if (hasInvalidError()) return false;
    }

    PolygonTopologyAnalyzer areaAnalyzer = new PolygonTopologyAnalyzer(g, isInvertedRingValid);
    
    checkAreaIntersections(areaAnalyzer);
    if (hasInvalidError()) return false;
    
    for (int i = 0; i < g.getNumGeometries(); i++) {
      Polygon p =  g.getGeometryN(i) as Polygon;
      checkHolesInShell(p);
      if (hasInvalidError()) return false;
    }
    for (int i = 0; i < g.getNumGeometries(); i++) {
      Polygon p = g.getGeometryN(i) as Polygon;
      checkHolesNotNested(p);
      if (hasInvalidError()) return false;
    }
    checkShellsNotNested(g);
    if (hasInvalidError()) return false;
    
    checkInteriorConnected(areaAnalyzer);
    if (hasInvalidError()) return false;

    return true;
  }

  /**
   * Tests validity of a GeometryCollection.
   * 
   * @param gc
   * @return
   */
 /**private */bool isValidGC(GeometryCollection gc)
  {
    for (int i = 0; i < gc.getNumGeometries(); i++) {
      if (! isValidGeometry( gc.getGeometryN(i) )) {
        return false;
      }
    }
    return true;
  }

 /**private */void checkCoordinatesValid(List<Coordinate> coords)
  {
    for (int i = 0; i < coords.length; i++) {
      if ( !ofCoord(coords[i])) {
        logInvalid(TopologyValidationError.INVALID_COORDINATE, coords[i]);
        return;
      }
    }
  }

 /**private */void checkCoordinatesValidPolygon(Polygon poly)
  {
    checkCoordinatesValid(poly.getExteriorRing().getCoordinates());
    if (hasInvalidError()) return;
    for (int i = 0; i < poly.getNumInteriorRing(); i++) {
      checkCoordinatesValid(poly.getInteriorRingN(i).getCoordinates());
      if (hasInvalidError()) return;
    }
  }

 /**private */void checkRingClosed(LinearRing ring)
  {
    if (ring.isEmpty()) return;
    if (! ring.isClosed() ) {
      Coordinate? pt = ring.getNumPoints() >= 1 ? ring.getCoordinateN(0) : null;
      logInvalid( TopologyValidationError.RING_NOT_CLOSED, pt);
      return;
    }
  }
  
 /**private */void checkRingsClosed(Polygon poly)
  {
    checkRingClosed(poly.getExteriorRing());
    if (hasInvalidError()) return;
    for (int i = 0; i < poly.getNumInteriorRing(); i++) {
      checkRingClosed(poly.getInteriorRingN(i));
      if (hasInvalidError()) return;
    }
  }

 /**private */void checkRingsPointSize(Polygon poly)
  {
    checkRingPointSize(poly.getExteriorRing());
    if (hasInvalidError()) return;
    for (int i = 0; i < poly.getNumInteriorRing(); i++) {
      checkRingPointSize(poly.getInteriorRingN(i));
      if (hasInvalidError()) return;
    }
  }

 /**private */void checkRingPointSize(LinearRing ring) {
    if (ring.isEmpty()) return;
    checkPointSize(ring, MIN_SIZE_RING);
  }

  /**
   * Check the number of non-repeated points is at least a given size.
   * 
   * @param line
   * @param minSize
   */
 /**private */void checkPointSize(LineString line, int minSize) {
    if (! isNonRepeatedSizeAtLeast(line, minSize) ) {
      Coordinate? pt = line.getNumPoints() >= 1 ? line.getCoordinateN(0) : null;
      logInvalid(TopologyValidationError.TOO_FEW_POINTS, pt);
    }
  }

  /**
   * Test if the number of non-repeated points in a line 
   * is at least a given minimum size.
   * 
   * @param line the line to test
   * @param minSize the minimum line size
   * @return true if the line has the required number of non-repeated points
   */
 /**private */bool isNonRepeatedSizeAtLeast(LineString line, int minSize) {
    int numPts = 0;
    Coordinate? prevPt;
    for (int i = 0; i < line.getNumPoints(); i++) {
      if (numPts >= minSize) return true;
      Coordinate pt = line.getCoordinateN(i);
      if (prevPt == null || ! pt.equals2D(prevPt)) {
        numPts++;
      }
      prevPt = pt; 
    }
    return numPts >= minSize;
  }

 /**private */void checkAreaIntersections(PolygonTopologyAnalyzer areaAnalyzer) {
    if (areaAnalyzer.hasInvalidIntersection()) {
      logInvalid(areaAnalyzer.getInvalidCode(),
                 areaAnalyzer.getInvalidLocation());
      return;
    }
  }

  /**
   * Check whether a ring self-intersects (except at its endpoints).
   *
   * @param ring the linear ring to check
   */
 /**private */void checkRingSimple(LinearRing ring)
  {
    Coordinate intPt = PolygonTopologyAnalyzer.findSelfIntersection(ring);
    if (intPt != null) {
      logInvalid(TopologyValidationError.RING_SELF_INTERSECTION,
          intPt);
    }
  }
  
  /**
   * Tests that each hole is inside the polygon shell.
   * This routine assumes that the holes have previously been tested
   * to ensure that all vertices lie on the shell or on the same side of it
   * (i.e. that the hole rings do not cross the shell ring).
   * Given this, a simple point-in-polygon test of a single point in the hole can be used,
   * provided the point is chosen such that it does not lie on the shell.
   *
   * @param poly the polygon to be tested for hole inclusion
   */
 /**private */void checkHolesInShell(Polygon poly)
  {
    // skip test if no holes are present
    if (poly.getNumInteriorRing() <= 0) return;
    
    LinearRing shell = poly.getExteriorRing();
    bool isShellEmpty = shell.isEmpty();
    
    for (int i = 0; i < poly.getNumInteriorRing(); i++) {
      LinearRing hole = poly.getInteriorRingN(i);
      if (hole.isEmpty()) continue;
      
      Coordinate? invalidPt = null;
      if (isShellEmpty) {
        invalidPt = hole.getCoordinate();
      }
      else {
        invalidPt = findHoleOutsideShellPoint(hole, shell);
      }
      if (invalidPt != null) {
        logInvalid(TopologyValidationError.HOLE_OUTSIDE_SHELL,
            invalidPt);
        return;
      }
    }
  }

  /**
   * Checks if a polygon hole lies inside its shell
   * and if not returns a point indicating this.
   * The hole is known to be wholly inside or outside the shell, 
   * so it suffices to find a single point which is interior or exterior,
   * or check the edge topology at a point on the boundary of the shell.
   * 
   * @param hole the hole to test
   * @param shell the polygon shell to test against
   * @return a hole point outside the shell, or null if it is inside
   */
 /**private */Coordinate? findHoleOutsideShellPoint(LinearRing hole, LinearRing shell) {
    Coordinate holePt0 = hole.getCoordinateN(0);
    /**
     * If hole envelope is not covered by shell, it must be outside
     */
    if (! shell.getEnvelopeInternal().covers( hole.getEnvelopeInternal() )) {
      //TODO: find hole pt outside shell env
      return holePt0;
    }
    
    if (PolygonTopologyAnalyzer.isRingNested(hole, shell)) {
      return null;
    }  
    //TODO: find hole point outside shell
    return holePt0;
  }
  
  /**
   * Checks if any polygon hole is nested inside another.
   * Assumes that holes do not cross (overlap),
   * This is checked earlier.
   * 
   * @param poly the polygon with holes to test
   */
 /**private */void checkHolesNotNested(Polygon poly)
  {
    // skip test if no holes are present
    if (poly.getNumInteriorRing() <= 0) return;
    
    IndexedNestedHoleTester nestedTester = new IndexedNestedHoleTester(poly);
    if ( nestedTester.isNested() ) {
      logInvalid(TopologyValidationError.NESTED_HOLES,nestedTester.getNestedPoint());
    }
  }

  /**
   * Checks that no element polygon is in the interior of another element polygon.
   * <p>
   * Preconditions:
   * <ul>
   * <li>shells do not partially overlap
   * <li>shells do not touch along an edge
   * <li>no duplicate rings exist
   * </ul>
   * These have been confirmed by the {@link PolygonTopologyAnalyzer}.
   */
 /**private */void checkShellsNotNested(MultiPolygon mp)
  {
    // skip test if only one shell present
    if (mp.getNumGeometries() <= 1) return;
    
    IndexedNestedPolygonTester nestedTester = new IndexedNestedPolygonTester(mp);
    if ( nestedTester.isNested() ) {
      logInvalid(TopologyValidationError.NESTED_SHELLS,
                            nestedTester.getNestedPoint());
    }
  }  
 
 /**private */void checkInteriorConnected(PolygonTopologyAnalyzer analyzer) {
    if (analyzer.isInteriorDisconnected()) {
      logInvalid(TopologyValidationError.DISCONNECTED_INTERIOR,
          analyzer.getDisconnectionLocation());
    }
  }

}
