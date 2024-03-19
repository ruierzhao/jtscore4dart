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

// import org.locationtech.jts.geom.Location;
// import org.locationtech.jts.geom.Position;

import 'package:jtscore4dart/src/geom/Location.dart';
import 'package:jtscore4dart/src/geom/Position.dart';

/**
  * A TopologyLocation is the labelling of a
  * GraphComponent's topological relationship to a single Geometry.
  * <p>
  * If the parent component is an area edge, each side and the edge itself
  * have a topological location.  These locations are named
  * <ul>
  * <li> ON: on the edge
  * <li> LEFT: left-hand side of the edge
  * <li> RIGHT: right-hand side
  * </ul>
  * If the parent component is a line edge or node, there is a single
  * topological relationship attribute, ON.
  * <p>
  * The possible values of a topological location are
  * {Location.NONE, Location.EXTERIOR, Location.BOUNDARY, Location.INTERIOR}
  * <p>
  * The labelling is stored in an array location[j] where
  * where j has the values ON, LEFT, RIGHT
  * @version 1.7
 */
class TopologyLocation {

  late List<int> location;

  TopologyLocation(List<int> location)
  {
    init(location.length);
  }
  /**
   * Constructs a TopologyLocation specifying how points on, to the left of, and to the
   * right of some GraphComponent relate to some Geometry. Possible values for the
   * parameters are Location.NULL, Location.EXTERIOR, Location.BOUNDARY,
   * and Location.INTERIOR.
   * @see Location
   * @param [on] on position
   * @param [left] left position
   * @param [right] right position
   */
  TopologyLocation.From3(int on, int left, int right) {
   init(3);
   location[Position.ON] = on;
   location[Position.LEFT] = left;
   location[Position.RIGHT] = right;
  }

  TopologyLocation.On(int on) {
   init(1);
   location[Position.ON] = on;
  }
  TopologyLocation.FromAnother(TopologyLocation gl) {
    init(gl.location.length);
    if (gl != null) {
      for (int i = 0; i < location.length; i++) {
        location[i] = gl.location[i];
      }
    }
  }
 /**private */void init(int size)
  {
    // location = new int[size];
    // setAllLocations(Location.NONE);
    this.location = List<int>.filled(size, Location.NONE);
  }
  int get(int posIndex)
  {
    if (posIndex < location.length) return location[posIndex];
    return Location.NONE;
  }
  /**
   * @return true if all locations are NULL
   */
  bool isNull()
  {
    for (int i = 0; i < location.length; i++) {
      if (location[i] != Location.NONE) return false;
    }
    return true;
  }
  /**
   * @return true if any locations are NULL
   */
  bool isAnyNull()
  {
    for (int i = 0; i < location.length; i++) {
      if (location[i] == Location.NONE) return true;
    }
    return false;
  }

  bool isEqualOnSide(TopologyLocation le, int locIndex)
  {
    return location[locIndex] == le.location[locIndex];
  }
  
  bool isArea() { return location.length > 1; }
  bool isLine() { return location.length == 1; }

  // 翻转
  void flip()
  {
    if (location.length <= 1) return;
    int temp = location[Position.LEFT];
    location[Position.LEFT] = location[Position.RIGHT];
    location[Position.RIGHT] = temp;
  }


  void setAllLocations(int locValue)
  {
    for (int i = 0; i < location.length; i++) {
      location[i]     = locValue;
    }
  }
  void setAllLocationsIfNull(int locValue)
  {
    for (int i = 0; i < location.length; i++) {
      if (location[i] == Location.NONE) location[i]     = locValue;
    }
  }

  void setLocationKV(int locIndex, int locValue)
  {
      location[locIndex] = locValue;
  }

  void setLocation(int locValue)
  {
    setLocationKV(Position.ON, locValue);
  }

  List<int> getLocations() { return location; }

  void setLocations(int on, int left, int right) {
      location[Position.ON] = on;
      location[Position.LEFT] = left;
      location[Position.RIGHT] = right;
  }
  bool allPositionsEqual(int loc)
  {
    for (int i = 0; i < location.length; i++) {
      if (location[i] != loc) return false;
    }
    return true;
  }

  /**
   * merge updates only the NULL attributes of this object
   * with the attributes of another.
   *
   * @param gl Topology location
   */
  void merge(TopologyLocation gl)
  {
    // if the src is an Area label & and the dest is not, increase the dest to be an Area
    if (gl.location.length > location.length) {
      // int [] newLoc = new int[3];
      List<int> newLoc = List.filled(3, Location.NONE);
      newLoc[Position.ON] = location[Position.ON];
      newLoc[Position.LEFT] = Location.NONE;
      newLoc[Position.RIGHT] = Location.NONE;
      location = newLoc;
    }
    for (int i = 0; i < location.length; i++) {
      if (location[i] == Location.NONE && i < gl.location.length) {
        location[i] = gl.location[i];
      }
    }
  }

  @override
  String toString()
  {
    StringBuffer buf = new StringBuffer();
    if (location.length > 1) buf.write(Location.toLocationSymbol(location[Position.LEFT]));
    buf.write(Location.toLocationSymbol(location[Position.ON]));
    if (location.length > 1) buf.write(Location.toLocationSymbol(location[Position.RIGHT]));
    return buf.toString();
  }
}
