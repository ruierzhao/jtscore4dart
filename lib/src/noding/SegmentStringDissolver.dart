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

// import java.util.Collection;
// import java.util.Iterator;
// import java.util.Map;
// import java.util.TreeMap;

// import org.locationtech.jts.geom.CoordinateArrays;

import 'dart:collection';

import 'package:jtscore4dart/src/geom/CoordinateArrays.dart';
import 'package:jtscore4dart/src/patch/Map.dart';

import 'OrientedCoordinateArray.dart';
import 'SegmentString.dart';

/**
	 * A merging strategy which can be used to update the context data of {@link SegmentString}s 
	 * which are merged during the dissolve process.
	 * 
	 * @author mbdavis
	 *
	 */
abstract class SegmentStringMerger {
  /**
     * Updates the context data of a SegmentString
     * when an identical (up to orientation) one is found during dissolving.
     *
     * @param mergeTarget the segment string to update
     * @param ssToMerge the segment string being dissolved
     * @param isSameOrientation <code>true</code> if the strings are in the same direction,
     * <code>false</code> if they are opposite
     */
  void merge(SegmentString mergeTarget, SegmentString ssToMerge,
      bool isSameOrientation);
}

/**
 * Dissolves a noded collection of {@link SegmentString}s to produce
 * a set of merged linework with unique segments.
 * A custom {@link SegmentStringMerger} merging strategy
 * can be supplied.  
 * This strategy will be called when two identical (up to orientation)
 * strings are dissolved together.
 * The default merging strategy is simply to discard one of the merged strings.
 * <p>
 * A common use for this class is to merge noded edges
 * while preserving topological labelling.
 * This requires a custom merging strategy to be supplied 
 * to merge the topology labels appropriately.
 *
 * @version 1.7
 * @see SegmentStringMerger
 */
class SegmentStringDissolver {
  /**private */ SegmentStringMerger? _merger;
//  /**private */Map ocaMap = new TreeMap();
  /**private */ Map _ocaMap = new SplayTreeMap();

  // testing only
  //private List testAddedSS = [];

  /**
   * Creates a dissolver with a user-defined merge strategy.
   *
   * @param merger the merging strategy to use
   */
  SegmentStringDissolver([this._merger]);

  /**
   * Creates a dissolver with the default merging strategy.
   */
  // SegmentStringDissolver() {
  //   this(null);
  // }

  /**
   * Dissolve all {@link SegmentString}s in the input {@link Collection}
   * @param segStrings
   */
  void dissolveAll(Iterable segStrings) {
    for (Iterator i = segStrings.iterator; i.moveNext();) {
      dissolve(i.current);
    }
  }

  void _add(OrientedCoordinateArray oca, SegmentString segString) {
    _ocaMap.put(oca, segString);
    //testAddedSS.add(oca);
  }

  /**
   * Dissolve the given {@link SegmentString}.
   *
   * @param segString the string to dissolve
   */
  void dissolve(SegmentString segString) {
    OrientedCoordinateArray oca =
        new OrientedCoordinateArray(segString.getCoordinates());
    SegmentString? existing = findMatching(oca, segString);
    if (existing == null) {
      _add(oca, segString);
    } else {
      if (_merger != null) {
        bool isSameOrientation = CoordinateArrays.equals(
            existing.getCoordinates(), segString.getCoordinates());
        _merger!.merge(existing, segString, isSameOrientation);
      }
    }
  }

  /**private */ SegmentString? findMatching(
      OrientedCoordinateArray oca, SegmentString segString) {
    SegmentString matchSS = _ocaMap.get(oca) as SegmentString;
    /*
    bool hasBeenAdded = checkAdded(oca);
    if (matchSS == null && hasBeenAdded) {
      System.out.println("added!");
    }
    */
    return matchSS;
  }

/*

 /**private */bool checkAdded(OrientedCoordinateArray oca)
  {
    for (Iterator i = testAddedSS.iterator(); i.moveNext(); ) {
      OrientedCoordinateArray addedOCA = (OrientedCoordinateArray) i.current;
      if (oca.compareTo(addedOCA) == 0)
        return true;
    }
    return false;
  }
*/

  /**
   * Gets the collection of dissolved (i.e. unique) {@link SegmentString}s
   *
   * @return the unique {@link SegmentString}s
   */
  Iterable getDissolved() {
    return _ocaMap.values;
  }
}
