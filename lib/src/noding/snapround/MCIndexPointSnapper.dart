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



// import org.locationtech.jts.geom.Coordinate;
// import org.locationtech.jts.geom.Envelope;
// import org.locationtech.jts.index.ItemVisitor;
// import org.locationtech.jts.index.SpatialIndex;
// import org.locationtech.jts.index.chain.MonotoneChain;
// import org.locationtech.jts.index.chain.MonotoneChainSelectAction;
// import org.locationtech.jts.noding.NodedSegmentString;
// import org.locationtech.jts.noding.SegmentString;

import 'package:jtscore4dart/src/geom/Coordinate.dart';
import 'package:jtscore4dart/src/geom/Envelope.dart';
import 'package:jtscore4dart/src/index/ItemVisitor.dart';
import 'package:jtscore4dart/src/index/SpatialIndex.dart';
import 'package:jtscore4dart/src/index/chain/MonotoneChain.dart';
import 'package:jtscore4dart/src/index/chain/MonotoneChainSelectAction.dart';
import 'package:jtscore4dart/src/noding/NodedSegmentString.dart';
import 'package:jtscore4dart/src/noding/SegmentString.dart';

import 'HotPixel.dart';

/**
 * "Snaps" all {@link SegmentString}s in a {@link SpatialIndex} containing
 * {@link MonotoneChain}s to a given {@link HotPixel}.
 *
 * @version 1.7
 */
class MCIndexPointSnapper
{
  //static final int nSnaps = 0;

 /**private */SpatialIndex index;

  MCIndexPointSnapper(this.index);

  /**
   * Snaps (nodes) all interacting segments to this hot pixel.
   * The hot pixel may represent a vertex of an edge,
   * in which case this routine uses the optimization
   * of not noding the vertex itself
   *
   * @param [hotPixel] the hot pixel to snap to
   * @param [parentEdge] the edge containing the vertex, if applicable, or <code>null</code>
   * @param [hotPixelVertexIndex] the index of the hotPixel vertex, if applicable, or -1
   * @return <code>true</code> if a node was added for this pixel
   */
  bool snap$2(HotPixel hotPixel, SegmentString? parentEdge, int hotPixelVertexIndex)
  {
    final Envelope pixelEnv = getSafeEnvelope(hotPixel);
    final HotPixelSnapAction hotPixelSnapAction = new HotPixelSnapAction(hotPixel, parentEdge, hotPixelVertexIndex);

    index.queryByVisitor(pixelEnv, _(pixelEnv,hotPixelSnapAction));
    
    return hotPixelSnapAction.isNodeAdded();
  }

  bool snap(HotPixel hotPixel)
  {
    return snap$2(hotPixel, null, -1);
  }

 /**private */static const double SAFE_ENV_EXPANSION_FACTOR = 0.75;
  
  /**
   * Returns a "safe" envelope that is guaranteed to contain the hot pixel.
   * The envelope returned is larger than the exact envelope of the 
   * pixel by a safe margin.
   * 
   * @return an envelope which contains the hot pixel
   */
  Envelope getSafeEnvelope(HotPixel hp)
  {
    double safeTolerance = SAFE_ENV_EXPANSION_FACTOR / hp.getScaleFactor();
    Envelope safeEnv = new Envelope.fromCoord1(hp.getCoordinate());
    safeEnv.expandBy(safeTolerance);
    return safeEnv;
  }

}


/**static */ class HotPixelSnapAction
    extends MonotoneChainSelectAction
{
  /**private */HotPixel hotPixel;
  /**private */SegmentString? parentEdge;
  // is -1 if hotPixel is not a vertex
  /**private */int hotPixelVertexIndex;
  /**private */bool _isNodeAdded = false;

  HotPixelSnapAction(this.hotPixel, this.parentEdge, this.hotPixelVertexIndex);

  /**
   * Reports whether the HotPixel caused a
   * node to be added in any target segmentString (including its own).
   * If so, the HotPixel must be added as a node as well.
   * @return true if a node was added in any target segmentString.
   */
  bool isNodeAdded() { return _isNodeAdded; }

  /**
   * Check if a segment of the monotone chain intersects
   * the hot pixel vertex and introduce a snap node if so.
   * Optimized to avoid noding segments which
   * contain the vertex (which otherwise
   * would cause every vertex to be noded).
   */
  @override
  void select(MonotoneChain mc, int startIndex)
  {
    NodedSegmentString ss =  mc.getContext() as NodedSegmentString;
    /**
     * Check to avoid snapping a hotPixel vertex to the its orginal vertex.
     * This method is called on segments which intersect the
     * hot pixel.
     * If either end of the segment is equal to the hot pixel
     * do not snap.
     */
    if (parentEdge != null && ss == parentEdge) {
      if (startIndex == hotPixelVertexIndex
            || startIndex + 1 == hotPixelVertexIndex
          ) {
        return;
      }
    }
    // records if this HotPixel caused any node to be added
    _isNodeAdded |= addSnappedNode(hotPixel, ss, startIndex);
  }

  /**
   * Adds a new node (equal to the snap pt) to the specified segment
   * if the segment passes through the hot pixel
   *
   * @param segStr
   * @param segIndex
   * @return true if a node was added to the segment
   */
  bool addSnappedNode(HotPixel hotPixel, 
      NodedSegmentString segStr,
      int segIndex
      )
  {
    Coordinate p0 = segStr.getCoordinate(segIndex);
    Coordinate p1 = segStr.getCoordinate(segIndex + 1);

    if (hotPixel.intersects2(p0, p1)) {
      //System.out.println("snapped: " + snapPt);
      //System.out.println("POINT (" + snapPt.x + " " + snapPt.y + ")");
      segStr.addIntersection(hotPixel.getCoordinate(), segIndex);

      return true;
    }
    return false;
  }
}

class _  implements ItemVisitor {
  final Envelope pixelEnv;
  final HotPixelSnapAction hotPixelSnapAction;

  _(this.pixelEnv, this.hotPixelSnapAction);
      @override
  void visitItem(Object item) {
        MonotoneChain testChain = item as MonotoneChain;
        testChain.select(pixelEnv, hotPixelSnapAction);
      }
    }
