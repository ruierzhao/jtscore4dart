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
// import org.locationtech.jts.geom.LineString;

import 'package:jtscore4dart/src/geom/Coordinate.dart';
import 'package:jtscore4dart/src/geom/Geometry.dart';
import 'package:jtscore4dart/src/geom/GeometryCollection.dart';
import 'package:jtscore4dart/src/geom/LineString.dart';

/**
 * 计算线的离质心最近的内部顶点
 * 如果没有内部顶点，寻找离质心最近的端点
 * 
 * Computes a point in the interior of an linear geometry.
 * <h2>Algorithm</h2>
 * <ul>
 * <li>Find an interior vertex which is closest to
 * the centroid of the linestring.
 * <li>If there is no interior vertex, find the endpoint which is
 * closest to the centroid.
 * </ul>
 *
 * @version 1.7
 */
class InteriorPointLine {
  
  /**
   * Computes an interior point for the
   * linear components of a Geometry.
   * 
   * @param [geom] the geometry to compute
   * @return the computed interior point,
   * or <code>null</code> if the geometry has no linear components
   */
  static Coordinate? of(Geometry geom) {
    InteriorPointLine intPt = InteriorPointLine(geom);
    return intPt.getInteriorPoint();
  }
  
 /**private */late Coordinate centroid;
//  /**private */double minDistance = Double.MAX_VALUE;
 /**private */double minDistance = double.maxFinite;

//  /**private */Coordinate interiorPoint = null;
 /**private */late Coordinate? interiorPoint;

  InteriorPointLine(Geometry g)
  {
    centroid = g.getCentroid().getCoordinate()!;
    addInterior(g);
    if (interiorPoint == null) {
      addEndpoints(g);
    }
  }

  Coordinate? getInteriorPoint()
  {
    return interiorPoint;
  }

  /**
   * Tests the interior vertices (if any)
   * defined by a linear Geometry for the best inside point.
   * If a Geometry is not of dimension 1 it is not tested.
   * @param geom the geometry to add
   */
 /**private */void addInterior(Geometry geom)
  {
    if (geom.isEmpty()) {
      return;
    }
    
    if (geom is LineString) {
      addInteriorFromCoord(geom.getCoordinates());
    }
    else if (geom is GeometryCollection) {
      GeometryCollection gc = geom;
      for (int i = 0; i < gc.getNumGeometries(); i++) {
        addInterior(gc.getGeometryN(i));
      }
    }
  }
 /**private */void addInteriorFromCoord(List<Coordinate> pts)
  {
    for (int i = 1; i < pts.length - 1; i++) {
      add(pts[i]);
    }
  }
  /**
   * Tests the endpoint vertices
   * defined by a linear Geometry for the best inside point.
   * If a Geometry is not of dimension 1 it is not tested.
   * @param geom the geometry to add
   */
 /**private */void addEndpoints(Geometry geom)
  {
    if (geom.isEmpty()) {
      return;
    }
    
    if (geom is LineString) {
      addEndpointsFromCoords(geom.getCoordinates());
    }
    else if (geom is GeometryCollection) {
      GeometryCollection gc =  geom;
      for (int i = 0; i < gc.getNumGeometries(); i++) {
        addEndpoints(gc.getGeometryN(i));
      }
    }
  }
 /**private */void addEndpointsFromCoords(List<Coordinate> pts)
  {
    add(pts[0]);
    add(pts[pts.length - 1]);
  }

 /**private */void add(Coordinate point)
  {
    double dist = point.distance(centroid);
    if (dist < minDistance) {
      interiorPoint = Coordinate.fromAnother(point);
      minDistance = dist;
    }
  }

}
