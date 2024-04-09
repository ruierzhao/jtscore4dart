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
// import java.util.List;

// import org.locationtech.jts.geom.Coordinate;
// import org.locationtech.jts.geom.Quadrant;
// import org.locationtech.jts.util.IntArrayList;


import 'package:jtscore4dart/src/geom/Coordinate.dart';
import 'package:jtscore4dart/src/geom/Quadrant.dart';
import 'package:jtscore4dart/src/patch/ArrayList.dart';

/**
 * MonotoneChains are a way of partitioning the segments of an edge to
 * allow for fast searching of intersections.
 * Specifically, a sequence of contiguous line segments
 * is a monotone chain if all the vectors defined by the oriented segments
 * lies in the same quadrant.
 * <p>
 * Monotone Chains have the following useful properties:
 * <ol>
 * <li>the segments within a monotone chain will never intersect each other
 * <li>the envelope of any contiguous subset of the segments in a monotone chain
 * is simply the envelope of the endpoints of the subset.
 * </ol>
 * Property 1 means that there is no need to test pairs of segments from within
 * the same monotone chain for intersection.
 * Property 2 allows
 * binary search to be used to find the intersection points of two monotone chains.
 * For many types of real-world data, these properties eliminate a large number of
 * segment comparisons, producing substantial speed gains.
 * <p>
 * Note that due to the efficient intersection test, there is no need to limit the size
 * of chains to obtain fast performance.
 *
 * @version 1.7
 */
class MonotoneChainIndexer {

  static /**int[] */ List<int>  toIntArray(List list){
    // /**int[] */ List<int>  array = new int[list.size()];
    /**int[] */ List<int>  array = List.filled(list.size(), 0,growable: false);
    for (int i = 0; i < array.length; i++) {
      array[i] = list.get(i);
    }
    return array;
  }

  MonotoneChainIndexer() {
  }

  /**int[] */ List<int>  getChainStartIndices(List<Coordinate> pts)
  {
    // find the startpoint (and endpoints) of all monotone chains in this edge
    int start = 0;
    // IntArrayList startIndexList = new IntArrayList(pts.length / 2);
    List<int> startIndexList = [];
    // use heuristic to size initial array
    //startIndexList.ensureCapacity(pts.length / 4);
    startIndexList.add(start);
    do {
      int last = findChainEnd(pts, start);
      startIndexList.add(last);
      start = last;
    } while (start < pts.length - 1);
    // copy list to an array of ints, for efficiency
    return startIndexList.toArray();
  }  
  
  /**int[] */ List<int>  OLDgetChainStartIndices(List<Coordinate> pts)
  {
    // find the startpoint (and endpoints) of all monotone chains in this edge
    int start = 0;
    List startIndexList = [];
    startIndexList.add(start);
    do {
      int last = findChainEnd(pts, start);
      startIndexList.add(last);
      start = last;
    } while (start < pts.length - 1);
    // copy list to an array of ints, for efficiency
    /**int[] */ List<int>  startIndex = toIntArray(startIndexList);
    return startIndex;
  }

  /**
   * @return the index of the last point in the monotone chain
   */
 /**private */int findChainEnd(List<Coordinate> pts, int start)
  {
    // determine quadrant for chain
    int chainQuad = Quadrant.quadrant$2(pts[start], pts[start + 1]);
    int last = start + 1;
    while (last < pts.length ) {
      //if (last - start > 100) break;
      // compute quadrant for next possible segment in chain
      int quad = Quadrant.quadrant$2(pts[last - 1], pts[last]);
      if (quad != chainQuad) break;
      last++;
    }
    return last - 1;
  }



}
