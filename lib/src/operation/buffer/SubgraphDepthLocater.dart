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


// import java.util.ArrayList;
// import java.util.Collection;
// import java.util.Collections;
// import java.util.Comparator;
// import java.util.Iterator;
// import java.util.List;

// import org.locationtech.jts.algorithm.Orientation;
// import org.locationtech.jts.geom.Coordinate;
// import org.locationtech.jts.geom.Envelope;
// import org.locationtech.jts.geom.LineSegment;
// import org.locationtech.jts.geom.Position;
// import org.locationtech.jts.geomgraph.DirectedEdge;

import 'dart:math';

import 'package:jtscore4dart/src/algorithm/Orientation.dart';
import "package:jtscore4dart/src/geom/Coordinate.dart";
import 'package:jtscore4dart/src/geom/LineSegment.dart';
import 'package:jtscore4dart/src/geom/Envelope.dart';
import 'package:jtscore4dart/src/geom/Position.dart';
import 'package:jtscore4dart/src/geomgraph/DirectedEdge.dart';

import 'package:jtscore4dart/src/patch/ArrayList.dart';

import 'BufferSubgraph.dart';
/**
 * Locates a subgraph inside a set of subgraphs,
 * in order to determine the outside depth of the subgraph.
 * The input subgraphs are assumed to have had depths
 * already calculated for their edges.
 *
 * @version 1.7
 */
class SubgraphDepthLocater
{
//  /**private */Collection subgraphs;
 /**private */Iterable subgraphs;
 /**private */LineSegment seg = new LineSegment.empty();

  SubgraphDepthLocater(List this.subgraphs);

  int getDepth(Coordinate p)
  {
    List stabbedSegments = findStabbedSegments(p);
    // if no segments on stabbing line subgraph must be outside all others.
    if (stabbedSegments.size() == 0) {
      return 0;
    }
    /// TODO: @ruier edit.bugs : 先解决报错，后面来处理。。。
    // DepthSegment ds =  Collections.min(stabbedSegments) as DepthSegment;
    DepthSegment ds =  stabbedSegments.firstOrNull as DepthSegment;
    return ds.leftDepth;
  }

  /**
   * Finds all non-horizontal segments intersecting the stabbing line.
   * The stabbing line is the ray to the right of stabbingRayLeftPt.
   *
   * @param stabbingRayLeftPt the left-hand origin of the stabbing line
   * @return a List of {@link DepthSegments} intersecting the stabbing line
   */
 /**private */List findStabbedSegments(Coordinate stabbingRayLeftPt)
  {
    List stabbedSegments = [];
    for (Iterator i = subgraphs.iterator; i.moveNext(); ) {
      BufferSubgraph bsg = i.current as BufferSubgraph;

      // optimization - don't bother checking subgraphs which the ray does not intersect
      Envelope env = bsg.getEnvelope();
      if (stabbingRayLeftPt.y < env.getMinY()
          || stabbingRayLeftPt.y > env.getMaxY()) {
        continue;
      }

      _findStabbedSegments(stabbingRayLeftPt, bsg.getDirectedEdges(), stabbedSegments);
    }
    return stabbedSegments;
  }

  /**
   * Finds all non-horizontal segments intersecting the stabbing line
   * in the list of dirEdges.
   * The stabbing line is the ray to the right of stabbingRayLeftPt.
   *
   * @param stabbingRayLeftPt the left-hand origin of the stabbing line
   * @param stabbedSegments the current list of {@link DepthSegments} intersecting the stabbing line
   */
 /**private */void _findStabbedSegments(Coordinate stabbingRayLeftPt,
                                   List dirEdges,
                                   List stabbedSegments)
  {
    /**
     * Check all forward DirectedEdges only.  This is still general,
     * because each Edge has a forward DirectedEdge.
     */
    for (Iterator i = dirEdges.iterator; i.moveNext();) {
      DirectedEdge de =  i.current as DirectedEdge;
      if (! de.isForward()) {
        continue;
      }
      __findStabbedSegments(stabbingRayLeftPt, de, stabbedSegments);
    }
  }

  /**
   * Finds all non-horizontal segments intersecting the stabbing line
   * in the input dirEdge.
   * The stabbing line is the ray to the right of stabbingRayLeftPt.
   *
   * @param stabbingRayLeftPt the left-hand origin of the stabbing line
   * @param stabbedSegments the current list of {@link DepthSegments} intersecting the stabbing line
   */
 /**private */void __findStabbedSegments(Coordinate stabbingRayLeftPt,
                                   DirectedEdge dirEdge,
                                   List stabbedSegments)
  {
    List<Coordinate> pts = dirEdge.getEdge().getCoordinates();
    for (int i = 0; i < pts.length - 1; i++) {
      seg.p0 = pts[i];
      seg.p1 = pts[i + 1];
      // ensure segment always points upwards
      if (seg.p0.y > seg.p1.y) {
        seg.reverse();
      }

      // skip segment if it is left of the stabbing line
      double maxx = max(seg.p0.x, seg.p1.x);
      if (maxx < stabbingRayLeftPt.x) {
        continue;
      }

      // skip horizontal segments (there will be a non-horizontal one carrying the same depth info
      if (seg.isHorizontal()) {
        continue;
      }

      // skip if segment is above or below stabbing line
      if (stabbingRayLeftPt.y < seg.p0.y || stabbingRayLeftPt.y > seg.p1.y) {
        continue;
      }

      // skip if stabbing ray is right of the segment
      if (Orientation.index(seg.p0, seg.p1, stabbingRayLeftPt)
          == Orientation.RIGHT) {
        continue;
      }

      // stabbing line cuts this segment, so record it
      int depth = dirEdge.getDepth(Position.LEFT);
      // if segment direction was flipped, use RHS depth instead
      if (! seg.p0.equals(pts[i])) {
        depth = dirEdge.getDepth(Position.RIGHT);
      }
      DepthSegment ds = new DepthSegment(seg, depth);
      stabbedSegments.add(ds);
    }
  }


}



  /**
   * A segment from a directed edge which has been assigned a depth value
   * for its sides.
   */

  /**static */ class DepthSegment
      implements Comparable
  {
   /**private */LineSegment upwardSeg;
   /**private */int leftDepth;

    DepthSegment(LineSegment seg, this.leftDepth)
      :upwardSeg = new LineSegment.fromAnother(seg);
    // {
    //   // Assert: input seg is upward (p0.y <= p1.y)
    //   this.leftDepth = depth;
    // }
    // DepthSegment(LineSegment seg, int depth)
    // {
    //   // Assert: input seg is upward (p0.y <= p1.y)
    //   upwardSeg = new LineSegment(seg);
    //   this.leftDepth = depth;
    // }
    
    bool isUpward() {
      return upwardSeg.p0.y <= upwardSeg.p1.y;
    }
    
    /**
     * A comparison operation
     * which orders segments left to right.
     * <p>
     * The definition of the ordering is:
     * <ul>
     * <li>-1 : if DS1.seg is left of or below DS2.seg (DS1 < DS2)
     * <li>1 : if  DS1.seg is right of or above DS2.seg (DS1 > DS2) 
     * <li>0 : if the segments are identical 
     * </ul>
     * 
     * @param obj a DepthSegment
     * @return the comparison value
     */
    int compareTo(var obj)
    {
      DepthSegment other =  obj as DepthSegment;
      
      /**
       * If segment envelopes do not overlap, then
       * can use standard segment lexicographic ordering.
       */
      if (upwardSeg.minX() >= other.upwardSeg.maxX()
          || upwardSeg.maxX() <= other.upwardSeg.minX()
          || upwardSeg.minY() >= other.upwardSeg.maxY()
          || upwardSeg.maxY() <= other.upwardSeg.minY()) {
        return upwardSeg.compareTo(other.upwardSeg);
      }
      
      /**
       * Otherwise if envelopes overlap, use relative segment orientation.
       * 
       * Collinear segments should be evaluated by previous logic
       */
      int orientIndex = upwardSeg.orientationIndexOf(other.upwardSeg);
      if (orientIndex != 0) return orientIndex;

      /**
       * If comparison between this and other is indeterminate,
       * try the opposite call order.
       * The sign of the result needs to be flipped.
       */
      orientIndex = -1 * other.upwardSeg.orientationIndexOf(upwardSeg);
      if (orientIndex != 0) return orientIndex;

      /**
       * If segment envelopes overlap and they are collinear,
       * since segments do not cross they must be equal.
       */
      // assert: segments are equal
      return 0;
    }
    
    int OLDcompareTo(Object obj)
    {
      DepthSegment other =  obj as DepthSegment;
      
      // fast check if segments are trivially ordered along X
      if (upwardSeg.minX() > other.upwardSeg.maxX()) return 1;
      if (upwardSeg.maxX() < other.upwardSeg.minX()) return -1;
      
      /**
       * try and compute a determinate orientation for the segments.
       * Test returns 1 if other is left of this (i.e. this > other)
       */
      int orientIndex = upwardSeg.orientationIndexOf(other.upwardSeg);
      if (orientIndex != 0) return orientIndex;

      /**
       * If comparison between this and other is indeterminate,
       * try the opposite call order.
       * The sign of the result needs to be flipped.
       */
      orientIndex = -1 * other.upwardSeg.orientationIndexOf(upwardSeg);
      if (orientIndex != 0) return orientIndex;

      // otherwise, use standard lexicographic segment ordering
      return upwardSeg.compareTo(other.upwardSeg);
    }

    String toString()
    {
      return upwardSeg.toString();
    }
  }
