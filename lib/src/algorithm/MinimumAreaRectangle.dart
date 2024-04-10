/*
 * Copyright (c) 2023 Martin Davis.
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
// import org.locationtech.jts.geom.Envelope;
// import org.locationtech.jts.geom.Geometry;
// import org.locationtech.jts.geom.GeometryFactory;
// import org.locationtech.jts.geom.LineSegment;
// import org.locationtech.jts.geom.LineString;
// import org.locationtech.jts.geom.Point;
// import org.locationtech.jts.geom.Polygon;

import 'package:jtscore4dart/geometry.dart';

import 'ConvexHull.dart';
import 'Rectangle.dart';

/**
 * 计算最小区域矩形
 * 和Envelope 区别：不一定和坐标轴平行
 * 
 * Computes the minimum-area rectangle enclosing a {@link Geometry}.
 * Unlike the {@link Envelope}, the rectangle may not be axis-parallel.
 * <p>
 * 先计算几何图形凸包，如果已知是凸的，可以避免计算凸包
 * 
 * The first step in the algorithm is computing the convex hull of the Geometry.
 * If the input Geometry is known to be convex, a hint can be supplied to
 * avoid this computation.
 * <p>
 * In degenerate cases the minimum enclosing geometry 
 * may be a {@link LineString} or a {@link Point}.
 * <p>
 * The minimum-area enclosing rectangle does not necessarily
 * have the minimum possible width.
 * Use {@link MinimumDiameter} to compute this.
 * 
 * @see MinimumDiameter
 * @see ConvexHull
 *
 */
class MinimumAreaRectangle
{
  /**
   * Gets the minimum-area rectangular {@link Polygon} which encloses the input geometry.
   * If the convex hull of the input is degenerate (a line or point)
   * a {@link LineString} or {@link Point} is returned.
   * 
   * @param [geom] the geometry
   * @param [isConvex] the geometry
   * @return the minimum rectangle enclosing the geometry
   */
  static Geometry of(Geometry geom,[bool isConvex=false]) {
    return MinimumAreaRectangle(geom, isConvex).getMinimumRectangle();
  }
  
 /**private */final Geometry inputGeom;
 /**private */final bool isConvex;

  /**
   * Compute a minimum-area rectangle for a given {@link Geometry}.
   *
   * @param inputGeom a Geometry
   */
  // MinimumAreaRectangle(Geometry inputGeom)
  // {
  //   this(inputGeom, false);
  // }

  /**
   * Compute a minimum rectangle for a {@link Geometry},
   * with a hint if the geometry is convex
   * (e.g. a convex Polygon or LinearRing,
   * or a two-point LineString, or a Point).
   *
   * @param inputGeom a Geometry which is convex
   * @param isConvex <code>true</code> if the input geometry is convex
   */
  MinimumAreaRectangle(this.inputGeom, [this.isConvex=false]);
  // {
  //   this.inputGeom = inputGeom;
  //   this.isConvex = isConvex;
  // }

 /**private */
 Geometry getMinimumRectangle(){
    if (inputGeom.isEmpty()) {
      return inputGeom.getFactory().createPolygon();
    }
    if (isConvex) {
      return computeConvex(inputGeom);
    }
    Geometry convexGeom = ConvexHull(inputGeom).getConvexHull();
    print('>>>>>>>>> ${ convexGeom } <<<<<<<<<<<<<<<<<<<<');
    return computeConvex(convexGeom);
  }

 /**private */Geometry computeConvex(Geometry convexGeom)
  {
//System.out.println("Input = " + geom);
    // List<Coordinate> convexHullPts = null;
    List<Coordinate> convexHullPts ;
    if (convexGeom is Polygon) {
      convexHullPts = ( convexGeom as Polygon).getExteriorRing().getCoordinates();
    } else {
      convexHullPts = convexGeom.getCoordinates();
    }

    // special cases for lines or points or degenerate rings
    if (convexHullPts.isEmpty) {
    }
    else if (convexHullPts.length == 1) {
      return inputGeom.getFactory().createPoint(convexHullPts[0].copy());
    }
    else if (convexHullPts.length == 2 || convexHullPts.length == 3) {
      //-- Min rectangle is a line. Use the diagonal of the extent
      return computeMaximumLine(convexHullPts, inputGeom.getFactory());
    }
    //TODO: ensure ring is CW
    return computeConvexRing(convexHullPts);
  }

  /**
   * Computes the minimum-area rectangle for a convex ring of {@link Coordinate}s.
   * <p>
   * This algorithm uses the "dual rotating calipers" technique. 
   * Performance is linear in the number of segments.
   *
   * @param ring the convex ring to scan
   */
 /**private */Polygon computeConvexRing(List<Coordinate> ring)
  {
    // Assert: ring is oriented CW
    
    // double minRectangleArea = Double.MAX_VALUE;
    double minRectangleArea = double.maxFinite;
    int minRectangleBaseIndex = -1;
    int minRectangleDiamIndex = -1;
    int minRectangleLeftIndex = -1;
    int minRectangleRightIndex = -1;
    
    //-- start at vertex after first one
    int diameterIndex = 1;
    int leftSideIndex = 1; 
    int rightSideIndex = -1; // initialized once first diameter is found

    LineSegment segBase = new LineSegment.empty();
    LineSegment segDiam = new LineSegment.empty();
    // for each segment, find the next vertex which is at maximum distance
    for (int i = 0; i < ring.length - 1; i++) {
      segBase.p0 = ring[i];
      segBase.p1 = ring[i + 1];
      diameterIndex = findFurthestVertex(ring, segBase, diameterIndex, 0);
      
      Coordinate diamPt = ring[diameterIndex];
      Coordinate diamBasePt = segBase.project(diamPt);  
      segDiam.p0 = diamBasePt;
      segDiam.p1 = diamPt;
      
      leftSideIndex = findFurthestVertex(ring, segDiam, leftSideIndex, 1);
      
      //-- init the max right index
      if (i == 0) {
        rightSideIndex = diameterIndex;
      }
      rightSideIndex = findFurthestVertex(ring, segDiam, rightSideIndex, -1);
      
      double rectWidth = segDiam.distancePerpendicular(ring[leftSideIndex]) 
          + segDiam.distancePerpendicular(ring[rightSideIndex]);
      double rectArea = segDiam.getLength() * rectWidth;
      
      if (rectArea < minRectangleArea) {
        minRectangleArea = rectArea;
        minRectangleBaseIndex = i;  
        minRectangleDiamIndex = diameterIndex;
        minRectangleLeftIndex = leftSideIndex;
        minRectangleRightIndex = rightSideIndex;
      }
    }
    return Rectangle.createFromSidePts(
        ring[minRectangleBaseIndex], ring[minRectangleBaseIndex + 1],
        ring[minRectangleDiamIndex], 
        ring[minRectangleLeftIndex], ring[minRectangleRightIndex], 
        inputGeom.getFactory());
  }

 /**private */int findFurthestVertex(List<Coordinate> pts, LineSegment baseSeg, int startIndex, int orient)
  {
    double maxDistance = orientedDistance(baseSeg, pts[startIndex], orient);
    double nextDistance = maxDistance;
    int maxIndex = startIndex;
    int _nextIndex = maxIndex;
    //-- rotate "caliper" while distance from base segment is non-decreasing
    while (isFurtherOrEqual(nextDistance, maxDistance, orient)) {
      maxDistance = nextDistance;
      maxIndex = _nextIndex;

      _nextIndex = nextIndex(pts, maxIndex);
      if (_nextIndex == startIndex) {
        break;
      }
      nextDistance = orientedDistance(baseSeg, pts[_nextIndex], orient);
    }
    return maxIndex;
  }

 /**private */bool isFurtherOrEqual(double d1, double d2, int orient) {
    switch (orient) {
    case 0: return (d1).abs() >= (d2).abs();
    case 1: return d1 >= d2;
    case -1: return d1 <= d2;  
    }
    throw ArgumentError("Invalid orientation index: $orient");
  }

 /**private */static double orientedDistance(LineSegment seg, Coordinate p, int orient) {
    double dist = seg.distancePerpendicularOriented(p);
    if (orient == 0) {
      return (dist).abs();
    }
    return dist;
  }

 /**private */static int nextIndex(List<Coordinate> ring, int index)
  {
    index++;
    if (index >= ring.length - 1) index = 0;
    return index;
  }
  
  /**
   * Creates a line of maximum extent from the provided vertices
   * @param pts the vertices
   * @param factory the geometry factory
   * @return the line of maximum extent
   */
 /**private */static LineString computeMaximumLine(List<Coordinate> pts, GeometryFactory factory) {
    //-- find max and min pts for X and Y
    Coordinate? ptMinX;
    Coordinate? ptMaxX;
    Coordinate? ptMinY;
    Coordinate? ptMaxY;
    for (Coordinate p in pts) {
      if (ptMinX == null || p.getX() < ptMinX.getX()) ptMinX = p;
      if (ptMaxX == null || p.getX() > ptMaxX.getX()) ptMaxX = p;
      if (ptMinY == null || p.getY() < ptMinY.getY()) ptMinY = p;
      if (ptMaxY == null || p.getY() > ptMaxY.getY()) ptMaxY = p;
    }
    Coordinate p0 = ptMinX!;
    Coordinate p1 = ptMaxX!;
    //-- line is vertical - use Y pts
    if (p0.getX() == p1.getX()) {
      p0 = ptMinY!;
      p1 = ptMaxY!;
    }
    // return factory.createLineString(new List<Coordinate> { p0.copy(), p1.copy() });
    return factory.createLineString(<Coordinate>[p0.copy(), p1.copy()]);
  }
}
