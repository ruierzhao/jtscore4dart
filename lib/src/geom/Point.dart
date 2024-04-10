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


// import org.locationtech.jts.util.Assert;

import 'package:jtscore4dart/src/geom/Coordinate.dart';
import 'package:jtscore4dart/src/geom/CoordinateFilter.dart';
import 'package:jtscore4dart/src/geom/CoordinateSequence.dart';
import 'package:jtscore4dart/src/geom/CoordinateSequenceComparator.dart';
import 'package:jtscore4dart/src/geom/CoordinateSequenceFilter.dart';
import 'package:jtscore4dart/src/geom/Dimension.dart';
import 'package:jtscore4dart/src/geom/Envelope.dart';
import 'package:jtscore4dart/src/geom/Geometry.dart';
import 'package:jtscore4dart/src/geom/GeometryComponentFilter.dart';
import 'package:jtscore4dart/src/geom/GeometryFactory.dart';
import 'package:jtscore4dart/src/geom/GeometryFilter.dart';
import 'package:jtscore4dart/src/geom/PrecisionModel.dart';
import 'package:jtscore4dart/src/geom/Puntal.dart';
import 'package:jtscore4dart/src/util/Assert.dart';

/// Represents a single point.
///
/// A <code>Point</code> is topologically valid if and only if:
/// <ul>
/// <li>the coordinate which defines it (if any) is a valid coordinate
/// (i.e. does not have an <code>NaN</code> X or Y ordinate)
/// </ul>
///
///@version 1.7
class Point
	extends Geometry
	implements Puntal
{
  ///**private */static final int serialVersionUID = 4902022702746614570L;
  ///  The <code>Coordinate</code> wrapped by this <code>Point</code>.
  /**private */ late CoordinateSequence coordinates;

  ///  Constructs a <code>Point</code> with the given coordinate.
  ///
  ///@param  coordinate      the coordinate on which to base this <code>Point</code>
  ///      , or <code>null</code> to create the empty geometry.
  ///@param  precisionModel  the specification of the grid of allowable points
  ///      for this <code>Point</code>
  ///@param  SRID            the ID of the Spatial Reference System used by this
  ///      <code>Point</code>
  /// @deprecated Use GeometryFactory instead
  @Deprecated("Use GeometryFactory instead")
  Point.FromPM(Coordinate? coordinate, PrecisionModel precisionModel, int SRID):super(GeometryFactory(precisionModel, SRID)) {
    init(getFactory().getCoordinateSequenceFactory().create(
          coordinate != null ? [coordinate] : <Coordinate>[]));
  }
  // Point(Coordinate coordinate, PrecisionModel precisionModel, int SRID) {
  //   super(GeometryFactory(precisionModel, SRID));
  //   init(getFactory().getCoordinateSequenceFactory().create(
  //         coordinate != null ? new List<Coordinate>{coordinate} : new List<Coordinate>{}));
  // }

  ///@param  coordinates      contains the single coordinate on which to base this <code>Point</code>
  ///      , or <code>null</code> to create the empty geometry.
  Point(CoordinateSequence coordinates, GeometryFactory factory):super(factory) {
    init(coordinates);
  }

  /**private */ void init([CoordinateSequence? coordinates])
  {
    coordinates ??= getFactory().getCoordinateSequenceFactory().create(<Coordinate>[]);
    Assert.isTrue(coordinates.size() <= 1);
    this.coordinates = coordinates;
  }

  @override
  List<Coordinate> getCoordinates() {
    return isEmpty() ? <Coordinate>[] : [getCoordinate()!];
  }

  @override
  int getNumPoints() {
    return isEmpty() ? 0 : 1;
  }

  @override
  bool isEmpty() {
    return coordinates.size() == 0;
  }

  @override
  bool isSimple() {
    return true;
  }

  @override
  int getDimension() {
    return 0;
  }

  @override
  int getBoundaryDimension() {
    return Dimension.FALSE;
  }

  double getX() {
    if (getCoordinate() == null) {
      throw new Exception("getX called on empty Point");
    }
    return getCoordinate()!.x;
  }

  double? getY() {
    if (getCoordinate() == null) {
      throw Exception("getY called on empty Point");
    }
    return getCoordinate()!.y;
  }

  @override
  Coordinate? getCoordinate() {
    return coordinates.size() != 0 ? coordinates.getCoordinate(0): null;
  }

  @override
  String getGeometryType() {
    return Geometry.TYPENAME_POINT;
  }

  /// Gets the boundary of this geometry.
  /// Zero-dimensional geometries have no boundary by definition,
  /// so an empty GeometryCollection is returned.
  ///
  /// @return an empty GeometryCollection
  /// @see Geometry#getBoundary
  @override
  Geometry getBoundary() {
    return getFactory().createGeometryCollection();
  }

  /**protected */ @override
  Envelope computeEnvelopeInternal() {
    if (isEmpty()) {
      return Envelope.init();
    }
    Envelope env = new Envelope.init();
    env.expandToIncludeXY(coordinates.getX(0), coordinates.getY(0));
    return env;
  }

  @override
  bool equalsExactWithTolerance(Geometry other, double tolerance) {
    if (!isEquivalentClass(other)) {
      return false;
    }
    if (isEmpty() && other.isEmpty()) {
      return true;
    }
    if (isEmpty() != other.isEmpty()) {
      return false;
    }
    return equal(( other as Point).getCoordinate()!, this.getCoordinate()!, tolerance);
  }

  @override
  void applyCoord(CoordinateFilter filter) {
	    if (isEmpty()) { return; }
	    filter.filter(getCoordinate()!);
	  }

  @override
  void applyCoordSeq(CoordinateSequenceFilter filter)
  {
	    if (isEmpty()) {
	      return;
	    }
	    filter.filter(coordinates, 0);
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

  /// Creates and returns a full copy of this {@link Point} object.
  /// (including all coordinates contained by it).
  ///
  /// @return a clone of this instance
  /// @deprecated
  @Deprecated("")
  @override
  Object clone() {
    return copy();
  }

  /**protected */ @override
  Point copyInternal() {
    return new Point(coordinates.copy(), factory);
  }

  @override
  Point reverse() {
    return super.reverse()as Point;
  }

  /**protected */ @override
  Point reverseInternal()
  {
    return getFactory().createPointFromCoordSeq(coordinates.copy());
  }

  @override
  void normalize()
  {
    // a Point is always in normalized form
  }

  /**protected */ @override
  int compareToSameClass(Object other) {
    Point point = other as Point;
    return getCoordinate()!.compareTo(point.getCoordinate()!);
  }

  /**protected */@override
  int compareToSameClassWithCompar(Object other, CoordinateSequenceComparator comp)
  {
    Point point = other as Point;
    return comp.compare(this.coordinates, point.coordinates);
  }
  
  /**protected */ @override
  int getTypeCode() {
    return Geometry.TYPECODE_POINT;
  }

  CoordinateSequence getCoordinateSequence() {
    return coordinates;
  }
  

}

