/*
 * Copyright (c) 2016 Martin Davis.
 *
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License 2.0
 * and Eclipse Distribution License v. 1.0 which accompanies this distribution.
 * The Eclipse Public License is available at http://www.eclipse.org/legal/epl-v20.html
 * and the Eclipse Distribution License is available at
 *
 * http://www.eclipse.org/org/documents/edl-v10.php.
 */

// import org.locationtech.jts.algorithm.Distance;
// import org.locationtech.jts.algorithm.LineIntersector;
// import org.locationtech.jts.algorithm.RobustLineIntersector;
// import org.locationtech.jts.geom.Coordinate;
// import org.locationtech.jts.noding.NodedSegmentString;
// import org.locationtech.jts.noding.SegmentIntersector;
// import org.locationtech.jts.noding.SegmentString;

import 'package:jtscore4dart/src/algorithm/Distance.dart';
import 'package:jtscore4dart/src/algorithm/LineIntersector.dart';
import 'package:jtscore4dart/src/algorithm/RobustLineIntersector.dart';
import "package:jtscore4dart/src/geom/Coordinate.dart";
import 'package:jtscore4dart/src/noding/NodedSegmentString.dart';
import 'package:jtscore4dart/src/noding/SegmentIntersector.dart';
import 'package:jtscore4dart/src/noding/SegmentString.dart';

import 'SnappingPointIndex.dart';

/**
 * Finds intersections between line segments which are being snapped,
 * and adds them as nodes.
 *
 * @version 1.17
 */
class SnappingIntersectionAdder implements SegmentIntersector {
  /**private */ LineIntersector _li = new RobustLineIntersector();

  /**private */ double _snapTolerance;

  /**private */ SnappingPointIndex _snapPointIndex;

  /**
   * Creates an intersector which finds intersections, snaps them,
   * and adds them as nodes.
   *
   * @param [snapTolerance] the snapping tolerance distance
   * @param [snapPointIndex] the snapPointIndex
   */
  SnappingIntersectionAdder(this._snapTolerance, this._snapPointIndex);

  /**
   * This method is called by clients
   * of the {@link SegmentIntersector} class to process
   * intersections for two segments of the {@link SegmentString}s being intersected.
   * Note that some clients (such as <code>MonotoneChain</code>s) may optimize away
   * this call for segment pairs which they have determined do not intersect
   * (e.g. by an disjoint envelope test).
   */
  @override
  void processIntersections(
      SegmentString seg0, int segIndex0, SegmentString seg1, int segIndex1) {
    // don't bother intersecting a segment with itself
    if (seg0 == seg1 && segIndex0 == segIndex1) return;

    Coordinate p00 = seg0.getCoordinate(segIndex0);
    Coordinate p01 = seg0.getCoordinate(segIndex0 + 1);
    Coordinate p10 = seg1.getCoordinate(segIndex1);
    Coordinate p11 = seg1.getCoordinate(segIndex1 + 1);

    /**
     * Don't node intersections which are just 
     * due to the shared vertex of adjacent segments.
     */
    if (!_isAdjacent(seg0, segIndex0, seg1, segIndex1)) {
      _li.computeIntersection4Coord(p00, p01, p10, p11);
      //if (li.hasIntersection() && li.isProper()) Debug.println(li);

      /**
       * Process single point intersections only.
       * Two-point (collinear) ones are handled by the near-vertex code
       */
      if (_li.hasIntersection() && _li.getIntersectionNum() == 1) {
        Coordinate intPt = _li.getIntersection(0);
        Coordinate snapPt = _snapPointIndex.snap(intPt);

        (seg0 as NodedSegmentString).addIntersection(snapPt, segIndex0);
        (seg1 as NodedSegmentString).addIntersection(snapPt, segIndex1);
      }
    }

    /**
     * The segments must also be snapped to the other segment endpoints.
     */
    _processNearVertex(seg0, segIndex0, p00, seg1, segIndex1, p10, p11);
    _processNearVertex(seg0, segIndex0, p01, seg1, segIndex1, p10, p11);
    _processNearVertex(seg1, segIndex1, p10, seg0, segIndex0, p00, p01);
    _processNearVertex(seg1, segIndex1, p11, seg0, segIndex0, p00, p01);
  }

  /**
   * If an endpoint of one segment is near 
   * the <i>interior</i> of the other segment, add it as an intersection.
   * EXCEPT if the endpoint is also close to a segment endpoint
   * (since this can introduce "zigs" in the linework).
   * <p>
   * This resolves situations where
   * a segment A endpoint is extremely close to another segment B,
   * but is not quite crossing.  Due to robustness issues
   * in orientation detection, this can 
   * result in the snapped segment A crossing segment B
   * without a node being introduced.
   * 
   * @param [p]
   * @param [ss]
   * @param [segIndex]
   * @param [p0]
   * @param [p1]
   */
  void _processNearVertex(SegmentString srcSS, int srcIndex, Coordinate p,
      SegmentString ss, int segIndex, Coordinate p0, Coordinate p1) {
    /**
     * Don't add intersection if candidate vertex is near endpoints of segment.
     * This avoids creating "zig-zag" linework
     * (since the vertex could actually be outside the segment envelope).
     * Also, this should have already been snapped.
     */
    if (p.distance(p0) < _snapTolerance) return;
    if (p.distance(p1) < _snapTolerance) return;

    double distSeg = Distance.pointToSegment(p, p0, p1);
    if (distSeg < _snapTolerance) {
      // add node to target segment
      (ss as NodedSegmentString).addIntersection(p, segIndex);
      // add node at vertex to source SS
      (srcSS as NodedSegmentString).addIntersection(p, srcIndex);
    }
  }

  /**
   * Tests if segments are adjacent on the same SegmentString.
   * Closed segStrings require a check for the point shared by the beginning
   * and end segments.
   */
  static bool _isAdjacent(
      SegmentString ss0, int segIndex0, SegmentString ss1, int segIndex1) {
    if (ss0 != ss1) return false;

    bool isAdjacent = (segIndex0 - segIndex1).abs() == 1;
    if (isAdjacent) return true;
    if (ss0.isClosed()) {
      int maxSegIndex = ss0.size() - 1;
      if ((segIndex0 == 0 && segIndex1 == maxSegIndex) ||
          (segIndex1 == 0 && segIndex0 == maxSegIndex)) {
        return true;
      }
    }
    return false;
  }

  /**
   * Always process all intersections
   * 
   * @return false always
   */
  @override
  bool isDone() {
    return false;
  }
}
