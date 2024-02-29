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

/**
 *  A {@link CoordinateFilter} that counts the total number of coordinates
 *  in a <code>Geometry</code>.
 *
 *@version 1.7
 */
class CoordinateCountFilter implements CoordinateFilter {
  private int n = 0;

  CoordinateCountFilter() { }

  /**
   *  Returns the result of the filtering.
   *
   *@return    the number of points found by this <code>CoordinateCountFilter</code>
   */
  int getCount() {
    return n;
  }

  void filter(Coordinate coord) {
    n++;
  }
}

