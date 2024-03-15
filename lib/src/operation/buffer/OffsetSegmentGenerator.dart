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


// import org.locationtech.jts.algorithm.Angle;
// import org.locationtech.jts.algorithm.Distance;
// import org.locationtech.jts.algorithm.Intersection;
// import org.locationtech.jts.algorithm.LineIntersector;
// import org.locationtech.jts.algorithm.Orientation;
// import org.locationtech.jts.algorithm.RobustLineIntersector;
// import org.locationtech.jts.geom.Coordinate;
// import org.locationtech.jts.geom.LineSegment;
// import org.locationtech.jts.geom.Position;
// import org.locationtech.jts.geom.PrecisionModel;

import 'dart:math';

import 'package:jtscore4dart/src/algorithm/Angle.dart';
import 'package:jtscore4dart/src/algorithm/Distance.dart';
import 'package:jtscore4dart/src/algorithm/Intersection.dart';
import 'package:jtscore4dart/src/algorithm/LineIntersector.dart';
import 'package:jtscore4dart/src/algorithm/Orientation.dart';
import 'package:jtscore4dart/src/algorithm/RobustLineIntersector.dart';
import 'package:jtscore4dart/src/geom/Coordinate.dart';
import 'package:jtscore4dart/src/geom/LineSegment.dart';
import 'package:jtscore4dart/src/geom/Position.dart';
import 'package:jtscore4dart/src/geom/PrecisionModel.dart';

import '../../utils.dart';
import 'BufferParameters.dart';
import 'OffsetSegmentString.dart';

/**
 * Generates segments which form an offset curve.
 * Supports all end cap and join options 
 * provided for buffering.
 * This algorithm implements various heuristics to 
 * produce smoother, simpler curves which are
 * still within a reasonable tolerance of the 
 * true curve.
 * 
 * @author Martin Davis
 *
 */
class OffsetSegmentGenerator 
{

  /**
   * Factor controlling how close offset segments can be to
   * skip adding a fillet or mitre.
   * This eliminates very short fillet segments, 
   * reduces the number of offset curve vertices.
   * and improves the robustness of mitre construction.
   */
 /**private */static const double OFFSET_SEGMENT_SEPARATION_FACTOR = .05;
  
  /**
   * Factor controlling how close curve vertices on inside turns can be to be snapped 
   */
 /**private */static const double INSIDE_TURN_VERTEX_SNAP_DISTANCE_FACTOR = 1.0E-3;

  /**
   * Factor which controls how close curve vertices can be to be snapped
   */
 /**private */static const double CURVE_VERTEX_SNAP_DISTANCE_FACTOR = 1.0E-6;

  /**
   * Factor which determines how short closing segs can be for round buffers
   */
 /**private */static const int MAX_CLOSING_SEG_LEN_FACTOR = 80;

  /**
   * the max error of approximation (distance) between a quad segment and the true fillet curve
   */
 /**private */double maxCurveSegmentError = 0.0;

  /**
   * The angle quantum with which to approximate a fillet curve
   * (based on the input # of quadrant segments)
   */
 /**private */late double filletAngleQuantum;

  /**
   * The Closing Segment Length Factor controls how long
   * "closing segments" are.  Closing segments are added
   * at the middle of inside corners to ensure a smoother
   * boundary for the buffer offset curve. 
   * In some cases (particularly for round joins with default-or-better
   * quantization) the closing segments can be made quite short.
   * This substantially improves performance (due to fewer intersections being created).
   * 
   * A closingSegFactor of 0 results in lines to the corner vertex
   * A closingSegFactor of 1 results in lines halfway to the corner vertex
   * A closingSegFactor of 80 results in lines 1/81 of the way to the corner vertex
   * (this option is reasonable for the very common default situation of round joins
   * and quadrantSegs >= 8)
   */
 /**private */int closingSegLengthFactor = 1;

 /**private */late OffsetSegmentString segList;
 /**private */double distance = 0.0;
 /**private */PrecisionModel precisionModel;
 /**private */BufferParameters bufParams;
 /**private */late LineIntersector li;

 /**private */late Coordinate s0, s1, s2;
 /**private */LineSegment seg0 = new LineSegment.empty();
 /**private */LineSegment seg1 = new LineSegment.empty();
 /**private */LineSegment offset0 = new LineSegment.empty();
 /**private */LineSegment offset1 = new LineSegment.empty();
 /**private */int side = 0;
 /**private */bool _hasNarrowConcaveAngle = false;

  OffsetSegmentGenerator(this.precisionModel,this.bufParams, double distance) {
    this.li = new RobustLineIntersector();
    
    int quadSegs = bufParams.getQuadrantSegments();
    if (quadSegs < 1) quadSegs = 1;
    this.filletAngleQuantum = Angle.PI_OVER_2 / quadSegs;

    /**
     * Non-round joins cause issues with short closing segments, so don't use
     * them. In any case, non-round joins only really make sense for relatively
     * small buffer distances.
     */
    if (bufParams.getQuadrantSegments() >= 8
        && bufParams.getJoinStyle() == BufferParameters.JOIN_ROUND) {
      closingSegLengthFactor = MAX_CLOSING_SEG_LEN_FACTOR;
    }
    init(distance);
  }

  /**
   * Tests whether the input has a narrow concave angle
   * (relative to the offset distance).
   * In this case the generated offset curve will contain self-intersections
   * and heuristic closing segments.
   * This is expected behaviour in the case of Buffer curves. 
   * For pure Offset Curves,
   * the output needs to be further treated 
   * before it can be used. 
   * 
   * @return true if the input has a narrow concave angle
   */
  bool hasNarrowConcaveAngle()
  {
    return _hasNarrowConcaveAngle;
  }
  
 /**private */void init(double distance)
  {
    this.distance = (distance).abs();
    maxCurveSegmentError = this.distance * (1 - cos(filletAngleQuantum / 2.0));
    segList = new OffsetSegmentString();
    segList.setPrecisionModel(precisionModel);
    /**
     * Choose the min vertex separation as a small fraction of the offset distance.
     */
    segList.setMinimumVertexDistance(this.distance * CURVE_VERTEX_SNAP_DISTANCE_FACTOR);
  }


  void initSideSegments(Coordinate s1, Coordinate s2, int side)
  {
    this.s1 = s1;
    this.s2 = s2;
    this.side = side;
    seg1.setCoordinatesFromCoord(s1, s2);
    computeOffsetSegment(seg1, side, distance, offset1);
  }

  List<Coordinate> getCoordinates()
  {
    List<Coordinate> pts = segList.getCoordinates();
    return pts;
  }
  
  void closeRing()
  {
    segList.closeRing();
  }
  
  void addSegments(List<Coordinate> pt, bool isForward)
  {
    segList.addPts(pt, isForward);
  }
  
  void addFirstSegment()
  {
    segList.addPt(offset1.p0);
  }
  
  /**
   * Add last offset point
   */
  void addLastSegment()
  {
    segList.addPt(offset1.p1);
  }

  //private static double MAX_CLOSING_SEG_LEN = 3.0;

  void addNextSegment(Coordinate p, bool addStartPoint)
  {
    // s0-s1-s2 are the coordinates of the previous segment and the current one
    s0 = s1;
    s1 = s2;
    s2 = p;
    seg0.setCoordinatesFromCoord(s0, s1);
    computeOffsetSegment(seg0, side, distance, offset0);
    seg1.setCoordinatesFromCoord(s1, s2);
    computeOffsetSegment(seg1, side, distance, offset1);

    // do nothing if points are equal
    if (s1.equals(s2)) return;

    int orientation = Orientation.index(s0, s1, s2);
    bool outsideTurn =
          (orientation == Orientation.CLOCKWISE        && side == Position.LEFT)
      ||  (orientation == Orientation.COUNTERCLOCKWISE && side == Position.RIGHT);

    if (orientation == 0) { // lines are collinear
      addCollinear(addStartPoint);
    }
    else if (outsideTurn) 
    {
      addOutsideTurn(orientation, addStartPoint);
    }
    else { // inside turn
      addInsideTurn(orientation, addStartPoint);
    }
  }
  
 /**private */void addCollinear(bool addStartPoint)
  {
    /**
     * This test could probably be done more efficiently,
     * but the situation of exact collinearity should be fairly rare.
     */
    li.computeIntersection(s0, s1, s1, s2);
    int numInt = li.getIntersectionNum();
    /**
     * if numInt is < 2, the lines are parallel and in the same direction. In
     * this case the point can be ignored, since the offset lines will also be
     * parallel.
     */
    if (numInt >= 2) {
      /**
       * segments are collinear but reversing. 
       * Add an "end-cap" fillet
       * all the way around to other direction This case should ONLY happen
       * for LineStrings, so the orientation is always CW. (Polygons can never
       * have two consecutive segments which are parallel but reversed,
       * because that would be a self intersection.
       * 
       */
      if (bufParams.getJoinStyle() == BufferParameters.JOIN_BEVEL 
          || bufParams.getJoinStyle() == BufferParameters.JOIN_MITRE) {
        if (addStartPoint) segList.addPt(offset0.p1);
        segList.addPt(offset1.p0);
      }
      else {
        addCornerFillet(s1, offset0.p1, offset1.p0, Orientation.CLOCKWISE, distance);
      }
    }
  }
  
  /**
   * Adds the offset points for an outside (convex) turn
   * 
   * @param orientation
   * @param addStartPoint
   */
 /**private */void addOutsideTurn(int orientation, bool addStartPoint)
  {
    /**
     * Heuristic: If offset endpoints are very close together,
     * (which happens for nearly-parallel segments),
     * use an endpoint as the single offset corner vertex.
     * This eliminates very short single-segment joins
     * and reduces the number of offset curve vertices.
     * This also avoids robustness problems with computing mitre corners 
     * for nearly-parallel segments.
     */
    if (offset0.p1.distance(offset1.p0) < distance * OFFSET_SEGMENT_SEPARATION_FACTOR) {
      //-- use endpoint of longest segment, to reduce change in area
      double segLen0 = s0.distance(s1);
      double segLen1 = s1.distance(s2);
      Coordinate offsetPt = (segLen0 > segLen1) ? offset0.p1 : offset1.p0;
      segList.addPt(offsetPt);
      return;
    }
    
    if (bufParams.getJoinStyle() == BufferParameters.JOIN_MITRE) {
      addMitreJoin(s1, offset0, offset1, distance);
    }
    else if (bufParams.getJoinStyle() == BufferParameters.JOIN_BEVEL){
      addBevelJoin(offset0, offset1);
    }
    else {
      //-- add a circular fillet connecting the endpoints of the offset segments
      if (addStartPoint) {
        segList.addPt(offset0.p1);
      }
      addCornerFillet(s1, offset0.p1, offset1.p0, orientation, distance);
      segList.addPt(offset1.p0);
    }
  }
  
  /**
   * Adds the offset points for an inside (concave) turn.
   * 
   * @param orientation
   * @param addStartPoint
   */
 /**private */void addInsideTurn(int orientation, bool addStartPoint) {
    /**
     * add intersection point of offset segments (if any)
     */
    li.computeIntersection(offset0.p0, offset0.p1, offset1.p0, offset1.p1);
    if (li.hasIntersection()) {
      segList.addPt(li.getIntersection(0));
    }
    else {
      /**
       * If no intersection is detected, 
       * it means the angle is so small and/or the offset so
       * large that the offsets segments don't intersect. 
       * In this case we must
       * add a "closing segment" to make sure the buffer curve is continuous,
       * fairly smooth (e.g. no sharp reversals in direction)
       * and tracks the buffer correctly around the corner. The curve connects
       * the endpoints of the segment offsets to points
       * which lie toward the centre point of the corner.
       * The joining curve will not appear in the final buffer outline, since it
       * is completely internal to the buffer polygon.
       * 
       * In complex buffer cases the closing segment may cut across many other
       * segments in the generated offset curve.  In order to improve the 
       * performance of the noding, the closing segment should be kept as short as possible.
       * (But not too short, since that would defeat its purpose).
       * This is the purpose of the closingSegFactor heuristic value.
       */ 
      
       /** 
       * The intersection test above is vulnerable to robustness errors; i.e. it
       * may be that the offsets should intersect very close to their endpoints,
       * but aren't reported as such due to rounding. To handle this situation
       * appropriately, we use the following test: If the offset points are very
       * close, don't add closing segments but simply use one of the offset
       * points
       */
      _hasNarrowConcaveAngle = true;
      //System.out.println("NARROW ANGLE - distance = " + distance);
      if (offset0.p1.distance(offset1.p0) < distance
          * INSIDE_TURN_VERTEX_SNAP_DISTANCE_FACTOR) {
        segList.addPt(offset0.p1);
      } else {
        // add endpoint of this segment offset
        segList.addPt(offset0.p1);
        
        /**
         * Add "closing segment" of required length.
         */
        if (closingSegLengthFactor > 0) {
          Coordinate mid0 = new Coordinate((closingSegLengthFactor * offset0.p1.x + s1.x)/(closingSegLengthFactor + 1), 
              (closingSegLengthFactor*offset0.p1.y + s1.y)/(closingSegLengthFactor + 1));
          segList.addPt(mid0);
          Coordinate mid1 = new Coordinate((closingSegLengthFactor*offset1.p0.x + s1.x)/(closingSegLengthFactor + 1), 
             (closingSegLengthFactor*offset1.p0.y + s1.y)/(closingSegLengthFactor + 1));
          segList.addPt(mid1);
        }
        else {
          /**
           * This branch is not expected to be used except for testing purposes.
           * It is equivalent to the JTS 1.9 logic for closing segments
           * (which results in very poor performance for large buffer distances)
           */
          segList.addPt(s1);
        }
        
        //*/  
        // add start point of next segment offset
        segList.addPt(offset1.p0);
      }
    }
  }
  

  /**
   * Compute an offset segment for an input segment on a given side and at a given distance.
   * The offset points are computed in full double precision, for accuracy.
   *
   * @param seg the segment to offset
   * @param side the side of the segment ({@link Position}) the offset lies on
   * @param distance the offset distance
   * @param offset the points computed for the offset segment
   */
  static void computeOffsetSegment(LineSegment seg, int side, double distance, LineSegment offset)
  {
    int sideSign = side == Position.LEFT ? 1 : -1;
    double dx = seg.p1.x - seg.p0.x;
    double dy = seg.p1.y - seg.p0.y;
    double len = hypot(dx, dy);
    // u is the vector that is the length of the offset, in the direction of the segment
    double ux = sideSign * distance * dx / len;
    double uy = sideSign * distance * dy / len;
    offset.p0.x = seg.p0.x - uy;
    offset.p0.y = seg.p0.y + ux;
    offset.p1.x = seg.p1.x - uy;
    offset.p1.y = seg.p1.y + ux;
  }

  /**
   * Add an end cap around point p1, terminating a line segment coming from p0
   */
  void addLineEndCap(Coordinate p0, Coordinate p1)
  {
    LineSegment seg = new LineSegment(p0, p1);

    LineSegment offsetL = new LineSegment.empty();
    computeOffsetSegment(seg, Position.LEFT, distance, offsetL);
    LineSegment offsetR = new LineSegment.empty();
    computeOffsetSegment(seg, Position.RIGHT, distance, offsetR);

    double dx = p1.x - p0.x;
    double dy = p1.y - p0.y;
    double angle = atan2(dy, dx);

    switch (bufParams.getEndCapStyle()) {
      case BufferParameters.CAP_ROUND:
        // add offset seg points with a fillet between them
        segList.addPt(offsetL.p1);
        addDirectedFillet(p1, angle + Angle.PI_OVER_2, angle - Angle.PI_OVER_2, Orientation.CLOCKWISE, distance);
        segList.addPt(offsetR.p1);
        break;
      case BufferParameters.CAP_FLAT:
        // only offset segment points are added
        segList.addPt(offsetL.p1);
        segList.addPt(offsetR.p1);
        break;
      case BufferParameters.CAP_SQUARE:
        // add a square defined by extensions of the offset segment endpoints
        Coordinate squareCapSideOffset = new Coordinate.empty2D();
        squareCapSideOffset.x = (distance).abs() * Angle.cosSnap(angle);
        squareCapSideOffset.y = (distance).abs() * Angle.sinSnap(angle);

        Coordinate squareCapLOffset = new Coordinate(
            offsetL.p1.x + squareCapSideOffset.x,
            offsetL.p1.y + squareCapSideOffset.y);
        Coordinate squareCapROffset = new Coordinate(
            offsetR.p1.x + squareCapSideOffset.x,
            offsetR.p1.y + squareCapSideOffset.y);
        segList.addPt(squareCapLOffset);
        segList.addPt(squareCapROffset);
        break;

    }
  }
  
  /**
   * Adds a mitre join connecting two convex offset segments.
   * The mitre is beveled if it exceeds the mitre limit factor.
   * The mitre limit is intended to prevent extremely int corners occurring.
   * If the mitre limit is very small it can cause unwanted artifacts around fairly flat corners.
   * This is prevented by using a simple bevel join in this case.
   * In other words, the limit prevents the corner from getting too long, 
   * but it won't force it to be very short/flat.
   * 
   * @param offset0 the first offset segment
   * @param offset1 the second offset segment
   * @param distance the offset distance
   */
 /**private */void addMitreJoin(Coordinate cornerPt, 
      LineSegment offset0, 
      LineSegment offset1,
      double distance)
  { 
    double mitreLimitDistance = bufParams.getMitreLimit() * distance;
    /**
     * First try a non-beveled join.
     * Compute the intersection point of the lines determined by the offsets.
     * Parallel or collinear lines will return a null point ==> need to be beveled
     * 
     * Note: This computation is unstable if the offset segments are nearly collinear.
     * However, this situation should have been eliminated earlier by the check
     * for whether the offset segment endpoints are almost coincident
     */
    Coordinate? intPt = Intersection.intersection(offset0.p0, offset0.p1, offset1.p0, offset1.p1);
    if (intPt != null && intPt.distance(cornerPt) <= mitreLimitDistance) {
        segList.addPt(intPt);
        return;
    }
    /**
     * In case the mitre limit is very small, try a plain bevel.
     * Use it if it's further than the limit.
     */
    double bevelDist = Distance.pointToSegment(cornerPt, offset0.p1, offset1.p0);
    if (bevelDist >= mitreLimitDistance) {
      addBevelJoin(offset0, offset1);
      return;
    }
    /**
     * Have to construct a limited mitre bevel.
     */
    addLimitedMitreJoin(offset0, offset1, distance, mitreLimitDistance);
  }
  
  /**
   * Adds a limited mitre join connecting two convex offset segments.
   * A limited mitre join is beveled at the distance
   * determined by the mitre limit factor,
   * or as a standard bevel join, whichever is further.
   * 
   * @param offset0 the first offset segment
   * @param offset1 the second offset segment
   * @param distance the offset distance
   * @param mitreLimitDistance the mitre limit distance
   */
 /**private */void addLimitedMitreJoin( 
      LineSegment offset0, 
      LineSegment offset1,
      double distance,
      double mitreLimitDistance)
  {
    Coordinate cornerPt = seg0.p1;
    // oriented angle of the corner formed by segments
    double angInterior = Angle.angleBetweenOriented(seg0.p0, cornerPt, seg1.p1);
    // half of the interior angle
    double angInterior2 = angInterior / 2;
  
    // direction of bisector of the interior angle between the segments
    double dir0 = Angle.angle(cornerPt, seg0.p0);
    double dirBisector = Angle.normalize(dir0 + angInterior2);
    
    // midpoint of the bevel segment
    Coordinate bevelMidPt = project(cornerPt, -mitreLimitDistance, dirBisector);
    
    // direction of bevel segment (at right angle to corner bisector)
    double dirBevel = Angle.normalize(dirBisector + Angle.PI_OVER_2);
    
    // compute the candidate bevel segment by projecting both sides of the midpoint
    Coordinate bevel0 = project(bevelMidPt, distance, dirBevel);
    Coordinate bevel1 = project(bevelMidPt, distance, dirBevel + pi);
    
    // compute actual bevel segment between the offset lines
    Coordinate? bevelInt0 = Intersection.lineSegment(offset0.p0, offset0.p1, bevel0, bevel1);
    Coordinate? bevelInt1 = Intersection.lineSegment(offset1.p0, offset1.p1, bevel0, bevel1);

    //-- add the limited bevel, if it intersects the offsets
    if (bevelInt0 != null && bevelInt1 != null) {
      segList.addPt(bevelInt0);
      segList.addPt(bevelInt1);      
      return;
    }
    /**
     * If the corner is very flat or the mitre limit is very small
     * the limited bevel segment may not intersect the offsets.
     * In this case just bevel the join.
     */
    addBevelJoin(offset0, offset1); 
  }
  
  /**
   * Projects a point to a given distance in a given direction angle.
   * 
   * @param pt the point to project
   * @param d the projection distance
   * @param dir the direction angle (in radians)
   * @return the projected point
   */
 /**private */static Coordinate project(Coordinate pt, double d, double dir) {
    double x = pt.x + d * Angle.cosSnap(dir);
    double y = pt.y + d * Angle.sinSnap(dir);
    return new Coordinate(x, y);
  }
  
  /**
   * Adds a bevel join connecting two offset segments
   * around a convex corner.
   * 
   * @param offset0 the first offset segment
   * @param offset1 the second offset segment
   */
 /**private */void addBevelJoin( 
      LineSegment offset0, 
      LineSegment offset1)
  {
     segList.addPt(offset0.p1);
     segList.addPt(offset1.p0);        
  }
  
  /**
   * Add points for a circular fillet around a convex corner.
   * Adds the start and end points
   * 
   * @param p base point of curve
   * @param p0 start point of fillet curve
   * @param p1 endpoint of fillet curve
   * @param direction the orientation of the fillet
   * @param radius the radius of the fillet
   */
 /**private */void addCornerFillet(Coordinate p, Coordinate p0, Coordinate p1, int direction, double radius)
  {
    double dx0 = p0.x - p.x;
    double dy0 = p0.y - p.y;
    double startAngle = atan2(dy0, dx0);
    double dx1 = p1.x - p.x;
    double dy1 = p1.y - p.y;
    double endAngle = atan2(dy1, dx1);

    if (direction == Orientation.CLOCKWISE) {
      if (startAngle <= endAngle) startAngle += Angle.PI_TIMES_2;
    }
    else {    // direction == COUNTERCLOCKWISE
      if (startAngle >= endAngle) startAngle -= Angle.PI_TIMES_2;
    }
    segList.addPt(p0);
    addDirectedFillet(p, startAngle, endAngle, direction, radius);
    segList.addPt(p1);
  }

  /**
   * Adds points for a circular fillet arc
   * between two specified angles.  
   * The start and end point for the fillet are not added -
   * the caller must add them if required.
   *
   * @param direction is -1 for a CW angle, 1 for a CCW angle
   * @param radius the radius of the fillet
   */
 /**private */void addDirectedFillet(Coordinate p, double startAngle, double endAngle, int direction, double radius)
  {
    int directionFactor = direction == Orientation.CLOCKWISE ? -1 : 1;

    double totalAngle = (startAngle - endAngle).abs();
    int nSegs = /**(int) */ (totalAngle / filletAngleQuantum + 0.5).floor();

    if (nSegs < 1) return;    // no segments because angle is less than increment - nothing to do!

     // choose angle increment so that each segment has equal length
    double angleInc = totalAngle / nSegs;

    Coordinate pt = new Coordinate.empty2D();
    for (int i = 0; i < nSegs; i++) {
      double angle = startAngle + directionFactor * i * angleInc;
      pt.x = p.x + radius * Angle.cosSnap(angle);
      pt.y = p.y + radius * Angle.sinSnap(angle);
      segList.addPt(pt);
    }
  }

  /**
   * Creates a CW circle around a point
   */
  void createCircle(Coordinate p)
  {
    // add start point
    Coordinate pt = new Coordinate(p.x + distance, p.y);
    segList.addPt(pt);
    addDirectedFillet(p, 0.0, Angle.PI_TIMES_2, -1, distance);
    segList.closeRing();
  }

  /**
   * Creates a CW square around a point
   */
  void createSquare(Coordinate p)
  {
    segList.addPt(new Coordinate(p.x + distance, p.y + distance));
    segList.addPt(new Coordinate(p.x + distance, p.y - distance));
    segList.addPt(new Coordinate(p.x - distance, p.y - distance));
    segList.addPt(new Coordinate(p.x - distance, p.y + distance));
    segList.closeRing();
  }
}
