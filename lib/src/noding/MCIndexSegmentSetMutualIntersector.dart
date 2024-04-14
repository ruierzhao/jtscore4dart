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
// import java.util.Collection;
// import java.util.Iterator;
// import java.util.List;

// import org.locationtech.jts.geom.Envelope;
// import org.locationtech.jts.index.SpatialIndex;
// import org.locationtech.jts.index.chain.MonotoneChain;
// import org.locationtech.jts.index.chain.MonotoneChainBuilder;
// import org.locationtech.jts.index.chain.MonotoneChainOverlapAction;
// import org.locationtech.jts.index.strtree.STRtree;

import "package:jtscore4dart/src/geom/Envelope.dart";
import 'package:jtscore4dart/src/index/SpatialIndex.dart';
import 'package:jtscore4dart/src/index/chain/MonotoneChain.dart';
import 'package:jtscore4dart/src/index/chain/MonotoneChainBuilder.dart';
import 'package:jtscore4dart/src/index/chain/MonotoneChainOverlapAction.dart';
import 'package:jtscore4dart/src/index/strtree/STRtree.dart';

import 'SegmentIntersector.dart';
import 'SegmentSetMutualIntersector.dart';
import 'SegmentString.dart';

/**
 * Intersects two sets of {@link SegmentString}s using a index based
 * on {@link MonotoneChain}s and a {@link SpatialIndex}.
 *
 * Thread-safe and immutable.
 * 
 * @version 1.7
 */
class MCIndexSegmentSetMutualIntersector
    implements SegmentSetMutualIntersector {
  /**
  * The {@link SpatialIndex} used should be something that supports
  * envelope (range) queries efficiently (such as a 
  * {@link org.locationtech.jts.index.quadtree.Quadtree}
  * or {@link STRtree}.
  */
  /**private */ STRtree index = new STRtree();
  /**private */ double overlapTolerance = 0.0;

  /**
   * Constructs a new intersector for a given set of {@link SegmentString}s.
   * 
   * @param baseSegStrings the base segment strings to intersect
   */
  // MCIndexSegmentSetMutualIntersector(Iterable baseSegStrings)
  // {
  //   initBaseSegments(baseSegStrings);
  // }

  MCIndexSegmentSetMutualIntersector(Iterable<SegmentString> baseSegStrings,
      [this.overlapTolerance = 0.0]) {
    _initBaseSegments(baseSegStrings);
  }

  /** 
   * Gets the index constructed over the base segment strings.
   * 
   * NOTE: To retain thread-safety, treat returned value as immutable!
   * 
   * @return the constructed index
   */
  SpatialIndex getIndex() {
    return index;
  }

  void _initBaseSegments(Iterable<SegmentString> segStrings) {
    for (SegmentString ss in segStrings) {
      if (ss.size() == 0) {
        continue;
      }
      _addToIndex(ss);
    }
    // build index to ensure thread-safety
    index.build();
  }

  void _addToIndex(SegmentString segStr) {
    List segChains =
        MonotoneChainBuilder.getChains(segStr.getCoordinates(), segStr);
    for (Iterator i = segChains.iterator; i.moveNext();) {
      MonotoneChain mc = i.current;
      index.insert(mc.getEnvelopeExpandOf(overlapTolerance), mc);
    }
  }

  /**
   * Calls {@link SegmentIntersector#processIntersections(SegmentString, int, SegmentString, int)} 
   * for all <i>candidate</i> intersections between
   * the given collection of SegmentStrings and the set of indexed segments. 
   * 
   * @param segStrings set of segments to intersect
   * @param segInt segment intersector to use
   */
  @override
  void process(Iterable segStrings, SegmentIntersector segInt) {
    List monoChains = [];
    for (Iterator i = segStrings.iterator; i.moveNext();) {
      _addToMonoChains(i.current, monoChains);
    }
    _intersectChains(monoChains, segInt);
//    System.out.println("MCIndexBichromaticIntersector: # chain overlaps = " + nOverlaps);
//    System.out.println("MCIndexBichromaticIntersector: # oct chain overlaps = " + nOctOverlaps);
  }

  void _addToMonoChains(SegmentString segStr, List monoChains) {
    if (segStr.size() == 0) {
      return;
    }
    List segChains =
        MonotoneChainBuilder.getChains(segStr.getCoordinates(), segStr);
    for (Iterator i = segChains.iterator; i.moveNext();) {
      MonotoneChain mc = i.current;
      monoChains.add(mc);
    }
  }

  void _intersectChains(List monoChains, SegmentIntersector segInt) {
    MonotoneChainOverlapAction overlapAction = new SegmentOverlapAction(segInt);

    for (Iterator i = monoChains.iterator; i.moveNext();) {
      MonotoneChain queryChain = i.current;
      Envelope queryEnv = queryChain.getEnvelopeExpandOf(overlapTolerance);
      List overlapChains = index.query(queryEnv);
      for (Iterator j = overlapChains.iterator; j.moveNext();) {
        MonotoneChain testChain = j.current;
        queryChain.computeOverlaps(testChain, overlapAction, overlapTolerance);
        if (segInt.isDone()) return;
      }
    }
  }
}

/**static */ class SegmentOverlapAction extends MonotoneChainOverlapAction {
  /**private */ SegmentIntersector si;

  SegmentOverlapAction(SegmentIntersector this.si);

  @override
  void overlap(MonotoneChain mc1, int start1, MonotoneChain mc2, int start2) {
    SegmentString ss1 = mc1.getContext() as SegmentString;
    SegmentString ss2 = mc2.getContext() as SegmentString;
    si.processIntersections(ss1, start1, ss2, start2);
  }
}
