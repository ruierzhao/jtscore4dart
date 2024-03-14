/*
 * Copyright (c) 2016 Vivid Solutions, and others.
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
// import org.locationtech.jts.index.hprtree.HPRtree;

import 'SinglePassNoder.dart';

/**
 * Nodes a set of {@link SegmentString}s using a index based
 * on {@link MonotoneChain}s and a {@link SpatialIndex}.
 * The {@link SpatialIndex} used should be something that supports
 * envelope (range) queries efficiently (such as a <code>Quadtree</code>}
 * or {@link HPRtree} (which is the default index provided).
 * <p>
 * The noder supports using an overlap tolerance distance .
 * This allows determining segment intersection using a buffer for uses
 * involving snapping with a distance tolerance.
 *
 * @version 1.7
 */
class MCIndexNoder
    extends SinglePassNoder
{
 /**private */List monoChains = new ArrayList();
 /**private */SpatialIndex index= new HPRtree();
 /**private */int idCounter = 0;
 /**private */Collection nodedSegStrings;
  // statistics
 /**private */int nOverlaps = 0;
 /**private */double overlapTolerance = 0;

  MCIndexNoder()
  {
  }
  
  MCIndexNoder(SegmentIntersector si)
  {
    super(si);
  }

  /**
   * Creates a new noder with a given {@link SegmentIntersector}
   * and an overlap tolerance distance to expand intersection tests with.
   * 
   * @param si the segment intersector
   * @param overlapTolerance the expansion distance for overlap tests
   */
  MCIndexNoder(SegmentIntersector si, double overlapTolerance)
  {
    super(si);
    this.overlapTolerance = overlapTolerance;
  }

  List getMonotoneChains() { return monoChains; }

  SpatialIndex getIndex() { return index; }

  Collection getNodedSubstrings()
  {
    return  NodedSegmentString.getNodedSubstrings(nodedSegStrings);
  }

  void computeNodes(Collection inputSegStrings)
  {
    this.nodedSegStrings = inputSegStrings;
    for (Iterator i = inputSegStrings.iterator(); i.moveNext(); ) {
      add((SegmentString) i.next());
    }
    intersectChains();
//System.out.println("MCIndexNoder: # chain overlaps = " + nOverlaps);
  }

 /**private */void intersectChains()
  {
    MonotoneChainOverlapAction overlapAction = new SegmentOverlapAction(segInt);

    for (Iterator i = monoChains.iterator(); i.moveNext(); ) {
      MonotoneChain queryChain = (MonotoneChain) i.current;
      Envelope queryEnv = queryChain.getEnvelope(overlapTolerance);
      List overlapChains = index.query(queryEnv);
      for (Iterator j = overlapChains.iterator(); j.moveNext(); ) {
        MonotoneChain testChain = (MonotoneChain) j.current;
        /**
         * following test makes sure we only compare each pair of chains once
         * and that we don't compare a chain to itself
         */
        if (testChain.getId() > queryChain.getId()) {
          queryChain.computeOverlaps(testChain, overlapTolerance, overlapAction);
          nOverlaps++;
        }
        // short-circuit if possible
        if (segInt.isDone())
        	return;
      }
    }
  }

 /**private */void add(SegmentString segStr)
  {
    List segChains = MonotoneChainBuilder.getChains(segStr.getCoordinates(), segStr);
    for (Iterator i = segChains.iterator(); i.moveNext(); ) {
      MonotoneChain mc = (MonotoneChain) i.current;
      mc.setId(idCounter++);
      //mc.setOverlapDistance(overlapDistance);
      index.insert(mc.getEnvelope(overlapTolerance), mc);
      monoChains.add(mc);
    }
  }

  static class SegmentOverlapAction
      extends MonotoneChainOverlapAction
  {
   /**private */SegmentIntersector si = null;

    SegmentOverlapAction(SegmentIntersector si)
    {
      this.si = si;
    }

    void overlap(MonotoneChain mc1, int start1, MonotoneChain mc2, int start2)
    {
      SegmentString ss1 = (SegmentString) mc1.getContext();
      SegmentString ss2 = (SegmentString) mc2.getContext();
      si.processIntersections(ss1, start1, ss2, start2);
    }

  }
}
