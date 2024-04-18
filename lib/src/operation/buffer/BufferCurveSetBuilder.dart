// ignore_for_file: curly_braces_in_flow_control_structures

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
 * @version 1.7
 */
// import java.util.ArrayList;
// import java.util.List;

// import org.locationtech.jts.algorithm.Distance;
// import org.locationtech.jts.algorithm.Orientation;
// import org.locationtech.jts.geom.Coordinate;
// import org.locationtech.jts.geom.CoordinateArrays;
// import org.locationtech.jts.geom.Envelope;
// import org.locationtech.jts.geom.Geometry;
// import org.locationtech.jts.geom.GeometryCollection;
// import org.locationtech.jts.geom.LineString;
// import org.locationtech.jts.geom.LinearRing;
// import org.locationtech.jts.geom.Location;
// import org.locationtech.jts.geom.MultiLineString;
// import org.locationtech.jts.geom.MultiPoint;
// import org.locationtech.jts.geom.MultiPolygon;
// import org.locationtech.jts.geom.Point;
// import org.locationtech.jts.geom.Polygon;
// import org.locationtech.jts.geom.Position;
// import org.locationtech.jts.geom.PrecisionModel;
// import org.locationtech.jts.geom.Triangle;
// import org.locationtech.jts.geomgraph.Label;
// import org.locationtech.jts.noding.NodedSegmentString;
// import org.locationtech.jts.noding.SegmentString;

import 'dart:math';

import 'package:jtscore4dart/geometry.dart';
import 'package:jtscore4dart/src/algorithm/Distance.dart';
import 'package:jtscore4dart/src/algorithm/Orientation.dart';
import 'package:jtscore4dart/src/geom/Triangle.dart';
import 'package:jtscore4dart/src/geomgraph/Label.dart';
import 'package:jtscore4dart/src/noding/NodedSegmentString.dart';
import 'package:jtscore4dart/src/noding/SegmentString.dart';

import 'BufferParameters.dart';
import 'OffsetCurveBuilder.dart';

/**
 * Creates all the raw offset curves for a buffer of a {@link Geometry}.
 * Raw curves need to be noded together and polygonized to form the final buffer area.
 *
 * @version 1.7
 */
class BufferCurveSetBuilder {
  /**private */ Geometry inputGeom;
  /**private */ double distance;
  /**private */ OffsetCurveBuilder curveBuilder;

//  /**private */List curveList = [];
  /**private */ List<NodedSegmentString> curveList = [];

  /**private */ bool isInvertOrientation = false;

  BufferCurveSetBuilder(this.inputGeom, this.distance,
      PrecisionModel precisionModel, BufferParameters bufParams)
      : this.curveBuilder = new OffsetCurveBuilder(precisionModel, bufParams);
  // {
  //   this.curveBuilder = new OffsetCurveBuilder(precisionModel, bufParams);
  // }

  /**
   * Sets whether the offset curve is generated 
   * using the inverted orientation of input rings.
   * This allows generating a buffer(0) polygon from the smaller lobes
   * of self-crossing rings.
   * 
   * @param isInvertOrientation true if input ring orientation should be inverted
   */
  void setInvertOrientation(bool isInvertOrientation) {
    this.isInvertOrientation = isInvertOrientation;
  }

  /**
   * Computes orientation of a ring using a signed-area orientation test. 
   * For invalid (self-crossing) rings this ensures the largest enclosed area
   * is taken to be the interior of the ring.
   * This produces a more sensible result when
   * used for repairing polygonal geometry via buffer-by-zero.
   * For buffer  use the lower robustness of orientation-by-area
   * doesn't matter, since narrow or flat rings
   * produce an acceptable offset curve for either orientation.
   * 
   * @param coord the ring coordinates
   * @return true if the ring is CCW
   */
  /**private */ bool isRingCCW(List<Coordinate> coord) {
    bool isCCW = Orientation.isCCWArea(coord);
    //--- invert orientation if required
    if (isInvertOrientation) return !isCCW;
    return isCCW;
  }

  /**
   * Computes the set of raw offset curves for the buffer.
   * Each offset curve has an attached {@link Label} indicating
   * its left and right location.
   *
   * @return a Collection of SegmentStrings representing the raw buffer curves
   */
  List<NodedSegmentString> getCurves() {
    add(inputGeom);
    return curveList;
  }

  /**
   * Creates a {@link SegmentString} for a coordinate list which is a raw offset curve,
   * and adds it to the list of buffer curves.
   * The SegmentString is tagged with a Label giving the topology of the curve.
   * The curve may be oriented in either direction.
   * If the curve is oriented CW, the locations will be:
   * <br>Left: Location.EXTERIOR
   * <br>Right: Location.INTERIOR
   */
  /**private */ void addCurve(
      List<Coordinate> coord, int leftLoc, int rightLoc) {
    // don't add null or trivial curves
    if (coord == null || coord.length < 2) return;
    // add the edge for a coordinate list which is a raw offset curve
    SegmentString e = NodedSegmentString(
        coord, Label.GeomFrom3(0, Location.BOUNDARY, leftLoc, rightLoc));
    print(
        '>>>>>>>>> e: ${Label.GeomFrom3(0, Location.BOUNDARY, leftLoc, rightLoc)} <<<<<<<<<<<<<<<<<<<<');
    curveList.add(e as NodedSegmentString);
  }

  /**private */ void add(Geometry g) {
    if (g.isEmpty()) return;

    if (g is Polygon)
      addPolygon(g);
    else if (g is LineString)
      addLineString(g);
    else if (g is Point)
      addPoint(g);
    else if (g is MultiPoint)
      addCollection(g);
    else if (g is MultiLineString)
      addCollection(g);
    else if (g is MultiPolygon)
      addCollection(g);
    else if (g is GeometryCollection)
      addCollection(g);
    // else  throw new UnsupportedOperationException(g.getClass().getName());
    else
      throw Exception(
          "UnsupportedOperationException BufferCurveSetBuilder#add");
  }

  /**private */ void addCollection(GeometryCollection gc) {
    for (int i = 0; i < gc.getNumGeometries(); i++) {
      Geometry g = gc.getGeometryN(i);
      add(g);
    }
  }

  /**
   * Add a Point to the graph.
   */
  /**private */ void addPoint(Point p) {
    // a zero or negative width buffer of a point is empty
    if (distance <= 0.0) {
      return;
    }
    List<Coordinate> coord = p.getCoordinates();
    // skip if coordinate is invalid
    if (coord.isNotEmpty && !coord[0].isValid()) {
      return;
    }

    // distance > 0 && !isSingleSided  => curve 不为 null
    List<Coordinate> curve = curveBuilder.getLineCurve(coord, distance)!;
    addCurve(curve, Location.EXTERIOR, Location.INTERIOR);
  }

  /**private */ void addLineString(LineString line) {
    if (curveBuilder.isLineOffsetEmpty(distance)) return;

    List<Coordinate> coord = clean(line.getCoordinates());

    /**
     * Rings (closed lines) are generated with a continuous curve, 
     * with no end arcs. This produces better quality linework, 
     * and avoids noding issues with arcs around almost-parallel end segments.
     * See JTS #523 and #518.
     * 
     * Singled-sided buffers currently treat rings as if they are lines.
     */
    if (CoordinateArrays.isRing(coord) &&
        !curveBuilder.getBufferParameters().isSingleSided) {
      addRingBothSides(coord, distance);
    } else {
      List<Coordinate> curve = curveBuilder.getLineCurve(coord, distance)!;
      addCurve(curve, Location.EXTERIOR, Location.INTERIOR);
    }
    // TESTING
    //List<Coordinate> curveTrim = BufferCurveLoopPruner.prune(curve);
    //addCurve(curveTrim, Location.EXTERIOR, Location.INTERIOR);
  }

  /**
   * Keeps only valid coordinates, and removes repeated points.
   * 
   * @param coordinates the coordinates to clean
   * @return an array of clean coordinates
   */
  /**private */ static List<Coordinate> clean(List<Coordinate> coords) {
    return CoordinateArrays.removeRepeatedOrInvalidPoints(coords);
  }

  /**private */ void addPolygon(Polygon p) {
    double offsetDistance = distance;
    int offsetSide = Position.LEFT;

    if (distance < 0.0) {
      offsetDistance = -distance;
      offsetSide = Position.RIGHT;
    }

    LinearRing shell = p.getExteriorRing();
    List<Coordinate> shellCoord = clean(shell.getCoordinates());
    // optimization - don't bother computing buffer
    // if the polygon would be completely eroded
    if (distance < 0.0 && isErodedCompletely(shell, distance)) {
      return;
    }
    // don't attempt to buffer a polygon with too few distinct vertices
    if (distance <= 0.0 && shellCoord.length < 3) {
      return;
    }

    _addRingSide(shellCoord, offsetDistance, offsetSide, Location.EXTERIOR,
        Location.INTERIOR);

    for (int i = 0; i < p.getNumInteriorRing(); i++) {
      LinearRing hole = p.getInteriorRingN(i);
      List<Coordinate> holeCoord = clean(hole.getCoordinates());

      // optimization - don't bother computing buffer for this hole
      // if the hole would be completely covered
      if (distance > 0.0 && isErodedCompletely(hole, -distance)) {
        continue;
      }

      // Holes are topologically labelled opposite to the shell, since
      // the interior of the polygon lies on their opposite side
      // (on the left, if the hole is oriented CCW)
      _addRingSide(holeCoord, offsetDistance, Position.opposite(offsetSide),
          Location.INTERIOR, Location.EXTERIOR);
    }
  }

  /**private */
  void addRingBothSides(List<Coordinate> coord, double distance) {
    _addRingSide(
        coord, distance, Position.LEFT, Location.EXTERIOR, Location.INTERIOR);
    /* Add the opposite side of the ring
    */
    _addRingSide(
        coord, distance, Position.RIGHT, Location.INTERIOR, Location.EXTERIOR);
  }

  /**
   * Adds an offset curve for one side of a ring.
   * The side and left and right topological location arguments
   * are provided as if the ring is oriented CW.
   * (If the ring is in the opposite orientation,
   * this is detected and 
   * the left and right locations are interchanged and the side is flipped.)
   *
   * @param [coord] the coordinates of the ring (must not contain repeated points)
   * @param [offsetDistance] the positive distance at which to create the buffer
   * @param [side] the side {@link Position} of the ring on which to construct the buffer line
   * @param [cwLeftLoc] the location on the L side of the ring (if it is CW)
   * @param [cwRightLoc] the location on the R side of the ring (if it is CW)
   */
  void _addRingSide(List<Coordinate> coord, double offsetDistance, int side,
      int cwLeftLoc, int cwRightLoc) {
    // don't bother adding ring if it is "flat" and will disappear in the output
    if (offsetDistance == 0.0 && coord.length < LinearRing.MINIMUM_VALID_SIZE) {
      return;
    }

    int leftLoc = cwLeftLoc;
    int rightLoc = cwRightLoc;
    bool isCCW = isRingCCW(coord);
    if (coord.length >= LinearRing.MINIMUM_VALID_SIZE && isCCW) {
      leftLoc = cwRightLoc;
      rightLoc = cwLeftLoc;
      side = Position.opposite(side);
    }
    List<Coordinate>? curve =
        curveBuilder.getRingCurve(coord, side, offsetDistance);

    /**
     * If the offset curve has inverted completely it will produce
     * an unwanted artifact in the result, so skip it. 
     */
    if (isRingCurveInverted(coord, offsetDistance, curve!)) {
      return;
    }

    addCurve(curve, leftLoc, rightLoc);
  }

  /**private */ static const int MAX_INVERTED_RING_SIZE = 9;
  /**private */ static const int INVERTED_CURVE_VERTEX_FACTOR = 4;
  /**private */ static const double NEARNESS_FACTOR = 0.99;

  /**
   * Tests whether the offset curve for a ring is fully inverted. 
   * An inverted ("inside-out") curve occurs in some specific situations 
   * involving a buffer distance which should result in a fully-eroded (empty) buffer.
   * It can happen that the sides of a small, convex polygon 
   * produce offset segments which all cross one another to form
   * a curve with inverted orientation.
   * This happens at buffer distances slightly greater than the distance at 
   * which the buffer should disappear.
   * The inverted curve will produce an incorrect non-empty buffer (for a shell)
   * or an incorrect hole (for a hole).
   * It must be discarded from the set of offset curves used in the buffer.
   * Heuristics are used to reduce the number of cases which area checked,
   * for efficiency and correctness.
   * <p>
   * See https://github.com/locationtech/jts/issues/472
   * 
   * @param inputPts the input ring
   * @param distance the buffer distance
   * @param curvePts the generated offset curve
   * @return true if the offset curve is inverted
   */
  /**private */ static bool isRingCurveInverted(
      List<Coordinate> inputPts, double distance, List<Coordinate> curvePts) {
    if (distance == 0.0) return false;
    /**
     * Only proper rings can invert.
     */
    if (inputPts.length <= 3) return false;
    /**
     * Heuristic based on low chance that a ring with many vertices will invert.
     * This low limit ensures this test is fairly efficient.
     */
    if (inputPts.length >= MAX_INVERTED_RING_SIZE) return false;

    /**
     * Don't check curves which are much larger than the input.
     * This improves performance by avoiding checking some concave inputs 
     * (which can produce fillet arcs with many more vertices)
     */
    if (curvePts.length > INVERTED_CURVE_VERTEX_FACTOR * inputPts.length)
      return false;

    /**
     * Check if the curve vertices are all closer to the input ring
     * than the buffer distance.
     * If so, the curve is NOT a valid buffer curve.
     */
    double distTol = NEARNESS_FACTOR * (distance).abs();
    double maxDist = maxDistance(curvePts, inputPts);
    bool isCurveTooClose = maxDist < distTol;
    return isCurveTooClose;
  }

  /**
   * Computes the maximum distance out of a set of points to a linestring.
   * 
   * @param pts the points
   * @param line the linestring vertices
   * @return the maximum distance
   */
  /**private */ static double maxDistance(
      List<Coordinate> pts, List<Coordinate> line) {
    double maxDistance = 0;
    for (Coordinate p in pts) {
      double dist = Distance.pointToSegmentString(p, line);
      if (dist > maxDistance) {
        maxDistance = dist;
      }
    }
    return maxDistance;
  }

  /**
   * Tests whether a ring buffer is eroded completely (is empty)
   * based on simple heuristics.
   * 
   * The ringCoord is assumed to contain no repeated points.
   * It may be degenerate (i.e. contain only 1, 2, or 3 points).
   * In this case it has no area, and hence has a minimum diameter of 0.
   *
   * @param [ringCoord]
   * @param [offsetDistance]
   * @return
   */
  /**private */ static bool isErodedCompletely(
      LinearRing ring, double bufferDistance) {
    List<Coordinate> ringCoord = ring.getCoordinates();
    // degenerate ring has no area
    if (ringCoord.length < 4) {
      return bufferDistance < 0;
    }

    // important test to eliminate inverted triangle bug
    // also optimizes erosion test for triangles
    if (ringCoord.length == 4) {
      return isTriangleErodedCompletely(ringCoord, bufferDistance);
    }

    // if envelope is narrower than twice the buffer distance, ring is eroded
    // ring 的宽度比两倍的buffer 距离小就是无效的
    Envelope env = ring.getEnvelopeInternal();
    double envMinDimension = min(env.getHeight(), env.getWidth());
    if (bufferDistance < 0.0 && 2 * (bufferDistance).abs() > envMinDimension) {
      return true;
    }

    return false;
  }

  /**
   * Tests whether a triangular ring would be eroded completely by the given
   * buffer distance.
   * This is a precise test.  It uses the fact that the inner buffer of a
   * triangle converges on the inCentre of the triangle (the point
   * equidistant from all sides).  If the buffer distance is greater than the
   * distance of the inCentre from a side, the triangle will be eroded completely.
   *
   * This test is important, since it removes a problematic case where
   * the buffer distance is slightly larger than the inCentre distance.
   * In this case the triangle buffer curve "inverts" with incorrect topology,
   * producing an incorrect hole in the buffer.
   *
   * @param triangleCoord
   * @param bufferDistance
   * @return
   */
  /**private */ static bool isTriangleErodedCompletely(
      List<Coordinate> triangleCoord, double bufferDistance) {
    Triangle tri =
        new Triangle(triangleCoord[0], triangleCoord[1], triangleCoord[2]);
    Coordinate inCentre = tri.inCentre();
    double distToCentre = Distance.pointToSegment(inCentre, tri.p0, tri.p1);
    return distToCentre < (bufferDistance).abs();
  }
}
