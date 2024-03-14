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

// import java.util.Iterator;
// import java.util.NoSuchElementException;

import 'Geometry.dart';
import 'GeometryCollection.dart';

///  Iterates over all {@link Geometry}s in a {@link Geometry},
///  (which may be either a collection or an atomic geometry).
///  The iteration sequence follows a pre-order, depth-first traversal of the
///  structure of the <code>GeometryCollection</code>
///  (which may be nested). The original <code>Geometry</code> object is
///  returned as well (as the first object), as are all sub-collections and atomic elements.
///  It is  simple to ignore the intermediate <code>GeometryCollection</code> objects if they are not
///  needed.
///
///@version 1.7
class GeometryCollectionIterator /** implements Iterator */ {
  ///  The <code>Geometry</code> being iterated over.
   final Geometry _parent;

  ///  Indicates whether or not the first element
  ///  (the root <code>GeometryCollection</code>) has been returned.
   bool _atStart;

  ///  The number of <code>Geometry</code>s in the the <code>GeometryCollection</code>.
   final int _max;

  ///  The index of the <code>Geometry</code> that will be returned when <code>next</code>
  ///  is called.
   int _index;

  ///  The iterator over a nested <code>Geometry</code>, or <code>null</code>
  ///  if this <code>GeometryCollectionIterator</code> is not currently iterating
  ///  over a nested <code>GeometryCollection</code>.
   GeometryCollectionIterator? _subcollectionIterator;

  ///  Constructs an iterator over the given <code>Geometry</code>.
  ///
  ///@param  parent  the geometry over which to iterate; also, the first
  ///      element returned by the iterator.
  GeometryCollectionIterator(this._parent)
      : _atStart = true,
        _index = 0,
        _max = _parent.getNumGeometries();
  //    {
  //   this.parent = parent;
  //   atStart = true;
  //   index = 0;
  //   max = parent.getNumGeometries();
  // }

  /// Tests whether any geometry elements remain to be returned.
  ///
  /// @return true if more geometry elements remain
  bool hasNext() {
    if (_atStart) {
      return true;
    }
    if (_subcollectionIterator != null) {
      if (_subcollectionIterator!.hasNext()) {
        return true;
      }
      _subcollectionIterator = null;
    }
    if (_index >= _max) {
      return false;
    }
    return true;
  }

  /// Gets the next geometry in the iteration sequence.
  ///
  /// @return the next geometry in the iteration
  Object next() {
    // the parent GeometryCollection is the first object returned
    if (_atStart) {
      _atStart = false;
      if (_isAtomic(_parent)) {
        _index++;
      }
      return _parent;
    }
    if (_subcollectionIterator != null) {
      if (_subcollectionIterator!.hasNext()) {
        return _subcollectionIterator!.next();
      } else {
        _subcollectionIterator = null;
      }
    }
    if (_index >= _max) {
      // throw NoSuchElementException();
      throw ArgumentError();
    }
    Geometry obj = _parent.getGeometryN(_index++);
    if (obj is GeometryCollection) {
      _subcollectionIterator = GeometryCollectionIterator(obj);
      // there will always be at least one element in the sub-collection
      return _subcollectionIterator!.next();
    }
    return obj;
  }

   static bool _isAtomic(Geometry geom) {
    return geom is! GeometryCollection;
  }

  /// Removal is not supported.
  ///
  /// @throws  UnsupportedOperationException  This method is not implemented.
  void remove() {
    // throw UnsupportedOperationException(getClass().getName());
    throw Exception("UnsupportedOperationException #remove");
  }
  
  // @override
  // // TODO: implement iterator
  // Iterator get iterator => throw UnimplementedError();
}
