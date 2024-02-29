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


// import java.util.Comparator;

// import org.locationtech.jts.edgegraph.HalfEdge;
// import org.locationtech.jts.geom.Coordinate;
// import org.locationtech.jts.geom.CoordinateArrays;
// import org.locationtech.jts.geom.CoordinateList;
// import org.locationtech.jts.io.WKTWriter;

class OverlayEdge extends HalfEdge {

  /**
   * Creates a single OverlayEdge.
   * 
   * @param pts
   * @param lbl 
   * @param direction
   * 
   * @return a new edge based on the given coordinates and direction
   */
  static OverlayEdge createEdge(List<Coordinate> pts, OverlayLabel lbl, bool direction)
  {
    Coordinate origin;
    Coordinate dirPt;
    if (direction) {
      origin = pts[0];
      dirPt = pts[1];
    }
    else {
      int ilast = pts.length - 1;
      origin = pts[ilast];
      dirPt = pts[ilast-1];
    }
    return new OverlayEdge(origin, dirPt, direction, lbl, pts);
  }

  static OverlayEdge createEdgePair(List<Coordinate> pts, OverlayLabel lbl)
  {
    OverlayEdge e0 = OverlayEdge.createEdge(pts, lbl, true);
    OverlayEdge e1 = OverlayEdge.createEdge(pts, lbl, false);
    e0.link(e1);
    return e0;
  }
  
  /**
   * Gets a {@link Comparator} which sorts by the origin Coordinates.
   * 
   * @return a Comparator sorting by origin coordinate
   */
  static Comparator<OverlayEdge> nodeComparator() {
    return new Comparator<OverlayEdge>() {
      @Override
      int compare(OverlayEdge e1, OverlayEdge e2) {
        return e1.orig().compareTo(e2.orig());
      }
    };
  }
  
  private List<Coordinate> pts;
  
  /**
   * <code>true</code> indicates direction is forward along segString
   * <code>false</code> is reverse direction
   * The label must be interpreted accordingly.
   */
  private bool direction;
  private Coordinate dirPt;
  private OverlayLabel label;

  private bool isInResultArea = false;
  private bool isInResultLine = false;
  private bool isVisited = false;

  /**
   * Link to next edge in the result ring.
   * The origin of the edge is the dest of this edge.
   */
  private OverlayEdge nextResultEdge;

  private OverlayEdgeRing edgeRing;

  private MaximalEdgeRing maxEdgeRing;

  private OverlayEdge nextResultMaxEdge;


  OverlayEdge(Coordinate orig, Coordinate dirPt, bool direction, OverlayLabel label, List<Coordinate> pts) {
    super(orig);
    this.dirPt = dirPt;
    this.direction = direction;
    this.pts = pts;
    this.label = label;
  }

  bool isForward() {
    return direction;
  }
  Coordinate directionPt() {
    return dirPt;
  }
  
  OverlayLabel getLabel() {
    return label;
  }

  int getLocation(int index, int position) {
    return label.getLocation(index, position, direction);
  }

  Coordinate getCoordinate() {
    return orig();
  }
  
  List<Coordinate> getCoordinates() {
    return pts;
  }
  
  List<Coordinate> getCoordinatesOriented() {
    if (direction) {
      return pts;
    }
    List<Coordinate> copy = pts.clone();
    CoordinateArrays.reverse(copy);
    return copy;
  }
  
  /**
   * Adds the coordinates of this edge to the given list,
   * in the direction of the edge.
   * Duplicate coordinates are removed
   * (which means that this is safe to use for a path 
   * of connected edges in the topology graph).
   * 
   * @param coords the coordinate list to add to
   */
  void addCoordinates(CoordinateList coords)
  {
    bool isFirstEdge = coords.size() > 0;
    if (direction) {
      int startIndex = 1;
      if (isFirstEdge) startIndex = 0;
      for (int i = startIndex; i < pts.length; i++) {
        coords.add(pts[i], false);
      }
    }
    else { // is backward
      int startIndex = pts.length - 2;
      if (isFirstEdge) startIndex = pts.length - 1;
      for (int i = startIndex; i >= 0; i--) {
        coords.add(pts[i], false);
      }
    }
  }
  
  /**
   * Gets the symmetric pair edge of this edge.
   * 
   * @return the symmetric pair edge
   */
  OverlayEdge symOE() {
    return (OverlayEdge) sym();
  }
  
  /**
   * Gets the next edge CCW around the origin of this edge,
   * with the same origin.
   * If the origin vertex has degree 1 then this is the edge itself.
   * 
   * @return the next edge around the origin
   */
  OverlayEdge oNextOE() {
    return (OverlayEdge) oNext();
  }
  
  bool isInResultArea() {
    return isInResultArea;
  }
  
  bool isInResultAreaBoth() {
    return isInResultArea && symOE().isInResultArea;
  }
  
  void unmarkFromResultAreaBoth() {
    isInResultArea = false;
    symOE().isInResultArea = false;
  }
  
  void markInResultArea() {
    isInResultArea  = true;
  }

  void markInResultAreaBoth() {
    isInResultArea  = true;
    symOE().isInResultArea = true;
  }
  
  bool isInResultLine() {
    return isInResultLine;
  }

  void markInResultLine() {
    isInResultLine  = true;
    symOE().isInResultLine = true;
  }
  
  bool isInResult() {
    return isInResultArea || isInResultLine;
  }

  bool isInResultEither() {
    return isInResult() || symOE().isInResult();
  }

  void setNextResult(OverlayEdge e) {
    // Assert: e.orig() == this.dest();
    nextResultEdge = e;
  }
  
  OverlayEdge nextResult() {
    return nextResultEdge;
  }
  
  bool isResultLinked() {
    return nextResultEdge != null;
  }
  
  void setNextResultMax(OverlayEdge e) {
    // Assert: e.orig() == this.dest();
    nextResultMaxEdge = e;
  }
  
  OverlayEdge nextResultMax() {
    return nextResultMaxEdge;
  }

  bool isResultMaxLinked() {
    return nextResultMaxEdge != null;
  }
  
  bool isVisited() {
    return isVisited;
  }
  
  private void markVisited() {
    isVisited = true;
  }
  
  void markVisitedBoth() {
    markVisited();
    symOE().markVisited();
  }
  
  void setEdgeRing(OverlayEdgeRing edgeRing) {
    this.edgeRing = edgeRing;
  } 
  
  OverlayEdgeRing getEdgeRing() {
    return edgeRing;
  } 
  
  MaximalEdgeRing getEdgeRingMax() {
    return maxEdgeRing;
  }

  void setEdgeRingMax(MaximalEdgeRing maximalEdgeRing) {
    maxEdgeRing = maximalEdgeRing;
  }

  String toString() {
    Coordinate orig = orig();
    Coordinate dest = dest();
    String dirPtStr = (pts.length > 2)
        ? ", " + WKTWriter.format(directionPt())
            : "";

    return "OE( "+ WKTWriter.format(orig)
        + dirPtStr
        + " .. " + WKTWriter.format(dest)
        + " ) " 
        + label.toString(direction) 
        + resultSymbol()
        + " / Sym: " + symOE().getLabel().toString(symOE().direction)
        + symOE().resultSymbol()
        ;
  }
  
  private String resultSymbol() {
    if (isInResultArea) return " resA";
    if (isInResultLine) return " resL";
    return "";
  }




}
