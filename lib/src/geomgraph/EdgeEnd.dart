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

// import org.locationtech.jts.algorithm.BoundaryNodeRule;
// import org.locationtech.jts.algorithm.Orientation;
// import org.locationtech.jts.geom.Coordinate;
// import org.locationtech.jts.geom.Quadrant;
// import org.locationtech.jts.util.Assert;

import 'package:jtscore4dart/src/algorithm/BoundaryNodeRule.dart';
import 'package:jtscore4dart/src/algorithm/Orientation.dart';
import 'package:jtscore4dart/src/geom/Coordinate.dart';
import 'package:jtscore4dart/src/geom/Quadrant.dart';
import 'package:jtscore4dart/src/util/Assert.dart';

import 'Edge.dart';
import 'Label.dart';
import 'Node.dart';

/**
 * Models the end of an edge incident on a node.
 * EdgeEnds have a direction
 * determined by the direction of the ray from the initial
 * point to the next point.
 * EdgeEnds are comparable under the ordering
 * "a has a greater angle with the x-axis than b".
 * This ordering is used to sort EdgeEnds around a node.
 * @version 1.7
 */
class EdgeEnd implements Comparable
{
 /**protected */Edge edge;  // the parent edge of this edge end
 /**protected */Label? label;

 /**private */late Node node;          // the node this edge end originates at
 /**private */late Coordinate p0, p1;  // points of initial line segment
 /**private */late double dx, dy;      // the direction vector for this edge from its starting point
 /**private */late int quadrant;

 /**protected */
 EdgeEnd(this.edge);

  // EdgeEnd(Edge edge, Coordinate p0, Coordinate p1) {
  //   this(edge, p0, p1, null);
  // }
  EdgeEnd.Coord2(this.edge, Coordinate p0, Coordinate p1, [this.label]) {
    init(p0, p1);
  }

 /**protected */
 void init(Coordinate p0, Coordinate p1)
  {
    this.p0 = p0;
    this.p1 = p1;
    dx = p1.x - p0.x;
    dy = p1.y - p0.y;
    quadrant = Quadrant.quadrant(dx, dy);
    Assert.isTrue(! (dx == 0 && dy == 0), "EdgeEnd with identical endpoints found");
  }

  Edge getEdge() { return edge; }
  Label? getLabel() { return label; }
  Coordinate getCoordinate() { return p0; }
  Coordinate getDirectedCoordinate() { return p1; }
  int getQuadrant() { return quadrant; }
  double getDx() { return dx; }
  double getDy() { return dy; }

  void setNode(Node node) { this.node = node; }
  Node getNode() { return node; }

  @override
  int compareTo(var obj)
  {
      EdgeEnd e =  obj as EdgeEnd;
      return compareDirection(e);
  }
  /**
   * Implements the total order relation:
   * <p>
   *    a has a greater angle with the positive x-axis than b
   * <p>
   * Using the obvious algorithm of simply computing the angle is not robust,
   * since the angle calculation is obviously susceptible to roundoff.
   * A robust algorithm is:
   * - first compare the quadrant.  If the quadrants
   * are different, it it trivial to determine which vector is "greater".
   * - if the vectors lie in the same quadrant, the computeOrientation function
   * can be used to decide the relative orientation of the vectors.
   *
   * @param e EdgeEnd
   * @return direction comparison
   */
  int compareDirection(EdgeEnd e)
  {
    if (dx == e.dx && dy == e.dy) {
      return 0;
    }
    // if the rays are in different quadrants, determining the ordering is trivial
    if (quadrant > e.quadrant) return 1;
    if (quadrant < e.quadrant) return -1;
    // vectors are in the same quadrant - check relative orientation of direction vectors
    // this is > e if it is CCW of e
    return Orientation.index(e.p0, e.p1, p1);
  }

  void computeLabel(BoundaryNodeRule boundaryNodeRule)
  {
    // subclasses should override this if they are using labels
    print('>>>>>>>>>   : EdgeEnd.computeLabel <<<<<<<<<<<<<<<<<<<<');
  }

  // void print(PrintStream out)
  // {
  //   double angle = math.atan2(dy, dx);
  //   String className = getClass().getName();
  //   int lastDotPos = className.lastIndexOf('.');
  //   String name = className.substring(lastDotPos + 1);
  //   out.print("  " + name + ": " + p0 + " - " + p1 + " " + quadrant + ":" + angle + "   " + label);
  // }
  // String toString()
  // {
  //   double angle = math.atan2(dy, dx);
  //   String className = getClass().getName();
  //   int lastDotPos = className.lastIndexOf('.');
  //   String name = className.substring(lastDotPos + 1);
  //   return "  " + name + ": " + p0 + " - " + p1 + " " + quadrant + ":" + angle + "   " + label;
  // }
}
