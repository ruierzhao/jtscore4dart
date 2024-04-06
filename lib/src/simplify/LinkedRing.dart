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


// import org.locationtech.jts.geom.Coordinate;
// import org.locationtech.jts.geom.CoordinateList;

import 'package:jtscore4dart/src/geom/Coordinate.dart';
import 'package:jtscore4dart/src/geom/CoordinateList.dart';

class LinkedRing {
  
 /**private */static final int NO_COORD_INDEX = -1;

 /**private */final List<Coordinate> coord;
//  /**private */List<int> next = null;
 /**private */List<int> _next;
//  /**private */List<int> prev = null;
 /**private */List<int> _prev;
 /**private */int _size;
  
  LinkedRing(this.coord) :
    // coord = pts;
    _size = coord.length - 1,
    _next = _createNextLinks(coord.length - 1),
    _prev = _createPrevLinks(coord.length - 1);

 /**private */static List<int> _createNextLinks(int size) {
    // int[] next = new int[size];
    List<int> next = List.filled(size, 0);
    for (int i = 0; i < size; i++) {
      next[i] = i + 1;
    }
    next[size - 1] = 0;
    return next;
  }
  
 /**private */static List<int> _createPrevLinks(int size) {
    // List<int> prev = new int[size];
    List<int> prev = List.filled(size, 0);
    for (int i = 0; i < size; i++) {
      prev[i] = i - 1;
    }
    prev[0] = size - 1;
    return prev;
  }
  
  int size() {
    return _size;
  }

  int next(int i) {
    return _next[i];
  }

  int prev(int i) {
    return _prev[i];
  }
  
  Coordinate getCoordinate(int index) {
    return coord[index];
  }

  Coordinate prevCoordinate(int index) {
    return coord[prev(index)];
  }

  Coordinate nextCoordinate(int index) {
    return coord[next(index)];
  }  
  
  bool hasCoordinate(int index) {
    return index >= 0 && index < _prev.length 
        && _prev[index] != NO_COORD_INDEX;
  }
  
  void remove(int index) {
    int iprev = _prev[index];
    int inext = _next[index];
    _next[iprev] = inext;
    _prev[inext] = iprev;
    _prev[index] = NO_COORD_INDEX;
    _next[index] = NO_COORD_INDEX;
    _size--;
  }
  
  List<Coordinate> getCoordinates() {
    CoordinateList coords = new CoordinateList();
    for (int i = 0; i < coord.length - 1; i++) {
      if (_prev[i] != NO_COORD_INDEX) {
        coords.add(coord[i].copy(), false);
      }
    }
    coords.closeRing();
    return coords.toCoordinateArray();
  }
}
