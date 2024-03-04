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
// import java.util.Collection;
// import java.util.Iterator;

import 'package:jtscore4dart/src/geom/Coordinate.dart';

/// A list of {@link Coordinate}s, which may
/// be set to prevent repeated coordinates from occurring in the list.
///
///
/// @version 1.7
class CoordinateList  /** extends ArrayList<Coordinate> */
{
  // private static final long serialVersionUID = -1626110935756089896L;
  //With contributions from Markus Schaber [schabios@logi-track.com]
  //[Jon Aquino 2004-03-25]
  // private final static List<Coordinate> coordArrayType = new Coordinate[0];

  /// Constructs a new list without any coordinates
  CoordinateList();

  /// Constructs a new list from an array of Coordinates, allowing repeated points.
  /// (I.e. this constructor produces a {@link CoordinateList} with exactly the same set of points
  /// as the input array.)
  /// 
  /// @param coord the initial coordinates
  // CoordinateList.fromAnother(List<Coordinate> coord){
  // 	ensureCapacity(coord.length);
  //   add(coord, true);
  // }

  /// Constructs a new list from an array of Coordinates,
  /// allowing caller to specify if repeated points are to be removed.
  ///
  /// @param coord the array of coordinates to load into the list
  /// @param allowRepeated if <code>false</code>, repeated points are removed
  CoordinateList(List<Coordinate> coord, [bool allowRepeated=true])
  {
  	// ensureCapacity(coord.length); // 预估容量大小
    add(coord, allowRepeated);
  }

  Coordinate getCoordinate(int i) { return (Coordinate) get(i); }


  /// Adds a section of an array of coordinates to the list.
  /// @param coord The coordinates
  /// @param allowRepeated if set to false, repeated coordinates are collapsed
  /// @param start the index to start from
  /// @param end the index to add up to but not including
  /// @return true (as by general collection contract)
  bool add(List<Coordinate> coord, bool allowRepeated, int start, int end)
  {
    int inc = 1;
    if (start > end) inc = -1;
    
    for (int i = start; i != end; i += inc) {
      add(coord[i], allowRepeated);
    }
    return true;
  }

  /// Adds an array of coordinates to the list.
  /// @param coord The coordinates
  /// @param allowRepeated if set to false, repeated coordinates are collapsed
  /// @param direction if false, the array is added in reverse order
  /// @return true (as by general collection contract)
  bool add(List<Coordinate> coord, bool allowRepeated, bool direction)
  {
    if (direction) {
      for (int i = 0; i < coord.length; i++) {
        add(coord[i], allowRepeated);
      }
    }
    else {
      for (int i = coord.length - 1; i >= 0; i--) {
        add(coord[i], allowRepeated);
      }
    }
    return true;
  }


  /// Adds an array of coordinates to the list.
  /// @param coord The coordinates
  /// @param allowRepeated if set to false, repeated coordinates are collapsed
  /// @return true (as by general collection contract)
  bool add(List<Coordinate> coord, bool allowRepeated)
  {
    add(coord, allowRepeated, true);
    return true;
  }

  /// Adds a coordinate to the list.
  /// @param obj The coordinate to add
  /// @param allowRepeated if set to false, repeated coordinates are collapsed
  /// @return true (as by general collection contract)
  bool add(Object obj, bool allowRepeated)
  {
    add((Coordinate) obj, allowRepeated);
    return true;
  }

  /// Adds a coordinate to the end of the list.
  /// 
  /// @param coord The coordinates
  /// @param allowRepeated if set to false, repeated coordinates are collapsed
  void add(Coordinate coord, bool allowRepeated)
  {
    // don't add duplicate coordinates
    if (! allowRepeated) {
      if (size() >= 1) {
        Coordinate last = (Coordinate) get(size() - 1);
        if (last.equals2D(coord)) return;
      }
    }
    super.add(coord);
  }

  /// Inserts the specified coordinate at the specified position in this list.
  /// 
  /// @param i the position at which to insert
  /// @param coord the coordinate to insert
  /// @param allowRepeated if set to false, repeated coordinates are collapsed
  void add(int i, Coordinate coord, bool allowRepeated)
  {
    // don't add duplicate coordinates
    if (! allowRepeated) {
      int size = size();
      if (size > 0) {
        if (i > 0) {
          Coordinate prev = (Coordinate) get(i - 1);
          if (prev.equals2D(coord)) return;
        }
        if (i < size) {
          Coordinate next = (Coordinate) get(i);
          if (next.equals2D(coord)) return;
        }
      }
    }
    super.add(i, coord);
  }

  /// Add an array of coordinates
  /// @param coll The coordinates
  /// @param allowRepeated if set to false, repeated coordinates are collapsed
  /// @return true (as by general collection contract)
  bool addAll(Collection<? extends Coordinate> coll, bool allowRepeated)
  {
    bool isChanged = false;
    for (Iterator<? extends Coordinate> i = coll.iterator(); i.hasNext(); ) {
      add(i.next(), allowRepeated);
      isChanged = true;
    }
    return isChanged;
  }

  /// Ensure this coordList is a ring, by adding the start point if necessary
  void closeRing()
  {
    if (size() > 0) {
      Coordinate duplicate = get(0).copy();
      add(duplicate, false);
    }
  }

  /// Returns the Coordinates in this collection.
  ///
  /// @return the coordinates
  List<Coordinate> toCoordinateArray()
  {
    return (List<Coordinate>) toArray(coordArrayType);
  }

  /// Creates an array containing the coordinates in this list,
  /// oriented in the given direction (forward or reverse).
  /// 
  /// @param isForward true if the direction is forward, false for reverse
  /// @return an oriented array of coordinates
  List<Coordinate> toCoordinateArray(bool isForward)
  {
    if (isForward) {
      return (List<Coordinate>) toArray(coordArrayType);
    }
    // construct reversed array
    int size = size();
    List<Coordinate> pts = new Coordinate[size];
    for (int i = 0; i < size; i++) {
      pts[i] = get(size - i - 1);
    }
    return pts;
  }

  /// Returns a deep copy of this <tt>CoordinateList</tt> instance.
  ///
  /// @return a clone of this <tt>CoordinateList</tt> instance
  Object clone() {
      CoordinateList clone = (CoordinateList) super.clone();
      for (int i = 0; i < this.size(); i++) {	  
          clone.add(i, (Coordinate) this.get(i).clone());
      }
      return clone;
  }
  
  @override
  int length;
  
  @override
  Coordinate operator [](int index) {
    // TODO: implement []
    throw UnimplementedError();
  }
  
  @override
  void operator []=(int index, Coordinate value) {
    // TODO: implement []=
  }
}
