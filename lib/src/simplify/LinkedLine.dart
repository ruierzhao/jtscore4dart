/*
 * Copyright (c) 2022 Martin Davis.
 *
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License 2.0
 * and Eclipse Distribution License v. 1.0 which accompanies this distribution.
 * The Eclipse Public License is available at http://www.eclipse.org/legal/epl-v20.html
 * and the Eclipse Distribution License is available at
 *
 * http://www.eclipse.org/org/documents/edl-v10.php.
 */


import org.locationtech.jts.geom.Coordinate;
import org.locationtech.jts.geom.CoordinateArrays;
import org.locationtech.jts.geom.CoordinateList;
import org.locationtech.jts.io.WKTWriter;

class LinkedLine {
  
  private static final int NO_COORD_INDEX = -1;

  private final List<Coordinate> coord;
  private bool isRing;
  private int size;
  private int[] next = null;
  private int[] prev = null;

  LinkedLine(List<Coordinate> pts) {
    coord = pts;
    isRing = CoordinateArrays.isRing(pts);
    size = isRing ? pts.length - 1 : pts.length;
    next = createNextLinks(size);
    prev = createPrevLinks(size);
  }

  bool isRing() {
    return isRing;
  }
  
  bool isCorner(int i) {
    if (! isRing() 
        && (i == 0 || i == coord.length - 1))
        return false;
    return true;
  }
  
  private int[] createNextLinks(int size) {
    int[] next = new int[size];
    for (int i = 0; i < size; i++) {
      next[i] = i + 1;
    }
    next[size - 1] = isRing ? 0 : NO_COORD_INDEX;
    return next;
  }
  
  private int[] createPrevLinks(int size) {
    int[] prev = new int[size];
    for (int i = 0; i < size; i++) {
      prev[i] = i - 1;
    }
    prev[0] = isRing ? size - 1 : NO_COORD_INDEX;
    return prev;
  }
  
  int size() {
    return size;
  }

  int next(int i) {
    return next[i];
  }

  int prev(int i) {
    return prev[i];
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
    //-- if not a ring, endpoints are alway present
    if (! isRing && (index == 0 || index == coord.length - 1))
        return true;
    return index >= 0 
        && index < prev.length
        && prev[index] != NO_COORD_INDEX;
  }
  
  void remove(int index) {
    int iprev = prev[index];
    int inext = next[index];
    if (iprev != NO_COORD_INDEX) next[iprev] = inext;
    if (inext != NO_COORD_INDEX) prev[inext] = iprev;
    prev[index] = NO_COORD_INDEX;
    next[index] = NO_COORD_INDEX;
    size--;
  }
  
  List<Coordinate> getCoordinates() {
    CoordinateList coords = new CoordinateList();
    int len = isRing ? coord.length - 1 : coord.length;
    for (int i = 0; i < len; i++) {
      if (hasCoordinate(i)) {
        coords.add(coord[i].copy(), false);
      }
    }
    if (isRing) {
      coords.closeRing();
    }
    return coords.toCoordinateArray();
  }
  
  String toString() {
    return WKTWriter.toLineString(getCoordinates());
  }
}
