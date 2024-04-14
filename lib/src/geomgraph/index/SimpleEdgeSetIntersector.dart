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

// import java.util.Iterator;
// import java.util.List;

// import org.locationtech.jts.geom.Coordinate;
// import org.locationtech.jts.geomgraph.Edge;

import 'package:jtscore4dart/src/geom/Coordinate.dart';
import 'package:jtscore4dart/src/geomgraph/Edge.dart';
import 'package:jtscore4dart/src/geomgraph/index/SegmentIntersector.dart';

import 'EdgeSetIntersector.dart';

/**
 * Finds all intersections in one or two sets of edges,
 * using the straightforward method of
 * comparing all segments.
 * This algorithm is too slow for production use, but is useful for testing purposes.
 * @version 1.7
 */
class SimpleEdgeSetIntersector extends EdgeSetIntersector {
  // statistics information
  int nOverlaps = 0;

  // SimpleEdgeSetIntersector() {
  // }

  @override
  void computeIntersections(
      List edges, SegmentIntersector si, bool testAllSegments) {
    nOverlaps = 0;

    for (Iterator i0 = edges.iterator; i0.moveNext();) {
      Edge edge0 = i0.current;
      for (Iterator i1 = edges.iterator; i1.moveNext();) {
        Edge edge1 = i1.current;
        if (testAllSegments || edge0 != edge1) {
          _computeIntersects(edge0, edge1, si);
        }
      }
    }
  }

  @override
  void computeIntersections2Set(
      List edges0, List edges1, SegmentIntersector si) {
    nOverlaps = 0;

    for (Iterator i0 = edges0.iterator; i0.moveNext();) {
      Edge edge0 = i0.current;
      for (Iterator i1 = edges1.iterator; i1.moveNext();) {
        Edge edge1 = i1.current;
        _computeIntersects(edge0, edge1, si);
      }
    }
  }

  /**
   * Performs a brute-force comparison of every segment in each Edge.
   * This has n^2 performance, and is about 100 times slower than using
   * monotone chains.
   */
  void _computeIntersects(Edge e0, Edge e1, SegmentIntersector si) {
    List<Coordinate> pts0 = e0.getCoordinates();
    List<Coordinate> pts1 = e1.getCoordinates();
    for (int i0 = 0; i0 < pts0.length - 1; i0++) {
      for (int i1 = 0; i1 < pts1.length - 1; i1++) {
        si.addIntersections(e0, i0, e1, i1);
      }
    }
  }
}
