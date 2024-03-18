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

import 'Label.dart';

/**
 * A Depth object records the topological depth of the sides
 * of an Edge for up to two Geometries.
 * @version 1.7
 */
class Depth {

 /**private */const static int NULL_VALUE = -1;

  static int depthAtLocation(int location)
  {
    if (location == Location.EXTERIOR) return 0;
    if (location == Location.INTERIOR) return 1;
    return NULL_VALUE;
  }

 /**private */int[][] depth = new int[2][3];

  Depth() {
    // initialize depth array to a sentinel value
    for (int i = 0; i < 2; i++) {
      for (int j = 0; j < 3; j++) {
        depth[i][j] = NULL_VALUE;
      }
    }
  }

  int getDepth(int geomIndex, int posIndex)
  {
    return depth[geomIndex][posIndex];
  }
  void setDepth(int geomIndex, int posIndex, int depthValue)
  {
    depth[geomIndex][posIndex] = depthValue;
  }
  int getLocation(int geomIndex, int posIndex)
  {
    if (depth[geomIndex][posIndex] <= 0) return Location.EXTERIOR;
    return Location.INTERIOR;
  }
  void add(int geomIndex, int posIndex, int location)
  {
    if (location == Location.INTERIOR)
      depth[geomIndex][posIndex]++;
  }
  /**
   * A Depth object is null (has never been initialized) if all depths are null.
   * 
   * @return True if depth is null (has never been initialized)
   */
  bool isNull()
  {
    for (int i = 0; i < 2; i++) {
      for (int j = 0; j < 3; j++) {
        if (depth[i][j] != NULL_VALUE)
          return false;
      }
    }
    return true;
  }
  bool isNull(int geomIndex)
  {
    return depth[geomIndex][1] == NULL_VALUE;
  }
  bool isNull(int geomIndex, int posIndex)
  {
    return depth[geomIndex][posIndex] == NULL_VALUE;
  }
  void add(Label lbl)
  {
    for (int i = 0; i < 2; i++) {
      for (int j = 1; j < 3; j++) {
        int loc = lbl.getLocation(i, j);
        if (loc == Location.EXTERIOR || loc == Location.INTERIOR) {
          // initialize depth if it is null, otherwise add this location value
          if (isNull(i, j)) {
            depth[i][j] = depthAtLocation(loc);
          }
          else
            depth[i][j] += depthAtLocation(loc);
        }
      }
    }
  }
  int getDelta(int geomIndex)
  {
    return depth[geomIndex][Position.RIGHT] - depth[geomIndex][Position.LEFT];
  }
  /**
   * Normalize the depths for each geometry, if they are non-null.
   * A normalized depth
   * has depth values in the set { 0, 1 }.
   * Normalizing the depths
   * involves reducing the depths by the same amount so that at least
   * one of them is 0.  If the remaining value is &gt; 0, it is set to 1.
   */
  void normalize()
  {
    for (int i = 0; i < 2; i++) {
      if (! isNull(i)) {
        int minDepth = depth[i][1];
        if (depth[i][2] < minDepth)
          minDepth = depth[i][2];

        if (minDepth < 0) minDepth = 0;
        for (int j = 1; j < 3; j++) {
          int newValue = 0;
          if (depth[i][j] > minDepth)
            newValue = 1;
          depth[i][j] = newValue;
        }
      }
    }
  }

  String toString()
  {
    return
        "A: " + depth[0][1] + "," + depth[0][2]
      + " B: " + depth[1][1] + "," + depth[1][2];
  }
}
