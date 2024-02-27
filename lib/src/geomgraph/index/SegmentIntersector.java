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
package org.locationtech.jts.geomgraph.index;

import java.util.Collection;
import java.util.Iterator;

import org.locationtech.jts.algorithm.LineIntersector;
import org.locationtech.jts.geom.Coordinate;
import org.locationtech.jts.geomgraph.Edge;
import org.locationtech.jts.geomgraph.Node;


/**
 * Computes the intersection of line segments,
 * and adds the intersection to the edges containing the segments.
 * 
 * @version 1.7
 */
public class SegmentIntersector 
{

  public static boolean isAdjacentSegments(int i1, int i2)
  {
    return Math.abs(i1 - i2) == 1;
  }

  /**
   * These variables keep track of what types of intersections were
   * found during ALL edges that have been intersected.
   */
  private boolean hasIntersection = false;
  private boolean hasProper = false;
  private boolean hasProperInterior = false;
  // the proper intersection point found
  private Coordinate properIntersectionPoint = null;

  private LineIntersector li;
  private boolean includeProper;
  private boolean recordIsolated;
  private boolean isSelfIntersection;
  //private boolean intersectionFound;
  private int numIntersections = 0;

  // testing only
  public int numTests = 0;

  private Collection[] bdyNodes;

  public SegmentIntersector(LineIntersector li,  boolean includeProper, boolean recordIsolated)
  {
    this.li = li;
    this.includeProper = includeProper;
    this.recordIsolated = recordIsolated;
  }

  public void setBoundaryNodes( Collection bdyNodes0,
                              Collection bdyNodes1)
  {
      bdyNodes = new Collection[2];
      bdyNodes[0] = bdyNodes0;
      bdyNodes[1] = bdyNodes1;
  }
  
  public boolean isDone() {
	  return false;
  }
  /**
   * @return the proper intersection point, or <code>null</code> if none was found
   */
  public Coordinate getProperIntersectionPoint()  {    return properIntersectionPoint;  }

  public boolean hasIntersection() { return hasIntersection; }
  /**
   * A proper intersection is an intersection which is interior to at least two
   * line segments.  Note that a proper intersection is not necessarily
   * in the interior of the entire Geometry, since another edge may have
   * an endpoint equal to the intersection, which according to SFS semantics
   * can result in the point being on the Boundary of the Geometry.
   *
   * @return indicates a proper intersection with an interior to at least two line segments
   */
  public boolean hasProperIntersection() { return hasProper; }
  /**
   * A proper interior intersection is a proper intersection which is <b>not</b>
   * contained in the set of boundary nodes set for this SegmentIntersector.
   *
   * @return indicates a proper interior intersection
   */
  public boolean hasProperInteriorIntersection() { return hasProperInterior; }


  /**
   * A trivial intersection is an apparent self-intersection which in fact
   * is simply the point shared by adjacent line segments.
   * Note that closed edges require a special check for the point shared by the beginning
   * and end segments.
   *
   * @oaram e0 edge 0
   * @param segIndex0 segment index 0
   * @param e1 edge 1
   * @param segIndex1 segment index 1
   * @return indicates a trivial intersection, a point shared by adjacent line segments
   */
  private boolean isTrivialIntersection(Edge e0, int segIndex0, Edge e1, int segIndex1)
  {
    if (e0 == e1) {
      if (li.getIntersectionNum() == 1) {
        if (isAdjacentSegments(segIndex0, segIndex1))
          return true;
        if (e0.isClosed()) {
          int maxSegIndex = e0.getNumPoints() - 1;
          if (    (segIndex0 == 0 && segIndex1 == maxSegIndex)
              ||  (segIndex1 == 0 && segIndex0 == maxSegIndex) ) {
            return true;
          }
        }
      }
    }
    return false;
  }

  /**
   * This method is called by clients of the EdgeIntersector class to test for and add
   * intersections for two segments of the edges being intersected.
   * Note that clients (such as MonotoneChainEdges) may choose not to intersect
   * certain pairs of segments for efficiency reasons.
   */
  public void addIntersections(
    Edge e0,  int segIndex0,
    Edge e1,  int segIndex1
     )
  {
    if (e0 == e1 && segIndex0 == segIndex1) return;
    numTests++;
    Coordinate p00 = e0.getCoordinate(segIndex0);
    Coordinate p01 = e0.getCoordinate(segIndex0 + 1);
    Coordinate p10 = e1.getCoordinate(segIndex1);
    Coordinate p11 = e1.getCoordinate(segIndex1 + 1);

    li.computeIntersection(p00, p01, p10, p11);
//if (li.hasIntersection() && li.isProper()) Debug.println(li);
    /**
     *  Always record any non-proper intersections.
     *  If includeProper is true, record any proper intersections as well.
     */
    if (li.hasIntersection()) {
      if (recordIsolated) {
        e0.setIsolated(false);
        e1.setIsolated(false);
      }
      //intersectionFound = true;
      numIntersections++;
      // if the segments are adjacent they have at least one trivial intersection,
      // the shared endpoint.  Don't bother adding it if it is the
      // only intersection.
      if (! isTrivialIntersection(e0, segIndex0, e1, segIndex1)) {
        hasIntersection = true;
        /**
         * In certain cases two line segments test as having a proper intersection
         * via the robust orientation check, but due to roundoff 
         * the computed intersection point is equal to an endpoint.
         * If the endpoint is a boundary point
         * the computed point must be included as a node.
         * If it is not a boundary point the intersection 
         * is recorded as properInterior by logic below. 
         */
        boolean isBoundaryPt = isBoundaryPoint(li, bdyNodes);
        boolean isNotProper = ! li.isProper() || isBoundaryPt;
        if (includeProper || isNotProper ) {
          e0.addIntersections(li, segIndex0, 0);
          e1.addIntersections(li, segIndex1, 1);
        }
        if (li.isProper()) {
          properIntersectionPoint = li.getIntersection(0).copy();
          hasProper = true;
          if (! isBoundaryPt)
            hasProperInterior = true;
        }
      }
    }
  }

  private boolean isBoundaryPoint(LineIntersector li, Collection[] bdyNodes)
  {
    if (bdyNodes == null) return false;
    if (isBoundaryPointInternal(li, bdyNodes[0])) return true;
    if (isBoundaryPointInternal(li, bdyNodes[1])) return true;
    return false;
  }

  private boolean isBoundaryPointInternal(LineIntersector li, Collection bdyNodes)
  {
    for (Iterator i = bdyNodes.iterator(); i.hasNext(); ) {
      Node node = (Node) i.next();
      Coordinate pt = node.getCoordinate();
      if (li.isIntersection(pt)) return true;
    }
    return false;
  }

}
