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

// import java.util.Comparator;
// import java.util.Iterator;
// import java.util.List;

import 'dart:math' as math;

import 'AbstractNode.dart';
import 'AbstractSTRtree.dart';
import 'Boundable.dart';
import 'Interval.dart';

class _ implements IntersectsOp {
  @override
  bool intersects(Object aBounds, Object bBounds) {
    return (aBounds as Interval).intersects(bBounds as Interval);
  }
}

// new AbstractNode(level) {
class _abstractNode extends AbstractNode {
  _abstractNode(super.level);
  /**protected */
  @override
  Object computeBounds() {
    Interval? bounds = null;
    for (Iterator i = getChildBoundables().iterator; i.moveNext();) {
      Boundable childBoundable = i.current;
      if (bounds == null) {
        bounds =
            new Interval.fromAnother(childBoundable.getBounds() as Interval);
      } else {
        bounds.expandToInclude(childBoundable.getBounds() as Interval);
      }
    }
    return bounds!;
  }
}

/**
 * One-dimensional version of an STR-packed R-tree. SIR stands for
 * "Sort-Interval-Recursive". STR-packed R-trees are described in:
 * P. Rigaux, Michel Scholl and Agnes Voisard. Spatial Databases With
 * Application To GIS. Morgan Kaufmann, San Francisco, 2002.
 * <p>
 * This class is thread-safe.  Building the tree is synchronized, 
 * and querying is stateless.
 * 
 * @see STRtree
 *
 * @version 1.7
 */
class SIRtree extends AbstractSTRtree {
  /**private */
//  Comparator comparator = new Comparator() {
//     int compare(Object o1, Object o2) {
  Comparator comparator = (dynamic o1, dynamic o2) {
    return AbstractSTRtree.compareDoubles(
        ((o1 as Boundable).getBounds() as Interval).getCentre(),
        ((o2 as Boundable).getBounds() as Interval).getCentre());
  };

  /**private */ IntersectsOp intersectsOp = _();

  /**
   * Constructs an SIRtree with the default node capacity.
   */
  // SIRtree() { this(10); }

  /**
   * Constructs an SIRtree with the given maximum number of child nodes that
   * a node may have
   */
  SIRtree([int nodeCapacity = 10]) : super(nodeCapacity);

  /**protected */ @override
  AbstractNode createNode(int level) {
    return _abstractNode(level);
  }

  /**
   * Inserts an item having the given bounds into the tree.
   */
  void insert(double x1, double x2, Object item) {
    super.insertS(new Interval(math.min(x1, x2), math.max(x1, x2)), item);
  }

  /**
   * Returns items whose bounds intersect the given value.
   */
  List query(double x) {
    return queryXY(x, x);
  }

  /**
   * Returns items whose bounds intersect the given bounds.
   * @param x1 possibly equal to x2
   */
  List queryXY(double x1, double x2) {
    return super.queryS(new Interval(math.min(x1, x2), math.max(x1, x2)));
  }

  /**protected */ @override
  IntersectsOp getIntersectsOp() {
    return intersectsOp;
  }

  /**protected */ @override
  Comparator getComparator() {
    return comparator;
  }
}
