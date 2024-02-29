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
// import org.locationtech.jts.geom.LineString;
// import org.locationtech.jts.geom.MultiPoint;
// import org.locationtech.jts.geom.Point;
// import org.locationtech.jts.geom.Polygon;

/**
 * Implements the appropriate checks for repeated points
 * (consecutive identical coordinates) as defined in the
 * JTS spec.
 *
 * @version 1.7
 */
class RepeatedPointTester {

  // save the repeated coord found (if any)
  private Coordinate repeatedCoord;

  RepeatedPointTester() {
  }

  Coordinate getCoordinate() { return repeatedCoord; }

  bool hasRepeatedPoint(Geometry g)
  {
    if (g.isEmpty()) return false;
    if (g is Point)                   return false;
    else if (g is MultiPoint)         return false;
                        // LineString also handles LinearRings
    else if (g is LineString)         return hasRepeatedPoint(((LineString) g).getCoordinates());
    else if (g is Polygon)            return hasRepeatedPoint((Polygon) g);
    else if (g is GeometryCollection) return hasRepeatedPoint((GeometryCollection) g);
    else  throw new UnsupportedOperationException(g.getClass().getName());
  }

  bool hasRepeatedPoint(List<Coordinate> coord)
  {
    for (int i = 1; i < coord.length; i++) {
      if (coord[i - 1].equals(coord[i]) ) {
        repeatedCoord = coord[i];
        return true;
      }
    }
    return false;
  }
  private bool hasRepeatedPoint(Polygon p)
  {
    if (hasRepeatedPoint(p.getExteriorRing().getCoordinates())) return true;
    for (int i = 0; i < p.getNumInteriorRing(); i++) {
      if (hasRepeatedPoint(p.getInteriorRingN(i).getCoordinates())) return true;
    }
    return false;
  }
  private bool hasRepeatedPoint(GeometryCollection gc)
  {
    for (int i = 0; i < gc.getNumGeometries(); i++) {
      Geometry g = gc.getGeometryN(i);
      if (hasRepeatedPoint(g)) return true;
    }
    return false;
  }


}
