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


// import org.locationtech.jts.geom.Coordinate;
// import org.locationtech.jts.geom.CoordinateFilter;
// import org.locationtech.jts.geom.Geometry;

import 'package:jtscore4dart/src/geom/Coordinate.dart';
import 'package:jtscore4dart/src/geom/CoordinateFilter.dart';

/**
 *  A {@link CoordinateFilter} that creates an array containing every
 *  coordinate in a {@link Geometry}.
 *
 *@version 1.7
 */
class CoordinateArrayFilter implements CoordinateFilter {
  List<Coordinate> pts ;
  int n = 0;

  /**
   *  Constructs a <code>CoordinateArrayFilter</code>.
   *
   *@param  size  the number of points that the <code>CoordinateArrayFilter</code>
   *      will collect
   */
  CoordinateArrayFilter(int size):pts = List.filled(size, Coordinate.empty2D(),growable: false);
  // CoordinateArrayFilter(int size) {
  //   pts = new Coordinate[size];
  // }

  /**
   *  Returns the gathered <code>Coordinate</code>s.
   *
   *@return    the <code>Coordinate</code>s collected by this <code>CoordinateArrayFilter</code>
   */
  List<Coordinate> getCoordinates() {
    return pts;
  }

  void filter(Coordinate coord) {
    pts[n++] = coord;
  }
}

