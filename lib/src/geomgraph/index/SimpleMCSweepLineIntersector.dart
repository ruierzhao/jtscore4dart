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

// import org.locationtech.jts.geomgraph.Edge;

import 'package:jtscore4dart/src/geomgraph/Edge.dart';
import 'package:jtscore4dart/src/patch/ArrayList.dart';

import 'EdgeSetIntersector.dart';
import 'MonotoneChain.dart';
import 'MonotoneChainEdge.dart';
import 'SegmentIntersector.dart';
import 'SweepLineEvent.dart';

/**
 * Finds all intersections in one or two sets of edges,
 * using an x-axis sweepline algorithm in conjunction with Monotone Chains.
 * While still O(n^2) in the worst case, this algorithm
 * drastically improves the average-case time.
 * The use of MonotoneChains as the items in the index
 * seems to offer an improvement in performance over a sweep-line alone.
 *
 * @version 1.7
 */
class SimpleMCSweepLineIntersector extends EdgeSetIntersector
{

  List events = [];
  // statistics information
  int nOverlaps=0;

  /**
   * A SimpleMCSweepLineIntersector creates monotone chains from the edges
   * and compares them using a simple sweep-line along the x-axis.
   */
  SimpleMCSweepLineIntersector() {
  }

  @override
  void computeIntersections(List edges, SegmentIntersector si, bool testAllSegments)
  {
    /// TODO: @ruier edit.很疑惑，不传参数和传null竟然不一样
    if (testAllSegments) {
      __addEdgesMBNull(edges, null);
    } else {
      __addEdges(edges);
    }
    _computeIntersections(si);
  }

  @override
  void computeIntersections2Set(List edges0, List edges1, SegmentIntersector si)
  {
    __addEdgesMBNull(edges0, edges0);
    __addEdgesMBNull(edges1, edges1);
    _computeIntersections(si);
  }

 /**private */void __addEdges(List edges)
  {
    for (Iterator i = edges.iterator; i.moveNext(); ) {
      Edge edge = i.current;
      // edge is its own group
      _addEdge(edge, edge);
    }
  }
 /**private */
 void __addEdgesMBNull(List edges, Object? edgeSet)
  {   
    for (Iterator i = edges.iterator; i.moveNext(); ) {
      Edge edge = i.current as Edge;
      _addEdge(edge, edgeSet);
    }
  }

 /**private */void _addEdge(Edge edge, Object? edgeSet)
  {
    MonotoneChainEdge mce = edge.getMonotoneChainEdge();
    List<int> startIndex = mce.getStartIndexes();
    for (int i = 0; i < startIndex.length - 1; i++) {
      MonotoneChain mc = new MonotoneChain(mce, i);
      SweepLineEvent insertEvent = new SweepLineEvent.insert(edgeSet, mce.getMinX(i), mc);
      events.add(insertEvent);
      events.add(new SweepLineEvent.delete(mce.getMaxX(i), insertEvent));
    }
  }

  /**
   * Because Delete Events have a link to their corresponding Insert event,
   * it is possible to compute exactly the range of events which must be
   * compared to a given Insert event object.
   */
 /**private */void prepareEvents()
  {
    // Collections.sort(events);
    /// TODO: @ruier edit.
    events.sort();
    // set DELETE event indexes
    for (int i = 0; i < events.size(); i++ )
    {
      SweepLineEvent ev = events.get(i);
      if (ev.isDelete()) {
        ev.getInsertEvent()!.setDeleteEventIndex(i);
      }
    }
  }

 /**private */void _computeIntersections(SegmentIntersector si)
  {
    nOverlaps = 0;
    prepareEvents();

    for (int i = 0; i < events.size(); i++ )
    {
      SweepLineEvent ev = events.get(i);
      if (ev.isInsert()) {
        processOverlaps(i, ev.getDeleteEventIndex()!, ev, si);
      }
      if (si.isDone()) {
    	  break;
      }
    }
  }

 /**private */void processOverlaps(int start, int end, SweepLineEvent ev0, SegmentIntersector si)
  {
    MonotoneChain mc0 =  ev0.getObject() as MonotoneChain;
    /**
     * Since we might need to test for self-intersections,
     * include current INSERT event object in list of event objects to test.
     * Last index can be skipped, because it must be a Delete event.
     */
    for (int i = start; i < end; i++ ) {
      SweepLineEvent ev1 =  events.get(i);
      if (ev1.isInsert()) {
        MonotoneChain mc1 = ev1.getObject() as MonotoneChain;
        // don't compare edges in same group, if labels are present
        if (! ev0.isSameLabel(ev1)) {
          mc0.computeIntersections(mc1, si);
          nOverlaps++;
        }
      }
    }
  }
}
