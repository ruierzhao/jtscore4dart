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


// import java.util.List;

// import org.locationtech.jts.geom.Coordinate;
// import org.locationtech.jts.geom.GeometryFactory;
// import org.locationtech.jts.geom.LineSegment;
// import org.locationtech.jts.geom.LineString;
// import org.locationtech.jts.geom.MultiLineString;
// import org.locationtech.jts.io.WKTWriter;

/**
 * An edge of a polygonal coverage formed from all or a section of a polygon ring.
 * An edge may be a free ring, which is a ring which has not node points
 * (i.e. does not touch any other rings in the parent coverage).
 * 
 * @author mdavis
 *
 */
class CoverageEdge {

  static CoverageEdge createEdge(List<Coordinate> ring) {
    List<Coordinate> pts = extractEdgePoints(ring, 0, ring.length - 1);
    CoverageEdge edge = new CoverageEdge(pts, true);
    return edge;
  }

  static CoverageEdge createEdge(List<Coordinate> ring, int start, int end) {
    List<Coordinate> pts = extractEdgePoints(ring, start, end);
    CoverageEdge edge = new CoverageEdge(pts, false);
    return edge;
  }

  static MultiLineString createLines(List<CoverageEdge> edges, GeometryFactory geomFactory) {
    LineString lines[] = new LineString[edges.size()];
    for (int i = 0; i < edges.size(); i++) {
      CoverageEdge edge = edges.get(i);
      lines[i] = edge.toLineString(geomFactory);
    }
    MultiLineString mls = geomFactory.createMultiLineString(lines);
    return mls;
  }
  
 /**private */static List<Coordinate> extractEdgePoints(List<Coordinate> ring, int start, int end) {
    int size = start < end 
                  ? end - start + 1 
                  : ring.length - start + end;
    List<Coordinate> pts = new Coordinate[size];
    int iring = start;
    for (int i = 0; i < size; i++) {
      pts[i] = ring[iring].copy();
      iring += 1;
      if (iring >= ring.length) iring = 1;
    }
    return pts;
  }

  /**
   * Computes a key segment for a ring.
   * The key is the segment starting at the lowest vertex,
   * towards the lowest adjacent distinct vertex.
   * 
   * @param ring a linear ring
   * @return a LineSegment representing the key
   */
  static LineSegment key(List<Coordinate> ring) {
   // find lowest vertex index
    int indexLow = 0;
    for (int i = 1; i < ring.length - 1; i++) {
      if (ring[indexLow].compareTo(ring[i]) < 0)
        indexLow = i;
    }
    Coordinate key0 = ring[indexLow];
    // find distinct adjacent vertices
    Coordinate adj0 = findDistinctPoint(ring, indexLow, true, key0);
    Coordinate adj1 = findDistinctPoint(ring, indexLow, false, key0);
    Coordinate key1 = adj0.compareTo(adj1) < 0 ? adj0 : adj1;
    return new LineSegment(key0, key1);
  }
  
  /**
   * Computes a distinct key for a section of a linear ring.
   * 
   * @param ring the linear ring
   * @param start index of the start of the section
   * @param end end index of the end of the section
   * @return a LineSegment representing the key
   */
  static LineSegment key(List<Coordinate> ring, int start, int end) {
    //-- endpoints are distinct in a line edge
    Coordinate end0 = ring[start];
    Coordinate end1 = ring[end];
    bool isForward = 0 > end0.compareTo(end1);
    Coordinate key0, key1;
    if (isForward) {
      key0 = end0;
      key1 = findDistinctPoint(ring, start, true, key0);
    }
    else {
      key0 = end1;
      key1 = findDistinctPoint(ring, end, false, key0);
    }
    return new LineSegment(key0, key1);  
  }

 /**private */static Coordinate findDistinctPoint(List<Coordinate> pts, int index, bool isForward, Coordinate pt) {
    int inc = isForward ? 1 : -1;
    int i = index;
    do {
      if (! pts[i].equals2D(pt)) {
        return pts[i];
      }
      // increment index with wrapping
      i += inc;
      if (i < 0) {
        i = pts.length - 1;
      }
      else if (i > pts.length - 1) {
        i = 0;
      }
    } while (i != index);
    throw new IllegalStateException("Edge does not contain distinct points");
  }

 /**private */List<Coordinate> pts;
 /**private */int ringCount = 0;
 /**private */bool isFreeRing = true;

  CoverageEdge(List<Coordinate> pts, bool isFreeRing) {
    this.pts = pts;
    this.isFreeRing = isFreeRing;
  }

  void incRingCount() {
    ringCount++;
  }
  
  int getRingCount() {
    return ringCount;
  }

  /**
   * Returns whether this edge is a free ring;
   * i.e. one with no constrained nodes.
   * 
   * @return true if this is a free ring
   */
  bool isFreeRing() {
    return isFreeRing;
  }

  void setCoordinates(List<Coordinate> pts) {
    this.pts = pts;
  }

  List<Coordinate> getCoordinates() {
    return pts;
  }

  Coordinate getEndCoordinate() {
    return pts[pts.length - 1];
  }
  
  Coordinate getStartCoordinate() {
    return pts[0];
  }
  
  LineString toLineString(GeometryFactory geomFactory) {
    return geomFactory.createLineString(getCoordinates());
  }
  
  String toString() {
    return WKTWriter.toLineString(pts);
  }


}
