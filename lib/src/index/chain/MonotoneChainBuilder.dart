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

import 'package:jtscore4dart/src/geom/Coordinate.dart';
import 'package:jtscore4dart/src/geom/Quadrant.dart';

import 'MonotoneChain.dart';

/**
 * Constructs {@link MonotoneChain}s
 * for sequences of {@link Coordinate}s.
 *
 * @version 1.7
 */
class MonotoneChainBuilder {

  /**
   * Computes a list of the {@link MonotoneChain}s
   * for a list of coordinates.
   * 
   * @param pts the list of points to compute chains for
   * @return a list of the monotone chains for the points 
   */
  // static List getChains(List<Coordinate> pts)
  // {
  //   return getChains(pts, null);
  // }

  /**
   * Computes a list of the {@link MonotoneChain}s
   * for a list of coordinates, 
   * attaching a context data object to each.
   * 
   * @param [pts] the list of points to compute chains for
   * @param [context] a data object to attach to each chain
   * @return a list of the monotone chains for the points 
   */
  static List<MonotoneChain> getChains(List<Coordinate> pts, [Object? context])
  {
    List<MonotoneChain> mcList = <MonotoneChain>[];
    if (pts.isEmpty) {
      return mcList;
    }
    int chainStart = 0;
    do {
      int chainEnd = findChainEnd(pts, chainStart);
      MonotoneChain mc = new MonotoneChain(pts, chainStart, chainEnd, context);
      mcList.add(mc);
      chainStart = chainEnd;
    } while (chainStart < pts.length -1);
    return mcList;
  }

  /**
   * Finds the index of the last point in a monotone chain
   * starting at a given point.
   * Repeated points (0-length segments) are included
   * in the monotone chain returned.
   * 
   * @param pts the points to scan
   * @param start the index of the start of this chain
   * @return the index of the last point in the monotone chain 
   * starting at <code>start</code>.
   */
 /**private */static int findChainEnd(List<Coordinate> pts, int start)
  {
  	int safeStart = start;
  	// skip any zero-length segments at the start of the sequence
  	// (since they cannot be used to establish a quadrant)
  	while (safeStart < pts.length - 1 && pts[safeStart].equals2D(pts[safeStart + 1])) {
  		safeStart++;
  	}
  	// check if there are NO non-zero-length segments
  	if (safeStart >= pts.length - 1) {
  		return pts.length - 1;
  	}
    // determine overall quadrant for chain (which is the starting quadrant)
    int chainQuad = Quadrant.quadrant$2(pts[safeStart], pts[safeStart + 1]);
    int last = start + 1;
    while (last < pts.length) {
    	// skip zero-length segments, but include them in the chain
    	if (! pts[last - 1].equals2D(pts[last])) {
        // compute quadrant for next possible segment in chain
    		int quad = Quadrant.quadrant$2(pts[last - 1], pts[last]);
      	if (quad != chainQuad) break;
    	}
      last++;
    }
    return last - 1;
  }

}
