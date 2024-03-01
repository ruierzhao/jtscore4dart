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
// import org.locationtech.jts.geom.Point;
// import org.locationtech.jts.geom.Polygon;

import 'package:jtscore4dart/src/algorithm/Orientation.dart';
import "package:jtscore4dart/src/geom/Coordinate.dart";
import 'package:jtscore4dart/src/geom/Geometry.dart';
import 'package:jtscore4dart/src/geom/GeometryCollection.dart';
import 'package:jtscore4dart/src/geom/LineString.dart';
import 'package:jtscore4dart/src/geom/Point.dart';
import 'package:jtscore4dart/src/geom/Polygon.dart';


/// Computes the centroid of a {@link Geometry} of any dimension.
/// For collections the centroid is computed for the collection of 
/// non-empty elements of highest dimension. 
/// The centroid of an empty geometry is {@code null}.
/// 
/// <h3>Algorithm</h3>
///
/// <ul>
/// <li><b>Dimension 2</b> - the centroid is computed 
/// as the weighted sum of the centroids
/// of a decomposition of the area into (possibly overlapping) triangles.
/// Holes and multipolygons are handled correctly.
/// See http://www.faqs.org/faqs/graphics/algorithms-faq/
/// for further details of the basic approach.
/// 
/// <li><b>Dimension 1</b> - Computes the average of the midpoints
/// of all line segments weighted by the segment length.
/// Zero-length lines are treated as points.
/// 
/// <li><b>Dimension 0</b> - Compute the average coordinate over all points.
/// Repeated points are all included in the average.
/// </ul>
/// 
/// @see InteriorPoint
/// @see org.locationtech.jts.algorithm.construct.MaximumInscribedCircle
/// @see org.locationtech.jts.algorithm.construct.LargestEmptyCircle
///  
/// @version 1.7
class Centroid
{
  /// Computes the centroid point of a geometry.
  /// 
  /// @param geom the geometry to use
  /// @return the centroid point, or null if the geometry is empty
  static Coordinate getCentroid(Geometry geom)
  {
    Centroid cent = Centroid(geom);
    return cent._getCentroid();
  }
  
  Coordinate? _areaBasePt;// the point all triangles are based at
  final Coordinate _triangleCent3 = Coordinate.empty2D();// temporary variable to hold centroid of triangle
  double  _areasum2 = 0;        /* Partial area sum */
  final Coordinate _cg3 = Coordinate.empty2D(); // partial centroid sum
  
  // data for linear centroid computation, if needed
  final Coordinate _lineCentSum = Coordinate.empty2D();
  double _totalLength = 0.0;

  int _ptCount = 0;
  final Coordinate _ptCentSum = Coordinate.empty2D();

  /// Creates a new instance for computing the centroid of a geometry
  Centroid(Geometry geom)
  {
    _areaBasePt = null;
    _add(geom);
  }

  /// Adds a Geometry to the centroid total.
  ///
  /// @param geom the geometry to add
  void _add(Geometry geom)
  {
    if (geom.isEmpty()) {
      return;
    }
    if (geom is Point) {
      _addPoint(geom.getCoordinate());
    }
    else if (geom is LineString) {
      _addLineSegments(geom.getCoordinates());
    }
    else if (geom is Polygon) {
      Polygon poly =/** @ruier edit (Polygon) */ geom;
      _addPolygon(poly);
    }
    else if (geom is GeometryCollection) {
      GeometryCollection gc = (GeometryCollection) geom;
      for (int i = 0; i < gc.getNumGeometries(); i++) {
        _add(gc.getGeometryN(i));
      }
    }
  }

  /// Gets the computed centroid.
  /// 
  /// @return the computed centroid, or null if the input is empty
  Coordinate _getCentroid()
  {
    /*
     * The centroid is computed from the highest dimension components present in the input.
     * I.e. areas dominate lineal geometry, which dominates points.
     * Degenerate geometry are computed using their effective dimension
     * (e.g. areas may degenerate to lines or points)
     */
    Coordinate cent = Coordinate.empty2D();
    if ((_areasum2).abs() > 0.0) {
      /*
       * Input contains areal geometry
       */
    	cent.x = _cg3.x / 3 / _areasum2;
    	cent.y = _cg3.y / 3 / _areasum2;
    }
    else if (_totalLength > 0.0) {
      /*
       * Input contains lineal geometry
       */
      cent.x = _lineCentSum.x / _totalLength;
      cent.y = _lineCentSum.y / _totalLength;   	
    }
    else if (_ptCount > 0){
      /*
       * Input contains puntal geometry only
       */
      cent.x = _ptCentSum.x / _ptCount;
      cent.y = _ptCentSum.y / _ptCount;
    }
    else {
      return null;
    }
    return cent;
  }

  void _setAreaBasePoint(Coordinate basePt)
  {
      _areaBasePt = basePt;
  }
  
  void _addPolygon(Polygon poly)
  {
    _addShell(poly.getExteriorRing().getCoordinates());
    for (int i = 0; i < poly.getNumInteriorRing(); i++) {
      _addHole(poly.getInteriorRingN(i).getCoordinates());
    }
  }

  void _addShell(List<Coordinate> pts)
  {
    if (pts.length > 0) {
      _setAreaBasePoint(pts[0]);
    }
    bool isPositiveArea = ! Orientation.isCCW(pts);
    for (int i = 0; i < pts.length - 1; i++) {
      _addTriangle(_areaBasePt, pts[i], pts[i+1], isPositiveArea);
    }
    _addLineSegments(pts);
  }
  
  void _addHole(List<Coordinate> pts)
  {
    bool isPositiveArea = Orientation.isCCW(pts);
    for (int i = 0; i < pts.length - 1; i++) {
      _addTriangle(_areaBasePt, pts[i], pts[i+1], isPositiveArea);
    }
    _addLineSegments(pts);
  }
  void _addTriangle(Coordinate p0, Coordinate p1, Coordinate p2, bool isPositiveArea)
  {
    double sign = (isPositiveArea) ? 1.0 : -10;
    _centroid3( p0, p1, p2, _triangleCent3 );
    double area2 =  _area2( p0, p1, p2 );
    _cg3.x += sign * area2 * _triangleCent3.x;
    _cg3.y += sign * area2 * _triangleCent3.y;
    _areasum2 += sign * area2;
  }
  /// Computes three times the centroid of the triangle p1-p2-p3.
  /// The factor of 3 is
  /// left in to permit division to be avoided until later.
  static void _centroid3( Coordinate p1, Coordinate p2, Coordinate p3, Coordinate c )
  {
    c.x = p1.x + p2.x + p3.x;
    c.y = p1.y + p2.y + p3.y;
    return;
  }

  /// Returns twice the signed area of the triangle p1-p2-p3.
  /// The area is positive if the triangle is oriented CCW, and negative if CW.
  static double _area2( Coordinate p1, Coordinate p2, Coordinate p3 )
  {
    return
    (p2.x - p1.x) * (p3.y - p1.y) -
        (p3.x - p1.x) * (p2.y - p1.y);
  }

  /// Adds the line segments defined by an array of coordinates
  /// to the linear centroid accumulators.
  /// 
  /// @param pts an array of {@link Coordinate}s
  void _addLineSegments(List<Coordinate> pts)
  {
    double lineLen = 0.0;
    for (int i = 0; i < pts.length - 1; i++) {
      double segmentLen = pts[i].distance(pts[i + 1]);
      if (segmentLen == 0.0) {
        continue;
      }
      
      lineLen += segmentLen;

      double midx = (pts[i].x + pts[i + 1].x) / 2;
      _lineCentSum.x += segmentLen * midx;
      double midy = (pts[i].y + pts[i + 1].y) / 2;
      _lineCentSum.y += segmentLen * midy;
    }
    _totalLength += lineLen;
    if (lineLen == 0.0 && pts.length > 0) {
      _addPoint(pts[0]);
    }
  }

  /// Adds a point to the point centroid accumulator.
  /// @param pt a {@link Coordinate}
  void _addPoint(Coordinate pt)
  {
    _ptCount += 1;
    _ptCentSum.x += pt.x;
    _ptCentSum.y += pt.y;
  }


}
