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
// import org.locationtech.jts.geom.Geometry;
// import org.locationtech.jts.geom.GeometryCollection;
// import org.locationtech.jts.geom.Point;

import 'package:jtscore4dart/geometry.dart';

/**
 * Computes a point in the interior of an point geometry.
 * <h2>Algorithm</h2>
 * Find a point which is closest to the centroid of the geometry.
 *
 * @version 1.7
 */
class InteriorPointPoint {

  /**
   * Computes an interior point for the
   * puntal components of a Geometry.
   * 
   * @param [geom] the geometry to compute
   * @return the computed interior point,
   * or <code>null</code> if the geometry has no puntal components
   */
  static Coordinate? of(Geometry geom) {
    InteriorPointPoint intPt = InteriorPointPoint(geom);
    return intPt.getInteriorPoint();
  }
  
 /**private */late Coordinate centroid;
//  /**@ruier replace */double minDistance = Double.MAX_VALUE;
 /**private */double minDistance = double.maxFinite;

//  /**private */Coordinate interiorPoint = null;
 /**private */late Coordinate interiorPoint;

  InteriorPointPoint(Geometry g)
  {
    centroid = g.getCentroid().getCoordinate()!;
    add(g);
  }

  /**
   * Tests the point(s) defined by a Geometry for the best inside point.
   * If a Geometry is not of dimension 0 it is not tested.
   * @param geom the geometry to add
   */
 /**private */void add(Geometry geom)
  {
    if (geom.isEmpty()) {
      return;
    }
    
    if (geom is Point) {
      addCoord(geom.getCoordinate()!);
    }
    else if (geom is GeometryCollection) {
      GeometryCollection gc = geom;
      for (int i = 0; i < gc.getNumGeometries(); i++) {
        add(gc.getGeometryN(i));
      }
    }
  }
 /**private */void addCoord(Coordinate point)
  {
    double dist = point.distance(centroid);
    if (dist < minDistance) {
      interiorPoint = Coordinate.fromAnother(point);
      minDistance = dist;
    }
  }

  Coordinate getInteriorPoint()
  {
    return interiorPoint;
  }
}
