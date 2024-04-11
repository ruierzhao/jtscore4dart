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


// import java.io.PrintStream;

// import org.locationtech.jts.algorithm.LineIntersector;
// import org.locationtech.jts.geom.Coordinate;
// import org.locationtech.jts.geom.Envelope;
// import org.locationtech.jts.geom.IntersectionMatrix;
// import org.locationtech.jts.geom.Position;
// import org.locationtech.jts.geomgraph.index.MonotoneChainEdge;


import 'package:jtscore4dart/src/algorithm/LineIntersector.dart';
import 'package:jtscore4dart/src/geom/Coordinate.dart';
import 'package:jtscore4dart/src/geom/Envelope.dart';
import 'package:jtscore4dart/src/geom/IntersectionMatrix.dart';
import 'package:jtscore4dart/src/geom/Position.dart';

import 'index/MonotoneChainEdge.dart';

import 'EdgeIntersection.dart';
import 'Depth.dart';
import 'EdgeIntersectionList.dart';
import 'GraphComponent.dart';
import 'Label.dart';

/// @version 1.7
class Edge extends GraphComponent
{

  /// Updates an IM from the label for an edge.
  /// Handles edges from both L and A geometries.
  /// @param [label] Label defining position
  /// @param [im] intersection matrix
  /// TODO: @ruier edit.区别父类的命名。
  static void _updateIM(Label label, IntersectionMatrix im)
  {
    im.setAtLeastIfValid(label.getLocation(0, Position.ON), label.getLocation(1, Position.ON), 1);
    if (label.isArea()) {
      im.setAtLeastIfValid(label.getLocation(0, Position.LEFT),  label.getLocation(1, Position.LEFT),   2);
      im.setAtLeastIfValid(label.getLocation(0, Position.RIGHT), label.getLocation(1, Position.RIGHT),  2);
    }
  }

  List<Coordinate> pts;
 /**private */late Envelope env;
  late EdgeIntersectionList eiList;
 /**private */late String name;
 /**private */MonotoneChainEdge? mce;
 /**private */bool _isIsolated = true;
 /**private */Depth depth = new Depth();
 /**private */int depthDelta = 0;   // the change in area depth from the R to L side of this edge

 /// TODO: @ruier edit. label must init.
  Edge(this.pts, super.label)
  {
    this.eiList = new EdgeIntersectionList(this);
  }

  // Edge(Coordinate[] pts, Label label)
  // {
  //   this.pts = pts;
  //   this.label = label;
  // }
  // Edge(Coordinate[] pts)
  // {
  //   this(pts, null);
  // }


  int getNumPoints() { return pts.length; }
  void setName(String name) { this.name = name; }
  List<Coordinate> getCoordinates()  {    return pts;  }
  // public Coordinate getCoordinate(int i)
  // {
  //   return pts[i];
  // }
  // public Coordinate getCoordinate()
  // {
  //   if (pts.length > 0) return pts[0];
  //   return null;
  // }
  
  // @override
  // Coordinate? getCoordinate([int? i])
  // {
  //   if (i == null) {
  //     if (pts.isNotEmpty) return pts[0];
  //     return null; 
  //   }else
  //   return pts[i];
  // }

  Coordinate getCoordinate(int i)
  {
    if (i>=0 && i<pts.length) {
      return pts[i];
    }
    return pts[0];
  }

  Envelope getEnvelope()
  {
    // compute envelope lazily
    if (env == null) {
      env = new Envelope.init();
      for (int i = 0; i < pts.length; i++) {
        env.expandToIncludeCoordinate(pts[i]);
      }
    }
    return env;
  }

  Depth getDepth() { return depth; }

  /// The depthDelta is the change in depth as an edge is crossed from R to L
  /// @return the change in depth as the edge is crossed from R to L
  int getDepthDelta()  { return depthDelta;  }
  void setDepthDelta(int depthDelta)  { this.depthDelta = depthDelta;  }

  int getMaximumSegmentIndex()
  {
    return pts.length - 1;
  }
  EdgeIntersectionList getEdgeIntersectionList() { return eiList; }

  MonotoneChainEdge getMonotoneChainEdge()
  {
    // mce ??= MonotoneChainEdge(this);
    return mce ??= MonotoneChainEdge(this);
  }

  bool isClosed()
  {
    return pts[0].equals(pts[pts.length - 1]);
  }
  /// An Edge is collapsed if it is an Area edge and it consists of
  /// two segments which are equal and opposite (eg a zero-width V).
  ///
  /// @return zero-width V area edge, consisting of two segments which are equal and of oppose orientation
  bool isCollapsed()
  {
    if (! label.isArea()) return false;
    if (pts.length != 3) return false;
    if (pts[0].equals(pts[2]) ) return true;
    return false;
  }
  Edge getCollapsedEdge()
  {
    // Coordinate newPts[] = new Coordinate[2];
    // newPts[0] = pts[0];
    // newPts[1] = pts[1];
    List<Coordinate> newPts = List.generate(2, (i) => pts[i], growable: false);
    Edge newe = new Edge(newPts, Label.toLineLabel(label));
    return newe;
  }

  void setIsolated(bool isIsolated)
  {
    this._isIsolated = isIsolated;
  }
  @override
  bool isIsolated()
  {
    return _isIsolated;
  }

  /// Adds EdgeIntersections for one or both
  /// intersections found for a segment of an edge to the edge intersection list.
  /// @param li Determining number of intersections to add
  /// @param segmentIndex Segment index to add
  /// @param geomIndex Geometry index to add
  void addIntersections(LineIntersector li, int segmentIndex, int geomIndex)
  {
    for (int i = 0; i < li.getIntersectionNum(); i++) {
      addIntersection(li, segmentIndex, geomIndex, i);
    }
  }
  /// Add an EdgeIntersection for intersection intIndex.
  /// An intersection that falls exactly on a vertex of the edge is normalized
  /// to use the higher of the two possible segmentIndexes
  ///
  /// @param li Determining number of intersections to add
  /// @param segmentIndex Segment index to add
  /// @param geomIndex Geometry index to add
  /// @param intIndex intIndex is 0 or 1
  void addIntersection(LineIntersector li, int segmentIndex, int geomIndex, int intIndex)
  {
      Coordinate intPt = new Coordinate.fromAnother(li.getIntersection(intIndex));
      int normalizedSegmentIndex = segmentIndex;
      double dist = li.getEdgeDistance(geomIndex, intIndex);
      //Debug.println("edge intpt: " + intPt + " dist: " + dist);
      // normalize the intersection point location
      int nextSegIndex = normalizedSegmentIndex + 1;
      if (nextSegIndex < pts.length) {
        Coordinate nextPt = pts[nextSegIndex];
      //Debug.println("next pt: " + nextPt);

        // Normalize segment index if intPt falls on vertex
        // The check for point equality is 2D only - Z values are ignored
        if (intPt.equals2D(nextPt)) {
      //Debug.println("normalized distance");
            normalizedSegmentIndex = nextSegIndex;
            dist = 0.0;
        }
      }
      /**
      * Add the intersection point to edge intersection list.
      */
      EdgeIntersection ei = eiList.add(intPt, normalizedSegmentIndex, dist);
      //ei.print(System.out);

  }

  /// Update the IM with the contribution for this component.
  /// A component only contributes if it has a labelling for both parent geometries
  @override
  void computeIM(IntersectionMatrix im)
  {
    _updateIM(label, im);
  }

  /// equals is defined to be:
  /// <p>
  /// e1 equals e2
  /// <b>iff</b>
  /// the coordinates of e1 are the same or the reverse of the coordinates in e2
  bool equals(Object o)
  {
    if (o is! Edge) return false;
    Edge e = o as Edge;

    if (pts.length != e.pts.length) return false;

    bool isEqualForward = true;
    bool isEqualReverse = true;
    int iRev = pts.length;
    for (int i = 0; i < pts.length; i++) {
      if (! pts[i].equals2D(e.pts[i])) {
         isEqualForward = false;
      }
      if (! pts[i].equals2D(e.pts[--iRev])) {
         isEqualReverse = false;
      }
      if (! isEqualForward && ! isEqualReverse) return false;
    }
    return true;
  }

  /* (non-Javadoc)
   * @see java.lang.Object#hashCode()
   */
  @override
  int get hashCode {
    const int prime = 31;
    int result = 1;
    result = prime * result + pts.length;
    if (pts.isNotEmpty) {
      Coordinate p0 = pts[0];
      Coordinate p1 = pts[pts.length - 1];
      if (1 == p0.compareTo(p1)) {
        p0 = pts[pts.length - 1];
        p1 = pts[0];
      }
      result = prime * result + p0.hashCode;
      result = prime * result + p1.hashCode;
    }
    return result;
  }
  
  /// Check if coordinate sequences of the Edges are identical.
  ///
  /// @param e Edge
  /// @return true if the coordinate sequences of the Edges are identical
  bool isPointwiseEqual(Edge e)
  {
    if (pts.length != e.pts.length) return false;

    for (int i = 0; i < pts.length; i++) {
      if (! pts[i].equals2D(e.pts[i])) {
         return false;
      }
    }
    return true;
  }

  @override
  String toString()
  {
    StringBuffer builder = new StringBuffer();
    builder.write("edge " + name + ": ");
    builder.write("LINESTRING (");
    for (int i = 0; i < pts.length; i++) {
      if (i > 0) builder.write(",");
      builder.write("${pts[i].x} ${pts[i].y}");
    }
    builder.write(")  $label $depthDelta" );
    return builder.toString();
  }
  

  // void print(PrintStream out)
  // {
  //   out.print("edge " + name + ": ");
  //   out.print("LINESTRING (");
  //   for (int i = 0; i < pts.length; i++) {
  //     if (i > 0) out.print(",");
  //     out.print(pts[i].x + " " + pts[i].y);
  //   }
  //   out.print(")  " + label + " " + depthDelta);
  // }
  // void printReverse(PrintStream out)
  // {
  //   out.print("edge " + name + ": ");
  //   for (int i = pts.length - 1; i >= 0; i--) {
  //     out.print(pts[i] + " ");
  //   }
  //   out.println("");
  // }

}
