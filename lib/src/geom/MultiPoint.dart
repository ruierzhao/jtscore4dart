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


import 'package:jtscore4dart/src/geom/CoordinateSequenceComparator.dart';

import 'Coordinate.dart';
import 'Dimension.dart';
import 'Geometry.dart';
import 'GeometryCollection.dart';
import 'Point.dart';
import 'PrecisionModel.dart';
import 'Puntal.dart';

/// Models a collection of {@link Point}s.
/// <p>
/// Any collection of Points is a valid MultiPoint.
///
///@version 1.7
class MultiPoint
  extends GeometryCollection
  implements Puntal
{

//  /**private */static final int serialVersionUID = -8048474874175355449L;

  ///  Constructs a <code>MultiPoint</code>.
  ///
  ///@param  points          the <code>Point</code>s for this <code>MultiPoint</code>
  ///      , or <code>null</code> or an empty array to create the empty geometry.
  ///      Elements may be empty <code>Point</code>s, but not <code>null</code>s.
  ///@param  precisionModel  the specification of the grid of allowable points
  ///      for this <code>MultiPoint</code>
  ///@param  SRID            the ID of the Spatial Reference System used by this
  ///      <code>MultiPoint</code>
  /// @deprecated Use GeometryFactory instead
  // MultiPoint.FromPM(List<Point> points, PrecisionModel precisionModel, int SRID) {
  //   super(points, new GeometryFactory(precisionModel, SRID));
  // }
  MultiPoint.FromPM(List<Point> points, PrecisionModel precisionModel, int SRID) :
  super.FromPM(points, precisionModel, SRID);

  ///@param  points          the <code>Point</code>s for this <code>MultiPoint</code>
  ///      , or <code>null</code> or an empty array to create the empty geometry.
  ///      Elements may be empty <code>Point</code>s, but not <code>null</code>s.
  // MultiPoint(List<Point> points, GeometryFactory factory) {
  //   super(points, factory);
  // }
  MultiPoint(super.points, super.factory);

  @override
  int getDimension() {
    return 0;
  }

  @override
  bool hasDimension(int dim) {
    return dim == 0;
  }
  
  @override
  int getBoundaryDimension() {
    return Dimension.FALSE;
  }

  @override
  String getGeometryType() {
    return Geometry.TYPENAME_MULTIPOINT;
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

  @override
  MultiPoint reverse() {
    return super.reverse() as MultiPoint;
  }
  
 /**protected */
 /// TODO. @ruier: maybe copy ???
 @override
  MultiPoint reverseInternal() {
    // List<Point> points = new Point[this.geometries.length];
    // for (int i = 0; i < points.length; i++) {
    //   points[i] = (Point) this.geometries[i].copy();
    // }
    List<Point> points = List<Point>.generate(this.geometries!.length, (index) => this.geometries![index].copy() as Point);
    return MultiPoint(points, factory);
  }

  @override
  bool equalsExactWithTolerance(Geometry other, double tolerance) {
    if (!isEquivalentClass(other)) {
      return false;
    }
    return super.equalsExactWithTolerance(other, tolerance);
  }

  ///  Returns the <code>Coordinate</code> at the given position.
  ///
  ///@param  n  the index of the <code>Coordinate</code> to retrieve, beginning
  ///      at 0
  ///@return    the <code>n</code>th <code>Coordinate</code>
 /**protected */
 Coordinate? getCoordinateN(int n) {
    return ( geometries![n] as Point).getCoordinate();
  }
  
 /**protected */@override
  MultiPoint copyInternal() {
    // TODO: ruier edit.
    // List<Point> points = new Point[this.geometries.length];
    // for (int i = 0; i < points.length; i++) {
    //   points[i] = (Point) this.geometries[i].copy();
    // }
    List<Point> points = List<Point>.generate(this.geometries!.length, (index) => this.geometries![index].copy() as Point);

    return new MultiPoint(points, factory);
  }
  
 /**protected */
  @override
  int getTypeCode() {
    return Geometry.TYPECODE_MULTIPOINT;
  }
  
}

