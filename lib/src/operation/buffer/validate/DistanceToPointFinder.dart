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

/**
 * Computes the Euclidean distance (L2 metric) from a Point to a Geometry.
 * Also computes two points which are separated by the distance.
 */
class DistanceToPointFinder {

  DistanceToPointFinder() {
  }

  static void computeDistance(Geometry geom, Coordinate pt, PointPairDistance ptDist)
  {
    if (geom is LineString) {
      computeDistance((LineString) geom, pt, ptDist);
    }
    else if (geom is Polygon) {
      computeDistance((Polygon) geom, pt, ptDist);
    }
    else if (geom is GeometryCollection) {
      GeometryCollection gc = (GeometryCollection) geom;
      for (int i = 0; i < gc.getNumGeometries(); i++) {
        Geometry g = gc.getGeometryN(i);
        computeDistance(g, pt, ptDist);
      }
    }
    else { // assume geom is Point
      ptDist.setMinimum(geom.getCoordinate(), pt);
    }
  }
  static void computeDistance(LineString line, Coordinate pt, PointPairDistance ptDist)
  {
    List<Coordinate> coords = line.getCoordinates();
    LineSegment tempSegment = new LineSegment();
    for (int i = 0; i < coords.length - 1; i++) {
      tempSegment.setCoordinates(coords[i], coords[i + 1]);
      // this is somewhat inefficient - could do better
      Coordinate closestPt = tempSegment.closestPoint(pt);
      ptDist.setMinimum(closestPt, pt);
    }
  }

  static void computeDistance(LineSegment segment, Coordinate pt, PointPairDistance ptDist)
  {
    Coordinate closestPt = segment.closestPoint(pt);
    ptDist.setMinimum(closestPt, pt);
  }

  static void computeDistance(Polygon poly, Coordinate pt, PointPairDistance ptDist)
  {
    computeDistance(poly.getExteriorRing(), pt, ptDist);
    for (int i = 0; i < poly.getNumInteriorRing(); i++) {
      computeDistance(poly.getInteriorRingN(i), pt, ptDist);
    }
  }
}
