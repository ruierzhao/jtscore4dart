/*
 * Copyright (c) 2019 Martin Davis.
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
// import java.util.List;

// import org.locationtech.jts.geom.GeometryFactory;
// import org.locationtech.jts.geom.Polygon;
// import org.locationtech.jts.geom.TopologyException;
// import org.locationtech.jts.util.Assert;

import 'package:jtscore4dart/src/geom/GeometryFactory.dart';
import 'package:jtscore4dart/src/geom/Polygon.dart';
import 'package:jtscore4dart/src/geom/TopologyException.dart';
import 'package:jtscore4dart/src/util/Assert.dart';

import 'MaximalEdgeRing.dart';
import 'OverlayEdge.dart';
import 'OverlayEdgeRing.dart';

class PolygonBuilder {
  final GeometryFactory _geometryFactory;
  final List<OverlayEdgeRing> _shellList = <OverlayEdgeRing>[];
  final List<OverlayEdgeRing> _freeHoleList = <OverlayEdgeRing>[];
  final bool _isEnforcePolygonal ;

  // PolygonBuilder(List<OverlayEdge> resultAreaEdges, GeometryFactory geomFact) {
  //   this(resultAreaEdges, geomFact, true);
  // }

  PolygonBuilder(List<OverlayEdge> resultAreaEdges, this._geometryFactory,
      [this._isEnforcePolygonal = true]) {
    _buildRings(resultAreaEdges);
  }

  List<Polygon> getPolygons() {
    return _computePolygons(_shellList);
  }

  List<OverlayEdgeRing> getShellRings() {
    return _shellList;
  }

  List<Polygon> _computePolygons(List<OverlayEdgeRing> shellList) {
    List<Polygon> resultPolyList = <Polygon>[];
    // add Polygons for all shells
    for (OverlayEdgeRing er in shellList) {
      Polygon poly = er.toPolygon(_geometryFactory);
      resultPolyList.add(poly);
    }
    return resultPolyList;
  }

  void _buildRings(List<OverlayEdge> resultAreaEdges) {
    _linkResultAreaEdgesMax(resultAreaEdges);
    List<MaximalEdgeRing> maxRings = buildMaximalRings(resultAreaEdges);
    buildMinimalRings(maxRings);
    _placeFreeHoles(_shellList, _freeHoleList);
    //Assert: every hole on freeHoleList has a shell assigned to it
  }

  void _linkResultAreaEdgesMax(List<OverlayEdge> resultEdges) {
    for (OverlayEdge edge in resultEdges) {
      //Assert.isTrue(edge.isInResult());
      // TODO: find some way to skip nodes which are already linked
      MaximalEdgeRing.linkResultAreaMaxRingAtNode(edge);
    }
  }

  /**
   * For all OverlayEdges in result, form them into MaximalEdgeRings
   */
  /**private */ static List<MaximalEdgeRing> buildMaximalRings(
      Iterable<OverlayEdge> edges) {
    List<MaximalEdgeRing> edgeRings = <MaximalEdgeRing>[];
    for (OverlayEdge e in edges) {
      if (e.isInResultArea && e.getLabel().isBoundaryEither()) {
        // if this edge has not yet been processed
        if (e.getEdgeRingMax() == null) {
          MaximalEdgeRing er = new MaximalEdgeRing(e);
          edgeRings.add(er);
        }
      }
    }
    return edgeRings;
  }

  /**private */ void buildMinimalRings(List<MaximalEdgeRing> maxRings) {
    for (MaximalEdgeRing erMax in maxRings) {
      List<OverlayEdgeRing> minRings = erMax.buildMinimalRings(_geometryFactory);
      assignShellsAndHoles(minRings);
    }
  }

  /**private */ void assignShellsAndHoles(List<OverlayEdgeRing> minRings) {
    /**
     * Two situations may occur:
     * - the rings are a shell and some holes
     * - rings are a set of holes
     * This code identifies the situation
     * and places the rings appropriately 
     */
    OverlayEdgeRing? shell = _findSingleShell(minRings);
    if (shell != null) {
      assignHoles(shell, minRings);
      _shellList.add(shell);
    } else {
      // all rings are holes; their shell will be found later
      _freeHoleList.addAll(minRings);
    }
  }

  /**
   * Finds the single shell, if any, out of 
   * a list of minimal rings derived from a maximal ring.
   * The other possibility is that they are a set of (connected) holes, 
   * in which case no shell will be found.
   *
   * @return the shell ring, if there is one
   * or null, if all rings are holes
   */
  OverlayEdgeRing? _findSingleShell(List<OverlayEdgeRing> edgeRings) {
    int shellCount = 0;
    OverlayEdgeRing? shell = null;
    for (OverlayEdgeRing er in edgeRings) {
      if (!er.isHole()) {
        shell = er;
        shellCount++;
      }
    }
    Assert.isTrue(shellCount <= 1, "found two shells in EdgeRing list");
    return shell!;
  }

  /**
   * For the set of minimal rings comprising a maximal ring, 
   * assigns the holes to the shell known to contain them.
   * Assigning the holes directly to the shell serves two purposes:
   * <ul>
   * <li>it is faster than using a point-in-polygon check later on.
   * <li>it ensures correctness, since if the PIP test was used the point
   * chosen might lie on the shell, which might return an incorrect result from the
   * PIP test
   * </ul>
   */
  /**private */ static void assignHoles(
      OverlayEdgeRing shell, List<OverlayEdgeRing> edgeRings) {
    for (OverlayEdgeRing er in edgeRings) {
      if (er.isHole()) {
        er.setShell(shell);
      }
    }
  }

  /**
   * Place holes have not yet been assigned to a shell.
   * These "free" holes should
   * all be <b>properly</b> contained in their parent shells, so it is safe to use the
   * <code>findEdgeRingContaining</code> method.
   * (This is the case because any holes which are NOT
   * properly contained (i.e. are connected to their
   * parent shell) would have formed part of a MaximalEdgeRing
   * and been handled in a previous step).
   *
   * @throws TopologyException if a hole cannot be assigned to a shell
   */
  void _placeFreeHoles(
      List<OverlayEdgeRing> shellList, List<OverlayEdgeRing> freeHoleList) {
    // TODO: use a spatial index to improve performance
    for (OverlayEdgeRing hole in freeHoleList) {
      // only place this hole if it doesn't yet have a shell
      if (hole.getShell() == null) {
        OverlayEdgeRing? shell = hole.findEdgeRingContaining(shellList);
        // only when building a polygon-valid result
        if (_isEnforcePolygonal && shell == null) {
          throw new TopologyException(
              "unable to assign free hole to a shell", hole.getCoordinate());
        }
        hole.setShell(shell!);
      }
    }
  }
}
