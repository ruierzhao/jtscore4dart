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

// import org.locationtech.jts.geom.Location;
// import org.locationtech.jts.geom.Position;
// import org.locationtech.jts.geom.TopologyException;


import 'package:jtscore4dart/src/geom/Location.dart';
import 'package:jtscore4dart/src/geom/Position.dart';
import 'package:jtscore4dart/src/geom/TopologyException.dart';

import 'Edge.dart';
import 'EdgeEnd.dart';
import 'EdgeRing.dart';
import 'Label.dart';

/**
 * @version 1.7
 */
class DirectedEdge
  extends EdgeEnd
{

  /**
   * Computes the factor for the change in depth when moving from one location to another.
   * E.g. if crossing from the {@link Location#INTERIOR} to the{@link Location#EXTERIOR}
   * the depth decreases, so the factor is -1.
   *
   * @param [currLocation] Current location
   * @param [nextLocation] Next location
   * @return change of depth moving from currLocation to nextLocation
   */
  static int depthFactor(int currLocation, int nextLocation)
  {
    if (currLocation == Location.EXTERIOR && nextLocation == Location.INTERIOR) {
      return 1;
    } else if (currLocation == Location.INTERIOR && nextLocation == Location.EXTERIOR){
       return -1;
    }
    return 0;
  }

 /**protected */bool _isForward;
 /**private */bool _isInResult = false;
 /**private */bool _isVisited = false;

 /**private */late DirectedEdge sym; // the symmetric edge
 /**private */late DirectedEdge next;  // the next edge in the edge ring for the polygon containing this edge
 /**private */late DirectedEdge nextMin;  // the next edge in the MinimalEdgeRing that contains this edge
 /**private */late EdgeRing edgeRing;  // the EdgeRing that this edge is part of
 /**private */EdgeRing? minEdgeRing;  // the MinimalEdgeRing that this edge is part of
  /**
   * The depth of each side (position) of this edge.
   * The 0 element of the array is never used.
   */
 /**private */
 List<int> depth = [ 0, -999, -999];

  DirectedEdge(Edge edge, bool isForward)
  :this._isForward = isForward,
  super(edge)
  {
    // super(edge);
    // this._isForward = isForward;
    if (isForward) {
      init(edge.getCoordinate(0)!, edge.getCoordinate(1)!);
    }
    else {
      int n = edge.getNumPoints() - 1;
      init(edge.getCoordinate(n)!, edge.getCoordinate(n-1)!);
    }
    computeDirectedLabel();
  }

  @override
  Edge getEdge() { return edge; }

  void setInResult(bool isInResult) { this._isInResult = isInResult; }

  bool isInResult() { return _isInResult; }

  bool isVisited() { return _isVisited; }

  void setVisited(bool isVisited) { this._isVisited = isVisited; }

  void setEdgeRing(EdgeRing edgeRing) { this.edgeRing = edgeRing; }

  EdgeRing getEdgeRing() { return edgeRing; }

  void setMinEdgeRing(EdgeRing minEdgeRing) { this.minEdgeRing = minEdgeRing; }

  EdgeRing? getMinEdgeRing() { return minEdgeRing; }
  
  int getDepth(int position) { return depth[position]; }

  /**
   * Set depth for a position.
   *
   * You may also use {@link #setEdgeDepths(int, int)} to
   * update depth and opposite depth together.
   *
   * @param position Position to update
   * @param depthVal Depth at the provided position
   */
  void setDepth(int position, int depthVal)
  {
    if (depth[position] != -999) {
//      if (depth[position] != depthVal) {
//        Debug.print(this);
//      }
      if (depth[position] != depthVal) {
        throw new Exception("TopologyException: assigned depths do not match ${getCoordinate()}");
      }
      //Assert.isTrue(depth[position] == depthVal, "assigned depths do not match at " + getCoordinate());
    }
    depth[position] = depthVal;
  }

  int getDepthDelta()
  {
    int depthDelta = edge.getDepthDelta();
    if (! _isForward) depthDelta = -depthDelta;
    return depthDelta;
  }

  /**
   * Marks both DirectedEdges attached to a given Edge.
   *
   * This is used for edges corresponding to lines, which will only
   * appear oriented in a single direction in the result.
   *
   * @param isVisited True to mark edge as visited
   */
  void setVisitedEdge(bool isVisited)
  {
    setVisited(isVisited);
    sym.setVisited(isVisited);
  }
  /**
   * Each Edge gives rise to a pair of symmetric DirectedEdges, in opposite
   * directions.
   * @return the DirectedEdge for the same Edge but in the opposite direction
   */
  DirectedEdge getSym() { return sym; }
  bool isForward() { return _isForward; }
  void setSym(DirectedEdge de)
  {
    sym = de;
  }
  DirectedEdge getNext() { return next; }
  void setNext(DirectedEdge next) { this.next = next; }
  DirectedEdge getNextMin() { return nextMin; }
  void setNextMin(DirectedEdge nextMin) { this.nextMin = nextMin; }

  /**
   * This edge is a line edge if
   * <ul>
   * <li> at least one of the labels is a line label
   * <li> any labels which are not line labels have all Locations = EXTERIOR
   * </ul>
   *
   * @return If edge is a line edge
   */
  bool isLineEdge()
  {
    bool isLine = label!.isLine(0) || label!.isLine(1);
    bool isExteriorIfArea0 =
      ! label!.isArea(0) || label!.allPositionsEqual(0, Location.EXTERIOR);
    bool isExteriorIfArea1 =
      ! label!.isArea(1) || label!.allPositionsEqual(1, Location.EXTERIOR);

    return isLine && isExteriorIfArea0 && isExteriorIfArea1;
  }
  /**
   * This is an interior Area edge if
   * <ul>
   * <li> its label is an Area label for both Geometries
   * <li> and for each Geometry both sides are in the interior.
   * </ul>
   *
   * @return true if this is an interior Area edge
   */
  bool isInteriorAreaEdge()
  {
    bool isInteriorAreaEdge = true;
    for (int i = 0; i < 2; i++) {
      if (! ( label!.isArea(i)
            && label!.getLocation(i, Position.LEFT ) == Location.INTERIOR
            && label!.getLocation(i, Position.RIGHT) == Location.INTERIOR) ) {
        isInteriorAreaEdge = false;
      }
    }
    return isInteriorAreaEdge;
  }

  /**
   * Compute the label in the appropriate orientation for this DirEdge
   */
 /**private */void computeDirectedLabel()
  {
    label = new Label.FromAnother(edge.getLabel());
    if (! _isForward) {
      label!.flip();
    }
  }

  /**
   * Set both edge depths.  One depth for a given side is provided.  The other is
   * computed depending on the Location transition and the depthDelta of the edge.
   *
   * @param position Position to update
   * @param depth Depth at the provided position
   */
  void setEdgeDepths(int position, int depth)
  {
    // get the depth transition delta from R to L for this directed Edge
    int depthDelta = getEdge().getDepthDelta();
    if (! _isForward) depthDelta = -depthDelta;

    // if moving from L to R instead of R to L must change sign of delta
    int directionFactor = 1;
    if (position == Position.LEFT) {
      directionFactor = -1;
    }

    int oppositePos = Position.opposite(position);
    int delta = depthDelta * directionFactor;
    //TESTINGint delta = depthDelta * DirectedEdge.depthFactor(loc, oppositeLoc);
    int oppositeDepth = depth + delta;
    setDepth(position, depth);
    setDepth(oppositePos, oppositeDepth);
  }
  /// TODO: @ruier edit.
  // void print(PrintStream out)
  // {
  //   super.print(out);
  //   out.print(" " + depth[Position.LEFT] + "/" + depth[Position.RIGHT]);
  //   out.print(" (" + getDepthDelta() + ")");
  //   //out.print(" " + this.hashCode());
  //   //if (next != null) out.print(" next:" + next.hashCode());
  //   if (isInResult) out.print(" inResult");
  // }

  // void printEdge(PrintStream out)
  // {
  //   print(out);
  //   out.print(" ");
  //   if (_isForward) {
  //     edge.print(out);
  //   } else {
  //     edge.printReverse(out);
  //   }
  // }

}
