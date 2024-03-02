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


// import java.util.Arrays;

import 'dart:math';

/// An extendable array of primitive <code>int</code> values.
/// 
/// @author Martin Davis
///
class IntArrayList {
  List<int> _data;
  int _size = 0;

  /// Constructs an empty list.
  IntArrayList.default() :this(10);

  /// Constructs an empty list with the specified initial capacity
  /// 
  /// @param initialCapacity the initial capacity of the list
  IntArrayList(int initialCapacity) {
    _data = List.filled(initialCapacity, 0);
  }

  /// Returns the number of values in this list.
  /// 
  /// @return the number of values in the list
  int size() {
    return _size;
  }

  /// Increases the capacity of this list instance, if necessary, 
  /// to ensure that it can hold at least the number of elements 
  /// specified by the capacity argument.
  /// 
  /// @param capacity the desired capacity
  void ensureCapacity(final int capacity) {
    if (capacity <= _data.length) return;
    int newLength  = max(capacity, _data.length * 2);
    //System.out.println("IntArrayList: copying " + size + " ints to new array of length " + capacity);
    _data = Arrays.copyOf(_data, newLength);
    // List.copyRange(target, at, source)
  }
  /// Adds a value to the end of this list.
  /// 
  /// @param value the value to add
  void add(final int value) {
    ensureCapacity(_size + 1);
    _data[_size] = value;
    ++_size;
  }
  
  /// Adds all values in an array to the end of this list.
  /// 
  /// @param values an array of values
  void addAll(final List<int> values) {
    if (values == null) return;
    if (values.length == 0) return;
    ensureCapacity(_size + values.length);
    System.arraycopy(values, 0, _data, _size, values.length);
    _size += values.length;
   }
  
  /// Returns a int array containing a copy of
  /// the values in this list.
  /// 
  /// @return an array containing the values in this list
  List<int> toArray() {
    List<int> array = int[_size];
    System.arraycopy(_data, 0, array, 0, _size);
    return array;
  }
}
