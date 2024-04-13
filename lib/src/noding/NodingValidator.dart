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

// import java.util.Collection;
// import java.util.Iterator;

// import org.locationtech.jts.algorithm.LineIntersector;
// import org.locationtech.jts.algorithm.RobustLineIntersector;
// import org.locationtech.jts.geom.Coordinate;
// import org.locationtech.jts.geom.GeometryFactory;

import 'package:jtscore4dart/src/algorithm/LineIntersector.dart';
import 'package:jtscore4dart/src/algorithm/RobustLineIntersector.dart';
import 'package:jtscore4dart/src/geom/Coordinate.dart';
import 'package:jtscore4dart/src/geom/GeometryFactory.dart';

import 'SegmentString.dart';

/**
 * Validates that a collection of {@link SegmentString}s is correctly noded.
 * Throws an appropriate exception if an noding error is found.
 *
 * @version 1.7
 */
class NodingValidator {
  /**private */ LineIntersector li = new RobustLineIntersector();

  /**private */ Iterable segStrings;

  /**private */ static final GeometryFactory fact = new GeometryFactory();

  NodingValidator(this.segStrings);

  void checkValid() {
    // MD - is this call required?  Or could it be done in the Interior Intersection code?
    checkEndPtVertexIntersections();
    checkInteriorIntersections();
    checkCollapses();
  }

  /**
   * Checks if a segment string contains a segment pattern a-b-a (which implies a self-intersection)
   */
  /**private */
  void checkCollapses() {
    for (Iterator i = segStrings.iterator; i.moveNext();) {
      SegmentString ss = i.current;
      _checkCollapses(ss);
    }
  }

  /**private */ void _checkCollapses(SegmentString ss) {
    List<Coordinate> pts = ss.getCoordinates();
    for (int i = 0; i < pts.length - 2; i++) {
      checkCollapse(pts[i], pts[i + 1], pts[i + 2]);
    }
  }

  /**private */ void checkCollapse(
      Coordinate p0, Coordinate p1, Coordinate p2) {
    if (p0.equals(p2)) {
      throw new Exception(
          "found non-noded collapse at ${fact.createLineString(<Coordinate>[
            p0,
            p1,
            p2
          ])}");
    }
  }

  /**
   * Checks all pairs of segments for intersections at an interior point of a segment
   */
  /**private */ void checkInteriorIntersections() {
    for (Iterator i = segStrings.iterator; i.moveNext();) {
      SegmentString ss0 = i.current;
      for (Iterator j = segStrings.iterator; j.moveNext();) {
        SegmentString ss1 = j.current;
        _checkInteriorIntersections(ss0, ss1);
      }
    }
  }

  /**private */ void _checkInteriorIntersections(
      SegmentString ss0, SegmentString ss1) {
    List<Coordinate> pts0 = ss0.getCoordinates();
    List<Coordinate> pts1 = ss1.getCoordinates();
    for (int i0 = 0; i0 < pts0.length - 1; i0++) {
      for (int i1 = 0; i1 < pts1.length - 1; i1++) {
        __checkInteriorIntersections(ss0, i0, ss1, i1);
      }
    }
  }

  /**private */ void __checkInteriorIntersections(
      SegmentString e0, int segIndex0, SegmentString e1, int segIndex1) {
    if (e0 == e1 && segIndex0 == segIndex1) return;
//numTests++;
    Coordinate p00 = e0.getCoordinate(segIndex0);
    Coordinate p01 = e0.getCoordinate(segIndex0 + 1);
    Coordinate p10 = e1.getCoordinate(segIndex1);
    Coordinate p11 = e1.getCoordinate(segIndex1 + 1);

    li.computeIntersection4Coord(p00, p01, p10, p11);
    if (li.hasIntersection()) {
      if (li.isProper ||
          hasInteriorIntersection(li, p00, p01) ||
          hasInteriorIntersection(li, p10, p11)) {
        throw new Exception("found non-noded intersection at " +
            p00.toString() +
            "-" +
            p01.toString() +
            " and " +
            p10.toString() +
            "-" +
            p11.toString());
      }
    }
  }

  /**
   *@return true if there is an intersection point which is not an endpoint of the segment p0-p1
   */
  /**private */ bool hasInteriorIntersection(
      LineIntersector li, Coordinate p0, Coordinate p1) {
    for (int i = 0; i < li.getIntersectionNum(); i++) {
      Coordinate intPt = li.getIntersection(i);
      if (!(intPt.equals(p0) || intPt.equals(p1))) {
        return true;
      }
    }
    return false;
  }

  /**
   * Checks for intersections between an endpoint of a segment string
   * and an interior vertex of another segment string
   */
  /**private */ void checkEndPtVertexIntersections() {
    for (Iterator i = segStrings.iterator; i.moveNext();) {
      SegmentString ss = i.current;
      List<Coordinate> pts = ss.getCoordinates();
      _checkEndPtVertexIntersections(pts[0], segStrings);
      _checkEndPtVertexIntersections(pts[pts.length - 1], segStrings);
    }
  }

  /**private */ void _checkEndPtVertexIntersections(
      Coordinate testPt, Iterable segStrings) {
    for (Iterator i = segStrings.iterator; i.moveNext();) {
      SegmentString ss = i.current;
      List<Coordinate> pts = ss.getCoordinates();
      for (int j = 1; j < pts.length - 1; j++) {
        if (pts[j].equals(testPt)) {
          throw new Exception(
              "found endpt/interior pt intersection at index $j :pt $testPt");
        }
      }
    }
  }
}
