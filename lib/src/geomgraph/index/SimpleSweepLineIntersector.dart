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
// import java.util.Collections;
// import java.util.Iterator;
// import java.util.List;

// import org.locationtech.jts.geom.Coordinate;
// import org.locationtech.jts.geomgraph.Edge;

import 'package:jtscore4dart/src/geom/Coordinate.dart';
import 'package:jtscore4dart/src/geomgraph/Edge.dart';
import 'package:jtscore4dart/src/patch/ArrayList.dart';

import 'EdgeSetIntersector.dart';
import 'SegmentIntersector.dart';
import 'SweepLineEvent.dart';
import 'SweepLineSegment.dart';

/**
 * Finds all intersections in one or two sets of edges,
 * using a simple x-axis sweepline algorithm.
 * While still O(n^2) in the worst case, this algorithm
 * drastically improves the average-case time.
 *
 * @version 1.7
 */
class SimpleSweepLineIntersector extends EdgeSetIntersector {
  List events = [];
  // statistics information
  int nOverlaps = 0;

  // SimpleSweepLineIntersector() {
  // }

  @override
  void computeIntersections(
      List edges, SegmentIntersector si, bool testAllSegments) {
    if (testAllSegments) {
      _addAll(edges, null);
    } else {
      _addAll(edges);
    }
    _computeIntersections(si);
  }

  @override
  void computeIntersections2Set(
      List edges0, List edges1, SegmentIntersector si) {
    _addAll(edges0, edges0);
    _addAll(edges1, edges1);
    _computeIntersections(si);
  }

  /**private */
  void addAll(List edges) {
    for (Iterator i = edges.iterator; i.moveNext();) {
      Edge edge = i.current;
      // edge is its own group
      _add(edge, edge);
    }
  }

  void _addAll(List edges, [Object? edgeSet]) {
    for (Iterator i = edges.iterator; i.moveNext();) {
      Edge edge = i.current;
      _add(edge, edgeSet);
    }
  }

  void _add(Edge edge, Object? edgeSet) {
    List<Coordinate> pts = edge.getCoordinates();
    for (int i = 0; i < pts.length - 1; i++) {
      SweepLineSegment ss = new SweepLineSegment(edge, i);
      SweepLineEvent insertEvent =
          SweepLineEvent.insert(edgeSet, ss.getMinX(), null);
      events.add(insertEvent);
      events.add(new SweepLineEvent.delete(ss.getMaxX(), insertEvent));
    }
  }

  /**
   * Because DELETE events have a link to their corresponding INSERT event,
   * it is possible to compute exactly the range of events which must be
   * compared to a given INSERT event object.
   */
  /**private */ void prepareEvents() {
    // Collections.sort(events);
    events.sort();
    // set DELETE event indexes
    for (int i = 0; i < events.size(); i++) {
      SweepLineEvent ev = events.get(i);
      if (ev.isDelete()) {
        ev.getInsertEvent()!.setDeleteEventIndex(i);
      }
    }
  }

  void _computeIntersections(SegmentIntersector si) {
    nOverlaps = 0;
    prepareEvents();

    for (int i = 0; i < events.size(); i++) {
      SweepLineEvent ev = events.get(i);
      if (ev.isInsert()) {
        processOverlaps(i, ev.getDeleteEventIndex()!, ev, si);
      }
    }
  }

  /**private */ void processOverlaps(
      int start, int end, SweepLineEvent ev0, SegmentIntersector si) {
    SweepLineSegment ss0 = ev0.getObject() as SweepLineSegment;
    /**
     * Since we might need to test for self-intersections,
     * include current INSERT event object in list of event objects to test.
     * Last index can be skipped, because it must be a Delete event.
     */
    for (int i = start; i < end; i++) {
      SweepLineEvent ev1 = events.get(i);
      if (ev1.isInsert()) {
        SweepLineSegment ss1 = ev1.getObject() as SweepLineSegment;
        // don't compare edges in same group, if labels are present
        if (!ev0.isSameLabel(ev1)) {
          ss0.computeIntersections(ss1, si);
          nOverlaps++;
        }
      }
    }
  }
}
