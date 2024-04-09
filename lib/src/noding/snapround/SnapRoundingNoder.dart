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

// import org.locationtech.jts.geom.Coordinate;
// import org.locationtech.jts.geom.CoordinateList;
// import org.locationtech.jts.geom.PrecisionModel;
// import org.locationtech.jts.index.kdtree.KdNode;
// import org.locationtech.jts.index.kdtree.KdNodeVisitor;
// import org.locationtech.jts.noding.MCIndexNoder;
// import org.locationtech.jts.noding.NodedSegmentString;
// import org.locationtech.jts.noding.Noder;
// import org.locationtech.jts.noding.SegmentString;

import 'package:jtscore4dart/src/geom/Coordinate.dart';
import 'package:jtscore4dart/src/geom/CoordinateList.dart';
import 'package:jtscore4dart/src/geom/PrecisionModel.dart';
import 'package:jtscore4dart/src/index/kdtree/KdNode.dart';
import 'package:jtscore4dart/src/index/kdtree/KdNodeVisitor.dart';

import '../MCIndexNoder.dart';
import '../NodedSegmentString.dart';
import '../Noder.dart';
import '../SegmentString.dart';
import 'HotPixel.dart';
import 'HotPixelIndex.dart';
import 'SnapRoundingIntersectionAdder.dart';

/**
 * Uses Snap Rounding to compute a rounded,
 * fully noded arrangement from a set of {@link SegmentString}s,
 * in a performant way, and avoiding unnecessary noding.
 * <p>
 * Implements the Snap Rounding technique described in 
 * the papers by Hobby, Guibas &amp; Marimont, and Goodrich et al.
 * Snap Rounding enforces that all output vertices lie on a uniform grid,
 * which is determined by the provided {@link PrecisionModel}.
 * <p>
 * Input vertices do not have to be rounded to the grid beforehand; 
 * this is done during the snap-rounding process.
 * In fact, rounding cannot be done a priori,
 * since rounding vertices by themselves can distort the rounded topology
 * of the arrangement (i.e. by moving segments away from hot pixels
 * that would otherwise intersect them, or by moving vertices
 * across segments).
 * <p>
 * To minimize the number of introduced nodes,
 * the Snap-Rounding Noder avoids creating nodes
 * at edge vertices if there is no intersection or snap at that location.
 * However, if two different input edges contain identical segments,
 * each of the segment vertices will be noded.
 * This still provides fully-noded output.
 * This is the same behaviour provided by other noders,
 * such as {@link MCIndexNoder} and {@link org.locationtech.jts.noding.snap.SnappingNoder}.
 * 
 * @version 1.7
 */
class SnapRoundingNoder implements Noder
{
  /**
   * The division factor used to determine
   * nearness distance tolerance for intersection detection.
   */
 /**private */static const int NEARNESS_FACTOR = 100;
  
 /**private */final PrecisionModel pm;
 /**private */final HotPixelIndex pixelIndex;
  
 /**private */late List<NodedSegmentString> snappedResult;

  SnapRoundingNoder(this.pm) :
    pixelIndex = new HotPixelIndex(pm);

  /**
	 * @return a Collection of NodedSegmentStrings representing the substrings
	 * 
	 */
  @override
  Iterable<SegmentString> getNodedSubstrings()
  {
    return NodedSegmentString.getNodedSubstrings(snappedResult);
  }

  /**
   * Computes the nodes in the snap-rounding line arrangement.
   * The nodes are added to the {@link NodedSegmentString}s provided as the input.
   * 
   * @param inputSegmentStrings a Collection of NodedSegmentStrings
   */
  @override
  void computeNodes(Iterable<NodedSegmentString> inputSegmentStrings)
  {
    snappedResult = snapRound(inputSegmentStrings);
  }
  
 /**private */
 List<NodedSegmentString> snapRound(Iterable<NodedSegmentString> segStrings)
  {
    /**
     * Determine hot pixels for intersections and vertices.
     * This is done BEFORE the input lines are rounded,
     * to avoid distorting the line arrangement 
     * (rounding can cause vertices to move across edges).
     */
    addIntersectionPixels(segStrings);
    addVertexPixels(segStrings);

    List<NodedSegmentString> snapped = computeSnaps(segStrings);
    return snapped;
  }

  /**
   * Detects interior intersections in the collection of {@link SegmentString}s,
   * and adds nodes for them to the segment strings.
   * Also creates HotPixel nodes for the intersection points.
   * 
   * @param segStrings the input NodedSegmentStrings
   */
 /**private */void addIntersectionPixels(Iterable<NodedSegmentString> segStrings)
  {
    /**
     * nearness tolerance is a small fraction of the grid size.
     */
    double snapGridSize = 1.0 / pm.getScale();
    double nearnessTol = snapGridSize / NEARNESS_FACTOR;
    
    SnapRoundingIntersectionAdder intAdder = new SnapRoundingIntersectionAdder(nearnessTol);
    MCIndexNoder noder = new MCIndexNoder(intAdder, nearnessTol);
    noder.computeNodes(segStrings);
    List<Coordinate> intPts = intAdder.getIntersections();
    pixelIndex.addNodes(intPts);
  }
  
  /**
   * Creates HotPixels for each vertex in the input segStrings.
   * The HotPixels are not marked as nodes, since they will
   * only be nodes in the final line arrangement
   * if they interact with other segments (or they are already
   * created as intersection nodes).
   * 
   * @param segStrings the input NodedSegmentStrings
   */
 /**private */
  void addVertexPixels(Iterable<NodedSegmentString> segStrings) {
    for (SegmentString nss in segStrings) {
      List<Coordinate> pts = nss.getCoordinates();
      pixelIndex.addAll(pts);
    }
  }

 /**private */Coordinate round(Coordinate pt) {
    Coordinate p2 = pt.copy();
    pm.makePreciseFromCoord(p2);
    return p2;
  }

  /**
   * Gets a list of the rounded coordinates.
   * Duplicate (collapsed) coordinates are removed.
   * 
   * @param pts the coordinates to round
   * @return array of rounded coordinates
   */
 /**private */List<Coordinate> roundAll(List<Coordinate> pts) {
    CoordinateList roundPts = new CoordinateList();
    
    for (int i = 0; i < pts.length; i++ ) {
      roundPts.add( round( pts[i] ), false);
    }
    return roundPts.toCoordinateArray();
  }

  /**
   * Computes new segment strings which are rounded and contain
   * intersections added as a result of snapping segments to snap points (hot pixels).
   * 
   * @param segStrings segments to snap
   * @return the snapped segment strings
   */
 /**private */List<NodedSegmentString> computeSnaps(Iterable<NodedSegmentString> segStrings)
  {
    // List<NodedSegmentString> snapped = new ArrayList<NodedSegmentString>();
    List<NodedSegmentString> snapped = [];
    for (NodedSegmentString ss in segStrings ) {
      NodedSegmentString? snappedSS = computeSegmentSnaps(ss);
      if (snappedSS != null) {
        snapped.add(snappedSS);
      }
    }
    /**
     * Some intersection hot pixels may have been marked as nodes in the previous
     * loop, so add nodes for them.
     */
    for (NodedSegmentString ss in snapped ) {
      addVertexNodeSnaps(ss);
    }
    return snapped;
  }

  /**
   * Add snapped vertices to a segment string.
   * If the segment string collapses completely due to rounding,
   * null is returned.
   * 
   * @param ss the segment string to snap
   * @return the snapped segment string, or null if it collapses completely
   */
 /**private */NodedSegmentString? computeSegmentSnaps(NodedSegmentString ss)
  {
    //List<Coordinate> pts = ss.getCoordinates();
    /**
     * Get edge coordinates, including added intersection nodes.
     * The coordinates are now rounded to the grid,
     * in preparation for snapping to the Hot Pixels
     */
    List<Coordinate> pts = ss.getNodedCoordinates();
    List<Coordinate> ptsRound = roundAll(pts);
    
    // if complete collapse this edge can be eliminated
    if (ptsRound.length <= 1) {
      return null;
    }
    
    // Create new nodedSS to allow adding any hot pixel nodes
    NodedSegmentString snapSS = new NodedSegmentString(ptsRound, ss.getData());
    
    int snapSSindex = 0;
    for (int i = 0; i < pts.length - 1; i++ ) {
      Coordinate currSnap = snapSS.getCoordinate(snapSSindex);

      /**
       * If the segment has collapsed completely, skip it
       */
      Coordinate p1 = pts[i+1];
      Coordinate p1Round = round(p1);
      if (p1Round.equals2D(currSnap)) {
        continue;
      }
      
      Coordinate p0 = pts[i];
      
      /**
       * Add any Hot Pixel intersections with *original* segment to rounded segment.
       * (It is important to check original segment because rounding can
       * move it enough to intersect other hot pixels not intersecting original segment)
       */
      snapSegment( p0, p1, snapSS, snapSSindex);      
      snapSSindex++;
    }
    return snapSS;
  }


  /**
   * Snaps a segment in a segmentString to HotPixels that it intersects.
   * 
   * @param p0 the segment start coordinate
   * @param p1 the segment end coordinate
   * @param ss the segment string to add intersections to
   * @param segIndex the index of the segment
   */
 /**private */void snapSegment(Coordinate p0, Coordinate p1, NodedSegmentString ss, int segIndex) {
    pixelIndex.query(p0, p1, _visitor1(p0,p1,ss,segIndex));
  }

  /**
   * Add nodes for any vertices in hot pixels that were
   * added as nodes during segment noding.
   * 
   * @param ss a noded segment string
   */
 /**private */void addVertexNodeSnaps(NodedSegmentString ss)
  {
    List<Coordinate> pts = ss.getCoordinates();
    for (int i = 1; i < pts.length - 1; i++ ) {
      Coordinate p0 = pts[i];
      snapVertexNode( p0, ss, i);      
    }
  }

 /**private */void snapVertexNode(Coordinate p0, NodedSegmentString ss, int segIndex) {
    pixelIndex.query(p0, p0, new _visitor2(p0,ss,segIndex));
  }

}

class _visitor1 implements KdNodeVisitor {
  final Coordinate p0;
  final Coordinate p1;
  final NodedSegmentString ss;
  final int segIndex;

  _visitor1(this.p0,this.p1, this.ss, this.segIndex);

  @override
  void visit(KdNode node) {
    HotPixel hp =  node.getData() as HotPixel;
    
    /**
     * If the hot pixel is not a node, and it contains one of the segment vertices,
     * then that vertex is the source for the hot pixel.
     * To avoid over-noding a node is not added at this point. 
     * The hot pixel may be subsequently marked as a node,
     * in which case the intersection will be added during the final vertex noding phase.
     */
    if (! hp.isNode()) {
      if (hp.intersects(p0) || hp.intersects(p1)) {
        return;
      }
    }
    /**
     * Add a node if the segment intersects the pixel.
     * Mark the HotPixel as a node (since it may not have been one before).
     * This ensures the vertex for it is added as a node during the final vertex noding phase.
     */
    if (hp.intersects2(p0, p1)) {
      //System.out.println("Added intersection: " + hp.getCoordinate());
      ss.addIntersection( hp.getCoordinate(), segIndex );
      hp.setToNode();
    }
  }
}

class _visitor2 implements KdNodeVisitor {
  final Coordinate p0;
  final NodedSegmentString ss;
  final int segIndex;
  
  _visitor2(this.p0, this.ss, this.segIndex);
  
  @override
  void visit(KdNode node) {
    HotPixel hp =  node.getData() as HotPixel;
    /**
     * If vertex pixel is a node, add it.
     */
    if (hp.isNode() && hp.getCoordinate().equals2D(p0)) {
      ss.addIntersection( p0, segIndex );
    }
  }
  
}

