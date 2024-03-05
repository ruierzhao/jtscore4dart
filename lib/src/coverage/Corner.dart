/*
 * Copyright (c) 2022 Martin Davis.
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
// import org.locationtech.jts.geom.GeometryFactory;
// import org.locationtech.jts.geom.LineString;
// import org.locationtech.jts.geom.Triangle;
// import org.locationtech.jts.simplify.LinkedLine;

class Corner implements Comparable<Corner> {
 /**private */LinkedLine edge;
 /**private */int index;
 /**private */int prev;
 /**private */int next;
 /**private */double area;

  Corner(LinkedLine edge, int i) {
    this.edge = edge;
    this.index = i; 
    this.prev = edge.prev(i);
    this.next = edge.next(i);
    this.area = area(edge, i);
  }

  bool isVertex(int index) {
    return index == this.index
        || index == prev
        || index == next;
  }

  int getIndex() {
    return index;
  }
  
  Coordinate getCoordinate() {
    return edge.getCoordinate(index);
  }
  
  double getArea() {
    return area;
  }
  
  Coordinate prev() {
    return edge.getCoordinate(prev);  
  }
  
  Coordinate next() {
    return edge.getCoordinate(next);  
  }
  
 /**private */static double area(LinkedLine edge, int index) {
    Coordinate pp = edge.prevCoordinate(index);
    Coordinate p = edge.getCoordinate(index);
    Coordinate pn = edge.nextCoordinate(index);
    return Triangle.area(pp, p, pn);
  }

  /**
   * Orders corners by increasing area.
   * To ensure equal-area corners have a deterministic ordering,
   * if area is equal then compares corner index.
   */
  @Override
  int compareTo(Corner o) {
    int comp = Double.compare(area, o.area);
    if (comp != 0) 
      return comp;
    //-- ensure equal-area corners have a deterministic ordering
    return Integer.compare(index, o.index);
  }
  
  Envelope envelope() {
    Coordinate pp = edge.getCoordinate(prev);
    Coordinate p = edge.getCoordinate(index);
    Coordinate pn = edge.getCoordinate(next);
    Envelope env = new Envelope(pp, pn);
    env.expandToInclude(p);
    return env;
  }
  
  bool isVertex(Coordinate v) {
    if (v.equals2D(edge.getCoordinate(prev))) return true;
    if (v.equals2D(edge.getCoordinate(index))) return true;
    if (v.equals2D(edge.getCoordinate(next))) return true;
    return false;
  }

  bool isBaseline(Coordinate p0, Coordinate p1) {
    Coordinate prev = prev();
    Coordinate next = next();
    if (prev.equals2D( p0 ) && next.equals2D( p1 )) return true;
    if (prev.equals2D( p1 ) && next.equals2D( p0 )) return true;
    return false;
  }
  
  bool intersects(Coordinate v) {
    Coordinate pp = edge.getCoordinate(prev);
    Coordinate p = edge.getCoordinate(index);
    Coordinate pn = edge.getCoordinate(next);
    return Triangle.intersects(pp, p, pn, v);
  }
  
  bool isRemoved() {
    return edge.prev(index) != prev || edge.next(index) != next;
  }
  
  LineString toLineString() {
    Coordinate pp = edge.getCoordinate(prev);
    Coordinate p = edge.getCoordinate(index);
    Coordinate pn = edge.getCoordinate(next);
    return (new GeometryFactory()).createLineString(
        new List<Coordinate> { safeCoord(pp), safeCoord(p), safeCoord(pn) });
  }

  String toString() {
    return toLineString().toString();
  }

 /**private */static Coordinate safeCoord(Coordinate p) {
    if (p == null) return new Coordinate(double.nan, double.nan);
    return p;
  }

}

