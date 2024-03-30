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
// import java.util.Collection;
// import java.util.Collections;
// import java.util.Comparator;
// import java.util.Iterator;
// import java.util.List;

// import org.locationtech.jts.index.ItemVisitor;
// import org.locationtech.jts.util.Assert;

import 'package:jtscore4dart/src/index/ItemVisitor.dart';
import 'package:jtscore4dart/src/patch/ArrayList.dart';
import 'package:jtscore4dart/src/util/Assert.dart';

import 'AbstractNode.dart';
import 'Boundable.dart';
import 'ItemBoundable.dart';



/**
 * A test for intersection between two bounds, necessary because subclasses
 * of AbstractSTRtree have different implementations of bounds.
 */
/**protected static*/ abstract class IntersectsOp {
  /**
   * For STRtrees, the bounds will be Envelopes; for SIRtrees, Intervals;
   * for other subclasses of AbstractSTRtree, some other class.
   * @param [aBounds] the bounds of one spatial object
   * @param [bBounds] the bounds of another spatial object
   * @return whether the two bounds intersect
   */
  bool intersects(Object aBounds, Object bBounds);
}



/**
 * Base class for STRtree and SIRtree. STR-packed R-trees are described in:
 * P. Rigaux, Michel Scholl and Agnes Voisard. <i>Spatial Databases With
 * Application To GIS.</i> Morgan Kaufmann, San Francisco, 2002.
 * <p>
 * This implementation is based on {@link Boundable}s rather than {@link AbstractNode}s,
 * because the STR algorithm operates on both nodes and
 * data, both of which are treated as Boundables.
 * <p>
 * This class is thread-safe.  Building the tree is synchronized, 
 * and querying is stateless.
 *
 * @see STRtree
 * @see SIRtree
 *
 * @version 1.7
 */
abstract class AbstractSTRtree /** implements Serializable  */ {

  /**
   * 
   */
//  /**private */static final int serialVersionUID = -3886435814360241337L;

 /**protected */late AbstractNode root;

 /**private */bool built = false;
  /**
   * Set to <tt>null</tt> when index is built, to avoid retaining memory.
   */
 /**private */List<Boundable>? itemBoundables = List.empty(growable: true);
  
 /**private */int nodeCapacity;

 /**private */static const int DEFAULT_NODE_CAPACITY = 10;

  /**
   * Constructs an AbstractSTRtree with the 
   * default node capacity.
   */
  // AbstractSTRtree() {
  //   this(DEFAULT_NODE_CAPACITY);
  // }

  /**
   * Constructs an AbstractSTRtree with the specified maximum number of child
   * nodes that a node may have
   * 
   * @param nodeCapacity the maximum number of child nodes in a node
   */
  // AbstractSTRtree(int nodeCapacity) {
  //   Assert.isTrue(nodeCapacity > 1, "Node capacity must be greater than 1");
  //   this.nodeCapacity = nodeCapacity;
  // }
  AbstractSTRtree([this.nodeCapacity=DEFAULT_NODE_CAPACITY]):
    assert(nodeCapacity > 1, "Node capacity must be greater than 1");


  /**
   * Constructs an AbstractSTRtree with the specified maximum number of child
   * nodes that a node may have, and the root node
   * @param [nodeCapacity] the maximum number of child nodes in a node
   * @param [root] the root node that links to all other nodes in the tree
   */
  // public AbstractSTRtree(int nodeCapacity, AbstractNode root) {
  //   this(nodeCapacity);
  //   built = true;
  //   this.root = root;
  //   this.itemBoundables = null;
  // }
  AbstractSTRtree.root(this.nodeCapacity, this.root) 
    :this.built = true,
    this.itemBoundables = null;

  /**
   * Constructs an AbstractSTRtree with the specified maximum number of child
   * nodes that a node may have, and all leaf nodes in the tree
   * @param [nodeCapacity] the maximum number of child nodes in a node
   * @param [itemBoundables] the list of leaf nodes in the tree
   */
  AbstractSTRtree.leaf(this.nodeCapacity, this.itemBoundables);
  /**
   * Creates parent nodes, grandparent nodes, and so forth up to the root
   * node, for the data that has been inserted into the tree. Can only be
   * called once, and thus can be called only after all of the data has been
   * inserted into the tree.
   */
  /**synchronized */ void build() {
    if (built) return;
    root = itemBoundables!.isEmpty
           ? createNode(0)
           : createHigherLevels(itemBoundables!, -1);
    // the item list is no longer needed
    itemBoundables = null;
    built = true;
  }

 /**protected abstract*/ AbstractNode createNode(int level);

  /**
   * Sorts the childBoundables then divides them into groups of size M, where
   * M is the node capacity.
   */
 /**protected */List createParentBoundables(List childBoundables, int newLevel) {
    Assert.isTrue(childBoundables.isNotEmpty);
    List parentBoundables = [];
    parentBoundables.add(createNode(newLevel));
    // List sortedChildBoundables = new ArrayList(childBoundables);
    List sortedChildBoundables = new ArrayList(childBoundables);
    Collections.sort(sortedChildBoundables, getComparator());
    for (Iterator i = sortedChildBoundables.iterator; i.moveNext(); ) {
      Boundable childBoundable =  i.current as Boundable;
      if (lastNode(parentBoundables).getChildBoundables().size() == getNodeCapacity()) {
        parentBoundables.add(createNode(newLevel));
      }
      lastNode(parentBoundables).addChildBoundable(childBoundable);
    }
    return parentBoundables;
  }

 /**protected */AbstractNode lastNode(List nodes) {
    return nodes.get(nodes.size() - 1) as AbstractNode;
  }

 /**protected */
  static int compareDoubles(double a, double b) {
    return a > b ? 1
         : a < b ? -1
         : 0;
  }

  /**
   * Creates the levels higher than the given level
   *
   * @param boundablesOfALevel
   *            the level to build on
   * @param level
   *            the level of the Boundables, or -1 if the boundables are item
   *            boundables (that is, below level 0)
   * @return the root, which may be a ParentNode or a LeafNode
   */
 /**private */AbstractNode createHigherLevels(List boundablesOfALevel, int level) {
    Assert.isTrue(boundablesOfALevel.isNotEmpty);
    List parentBoundables = createParentBoundables(boundablesOfALevel, level + 1);
    if (parentBoundables.size() == 1) {
      return parentBoundables.get(0) as AbstractNode;
    }
    return createHigherLevels(parentBoundables, level + 1);
  }

  /**
   * Gets the root node of the tree.
   * 
   * @return the root node
   */
  AbstractNode getRoot() 
  {
    build();
    return root; 
  }

  /**
   * Returns the maximum number of child nodes that a node may have.
   * 
   * @return the node capacity
   */
  int getNodeCapacity() { return nodeCapacity; }

  /**
   * Tests whether the index contains any items.
   * This method does not build the index,
   * so items can still be inserted after it has been called.
   * 
   * @return true if the index does not contain any items
   */
  bool isEmpty()
  {
    if (! built) return (itemBoundables!=null && itemBoundables!.isEmpty);
    return root.isEmpty();
  }
  
 /**protected */
 int size() {
    if (isEmpty()) {
      return 0;
    }
    build();
    return size$1(root);
  }

 /**protected */int size$1(AbstractNode node)
  {
    int _size = 0;
    for (Iterator i = node.getChildBoundables().iterator; i.moveNext(); ) {
      Boundable childBoundable = i.current as Boundable;
      if (childBoundable is AbstractNode) {
        _size += size$1(childBoundable as AbstractNode);
      }
      else if (childBoundable is ItemBoundable) {
        _size += 1;
      }
    }
    return _size;
  }

 /**protected */int depth() {
    if (isEmpty()) {
      return 0;
    }
    build();
    return depth$1(root);
  }

 /**protected */int depth$1(AbstractNode node)
  {
    int maxChildDepth = 0;
    for (Iterator i = node.getChildBoundables().iterator; i.moveNext(); ) {
      Boundable childBoundable =  i.current as Boundable;
      if (childBoundable is AbstractNode) {
        int childDepth = depth$1( childBoundable as AbstractNode);
        if (childDepth > maxChildDepth) {
          maxChildDepth = childDepth;
        }
      }
    }
    return maxChildDepth + 1;
  }


 /**protected */void insert(Object bounds, Object item) {
    Assert.isTrue(!built, "Cannot insert items into an STR packed R-tree after it has been built.");
    itemBoundables!.add(new ItemBoundable(bounds, item));
  }

  /**
   *  Also builds the tree, if necessary.
   */
 /**protected */List query(Object searchBounds) {
    build();
    List matches = [];
    if (isEmpty()) {
      //Assert.isTrue(root.getBounds() == null);
      return matches;
    }
    if (getIntersectsOp().intersects(root.getBounds(), searchBounds)) {
      queryInternal$1(searchBounds, root, matches);
    }
    return matches;
  }

  /**
   *  Also builds the tree, if necessary.
   */
 /**protected */void queryByVisitor(Object searchBounds, ItemVisitor visitor) {
    build();
    if (isEmpty()) {
      // nothing in tree, so return
      //Assert.isTrue(root.getBounds() == null);
      return;
    }
    if (getIntersectsOp().intersects(root.getBounds(), searchBounds)) {
      queryInternal$2(searchBounds, root, visitor);
    }
  }

  /**
   * @return a test for intersection between two bounds, necessary because subclasses
   * of AbstractSTRtree have different implementations of bounds.
   * @see IntersectsOp
   */
 /**protected abstract */ IntersectsOp getIntersectsOp();

 /**private */void queryInternal$1(Object searchBounds, AbstractNode node, List matches) {
    List childBoundables = node.getChildBoundables();
    for (int i = 0; i < childBoundables.size(); i++) {
      Boundable childBoundable =  childBoundables.get(i) as Boundable;
      if (! getIntersectsOp().intersects(childBoundable.getBounds(), searchBounds)) {
        continue;
      }
      if (childBoundable is AbstractNode) {
        queryInternal$1(searchBounds,  childBoundable as AbstractNode, matches);
      }
      else if (childBoundable is ItemBoundable) {
        matches.add((childBoundable as ItemBoundable).getItem());
      }
      else {
        Assert.shouldNeverReachHere();
      }
    }
  }

 /**private */void queryInternal$2(Object searchBounds, AbstractNode node, ItemVisitor visitor) {
    List childBoundables = node.getChildBoundables();
    for (int i = 0; i < childBoundables.size(); i++) {
      Boundable childBoundable =  childBoundables.get(i) as Boundable;
      if (! getIntersectsOp().intersects(childBoundable.getBounds(), searchBounds)) {
        continue;
      }
      if (childBoundable is AbstractNode) {
        queryInternal$2(searchBounds,  childBoundable as AbstractNode, visitor);
      }
      else if (childBoundable is ItemBoundable) {
        visitor.visitItem((childBoundable as ItemBoundable).getItem());
      }
      else {
        Assert.shouldNeverReachHere();
      }
    }
  }

  /**
   * Gets a tree structure (as a nested list) 
   * corresponding to the structure of the items and nodes in this tree.
   * <p>
   * The returned {@link List}s contain either {@link Object} items, 
   * or Lists which correspond to subtrees of the tree
   * Subtrees which do not contain any items are not included.
   * <p>
   * Builds the tree if necessary.
   * 
   * @return a List of items and/or Lists
   */
  List itemsTree()
  {
    build();

    List<Boundable>? valuesTree = _itemsTree(root);
    if (valuesTree == null) {
      return [];
    }
    return valuesTree;
  }
  
 /**private */List<Boundable>? _itemsTree(AbstractNode node)
  {
    List<Boundable> valuesTreeForNode = [];
    for (Iterator i = node.getChildBoundables().iterator; i.moveNext(); ) {
      Boundable childBoundable =  i.current as Boundable;
      if (childBoundable is AbstractNode) {
        List<Boundable>? valuesTreeForChild = _itemsTree( childBoundable as AbstractNode);
        // only add if not null (which indicates an item somewhere in this tree
        if (valuesTreeForChild != null) {
          valuesTreeForNode.addAll(valuesTreeForChild);
        }
      }
      else if (childBoundable is ItemBoundable) {
        valuesTreeForNode.add(childBoundable.getItem() as Boundable);
      }
      else {
        Assert.shouldNeverReachHere();
      }
    }
    if (valuesTreeForNode.size() <= 0) {
      return null;
    }
    return valuesTreeForNode;
  }

  /**
   * Removes an item from the tree.
   * (Builds the tree, if necessary.)
   */
  /**protected */
  bool remove(Object searchBounds, Object item) {
    build();
    if (getIntersectsOp().intersects(root.getBounds(), searchBounds)) {
      return _removeByBounds(searchBounds, root, item);
    }
    return false;
  }

 bool _remove(AbstractNode node, Object item)
  {
    Boundable? childToRemove;
    for (Iterator i = node.getChildBoundables().iterator; i.moveNext(); ) {
      Boundable childBoundable =  i.current;
      if (childBoundable is ItemBoundable) {
        if ( ( childBoundable).getItem() == item) {
          childToRemove = childBoundable;
        }
      }
    }
    if (childToRemove != null) {
      node.getChildBoundables().remove(childToRemove);
      return true;
    }
    return false;
  }

  bool _removeByBounds(Object searchBounds, AbstractNode node, Object item) {
    // first try removing item from this node
    bool found = _remove(node, item);
    if (found) {
      return true;
    }

    AbstractNode? childToPrune = null;
    // next try removing item from lower nodes
    for (Iterator i = node.getChildBoundables().iterator; i.moveNext(); ) {
      Boundable childBoundable =  i.current ;
      if (!getIntersectsOp().intersects(childBoundable.getBounds(), searchBounds)) {
        continue;
      }
      if (childBoundable is AbstractNode) {
        found = _removeByBounds(searchBounds,  childBoundable as AbstractNode, item);
        // if found, record child for pruning and exit
        if (found) {
          childToPrune =  childBoundable as AbstractNode;
          break;
        }
      }
    }
    // prune child if possible
    if (childToPrune != null) {
      if (childToPrune.getChildBoundables().isEmpty) {
        node.getChildBoundables().remove(childToPrune);
      }
    }
    return found;
  }

  /**protected */List boundablesAtLevel(int level) {
    List boundables = [];
    boundablesAtLevel(level, root, boundables);
    return boundables;
  }

  /**
   * @param level -1 to get items
   */
 /**private */void _boundablesAtLevel(int level, AbstractNode top, Iterable boundables) {
    Assert.isTrue(level > -2);
    if (top.getLevel() == level) {
      boundables.add(top);
      return;
    }
    for (Iterator i = top.getChildBoundables().iterator; i.moveNext(); ) {
      Boundable boundable =  i.current as Boundable;
      if (boundable is AbstractNode) {
        _boundablesAtLevel(level, boundable as AbstractNode, boundables);
      }
      else {
        Assert.isTrue(boundable is ItemBoundable);
        if (level == -1) { boundables.add(boundable); }
      }
    }
    return;
  }

  /**protected abstract*/ Comparator getComparator();

  List  getItemBoundables()
  {
    return itemBoundables;
  }
}
