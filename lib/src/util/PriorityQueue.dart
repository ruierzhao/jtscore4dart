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

import 'package:jtscore4dart/src/patch/ArrayList.dart';

/**
 * A priority queue over a set of {@link Comparable} objects.
 * 
 * @author Martin Davis
 * @deprecated
 */
class PriorityQueue 
{
 /**private */late int _size; // Number of elements in queue
 /**private */late List _items; // The queue binary heap array

  /**
   * Creates a new empty priority queue
   */
  PriorityQueue() {
    _size = 0;
    _items = [];
    // create space for sentinel
    _items.add(null);
  }

  /**
   * Insert into the priority queue.
   * Duplicates are allowed.
   * @param [x] the item to insert.
   */
  void add(Comparable x) 
  {
    // increase the size of the items heap to create a hole for the new item
    _items.add(null);

    // Insert item at end of heap and then re-establish ordering
    _size += 1;
    int hole = _size;
    // set the item as a sentinel at the base of the heap
    _items.set(0, x);

    // move the item up from the hole position to its correct place
    for (; x.compareTo(_items.get((hole / 2).floor())) < 0; hole = (hole/2).floor() /**hole /= 2 */ ) {
      _items.set(hole, _items.get((hole / 2).floor()));
    }
    // insert the new item in the correct place
    _items.set(hole, x);
  }

  /**
   * Establish heap from an arbitrary arrangement of items. 
   */
  /*
  /**private */void buildHeap( ) {
   for( int i = currentSize / 2; i > 0; i-- )
   reorder( i );
   }
   */

  /**
   * Test if the priority queue is logically empty.
   * @return true if empty, false otherwise.
   */
  bool isEmpty() {
    return _size == 0;
  }

  /**
   * Returns size.
   * @return current size.
   */
  int size() {
    return _size;
  }

  /**
   * Make the priority queue logically empty.
   */
  void clear() {
    _size = 0;
    _items.clear();
  }

  /**
   * Remove the smallest item from the priority queue.
   * @return the smallest item, or null if empty
   */
  Object? poll()
  {
    if (isEmpty()) {
      return null;
    }
    Object minItem = _items.get(1);
    _items.set(1, _items.get(_size));
    _size -= 1;
    reorder(1);

    return minItem;
  }

  Object? peek() 
  {
    if (isEmpty()) {
      return null;
    }
    Object minItem = _items.get(1);
    return minItem;
  }
  
  /**
   * Internal method to percolate down in the heap.
   * 
   * @param hole the index at which the percolate begins.
   */
 /**private */void reorder(int hole) 
  {
    int child;
    Object tmp = _items.get(hole);

    for (; hole * 2 <= _size; hole = child) {
      child = hole * 2;
      if (child != _size
          && ( _items.get(child + 1) as Comparable).compareTo(_items.get(child)) < 0) {
        child++;
      }
      if (( _items.get(child)  as Comparable).compareTo(tmp) < 0) {
        _items.set(hole, _items.get(child));
      } else {
        break;
      }
    }
    _items.set(hole, tmp);
  }
}

