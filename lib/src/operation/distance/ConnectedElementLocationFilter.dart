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
// import java.util.List;

// import org.locationtech.jts.geom.Geometry;
// import org.locationtech.jts.geom.GeometryFilter;
// import org.locationtech.jts.geom.LineString;
// import org.locationtech.jts.geom.Point;
// import org.locationtech.jts.geom.Polygon;

import 'package:jtscore4dart/src/geom/Geometry.dart';
import 'package:jtscore4dart/src/geom/GeometryFilter.dart';
import 'package:jtscore4dart/src/geom/LineString.dart';
import 'package:jtscore4dart/src/geom/Point.dart';
import 'package:jtscore4dart/src/geom/Polygon.dart';

import 'GeometryLocation.dart';

/**
 * A ConnectedElementPointFilter extracts a single point
 * from each connected element in a Geometry
 * (e.g. a polygon, linestring or point)
 * and returns them in a list. The elements of the list are 
 * {@link org.locationtech.jts.operation.distance.GeometryLocation}s.
 * Empty geometries do not provide a location item.
 *
 * @version 1.7
 */
class ConnectedElementLocationFilter
  implements GeometryFilter
{

  /**
   * Returns a list containing a point from each Polygon, LineString, and Point
   * found inside the specified geometry. Thus, if the specified geometry is
   * not a GeometryCollection, an empty list will be returned. The elements of the list 
   * are {@link org.locationtech.jts.operation.distance.GeometryLocation}s.
   */  
  static List getLocations(Geometry geom)
  {
    List locations = [];
    geom.apply(new ConnectedElementLocationFilter(locations));
    return locations;
  }

 /**private */List locations;

  ConnectedElementLocationFilter(this.locations);

  @override
  void filter(Geometry geom)
  {
    // empty geometries do not provide a location
    if (geom.isEmpty()) return;
    if (geom is Point
      || geom is LineString
      || geom is Polygon ) {
      locations.add(new GeometryLocation(geom, geom.getCoordinate()!, 0));
    }
  }

}
