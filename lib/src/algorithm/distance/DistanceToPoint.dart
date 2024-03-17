/*
 * Copyright (c) 2016 Vivid Solutions.
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
// import org.locationtech.jts.geom.LineSegment;
// import org.locationtech.jts.geom.LineString;
// import org.locationtech.jts.geom.Polygon;

import 'package:jtscore4dart/geometry.dart';
import 'package:jtscore4dart/src/geom/LineSegment.dart';

import 'PointPairDistance.dart';

/**
 * Computes the Euclidean distance (L2 metric) from a {@link Coordinate} to a {@link Geometry}.
 * Also computes two points on the geometry which are separated by the distance found.
 */
class DistanceToPoint 
{
  //@ruier edit. // static void computeDistance(Geometry geom, Coordinate pt, PointPairDistance ptDist)
  static void computeDistance(Geometry geom, Coordinate pt, PointPairDistance ptDist)
  {
    if (geom is LineString) {
      computeDistanceLine( geom, pt, ptDist);
    }
    else if (geom is Polygon) {
      computeDistancePoly( geom, pt, ptDist);
    }
    else if (geom is GeometryCollection) {
      GeometryCollection gc =  geom;
      for (int i = 0; i < gc.getNumGeometries(); i++) {
        Geometry g = gc.getGeometryN(i);
        computeDistance(g, pt, ptDist);
      }
    }
    else { // assume geom is Point
      ptDist.setMinimumCoord(geom.getCoordinate()!, pt);
    }
  }
  
  static void computeDistanceLine(LineString line, Coordinate pt, PointPairDistance ptDist)
  {
    LineSegment tempSegment = new LineSegment.empty();
    List<Coordinate> coords = line.getCoordinates();
    for (int i = 0; i < coords.length - 1; i++) {
      tempSegment.setCoordinatesFromCoord(coords[i], coords[i + 1]);
      // this is somewhat inefficient - could do better
      Coordinate closestPt = tempSegment.closestPoint(pt);
      ptDist.setMinimumCoord(closestPt, pt);
    }
  }

  static void computeDistanceLineSeg(LineSegment segment, Coordinate pt, PointPairDistance ptDist)
  {
    Coordinate closestPt = segment.closestPoint(pt);
    ptDist.setMinimumCoord(closestPt, pt);
  }

  static void computeDistancePoly(Polygon poly, Coordinate pt, PointPairDistance ptDist)
  {
    computeDistance(poly.getExteriorRing(), pt, ptDist);
    for (int i = 0; i < poly.getNumInteriorRing(); i++) {
      computeDistance(poly.getInteriorRingN(i), pt, ptDist);
    }
  }
}
