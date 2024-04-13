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

import 'package:jtscore4dart/src/edgegraph/HalfEdge.dart';
import 'package:jtscore4dart/src/geom/Coordinate.dart';
import 'package:jtscore4dart/src/geom/CoordinateArrays.dart';
import 'package:jtscore4dart/src/geom/CoordinateList.dart';

import 'MaximalEdgeRing.dart';
import 'OverlayEdgeRing.dart';
import 'OverlayLabel.dart';
import 'util.dart';

class OverlayEdge extends HalfEdge {
  /**
   * Creates a single OverlayEdge.
   * 
   * @param [pts]
   * @param [lbl] 
   * @param [direction]
   * 
   * @return a new edge based on the given coordinates and direction
   */
  static OverlayEdge createEdge(
      List<Coordinate> pts, OverlayLabel lbl, bool direction) {
    Coordinate origin;
    Coordinate dirPt;
    if (direction) {
      origin = pts[0];
      dirPt = pts[1];
    } else {
      int ilast = pts.length - 1;
      origin = pts[ilast];
      dirPt = pts[ilast - 1];
    }
    return new OverlayEdge(origin, dirPt, direction, lbl, pts);
  }

  static OverlayEdge createEdgePair(List<Coordinate> pts, OverlayLabel lbl) {
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
  // static Comparator<OverlayEdge> nodeComparator() {
  //   return new Comparator<OverlayEdge>() {
  //     @Override
  //     int compare(OverlayEdge e1, OverlayEdge e2) {
  //       return e1.orig().compareTo(e2.orig());
  //     }
  //   };
  // }
  static Comparator<OverlayEdge> nodeComparator() {
    return (OverlayEdge e1, OverlayEdge e2) {
      return e1.orig().compareTo(e2.orig());
    };
  }

  /**private */ List<Coordinate> pts;

  /**
   * <code>true</code> indicates direction is forward along segString
   * <code>false</code> is reverse direction
   * The label must be interpreted accordingly.
   */
  /**private */ bool direction;
  /**private */ Coordinate dirPt;
  /**private */ OverlayLabel label;

  /**private */ bool isInResultArea = false;
  /**private */ bool _isInResultLine = false;
  /**private */ bool _isVisited = false;

  /**
   * Link to next edge in the result ring.
   * The origin of the edge is the dest of this edge.
   */
  /**private */ OverlayEdge? nextResultEdge;

  /**private */ OverlayEdgeRing? edgeRing;

  /**private */ MaximalEdgeRing? maxEdgeRing;

  /**private */ OverlayEdge? nextResultMaxEdge;

  OverlayEdge(Coordinate orig, this.dirPt, this.direction, this.label, this.pts)
      : super(orig);

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
    // List<Coordinate> copy = pts.clone();
    /// TODO: @ruier edit.
    List<Coordinate> copy = List.from(pts, growable: false);
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
  void addCoordinates(CoordinateList coords) {
    bool isFirstEdge = coords.size() > 0;
    if (direction) {
      int startIndex = 1;
      if (isFirstEdge) startIndex = 0;
      for (int i = startIndex; i < pts.length; i++) {
        coords.add(pts[i], false);
      }
    } else {
      // is backward
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
    return sym() as OverlayEdge;
  }

  /**
   * Gets the next edge CCW around the origin of this edge,
   * with the same origin.
   * If the origin vertex has degree 1 then this is the edge itself.
   * 
   * @return the next edge around the origin
   */
  OverlayEdge oNextOE() {
    return oNext() as OverlayEdge;
  }

  bool isInResultAreaF() {
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
    isInResultArea = true;
  }

  void markInResultAreaBoth() {
    isInResultArea = true;
    symOE().isInResultArea = true;
  }

  bool isInResultLine() {
    return _isInResultLine;
  }

  void markInResultLine() {
    _isInResultLine = true;
    symOE()._isInResultLine = true;
  }

  bool isInResult() {
    return isInResultArea || _isInResultLine;
  }

  bool isInResultEither() {
    return isInResult() || symOE().isInResult();
  }

  void setNextResult(OverlayEdge e) {
    // Assert: e.orig() == this.dest();
    nextResultEdge = e;
  }

  OverlayEdge? nextResult() {
    return nextResultEdge;
  }

  bool isResultLinked() {
    return nextResultEdge != null;
  }

  void setNextResultMax(OverlayEdge e) {
    // Assert: e.orig() == this.dest();
    nextResultMaxEdge = e;
  }

  OverlayEdge? nextResultMax() {
    return nextResultMaxEdge;
  }

  bool isResultMaxLinked() {
    return nextResultMaxEdge != null;
  }

  bool isVisited() {
    return _isVisited;
  }

  /**private */ void markVisited() {
    _isVisited = true;
  }

  void markVisitedBoth() {
    markVisited();
    symOE().markVisited();
  }

  void setEdgeRing(OverlayEdgeRing edgeRing) {
    this.edgeRing = edgeRing;
  }

  OverlayEdgeRing? getEdgeRing() {
    return edgeRing;
  }

  MaximalEdgeRing? getEdgeRingMax() {
    return maxEdgeRing;
  }

  void setEdgeRingMax(MaximalEdgeRing maximalEdgeRing) {
    maxEdgeRing = maximalEdgeRing;
  }

  String toString() {
    Coordinate _orig = orig();
    Coordinate _dest = dest();
    String dirPtStr = (pts.length > 2) ? ", " + format(directionPt()) : "";

    return "OE( " +
        format(_orig) +
        dirPtStr +
        " .. " +
        format(_dest) +
        " ) " +
        label.toString2(direction) +
        resultSymbol() +
        " / Sym: " +
        symOE().getLabel().toString2(symOE().direction) +
        symOE().resultSymbol();
  }

  /**private */ String resultSymbol() {
    if (isInResultArea) return " resA";
    if (_isInResultLine) return " resL";
    return "";
  }
}
