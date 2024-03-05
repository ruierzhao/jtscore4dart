/*
 * Copyright (c) 2019 Martin Davis.
 *
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License 2.0
 * and Eclipse Distribution License v. 1.0 which accompanies this distribution.
 * The Eclipse Public License is available at http://www.eclipse.org/legal/epl-v20.html
 * and the Eclipse Distribution License is available at
 *
 * http://www.eclipse.org/org/documents/edl-v10.php.
 */


// import org.locationtech.jts.algorithm.locate.IndexedPointInAreaLocator;
// import org.locationtech.jts.algorithm.locate.PointOnGeometryLocator;
// import org.locationtech.jts.geom.Coordinate;
// import org.locationtech.jts.geom.Envelope;
// import org.locationtech.jts.geom.Geometry;
// import org.locationtech.jts.geom.Location;

/**
 * Manages the input geometries for an overlay operation.
 * The second geometry is allowed to be null, 
 * to support for instance precision reduction.
 * 
 * @author Martin Davis
 *
 */
class InputGeometry {
  
  //private static final PointLocator ptLocator = new PointLocator();

 /**private */List<Geometry> geom = new Geometry[2];
 /**private */PointOnGeometryLocator ptLocatorA;
 /**private */PointOnGeometryLocator ptLocatorB;
 /**private */bool[] isCollapsed = new bool[2];
  
  InputGeometry(Geometry geomA, Geometry geomB) {
    geom = new List<Geometry> { geomA, geomB };
  }
  
  bool isSingle() {
    return geom[1] == null;
  }
  
  int getDimension(int index) {
    if (geom[index] == null) return -1;
    return geom[index].getDimension();
  }

  Geometry getGeometry(int geomIndex) {
    return geom[geomIndex];
  }

  Envelope getEnvelope(int geomIndex) {
    return geom[geomIndex].getEnvelopeInternal();
  }

  bool isEmpty(int geomIndex) {
    return geom[geomIndex].isEmpty();
  }
  
  bool isArea(int geomIndex) {
    return geom[geomIndex] != null && geom[geomIndex].getDimension() == 2;
  }
  
  /**
   * Gets the index of an input which is an area,
   * if one exists.
   * Otherwise returns -1.
   * If both inputs are areas, returns the index of the first one (0).
   * 
   * @return the index of an area input, or -1
   */
  int getAreaIndex() {
    if (getDimension(0) == 2) return 0;
    if (getDimension(1) == 2) return 1;
    return -1;
  }
  
  bool isLine(int geomIndex) {
    return getDimension(geomIndex) == 1;
  }

  bool isAllPoints() {
    return getDimension(0) == 0 
        && geom[1] != null && getDimension(1) == 0;
  }
  
  bool hasPoints() {
    return getDimension(0) == 0 || getDimension(1) == 0;
  }
  
  /**
   * Tests if an input geometry has edges.
   * This indicates that topology needs to be computed for them.
   * 
   * @param geomIndex
   * @return true if the input geometry has edges
   */
  bool hasEdges(int geomIndex) {
    return geom[geomIndex] != null && geom[geomIndex].getDimension() > 0;
  }
  
  /**
   * Determines the location within an area geometry.
   * This allows disconnected edges to be fully 
   * located.  
   * 
   * @param geomIndex the index of the geometry
   * @param pt the coordinate to locate
   * @return the location of the coordinate
   * 
   * @see Location
   */
  int locatePointInArea(int geomIndex, Coordinate pt) {
    // Assert: only called if dimension(geomIndex) = 2
    
    if ( isCollapsed[geomIndex]) 
      return Location.EXTERIOR;

    
    //return ptLocator.locate(pt, geom[geomIndex]);
    
    //*
    // this check is required because IndexedPointInAreaLocator can't handle empty polygons
    if (getGeometry(geomIndex).isEmpty()  
        || isCollapsed[geomIndex]) 
      return Location.EXTERIOR;
    
    PointOnGeometryLocator ptLocator = getLocator(geomIndex);
    return ptLocator.locate(pt);
    //*/
  }

 /**private */PointOnGeometryLocator getLocator(int geomIndex) {
    if (geomIndex == 0) {
      if (ptLocatorA == null)
        ptLocatorA = new IndexedPointInAreaLocator(getGeometry(geomIndex));
      return ptLocatorA;
    }
    else {
      if (ptLocatorB == null)
        ptLocatorB = new IndexedPointInAreaLocator(getGeometry(geomIndex));
      return ptLocatorB;
    } 
  }

  void setCollapsed(int geomIndex, bool isGeomCollapsed) {
    isCollapsed[geomIndex] = isGeomCollapsed;
  }


}
