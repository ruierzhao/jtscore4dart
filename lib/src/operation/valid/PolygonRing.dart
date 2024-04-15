/*
 * Copyright (c) 2021 Martin Davis.
 *
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License 2.0
 * and Eclipse Distribution License v. 1.0 which accompanies this distribution.
 * The Eclipse Public License is available at http://www.eclipse.org/legal/epl-v20.html
 * and the Eclipse Distribution License is available at
 *
 * http://www.eclipse.org/org/documents/edl-v10.php.
 */

// import java.util.ArrayDeque;
// import java.util.ArrayList;
// import java.util.Collection;
// import java.util.Deque;
// import java.util.Map;
// import java.util.List;
// import java.util.Map;

// import org.locationtech.jts.algorithm.Orientation;
// import org.locationtech.jts.algorithm.PolygonNodeTopology;
// import org.locationtech.jts.geom.Coordinate;
// import org.locationtech.jts.geom.LinearRing;

import 'dart:collection';

import 'package:jtscore4dart/src/geom/Coordinate.dart';
import 'package:jtscore4dart/src/geom/LinearRing.dart';
import 'package:jtscore4dart/src/algorithm/Orientation.dart';
import 'package:jtscore4dart/src/algorithm/PolygonNodeTopology.dart';
import 'package:jtscore4dart/src/patch/Map.dart';
import 'package:stack/stack.dart';

/**
 * A ring of a polygon being analyzed for topological validity.
 * The shell and hole rings of valid polygons touch only at discrete points.
 * The "touch" relationship induces a graph over the set of rings. 
 * The interior of a valid polygon must be connected.
 * This is the case if there is no "chain" of touching rings
 * (which would partition off part of the interior).
 * This is equivalent to the touch graph having no cycles.
 * Thus the touch graph of a valid polygon is a forest - a set of disjoint trees.
 * <p>
 * Also, in a valid polygon two rings can touch only at a single location,
 * since otherwise they disconnect a portion of the interior between them.
 * This is checked as the touches relation is built
 * (so the touch relation representation for a polygon ring does not need to support
 * more than one touch location for each adjacent ring).
 * <p>
 * The cycle detection algorithm works for polygon rings which also contain self-touches
 * (inverted shells and exverted holes).
 * <p>
 * Polygons with no holes do not need to be checked for
 * a connected interior, unless self-touches are allowed.
 * The class also records the topology at self-touch nodes,
 * to support checking if an invalid self-touch disconnects the polygon.
 *
 * @author mdavis
 *
 */
class PolygonRing {
  /**
   * Tests if a polygon ring represents a shell.
   * 
   * @param polyRing the ring to test (may be null)
   * @return true if the ring represents a shell
   */
  static bool isShell(PolygonRing polyRing) {
    /// TODO: @ruier edit.可能不太需要
    // if (polyRing == null) return true;
    return polyRing.isShell_();
  }

  /**
   * Records a touch location between two rings,
   * and checks if the rings already touch in a different location.
   * 
   * @param [ring0] a polygon ring
   * @param [ring1] a polygon ring
   * @param [pt] the location where they touch
   * @return true if the polygons already touch
   */
  static bool addTouch(PolygonRing? ring0, PolygonRing? ring1, Coordinate pt) {
    //--- skip if either polygon does not have holes
    if (ring0 == null || ring1 == null) {
      return false;
    }

    //--- only record touches within a polygon
    if (!ring0.isSamePolygon(ring1)) return false;

    if (!ring0.isOnlyTouch(ring1, pt)) return true;
    if (!ring1.isOnlyTouch(ring0, pt)) return true;

    ring0.addTouch_(ring1, pt);
    ring1.addTouch_(ring0, pt);
    return false;
  }

  /**
   * Finds a location (if any) where a chain of holes forms a cycle
   * in the ring touch graph.
   * The shell may form part of the chain as well.
   * This indicates that a set of holes disconnects the interior of a polygon.
   * 
   * @param [polyRings] the list of rings to check
   * @return a vertex contained in a ring cycle, or null if none is found
   */
  static Coordinate? findHoleCycleLocation(List<PolygonRing> polyRings) {
    for (PolygonRing polyRing in polyRings) {
      if (!polyRing.isInTouchSet()) {
        Coordinate? holeCycleLoc = polyRing.findHoleCycleLocation_();
        if (holeCycleLoc != null) return holeCycleLoc;
      }
    }
    return null;
  }

  /**
   * Finds a location of an interior self-touch in a list of rings,
   * if one exists. 
   * This indicates that a self-touch disconnects the interior of a polygon,
   * which is invalid.
   * 
   * @param polyRings the list of rings to check
   * @return the location of an interior self-touch node, or null if there are none
   */
  static Coordinate? findInteriorSelfNode(List<PolygonRing> polyRings) {
    for (PolygonRing polyRing in polyRings) {
      Coordinate? interiorSelfNode = polyRing.findInteriorSelfNode_();
      if (interiorSelfNode != null) {
        return interiorSelfNode;
      }
    }
    return null;
  }

  /**private */ late int id;
  /**private */ late PolygonRing shell;
  /**private */ LinearRing ring;

  /**
   * The root of the touch graph tree containing this ring.
   * Serves as the id for the graph partition induced by the touch relation.
   */
  /**private */ PolygonRing? touchSetRoot = null;

  // lazily created
  /**
   * The set of PolygonRingTouch links
   * for this ring. 
   * The set of all touches in the rings of a polygon
   * forms the polygon touch graph. 
   * This supports detecting touch cycles, which
   * reveal the condition of a disconnected interior.
   * <p>
   * Only a single touch is recorded between any two rings, 
   * since more than one touch between two rings 
   * indicates interior disconnection as well.
   */
  /**private */ Map<int, PolygonRingTouch>? touches = null;

  /**
   * The set of self-nodes in this ring.
   * This supports checking valid ring self-touch topology.
   */
  /**private */ List<PolygonRingSelfNode>? selfNodes = null;

  /**
   * Creates a ring for a polygon shell.
   * @param ring
   */
  // PolygonRing(LinearRing ring) {
  //   this.ring = ring;
  //   id = -1;
  //   shell = this;
  // }

  /**
   * Creates a ring for a polygon hole.
   * @param [ring] the ring geometry
   * @param [index] the index of the hole
   * @param [shell] the parent polygon shell
   */
  PolygonRing(this.ring, [int index = -1, PolygonRing? shell]) {
    this.id = index;
    this.shell = shell ??= this;
  }

  bool isSamePolygon(PolygonRing ring) {
    return shell == ring.shell;
  }

  bool isShell_() {
    return shell == this;
  }

  /**private */ bool isInTouchSet() {
    return touchSetRoot != null;
  }

  /**private */ void setTouchSetRoot(PolygonRing ring) {
    touchSetRoot = ring;
  }

  /**private */ PolygonRing? getTouchSetRoot() {
    return touchSetRoot;
  }

  /**private */ bool hasTouches() {
    return touches != null && touches!.isNotEmpty;
  }

  /**private */ Iterable<PolygonRingTouch> getTouches() {
    return touches!.values;
  }

  /**private */ void addTouch_(PolygonRing ring, Coordinate pt) {
    touches ??= <int, PolygonRingTouch>{};
    PolygonRingTouch? touch = touches!.get(ring.id);
    if (touch == null) {
      touches!.put(ring.id, new PolygonRingTouch(ring, pt));
    }
    ;
  }

  void addSelfTouch(Coordinate origin, Coordinate e00, Coordinate e01,
      Coordinate e10, Coordinate e11) {
    selfNodes ??= <PolygonRingSelfNode>[];
    selfNodes!.add(new PolygonRingSelfNode(origin, e00, e01, e10, e11));
  }

  /**
   * Tests if this ring touches a given ring at
   * the single point specified.
   * 
   * @param ring the other PolygonRing
   * @param pt the touch point
   * @return true if the rings touch only at the given point
   */
  /**private */ bool isOnlyTouch(PolygonRing ring, Coordinate pt) {
    //--- no touches for this ring
    if (touches == null) return true;
    //--- no touches for other ring
    PolygonRingTouch? touch = touches!.get(ring.id);
    if (touch == null) return true;
    //--- the rings touch - check if point is the same
    return touch.isAtLocation(pt);
  }

  /**
   * Detects whether the subgraph of holes linked by touch to this ring
   * contains a hole cycle.
   * If no cycles are detected, the set of touching rings is a tree.
   * The set is marked using this ring as the root.
   * 
   * @return a vertex in a hole cycle, or null if no cycle found
   */
  /**private */ Coordinate? findHoleCycleLocation_() {
    //--- the touch set including this ring is already processed
    if (isInTouchSet()) return null;

    //--- scan the touch set tree rooted at this ring
    // Assert: this.touchSetRoot is null
    PolygonRing root = this;
    root.setTouchSetRoot(root);

    if (!hasTouches()) {
      return null;
    }

    // Deque<PolygonRingTouch> touchStack = new ArrayDeque<PolygonRingTouch>();
    /// TODO: @ruier edit.
    Stack<PolygonRingTouch> touchStack = new Stack<PolygonRingTouch>();
    // Queue<PolygonRingTouch> touchStack = new Queue<PolygonRingTouch>();
    init(root, touchStack);

    while (touchStack.isNotEmpty) {
      PolygonRingTouch touch = touchStack.pop();
      Coordinate? holeCyclePt = scanForHoleCycle(touch, root, touchStack);
      if (holeCyclePt != null) {
        return holeCyclePt;
      }
    }
    return null;
  }

  /**private */ static void init(
      PolygonRing root, Stack<PolygonRingTouch> touchStack) {
    for (PolygonRingTouch touch in root.getTouches()) {
      touch.getRing().setTouchSetRoot(root);
      touchStack.push(touch);
    }
  }

  /**
   * Scans for a hole cycle starting at a given touch. 
   *  
   * @param [currentTouch] the touch to investigate
   * @param [root] the root of the touch subgraph
   * @param [touchStack] the stack of touches to scan
   * @return a vertex in a hole cycle if found, or null
   */
  /**private */ Coordinate? scanForHoleCycle(PolygonRingTouch currentTouch,
      PolygonRing root, Stack<PolygonRingTouch> touchStack) {
    PolygonRing ring = currentTouch.getRing();
    Coordinate currentPt = currentTouch.getCoordinate();

    /**
     * Scan the touched rings
     * Either they form a hole cycle, or they are added to the touch set
     * and pushed on the stack for scanning
     */
    for (PolygonRingTouch touch in ring.getTouches()) {
      /**
       * Don't check touches at the entry point
       * to avoid trivial cycles.
       * They will already be processed or on the stack
       * from the previous ring (which touched
       * all the rings at that point as well)
       */
      if (currentPt.equals2D(touch.getCoordinate())) {
        continue;
      }

      /**
       * Test if the touched ring has already been 
       * reached via a different touch path.
       * This is indicated by it already being marked as
       * part of the touch set.
       * This indicates a hole cycle has been found. 
       */
      PolygonRing touchRing = touch.getRing();
      if (touchRing.getTouchSetRoot() == root) {
        return touch.getCoordinate();
      }

      touchRing.setTouchSetRoot(root);

      touchStack.push(touch);
    }
    return null;
  }

  /**
   * Finds the location of an invalid interior self-touch in this ring,
   * if one exists. 
   * 
   * @return the location of an interior self-touch node, or null if there are none
   */
  Coordinate? findInteriorSelfNode_() {
    if (selfNodes == null) return null;

    /**
     * Determine if the ring interior is on the Right.
     * This is the case if the ring is a shell and is CW,
     * or is a hole and is CCW.
     */
    bool isCCW = Orientation.isCCW(ring.getCoordinates());
    bool isInteriorOnRight = isShell_() ^ isCCW;

    for (PolygonRingSelfNode selfNode in selfNodes!) {
      if (!selfNode.isExterior(isInteriorOnRight)) {
        return selfNode.getCoordinate();
      }
    }
    return null;
  }

  String toString() {
    return ring.toString();
  }
}

/**
 * Records a point where a {@link PolygonRing} touches another one.
 * This forms an edge in the induced ring touch graph.
 * 
 * @author mdavis
 *
 */
class PolygonRingTouch {
  /**private */ PolygonRing ring;
  /**private */ Coordinate touchPt;

  PolygonRingTouch(this.ring, this.touchPt);

  Coordinate getCoordinate() {
    return touchPt;
  }

  PolygonRing getRing() {
    return ring;
  }

  bool isAtLocation(Coordinate pt) {
    return touchPt.equals2D(pt);
  }
}

/**
 * Represents a ring self-touch node, recording the node (intersection point)
 * and the endpoints of the four adjacent segments.
 * <p>
 * This is used to evaluate validity of self-touching nodes,
 * when they are allowed.
 * 
 * @author mdavis
 *
 */
class PolygonRingSelfNode {
  /**private */ Coordinate nodePt;
  /**private */ Coordinate e00;
  /**private */ Coordinate e01;
  /**private */ Coordinate e10;
  //private Coordinate e11;

  PolygonRingSelfNode(
      this.nodePt, this.e00, this.e01, this.e10, Coordinate e11);

  /**
   * The node point.
   * 
   * @return
   */
  Coordinate getCoordinate() {
    return nodePt;
  }

  /**
   * Tests if a self-touch has the segments of each half of the touch
   * lying in the exterior of a polygon.
   * This is a valid self-touch.
   * It applies to both shells and holes.
   * Only one of the four possible cases needs to be tested, 
   * since the situation has full symmetry.
   * 
   * @param isInteriorOnRight whether the interior is to the right of the parent ring
   * @return true if the self-touch is in the exterior
   */
  bool isExterior(bool isInteriorOnRight) {
    /**
     * Note that either corner and either of the other edges could be used to test.
     * The situation is fully symmetrical.
     */
    bool isInteriorSeg =
        PolygonNodeTopology.isInteriorSegment(nodePt, e00, e01, e10);
    bool isExterior = isInteriorOnRight ? !isInteriorSeg : isInteriorSeg;
    return isExterior;
  }
}
