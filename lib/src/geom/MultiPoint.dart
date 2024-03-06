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


import 'GeometryCollection.dart';
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

 /**private */static final int serialVersionUID = -8048474874175355449L;

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
  MultiPoint(Point[] points, PrecisionModel precisionModel, int SRID) {
    super(points, new GeometryFactory(precisionModel, SRID));
  }

  ///@param  points          the <code>Point</code>s for this <code>MultiPoint</code>
  ///      , or <code>null</code> or an empty array to create the empty geometry.
  ///      Elements may be empty <code>Point</code>s, but not <code>null</code>s.
  MultiPoint(Point[] points, GeometryFactory factory) {
    super(points, factory);
  }

  int getDimension() {
    return 0;
  }

  bool hasDimension(int dim) {
    return dim == 0;
  }
  
  int getBoundaryDimension() {
    return Dimension.FALSE;
  }

  String getGeometryType() {
    return Geometry.TYPENAME_MULTIPOINT;
  }

  /// Gets the boundary of this geometry.
  /// Zero-dimensional geometries have no boundary by definition,
  /// so an empty GeometryCollection is returned.
  ///
  /// @return an empty GeometryCollection
  /// @see Geometry#getBoundary
  Geometry getBoundary() {
    return getFactory().createGeometryCollection();
  }

  MultiPoint reverse() {
    return (MultiPoint) super.reverse();
  }
  
 /**protected */MultiPoint reverseInternal() {
    Point[] points = new Point[this.geometries.length];
    for (int i = 0; i < points.length; i++) {
      points[i] = (Point) this.geometries[i].copy();
    }
    return new MultiPoint(points, factory);
  }

  bool equalsExact(Geometry other, double tolerance) {
    if (!isEquivalentClass(other)) {
      return false;
    }
    return super.equalsExact(other, tolerance);
  }

  ///  Returns the <code>Coordinate</code> at the given position.
  ///
  ///@param  n  the index of the <code>Coordinate</code> to retrieve, beginning
  ///      at 0
  ///@return    the <code>n</code>th <code>Coordinate</code>
 /**protected */Coordinate getCoordinate(int n) {
    return ((Point) geometries[n]).getCoordinate();
  }
  
 /**protected */MultiPoint copyInternal() {
    Point[] points = new Point[this.geometries.length];
    for (int i = 0; i < points.length; i++) {
      points[i] = (Point) this.geometries[i].copy();
    }
    return new MultiPoint(points, factory);
  }
  
 /**protected */int getTypeCode() {
    return Geometry.TYPECODE_MULTIPOINT;
  }

}

