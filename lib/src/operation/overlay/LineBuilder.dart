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
// import java.util.Iterator;
// import java.util.List;

// import org.locationtech.jts.algorithm.PointLocator;
// import org.locationtech.jts.geom.GeometryFactory;
// import org.locationtech.jts.geom.LineString;
// import org.locationtech.jts.geomgraph.DirectedEdge;
// import org.locationtech.jts.geomgraph.DirectedEdgeStar;
// import org.locationtech.jts.geomgraph.Edge;
// import org.locationtech.jts.geomgraph.Label;
// import org.locationtech.jts.geomgraph.Node;
// import org.locationtech.jts.util.Assert;

import 'package:jtscore4dart/src/algorithm/PointLocator.dart';
import 'package:jtscore4dart/src/geom/GeometryFactory.dart';
import 'package:jtscore4dart/src/geom/LineString.dart';
import 'package:jtscore4dart/src/geomgraph/DirectedEdge.dart';
import 'package:jtscore4dart/src/geomgraph/DirectedEdgeStar.dart';
import 'package:jtscore4dart/src/geomgraph/Edge.dart';
import 'package:jtscore4dart/src/geomgraph/Label.dart';
import 'package:jtscore4dart/src/geomgraph/Node.dart';
import 'package:jtscore4dart/src/util/Assert.dart';

import 'OverlayOp.dart';

/**
 * Forms JTS LineStrings out of a the graph of {@link DirectedEdge}s
 * created by an {@link OverlayOp}.
 *
 * @version 1.7
 */
class LineBuilder {
  /**private */ OverlayOp op;
  /**private */ GeometryFactory geometryFactory;
  /**private */ PointLocator ptLocator;

  /**private */ List lineEdgesList = [];
  /**private */ List<LineString> resultLineList = [];

  LineBuilder(this.op, this.geometryFactory, this.ptLocator);

  /**
   * @return a list of the LineStrings in the result of the specified overlay operation
   */
  List<LineString> build(int opCode) {
    findCoveredLineEdges();
    collectLines(opCode);
    //labelIsolatedLines(lineEdgesList);
    buildLines(opCode);
    return resultLineList;
  }

  /**
   * Find and mark L edges which are "covered" by the result area (if any).
   * L edges at nodes which also have A edges can be checked by checking
   * their depth at that node.
   * L edges at nodes which do not have A edges can be checked by doing a
   * point-in-polygon test with the previously computed result areas.
   */
  /**private */ void findCoveredLineEdges() {
    // first set covered for all L edges at nodes which have A edges too
    for (Iterator nodeit = op.getGraph().getNodes().iterator;
        nodeit.moveNext();) {
      Node node = nodeit.current;
//node.print(System.out);
      (node.getEdges() as DirectedEdgeStar).findCoveredLineEdges();
    }

    /**
     * For all L edges which weren't handled by the above,
     * use a point-in-poly test to determine whether they are covered
     */
    for (Iterator it = op.getGraph().getEdgeEnds().iterator; it.moveNext();) {
      DirectedEdge de = it.current;
      Edge e = de.getEdge();
      if (de.isLineEdge() && !e.isCoveredSet()) {
        bool isCovered = op.isCoveredByA(de.getCoordinate());
        e.setCovered(isCovered);
      }
    }
  }

  /**private */ void collectLines(int opCode) {
    for (Iterator it = op.getGraph().getEdgeEnds().iterator; it.moveNext();) {
      DirectedEdge de = it.current as DirectedEdge;
      collectLineEdge(de, opCode, lineEdgesList);
      collectBoundaryTouchEdge(de, opCode, lineEdgesList);
    }
  }

  /**
   * Collect line edges which are in the result.
   * Line edges are in the result if they are not part of
   * an area boundary, if they are in the result of the overlay operation,
   * and if they are not covered by a result area.
   *
   * @param de the directed edge to test
   * @param opCode the overlap operation
   * @param edges the list of included line edges
   */
  /**private */ void collectLineEdge(DirectedEdge de, int opCode, List edges) {
    Label label = de.getLabel()!;
    Edge e = de.getEdge();
    // include L edges which are in the result
    if (de.isLineEdge()) {
      if (!de.isVisited() &&
          OverlayOp.isResultOfOp(label, opCode) &&
          !e.isCovered()) {
//Debug.println("de: " + de.getLabel());
//Debug.println("edge: " + e.getLabel());

        edges.add(e);
        de.setVisitedEdge(true);
      }
    }
  }

  /**
   * Collect edges from Area inputs which should be in the result but
   * which have not been included in a result area.
   * This happens ONLY:
   * <ul>
   * <li>during an intersection when the boundaries of two
   * areas touch in a line segment
   * <li> OR as a result of a dimensional collapse.
   * </ul>
   */
  /**private */ void collectBoundaryTouchEdge(
      DirectedEdge de, int opCode, List edges) {
    Label label = de.getLabel()!;
    if (de.isLineEdge()) return; // only interested in area edges
    if (de.isVisited()) return; // already processed
    if (de.isInteriorAreaEdge())
      return; // added to handle dimensional collapses
    if (de.getEdge().isInResult())
      return; // if the edge linework is already included, don't include it again

    // sanity check for labelling of result edgerings
    Assert.isTrue(!(de.isInResult() || de.getSym().isInResult()) ||
        !de.getEdge().isInResult());

    // include the linework if it's in the result of the operation
    if (OverlayOp.isResultOfOp(label, opCode) &&
        opCode == OverlayOp.INTERSECTION) {
      edges.add(de.getEdge());
      de.setVisitedEdge(true);
    }
  }

  /**private */ void buildLines(int opCode) {
    for (Iterator it = lineEdgesList.iterator; it.moveNext();) {
      Edge e = it.current;
      // Label label = e.getLabel();
      LineString line = geometryFactory.createLineString(e.getCoordinates());
      resultLineList.add(line);
      e.setInResult(true);
    }
  }

  /**private */ void labelIsolatedLines(List edgesList) {
    for (Iterator it = edgesList.iterator; it.moveNext();) {
      Edge e = it.current;
      Label? label = e.getLabel();
//n.print(System.out);
      if (e.isIsolated()) {
        if (label!.isNull(0)) {
          labelIsolatedLine(e, 0);
        } else {
          labelIsolatedLine(e, 1);
        }
      }
    }
  }

  /**
   * Label an isolated node with its relationship to the target geometry.
   */
  /**private */ void labelIsolatedLine(Edge e, int targetIndex) {
    int loc =
        ptLocator.locate(e.getCoordinate(0), op.getArgGeometry(targetIndex));
    e.getLabel()!.setLocationOn(targetIndex, loc);
  }
}
