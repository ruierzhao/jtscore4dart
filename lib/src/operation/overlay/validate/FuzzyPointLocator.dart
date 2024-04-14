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

// import org.locationtech.jts.algorithm.PointLocator;
// import org.locationtech.jts.geom.Coordinate;
// import org.locationtech.jts.geom.CoordinateSequence;
// import org.locationtech.jts.geom.Geometry;
// import org.locationtech.jts.geom.GeometryFactory;
// import org.locationtech.jts.geom.GeometryFilter;
// import org.locationtech.jts.geom.LineSegment;
// import org.locationtech.jts.geom.LineString;
// import org.locationtech.jts.geom.Location;
// import org.locationtech.jts.geom.MultiLineString;
// import org.locationtech.jts.geom.Polygon;

import 'package:jtscore4dart/src/algorithm/PointLocator.dart';
import 'package:jtscore4dart/src/geom/Coordinate.dart';
import 'package:jtscore4dart/src/geom/CoordinateSequence.dart';
import 'package:jtscore4dart/src/geom/Geometry.dart';
import 'package:jtscore4dart/src/geom/GeometryFactory.dart';
import 'package:jtscore4dart/src/geom/GeometryFilter.dart';
import 'package:jtscore4dart/src/geom/LineSegment.dart';
import 'package:jtscore4dart/src/geom/LineString.dart';
import 'package:jtscore4dart/src/geom/Location.dart';
import 'package:jtscore4dart/src/geom/MultiLineString.dart';
import 'package:jtscore4dart/src/geom/Polygon.dart';

/**
 * Finds the most likely {@link Location} of a point relative to
 * the polygonal components of a geometry, using a tolerance value.
 * If a point is not clearly in the Interior or Exterior,
 * it is considered to be on the Boundary.
 * In other words, if the point is within the tolerance of the Boundary,
 * it is considered to be on the Boundary; otherwise, 
 * whether it is Interior or Exterior is determined directly.
 *
 * @author Martin Davis
 * @version 1.7
 */
class FuzzyPointLocator {
  /**private */ Geometry g;
  /**private */ double boundaryDistanceTolerance;
  /**private */ late MultiLineString linework;
  /**private */ PointLocator ptLocator = new PointLocator();
  /**private */ LineSegment seg = new LineSegment.empty();

  FuzzyPointLocator(this.g, this.boundaryDistanceTolerance) {
    linework = extractLinework(g);
  }

  int getLocation(Coordinate pt) {
    if (isWithinToleranceOfBoundary(pt)) {
      return Location.BOUNDARY;
    }
    /*
    double dist = linework.distance(point);

    // if point is close to boundary, it is considered to be on the boundary
    if (dist < tolerance)
      return Location.BOUNDARY;
     */

    // now we know point must be clearly inside or outside geometry, so return actual location value
    return ptLocator.locate(pt, g);
  }

  /**
   * Extracts linework for polygonal components.
   * 
   * @param g the geometry from which to extract
   * @return a lineal geometry containing the extracted linework
   */
  /**private */ MultiLineString extractLinework(Geometry g) {
    PolygonalLineworkExtracter extracter = new PolygonalLineworkExtracter();
    g.apply(extracter);
    List linework = extracter.getLinework();
    List<LineString> lines = GeometryFactory.toLineStringArray(linework);
    return g.getFactory().createMultiLineString(lines);
  }

  /**private */ bool isWithinToleranceOfBoundary(Coordinate pt) {
    for (int i = 0; i < linework.getNumGeometries(); i++) {
      LineString line = linework.getGeometryN(i) as LineString;
      CoordinateSequence seq = line.getCoordinateSequence();
      for (int j = 0; j < seq.size() - 1; j++) {
        seq.getCoordinateTo(j, seg.p0);
        seq.getCoordinateTo(j + 1, seg.p1);
        double dist = seg.distanceToCoord(pt);
        if (dist <= boundaryDistanceTolerance) {
          return true;
        }
      }
    }
    return false;
  }
}

/**
 * Extracts the LineStrings in the boundaries 
 * of all the polygonal elements in the target {@link Geometry}.
 * 
 * @author Martin Davis
 */
class PolygonalLineworkExtracter implements GeometryFilter {
  final List _linework = [];

  // PolygonalLineworkExtracter()
  // {
  // 	linework = [];
  // }

  /**
	 * Filters out all linework for polygonal elements
	 */
  void filter(Geometry g) {
    if (g is Polygon) {
      Polygon poly = g;
      _linework.add(poly.getExteriorRing());
      for (int i = 0; i < poly.getNumInteriorRing(); i++) {
        _linework.add(poly.getInteriorRingN(i));
      }
    }
  }

  /**
	 * Gets the list of polygonal linework.
	 * 
	 * @return a List of LineStrings
	 */
  List getLinework() {
    return _linework;
  }
}
