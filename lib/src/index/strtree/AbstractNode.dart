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


// import java.io.Serializable;
// import java.util.ArrayList;
// import java.util.List;

// import org.locationtech.jts.util.Assert;

import 'package:jtscore4dart/src/util/Assert.dart';

import 'Boundable.dart';

/**
 * A node of an {@link AbstractSTRtree}. A node is one of:
 * <ul>
 * <li>empty
 * <li>an <i>interior node</i> containing child {@link AbstractNode}s
 * <li>a <i>leaf node</i> containing data items ({@link ItemBoundable}s). 
 * </ul>
 * A node stores the bounds of its children, and its level within the index tree.
 *
 * @version 1.7
 */
abstract class AbstractNode implements Boundable /**, Serializable */ {
  /**
   * 
   */
//  /**private */static final int serialVersionUID = 6493722185909573708L;
  
 /**private */List childBoundables = [];
 /**private */Object? bounds = null;
 /**private */int? level;

  /**
   * Default constructor required for serialization.
   */
  // AbstractNode() {
  // }

  /**
   * Constructs an AbstractNode at the given level in the tree
   * @param level 0 if this node is a leaf, 1 if a parent of a leaf, and so on; the
   * root node will have the highest level
   */
  AbstractNode([this.level]);

  /**
   * Returns either child {@link AbstractNode}s, or if this is a leaf node, real data (wrapped
   * in {@link ItemBoundable}s).
   * 
   * @return a list of the children
   */
  List getChildBoundables() {
    return childBoundables;
  }

  /**
   * Returns a representation of space that encloses this Boundable,
   * preferably not much bigger than this Boundable's boundary yet fast to
   * test for intersection with the bounds of other Boundables. The class of
   * object returned depends on the subclass of AbstractSTRtree.
   *
   * @return an Envelope (for STRtrees), an Interval (for SIRtrees), or other
   *         object (for other subclasses of AbstractSTRtree)
   * @see AbstractSTRtree.IntersectsOp
   */
 /**protected abstract */ Object computeBounds();

  /**
   * Gets the bounds of this node
   * 
   * @return the object representing bounds in this index
   */
  Object getBounds() {
    bounds ??= computeBounds();
    return bounds!;
  }

  /**
   * Returns 0 if this node is a leaf, 1 if a parent of a leaf, and so on; the
   * root node will have the highest level
   * 
   * @return the node level
   */
  int? getLevel() {
    return level;
  }

  /**
   * Gets the count of the {@link Boundable}s at this node.
   * 
   * @return the count of boundables at this node
   */
  int size()
  {
    return childBoundables.length;
  }
  
  /**
   * Tests whether there are any {@link Boundable}s at this node.
   * 
   * @return true if there are boundables at this node
   */
  bool isEmpty()
  {
    return childBoundables.isEmpty;
  }
  
  /**
   * Adds either an AbstractNode, or if this is a leaf node, a data object
   * (wrapped in an ItemBoundable)
   * 
   * @param childBoundable the child to add
   */
  void addChildBoundable(Boundable childBoundable) {
    Assert.isTrue(bounds == null);
    childBoundables.add(childBoundable);
  }

  void setChildBoundables(List childBoundables)
  {
    this.childBoundables = childBoundables;
  }
}
