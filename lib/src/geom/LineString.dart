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


// import org.locationtech.jts.algorithm.Length;
// import org.locationtech.jts.operation.BoundaryOp;

import 'package:jtscore4dart/src/algorithm/Length.dart';
import 'package:jtscore4dart/src/geom/Coordinate.dart';
import 'package:jtscore4dart/src/geom/CoordinateFilter.dart';
import 'package:jtscore4dart/src/geom/CoordinateSequence.dart';
import 'package:jtscore4dart/src/geom/CoordinateSequenceFilter.dart';
import 'package:jtscore4dart/src/geom/Geometry.dart';
import 'package:jtscore4dart/src/geom/GeometryComponentFilter.dart';
import 'package:jtscore4dart/src/geom/GeometryFactory.dart';
import 'package:jtscore4dart/src/geom/Lineal.dart';
import 'package:jtscore4dart/src/geom/PrecisionModel.dart';
import 'package:jtscore4dart/src/operation/BoundaryOp.dart';

import 'CoordinateSequenceComparator.dart';
import 'CoordinateSequences.dart';
import 'Dimension.dart';
import 'Envelope.dart';
import 'GeometryFilter.dart';
import 'Point.dart';

///  Models an OGC-style <code>LineString</code>.
///  A LineString consists of a sequence of two or more vertices,
///  along with all points along the linearly-interpolated curves
///  (line segments) between each
///  pair of consecutive vertices.
///  Consecutive vertices may be equal.
///  The line segments in the line may intersect each other (in other words,
///  the linestring may "curl back" in itself and self-intersect.
///  Linestrings with exactly two identical points are invalid.
///  <p>
/// A linestring must have either 0 or 2 or more points.
/// If these conditions are not met, the constructors throw
/// an {@link ArgumentError}
///
///@version 1.7
class LineString
	extends Geometry
	implements Lineal
{
//  /**private */static final int serialVersionUID = 3110669828065365560L;
  
  /// The minimum number of vertices allowed in a valid non-empty linestring.
  /// Empty linestrings with 0 vertices are also valid.
  static const int MINIMUM_VALID_SIZE = 2;
  
  ///  The points of this <code>LineString</code>.
 /**protected */late CoordinateSequence points;

  /**
   *  Constructs a <code>LineString</code> with the given points.
   *
   *@param  [points] the points of the linestring, or <code>null</code>
   *      to create the empty geometry. This array must not contain <code>null</code>
   *      elements. Consecutive points may be equal.
   *@param  [precisionModel]  the specification of the grid of allowable points
   *      for this <code>LineString</code>
   *@param  [SRID]            the ID of the Spatial Reference System used by this
   *      <code>LineString</code>
   * @throws ArgumentError if too few points are provided
   */
  /// @deprecated Use GeometryFactory instead
  LineString.FromPM(List<Coordinate> points, PrecisionModel precisionModel, int SRID):
  super(GeometryFactory(precisionModel, SRID))
  {
    init(getFactory().getCoordinateSequenceFactory().create(points));
  }

  /// Constructs a <code>LineString</code> with the given points.
  ///
  ///@param  points the points of the linestring, or <code>null</code>
  ///      to create the empty geometry.
  /// @throws ArgumentError if too few points are provided
  LineString(CoordinateSequence points, GeometryFactory factory):super(factory) {
    init(points);
  }

 /**private */
  void init(CoordinateSequence points){
    // TODO: ruier edit. 优化表达。
    if (points == null) {
      points = getFactory().getCoordinateSequenceFactory().create(<Coordinate>[]);
    }
    if (points.size() > 0 && points.size() < MINIMUM_VALID_SIZE) {
      throw new ArgumentError("Invalid number of points in LineString (found ${points.size()} - must be 0 or >= $MINIMUM_VALID_SIZE)");
    }
    this.points = points;
  }
  
  @override
  List<Coordinate> getCoordinates() {
    return points.toCoordinateArray();
  }

  CoordinateSequence getCoordinateSequence() {
      return points;
  }

  Coordinate getCoordinateN(int n) {
      return points.getCoordinate(n);
  }

  @override
  Coordinate? getCoordinate()
  {
    if (isEmpty()) return null;
    return points.getCoordinate(0);
  }

  @override
  int getDimension() {
    return 1;
  }

  @override
  int getBoundaryDimension() {
    if (isClosed()) {
      return Dimension.FALSE;
    }
    return 0;
  }

  @override
  bool isEmpty() {
      return points.size() == 0;
  }

  @override
  int getNumPoints() {
      return points.size();
  }

  Point getPointN(int n) {
      return getFactory().createPointFromCoord(points.getCoordinate(n));
  }

  Point? getStartPoint() {
    if (isEmpty()) {
      return null;
    }
    return getPointN(0);
  }

  Point? getEndPoint() {
    if (isEmpty()) {
      return null;
    }
    return getPointN(getNumPoints() - 1);
  }

  bool isClosed() {
    if (isEmpty()) {
      return false;
    }
    return getCoordinateN(0).equals2D(getCoordinateN(getNumPoints() - 1));
  }

  bool isRing() {
    return isClosed() && isSimple();
  }

  @override
  String getGeometryType() {
    return Geometry.TYPENAME_LINESTRING;
  }

  ///  Returns the length of this <code>LineString</code>
  ///
  ///@return the length of the linestring
  @override
  double getLength()
  {
   return Length.ofLine(points);
  }

  /// Gets the boundary of this geometry.
  /// The boundary of a lineal geometry is always a zero-dimensional geometry (which may be empty).
  ///
  /// @return the boundary geometry
  /// @see Geometry#getBoundary
  @override
  Geometry getBoundary() {
    return (BoundaryOp(this)).getBoundary();
  }

  /// Creates a {@link LineString} whose coordinates are in the reverse
  /// order of this objects
  ///
  /// @return a {@link LineString} with coordinates in the reverse order
  @override
  LineString reverse() {
    return  super.reverse() as LineString;
  }

 /**protected */@override
  LineString reverseInternal()
  {
    CoordinateSequence seq = points.copy();
    CoordinateSequences.reverse(seq);
    return getFactory().createLineString(seq);
  }

  ///  Returns true if the given point is a vertex of this <code>LineString</code>.
  ///
  ///@param  pt  the <code>Coordinate</code> to check
  ///@return     <code>true</code> if <code>pt</code> is one of this <code>LineString</code>
  ///      's vertices
  bool isCoordinate(Coordinate pt) {
      for (int i = 0; i < points.size(); i++) {
        if (points.getCoordinate(i).equals(pt)) {
          return true;
        }
      }
    return false;
  }

 /**protected */
  @override
  Envelope computeEnvelopeInternal() {
    if (isEmpty()) {
      return Envelope.init();
    }
    return points.expandEnvelope(Envelope.init());
  }

  
  // @override
  // TODO: ruier edit. 存疑修改
  // bool equalsExact(Geometry other, double tolerance) {
    // if (!isEquivalentClass(other)) {
    //   return false;
    // }
    // LineString otherLineString =  other as LineString;
    // if (points.size() != otherLineString.points.size()) {
    //   return false;
    // }
    // for (int i = 0; i < points.size(); i++) {
    //   if (!equal(points.getCoordinate(i), otherLineString.points.getCoordinate(i), tolerance)) {
    //     return false;
    //   }
    // }
    // return true;
  // }
  @override
  bool equalsExactWithTolerance(Geometry other, double tolerance) {
    if (!isEquivalentClass(other)) {
      return false;
    }
    LineString otherLineString =  other as LineString;
    if (points.size() != otherLineString.points.size()) {
      return false;
    }
    for (int i = 0; i < points.size(); i++) {
      if (!equal(points.getCoordinate(i), otherLineString.points.getCoordinate(i), tolerance)) {
        return false;
      }
    }
    return true;
  }

  @override
  void applyCoord(CoordinateFilter filter) {
      for (int i = 0; i < points.size(); i++) {
        filter.filter(points.getCoordinate(i));
      }
  }

  @override
  void applyCoordSeq(CoordinateSequenceFilter filter)
  {
    if (points.size() == 0) {
      return;
    }
    for (int i = 0; i < points.size(); i++) {
      filter.filter(points, i);
      if (filter.isDone()) {
        break;
      }
    }
    if (filter.isGeometryChanged()) {
      geometryChanged();
    }
  }

  @override
  void apply(GeometryFilter filter) {
    filter.filter(this);
  }

  @override
  void applyGeometryComonent(GeometryComponentFilter filter) {
    filter.filter(this);
  }

  /// Creates and returns a full copy of this {@link LineString} object.
  /// (including all coordinates contained by it).
  ///
  /// @return a clone of this instance
  /// @deprecated
  @override
  Object clone() {
    return copy();
  }

 /**protected */@override
  LineString copyInternal() {
    return new LineString(points.copy(), factory);
  }

  /// Normalizes a LineString.  A normalized linestring
  /// has the first point which is not equal to it's reflected point
  /// less than the reflected point.
  @override
  void normalize()
  {
      for (int i = 0; i < points.size() / 2; i++) {
        int j = points.size() - 1 - i;
        // skip equal points on both ends
        if (!points.getCoordinate(i).equals(points.getCoordinate(j))) {
          if (points.getCoordinate(i).compareTo(points.getCoordinate(j)) > 0) {
            CoordinateSequence copy = points.copy();
            CoordinateSequences.reverse(copy);
            points = copy;
          }
          return;
        }
      }
  }

 /**protected */
  @override
  bool isEquivalentClass(Geometry other) {
    return other is LineString;
  }

 /**protected */
  @override
  int compareToSameClass(Object o)
  {
    LineString line =  o as LineString;
    // MD - optimized implementation
    int i = 0;
    int j = 0;
    while (i < points.size() && j < line.points.size()) {
      int comparison = points.getCoordinate(i).compareTo(line.points.getCoordinate(j));
      if (comparison != 0) {
        return comparison;
      }
      i++;
      j++;
    }
    if (i < points.size()) {
      return 1;
    }
    if (j < line.points.size()) {
      return -1;
    }
    return 0;
  }

 /**protected */@override
  int compareToSameClassWithCompar(Object o, CoordinateSequenceComparator comp)
  {
    LineString line =  o as LineString;
    return comp.compare(this.points, line.points);
  }
  
 /**protected */@override
  int getTypeCode() {
    return Geometry.TYPECODE_LINESTRING;
  }


}
