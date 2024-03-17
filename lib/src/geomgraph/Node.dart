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
// import java.util.Iterator;

// import org.locationtech.jts.geom.Coordinate;
// import org.locationtech.jts.geom.IntersectionMatrix;
// import org.locationtech.jts.geom.Location;


import 'package:jtscore4dart/src/geom/Coordinate.dart';
import 'package:jtscore4dart/src/geom/IntersectionMatrix.dart';
import 'package:jtscore4dart/src/geom/Location.dart';

import 'DirectedEdge.dart';
import 'EdgeEnd.dart';
import 'EdgeEndStar.dart';
import 'GraphComponent.dart';
import 'Label.dart';

/**
 * @version 1.7
 */
/**ruier edit*/ 
class Node extends GraphComponent
{
 /**protected */Coordinate coord; // only non-null if this node is precise
 /**protected */EdgeEndStar? edges;

  Node(this.coord, [this.edges]) : super(new Label.GeomIndex(0, Location.NONE));
  // {
  //   label = new Label.GeomIndex(0, Location.NONE);
  // }

  @override
  Coordinate getCoordinate() { return coord; }
  EdgeEndStar getEdges() { return edges!; }

  /**
   * Tests whether any incident edge is flagged as
   * being in the result.
   * This test can be used to determine if the node is in the result,
   * since if any incident edge is in the result, the node must be in the result as well.
   *
   * @return <code>true</code> if any incident edge in the in the result
   */
  bool isIncidentEdgeInResult()
  {
    for (Iterator it = getEdges().getEdges().iterator; it.moveNext(); ) {
      DirectedEdge de =  it.current as DirectedEdge;
      if (de.getEdge().isInResult()) {
        return true;
      }
    }
    return false;
  }

  @override
  bool isIsolated()
  {
    return (label.getGeometryCount() == 1);
  }

  /**
   * Basic nodes do not compute IMs
   */
 /**protected */
  @override
  void computeIM(IntersectionMatrix im){
    /// TODO: @ruier edit. nothing todo, maybe error
  }
//  /**protected */void computeIM(IntersectionMatrix im) {}

  /**
   * Add the edge to the list of edges at this node.
   *
   * @param e EdgeEnd
   */
  void add(EdgeEnd e)
  {
    // Assert: start pt of e is equal to node point
    edges!.insert(e);
    e.setNode(this);
  }

  void mergeLabel(Node n)
  {
    mergeLabelFromLabel(n.label);
  }

  /**
   * To merge labels for two nodes,
   * the merged location for each LabelElement is computed.
   * The location for the corresponding node LabelElement is set to the result,
   * as int as the location is non-null.
   *
   * @param label2 Label to merge
   */
  void mergeLabelFromLabel(Label label2)
  {
    for (int i = 0; i < 2; i++) {
      int loc = computeMergedLocation(label2, i);
      int thisLoc = label.getLocation(i);
      if (thisLoc == Location.NONE) label.setLocationOn(i, loc);
    }
  }

  // TODO: ruier edit.
  // void setLabel(int argIndex, int onLocation)
  void setLabelLocation(int argIndex, int onLocation)
  {
    // TODO: ruier edit. label never null.
    label.setLocationOn(argIndex, onLocation);
    // if (label == null) {
    //   label = new Label.GeomIndex(argIndex, onLocation);
    // }
    // else {
    //   label.setLocationOn(argIndex, onLocation);
    // }
  }

  /**
   * Updates the label of a node to BOUNDARY,
   * obeying the mod-2 boundaryDetermination rule.
   * @param argIndex location index
   */
  void setLabelBoundary(int argIndex)
  {
    if (label == null) return;

    // determine the current location for the point (if any)
    int loc = Location.NONE;
    if (label != null) {
      loc = label.getLocation(argIndex);
    }
    // flip the loc
    int newLoc;
    switch (loc) {
    case Location.BOUNDARY: newLoc = Location.INTERIOR; break;
    case Location.INTERIOR: newLoc = Location.BOUNDARY; break;
    default: newLoc = Location.BOUNDARY;  break;
    }
    label.setLocationOn(argIndex, newLoc);
  }

  /**
   * The location for a given eltIndex for a node will be one
   * of { null, INTERIOR, BOUNDARY }.
   * A node may be on both the boundary and the interior of a geometry;
   * in this case, the rule is that the node is considered to be in the boundary.
   * The merged location is the maximum of the two input values.
   */
  int computeMergedLocation(Label label2, int eltIndex)
  {
    int loc = Location.NONE;
    loc = label.getLocation(eltIndex);
    if (! label2.isNull(eltIndex)) {
        int nLoc = label2.getLocation(eltIndex);
        if (loc != Location.BOUNDARY) loc = nLoc;
    }
    return loc;
  }
  // TODO: ruier edit.
  // void print(PrintStream out)
  // {
  //   out.println("node " + coord + " lbl: " + label);
  // }
  void printOut()
  {
    print("node $coord lbl: $label");
  }
  
  @override
  String toString() {
    return "Node(${coord.x} , ${coord.y})";
  }
  
}
