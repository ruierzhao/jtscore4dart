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


/**
 * A bounding container for a {@link Geometry} which is in the shape of a general octagon.
 * The OctagonalEnvelope of a geometric object
 * is a geometry which is a tight bound
 * along the (up to) four extremal rectilinear parallels
 * and along the (up to) four extremal diagonal parallels.
 * Depending on the shape of the contained
 * geometry, the octagon may be degenerate to any extreme
 * (e.g. it may be a rectangle, a line, or a point).
 */
class OctagonalEnvelope
{
  /**
   * Gets the octagonal envelope of a geometry
   * @param geom the geometry
   * @return the octagonal envelope of the geometry
   */
  static Geometry octagonalEnvelope(Geometry geom) {
    return (new OctagonalEnvelope(geom)).toGeometry(geom.getFactory());
  }
  
  private static double computeA(double x, double y)
  {
    return x + y;
  }

  private static double computeB(double x, double y)
  {
    return x - y;
  }

  private static double SQRT2 = Math.sqrt(2.0);
  
  // initialize in the null state
  private double minX = Double.NaN;
  private double maxX;
  private double minY;
  private double maxY;
  private double minA;
  private double maxA;
  private double minB;
  private double maxB;

  /**
   * Creates a new null bounding octagon
   */
  OctagonalEnvelope()
  {
  }

  /**
   * Creates a new null bounding octagon bounding a {@link Coordinate}
   * 
   * @param p the coordinate to bound
   */
  OctagonalEnvelope(Coordinate p)
  {
    expandToInclude(p);
  }

  /**
   * Creates a new null bounding octagon bounding a pair of {@link Coordinate}s
   * 
   * @param p0 a coordinate to bound
   * @param p1 a coordinate to bound
   */
  OctagonalEnvelope(Coordinate p0, Coordinate p1)
  {
    expandToInclude(p0);
    expandToInclude(p1);
  }

  /**
   * Creates a new null bounding octagon bounding an {@link Envelope}
   */
  OctagonalEnvelope(Envelope env)
  {
    expandToInclude(env);
  }

  /**
   * Creates a new null bounding octagon bounding an {@link OctagonalEnvelope}
   * (the copy constructor).
   */
  OctagonalEnvelope(OctagonalEnvelope oct)
  {
    expandToInclude(oct);
  }

  /**
   * Creates a new null bounding octagon bounding a {@link Geometry}
   */
  OctagonalEnvelope(Geometry geom)
  {
    expandToInclude(geom);
  }


  double getMinX() { return minX; }
  double getMaxX() { return maxX; }
  double getMinY() { return minY; }
  double getMaxY() { return maxY; }
  double getMinA() { return minA; }
  double getMaxA() { return maxA; }
  double getMinB() { return minB; }
  double getMaxB() { return maxB; }

  bool isNull() { return Double.isNaN(minX); }

  /**
   *  Sets the value of this object to the null value
   */
  void setToNull() {
    minX = Double.NaN;
  }

  void expandToInclude(Geometry g)
  {
    g.apply(new BoundingOctagonComponentFilter(this));
  }

  OctagonalEnvelope expandToInclude(CoordinateSequence seq)
  {
    for (int i = 0; i < seq.size(); i++) {
      double x = seq.getX(i);
      double y = seq.getY(i);
      expandToInclude(x, y);
    }
    return this;
  }

  OctagonalEnvelope expandToInclude(OctagonalEnvelope oct)
  {
    if (oct.isNull()) return this;

    if (isNull()) {
      minX = oct.minX;
      maxX = oct.maxX;
      minY = oct.minY;
      maxY = oct.maxY;
      minA = oct.minA;
      maxA = oct.maxA;
      minB = oct.minB;
      maxB = oct.maxB;
      return this;
    }
    if (oct.minX < minX) minX = oct.minX;
    if (oct.maxX > maxX) maxX = oct.maxX;
    if (oct.minY < minY) minY = oct.minY;
    if (oct.maxY > maxY) maxY = oct.maxY;
    if (oct.minA < minA) minA = oct.minA;
    if (oct.maxA > maxA) maxA = oct.maxA;
    if (oct.minB < minB) minB = oct.minB;
    if (oct.maxB > maxB) maxB = oct.maxB;
    return this;
  }

  OctagonalEnvelope expandToInclude(Coordinate p)
  {
    expandToInclude(p.x, p.y);
    return this;
  }

  OctagonalEnvelope expandToInclude(Envelope env)
  {
    expandToInclude(env.getMinX(), env.getMinY());
    expandToInclude(env.getMinX(), env.getMaxY());
    expandToInclude(env.getMaxX(), env.getMinY());
    expandToInclude(env.getMaxX(), env.getMaxY());
    return this;
  }

  OctagonalEnvelope expandToInclude(double x, double y)
  {
    double A = computeA(x, y);
    double B = computeB(x, y);

    if (isNull()) {
      minX = x;
      maxX = x;
      minY = y;
      maxY = y;
      minA = A;
      maxA = A;
      minB = B;
      maxB = B;
    }
    else {
      if (x < minX) minX = x;
      if (x > maxX) maxX = x;
      if (y < minY) minY = y;
      if (y > maxY) maxY = y;
      if (A < minA) minA = A;
      if (A > maxA) maxA = A;
      if (B < minB) minB = B;
      if (B > maxB) maxB = B;
    }
    return this;
  }

  void expandBy(double distance)
  {
    if (isNull()) return;

    double diagonalDistance = SQRT2 * distance;

    minX -= distance;
    maxX += distance;
    minY -= distance;
    maxY += distance;
    minA -= diagonalDistance;
    maxA += diagonalDistance;
    minB -= diagonalDistance;
    maxB += diagonalDistance;

    if (! isValid())
      setToNull();
  }

  /**
   * Tests if the extremal values for this octagon are valid.
   *
   * @return <code>true</code> if this object has valid values
   */
  private bool isValid()
  {
    if (isNull()) return true;
    return minX <= maxX
                 && minY <= maxY
                 && minA <= maxA
                 && minB <= maxB;
  }

  bool intersects(OctagonalEnvelope other)
  {
    if (isNull() || other.isNull()) { return false; }

    if (minX > other.maxX) return false;
    if (maxX < other.minX) return false;
    if (minY > other.maxY) return false;
    if (maxY < other.minY) return false;
    if (minA > other.maxA) return false;
    if (maxA < other.minA) return false;
    if (minB > other.maxB) return false;
    if (maxB < other.minB) return false;
    return true;
  }

  bool intersects(Coordinate p)
  {
    if (minX > p.x) return false;
    if (maxX < p.x) return false;
    if (minY > p.y) return false;
    if (maxY < p.y) return false;
    
    double A = computeA(p.x, p.y);
    double B = computeB(p.x, p.y);
    if (minA > A) return false;
    if (maxA < A) return false;
    if (minB > B) return false;
    if (maxB < B) return false;
    return true;
  }

  bool contains(OctagonalEnvelope other)
  {
    if (isNull() || other.isNull()) { return false; }

    return other.minX >= minX
        && other.maxX <= maxX
        && other.minY >= minY
        && other.maxY <= maxY
        && other.minA >= minA
        && other.maxA <= maxA
        && other.minB >= minB
        && other.maxB <= maxB;
  }

  Geometry toGeometry(GeometryFactory geomFactory)
  {
    if (isNull()) {
      return geomFactory.createPoint();
    }

    Coordinate px00 = new Coordinate(minX, minA - minX);
    Coordinate px01 = new Coordinate(minX, minX - minB);

    Coordinate px10 = new Coordinate(maxX, maxX - maxB);
    Coordinate px11 = new Coordinate(maxX, maxA - maxX);

    Coordinate py00 = new Coordinate(minA - minY, minY);
    Coordinate py01 = new Coordinate(minY + maxB, minY);

    Coordinate py10 = new Coordinate(maxY + minB, maxY);
    Coordinate py11 = new Coordinate(maxA - maxY, maxY);

    PrecisionModel pm = geomFactory.getPrecisionModel();
    pm.makePrecise(px00);
    pm.makePrecise(px01);
    pm.makePrecise(px10);
    pm.makePrecise(px11);
    pm.makePrecise(py00);
    pm.makePrecise(py01);
    pm.makePrecise(py10);
    pm.makePrecise(py11);

    CoordinateList coordList = new CoordinateList();
    coordList.add(px00, false);
    coordList.add(px01, false);
    coordList.add(py10, false);
    coordList.add(py11, false);
    coordList.add(px11, false);
    coordList.add(px10, false);
    coordList.add(py01, false);
    coordList.add(py00, false);

    if (coordList.size() == 1) {
      return geomFactory.createPoint(px00);
    }
    if (coordList.size() == 2) {
      List<Coordinate> pts = coordList.toCoordinateArray();
      return geomFactory.createLineString(pts);
    }
    // must be a polygon, so add closing point
    coordList.add(px00, false);
    List<Coordinate> pts = coordList.toCoordinateArray();
    return geomFactory.createPolygon(geomFactory.createLinearRing(pts));
  }

  private static class BoundingOctagonComponentFilter
  implements GeometryComponentFilter
  {
    OctagonalEnvelope oe;
    
    BoundingOctagonComponentFilter(OctagonalEnvelope oe) {
      this.oe = oe;
    }
    
     void filter(Geometry geom)
     {
       if (geom instanceof LineString) {
         oe.expandToInclude( ((LineString) geom).getCoordinateSequence());
       }
       else if (geom instanceof Point) {
         oe.expandToInclude( ((Point) geom).getCoordinateSequence());
       }
     }
  }
}
