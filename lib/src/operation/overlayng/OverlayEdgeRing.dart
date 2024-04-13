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

// import java.util.ArrayList;
// import java.util.List;

// import org.locationtech.jts.algorithm.Orientation;
// import org.locationtech.jts.algorithm.locate.IndexedPointInAreaLocator;
// import org.locationtech.jts.algorithm.locate.PointOnGeometryLocator;
// import org.locationtech.jts.geom.Coordinate;
// import org.locationtech.jts.geom.CoordinateArrays;
// import org.locationtech.jts.geom.CoordinateList;
// import org.locationtech.jts.geom.Envelope;
// import org.locationtech.jts.geom.GeometryFactory;
// import org.locationtech.jts.geom.LinearRing;
// import org.locationtech.jts.geom.Location;
// import org.locationtech.jts.geom.Polygon;
// import org.locationtech.jts.geom.TopologyException;

import 'package:jtscore4dart/geometry.dart';
import 'package:jtscore4dart/src/algorithm/Orientation.dart';
import 'package:jtscore4dart/src/algorithm/locate/IndexedPointInAreaLocator.dart';
import 'package:jtscore4dart/src/algorithm/locate/PointOnGeometryLocator.dart';
import 'package:jtscore4dart/src/geom/Location.dart';
import 'package:jtscore4dart/src/geom/TopologyException.dart';

import 'OverlayEdge.dart';

class OverlayEdgeRing {
  OverlayEdge _startEdge;
  LinearRing? _ring;
  bool _isHole = false;
  late List<Coordinate> _ringPts;
  IndexedPointInAreaLocator? _locator;
  OverlayEdgeRing? _shell;
  // a list of EdgeRings which are holes in this EdgeRing
  List<OverlayEdgeRing> _holes = <OverlayEdgeRing>[];

  OverlayEdgeRing(OverlayEdge start, GeometryFactory geometryFactory)
      : this._startEdge = start {
    this._ringPts = _computeRingPts(start);
    computeRing(_ringPts, geometryFactory);
  }

  LinearRing getRing() {
    return _ring!;
  }

  /**private */
  Envelope getEnvelope() {
    return _ring!.getEnvelopeInternal();
  }

  /**
   * Tests whether this ring is a hole.
   * @return <code>true</code> if this ring is a hole
   */
  bool isHole() {
    return _isHole;
  }

  /**
   * Sets the containing shell ring of a ring that has been determined to be a hole.
   * 
   * @param shell the shell ring
   */
  void setShell(OverlayEdgeRing shell) {
    this._shell = shell;
    if (shell != null) shell.addHole(this);
  }

  /**
   * Tests whether this ring has a shell assigned to it.
   * 
   * @return true if the ring has a shell
   */
  bool hasShell() {
    return _shell != null;
  }

  /**
   * Gets the shell for this ring.  The shell is the ring itself if it is not a hole, otherwise its parent shell.
   * 
   * @return the shell for this ring
   */
  OverlayEdgeRing? getShell() {
    if (isHole()) return _shell!;
    return this;
  }

  void addHole(OverlayEdgeRing ring) {
    _holes.add(ring);
  }

  List<Coordinate> _computeRingPts(OverlayEdge start) {
    OverlayEdge edge = start;
    CoordinateList pts = new CoordinateList();
    do {
      if (edge.getEdgeRing() == this) {
        throw new TopologyException(
            "Edge visited twice during ring-building at ${edge.getCoordinate()}",
            edge.getCoordinate());
      }

      //edges.add(de);
//Debug.println(de);
//Debug.println(de.getEdge());

      // only valid for polygonal output
      //Assert.isTrue(edge.getLabel().isBoundaryEither());

      edge.addCoordinates(pts);
      edge.setEdgeRing(this);
      if (edge.nextResult() == null) {
        throw new TopologyException("Found null edge in ring", edge.dest());
      }

      edge = edge.nextResult()!;
    } while (edge != start);
    pts.closeRing();
    return pts.toCoordinateArray();
  }

  void computeRing(List<Coordinate> ringPts, GeometryFactory geometryFactory) {
    if (_ring != null) return; // don't compute more than once
    _ring = geometryFactory.createLinearRing(ringPts);
    _isHole = Orientation.isCCW(_ring!.getCoordinates());
  }

  /**
   * Computes the list of coordinates which are contained in this ring.
   * The coordinates are computed once only and cached.
   *
   * @return an array of the {@link Coordinate}s in this ring
   */
  /**private */ List<Coordinate> getCoordinates() {
    return _ringPts;
  }

  /**
   * Finds the innermost enclosing shell OverlayEdgeRing
   * containing this OverlayEdgeRing, if any.
   * The innermost enclosing ring is the <i>smallest</i> enclosing ring.
   * The algorithm used depends on the fact that:
   * <br>
   *  ring A contains ring B if envelope(ring A) contains envelope(ring B)
   * <br>
   * This routine is only safe to use if the chosen point of the hole
   * is known to be properly contained in a shell
   * (which is guaranteed to be the case if the hole does not touch its shell)
   * <p>
   * To improve performance of this function the caller should 
   * make the passed shellList as small as possible (e.g.
   * by using a spatial index filter beforehand).
   * 
   * @return containing EdgeRing or null if no containing EdgeRing is found
   */
  OverlayEdgeRing? findEdgeRingContaining(List<OverlayEdgeRing> erList) {
    OverlayEdgeRing? minContainingRing = null;

    for (OverlayEdgeRing edgeRing in erList) {
      if (edgeRing._contains(this)) {
        if (minContainingRing == null ||
            minContainingRing.getEnvelope().contains(edgeRing.getEnvelope())) {
          minContainingRing = edgeRing;
        }
      }
    }
    return minContainingRing;
  }

  /**private */ PointOnGeometryLocator _getLocator() {
    _locator ??= new IndexedPointInAreaLocator(getRing());
    return _locator!;
  }

  int locate(Coordinate pt) {
    /**
     * Use an indexed point-in-polygon for performance
     */
    return _getLocator().locate(pt);
  }

  /**
   * Tests if an edgeRing is properly contained in this ring.
   * Relies on property that edgeRings never overlap (although they may
   * touch at single vertices).
   * 
   * @param [ring] ring to test
   * @return true if ring is properly contained
   */
  bool _contains(OverlayEdgeRing ring) {
    // the test envelope must be properly contained
    // (guards against testing rings against themselves)
    Envelope env = getEnvelope();
    Envelope testEnv = ring.getEnvelope();
    if (!env.containsProperly(testEnv)) {
      return false;
    }
    return _isPointInOrOut(ring);
  }

  bool _isPointInOrOut(OverlayEdgeRing ring) {
    // in most cases only one or two points will be checked
    for (Coordinate pt in ring.getCoordinates()) {
      int loc = locate(pt);
      if (loc == Location.INTERIOR) {
        return true;
      }
      if (loc == Location.EXTERIOR) {
        return false;
      }
      // pt is on BOUNDARY, so keep checking for a determining location
    }
    return false;
  }

  Coordinate getCoordinate() {
    return _ringPts[0];
  }

  /**
   * Computes the {@link Polygon} formed by this ring and any contained holes.
   *
   * @return the {@link Polygon} formed by this ring and its holes.
   */
  Polygon toPolygon(GeometryFactory factory) {
    List<LinearRing>? holeLR = null;
    if (_holes != null) {
      // holeLR = new LinearRing[holes.size()];
      // for (int i = 0; i < holes.size(); i++) {
      //   holeLR[i] =  holes.get(i).getRing();
      // }
      holeLR = List.generate(_holes.length, (index) => _holes[index].getRing(),
          growable: false);
    }
    Polygon poly = factory.createPolygon(_ring, holeLR);
    return poly;
  }

  OverlayEdge getEdge() {
    return _startEdge;
  }
}
