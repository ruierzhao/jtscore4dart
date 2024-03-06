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


// import java.util.Arrays;
// import java.util.TreeSet;

// import org.locationtech.jts.util.Assert;


import 'package:jtscore4dart/src/geom/CoordinateFilter.dart';

import 'package:jtscore4dart/src/geom/CoordinateSequenceFilter.dart';

import 'package:jtscore4dart/src/geom/GeometryComponentFilter.dart';

import 'Coordinate.dart';
import 'Geometry.dart';
import 'GeometryFactory.dart';
import 'GeometryFilter.dart';
import 'PrecisionModel.dart';

/// Models a collection of {@link Geometry}s of
/// arbitrary type and dimension.
///
///
///@version 1.7
class GeometryCollection extends Geometry {
//  With contributions from Markus Schaber [schabios@logi-track.com] 2004-03-26
//  /**private */static final int serialVersionUID = -5694727726395021467L;

  ///  Internal representation of this <code>GeometryCollection</code>.
 /**protected */List<Geometry> geometries;

  /// @deprecated Use GeometryFactory instead
  @Deprecated("Use GeometryFactory instead")
  GeometryCollection(List<Geometry> geometries, PrecisionModel precisionModel, int SRID) {
      this(geometries, new GeometryFactory(precisionModel, SRID));
  }


  /// @param geometries
  ///            the <code>Geometry</code>s for this <code>GeometryCollection</code>,
  ///            or <code>null</code> or an empty array to create the empty
  ///            geometry. Elements may be empty <code>Geometry</code>s,
  ///            but not <code>null</code>s.
  GeometryCollection(List<Geometry> geometries, GeometryFactory factory) {
    super(factory);
    if (geometries == null) {
      geometries = new List<Geometry>{};
    }
    if (hasNullElements(geometries)) {
      throw new ArgumentError("geometries must not contain null elements");
    }
    this.geometries = geometries;
  }

  @override
  Coordinate getCoordinate() {
    for (int i = 0; i < geometries.length; i++) {
      if (! geometries[i].isEmpty()) {
        return geometries[i].getCoordinate();
      }
    }
    return null;
  }

  /// Collects all coordinates of all subgeometries into an Array.
  ///
  /// Note that while changes to the coordinate objects themselves
  /// may modify the Geometries in place, the returned Array as such
  /// is only a temporary container which is not synchronized back.
  ///
  /// @return the collected coordinates
  ///
  @override
  List<Coordinate> getCoordinates() {
    List<Coordinate> coordinates = new Coordinate[getNumPoints()];
    int k = -1;
    for (int i = 0; i < geometries.length; i++) {
      List<Coordinate> childCoordinates = geometries[i].getCoordinates();
      for (int j = 0; j < childCoordinates.length; j++) {
        k++;
        coordinates[k] = childCoordinates[j];
      }
    }
    return coordinates;
  }

  @override
  bool isEmpty() {
    for (int i = 0; i < geometries.length; i++) {
      if (!geometries[i].isEmpty()) {
        return false;
      }
    }
    return true;
  }

  @override
  int getDimension() {
    int dimension = Dimension.FALSE;
    for (int i = 0; i < geometries.length; i++) {
      dimension = math.max(dimension, geometries[i].getDimension());
    }
    return dimension;
  }

  @override
  bool hasDimension(int dim) {
    for (int i = 0; i < geometries.length; i++) {
      if (geometries[i].hasDimension(dim))
        return true;
    }
    return false;
  }
  
  @override
  int getBoundaryDimension() {
    int dimension = Dimension.FALSE;
    for (int i = 0; i < geometries.length; i++) {
      dimension = math.max(dimension, ((Geometry) geometries[i]).getBoundaryDimension());
    }
    return dimension;
  }

  @override
  int getNumGeometries() {
    return geometries.length;
  }

  @override
  Geometry getGeometryN(int n) {
    return geometries[n];
  }

  @override
  int getNumPoints() {
    int numPoints = 0;
    for (int i = 0; i < geometries.length; i++) {
      numPoints += ((Geometry) geometries[i]).getNumPoints();
    }
    return numPoints;
  }

  @override
  String getGeometryType() {
    return Geometry.TYPENAME_GEOMETRYCOLLECTION;
  }

  @override
  Geometry getBoundary() {
    checkNotGeometryCollection(this);
    Assert.shouldNeverReachHere();
    return null;
  }

  ///  Returns the area of this <code>GeometryCollection</code>
  ///
  /// @return the area of the polygon
  @override
  double getArea()
  {
    double area = 0.0;
    for (int i = 0; i < geometries.length; i++) {
      area += geometries[i].getArea();
    }
    return area;
  }

  @override
  double getLength()
  {
    double sum = 0.0;
    for (int i = 0; i < geometries.length; i++) {
      sum += (geometries[i]).getLength();
    }
    return sum;
  }

  @override
  bool equalsExact(Geometry other, double tolerance) {
    if (!isEquivalentClass(other)) {
      return false;
    }
    GeometryCollection otherCollection = (GeometryCollection) other;
    if (geometries.length != otherCollection.geometries.length) {
      return false;
    }
    for (int i = 0; i < geometries.length; i++) {
      if (!((Geometry) geometries[i]).equalsExact(otherCollection.geometries[i], tolerance)) {
        return false;
      }
    }
    return true;
  }

  @override
  void applyCoord(CoordinateFilter filter) {
	    for (int i = 0; i < geometries.length; i++) {
	      geometries[i].apply(filter);
	    }
	  }

  @override
  void applyCoordSeq(CoordinateSequenceFilter filter) {
    if (geometries.length == 0)
      return;
    for (int i = 0; i < geometries.length; i++) {
      geometries[i].apply(filter);
      if (filter.isDone()) {
        break;
      }
    }
    if (filter.isGeometryChanged())
      geometryChanged();
  }

  @override
  void apply(GeometryFilter filter) {
    filter.filter(this);
    for (int i = 0; i < geometries.length; i++) {
      geometries[i].apply(filter);
    }
  }

  @override
  void applyGeometryComonent(GeometryComponentFilter filter) {
    filter.filter(this);
    for (int i = 0; i < geometries.length; i++) {
      geometries[i].apply(filter);
    }
  }

  /// Creates and returns a full copy of this {@link GeometryCollection} object.
  /// (including all coordinates contained by it).
  ///
  /// @return a clone of this instance
  /// @deprecated
  @override
  Object clone() {
    return copy();
  }

 /**protected */@override
  GeometryCollection copyInternal() {
    List<Geometry> geometries = new Geometry[this.geometries.length];
    for (int i = 0; i < geometries.length; i++) {
      geometries[i] = this.geometries[i].copy();
    }
    return new GeometryCollection(geometries, factory);
  }

  @override
  void normalize() {
    for (int i = 0; i < geometries.length; i++) {
      geometries[i].normalize();
    }
    Arrays.sort(geometries);
  }

 /**protected */@override
  Envelope computeEnvelopeInternal() {
    Envelope envelope = new Envelope();
    for (int i = 0; i < geometries.length; i++) {
      envelope.expandToInclude(geometries[i].getEnvelopeInternal());
    }
    return envelope;
  }

 /**protected */@override
  int compareToSameClass(Object o) {
    TreeSet theseElements = new TreeSet(Arrays.asList(geometries));
    TreeSet otherElements = new TreeSet(Arrays.asList(((GeometryCollection) o).geometries));
    return compare(theseElements, otherElements);
  }

 /**protected */@override
  int compareToSameClass(Object o, CoordinateSequenceComparator comp) {
    GeometryCollection gc = (GeometryCollection) o;

    int n1 = getNumGeometries();
    int n2 = gc.getNumGeometries();
    int i = 0;
    while (i < n1 && i < n2) {
      Geometry thisGeom = getGeometryN(i);
      Geometry otherGeom = gc.getGeometryN(i);
      int holeComp = thisGeom.compareToSameClass(otherGeom, comp);
      if (holeComp != 0) return holeComp;
      i++;
    }
    if (i < n1) return 1;
    if (i < n2) return -1;
    return 0;

  }
  
 /**protected */@override
  int getTypeCode() {
    return Geometry.TYPECODE_GEOMETRYCOLLECTION;
  }

  /// Creates a {@link GeometryCollection} with
  /// every component reversed.
  /// The order of the components in the collection are not reversed.
  ///
  /// @return a {@link GeometryCollection} in the reverse order
  @override
  GeometryCollection reverse() {
    return (GeometryCollection) super.reverse();
  }

 /**protected */@override
  GeometryCollection reverseInternal()
  {
    List<Geometry> geometries = new Geometry[this.geometries.length];
    for (int i = 0; i < geometries.length; i++) {
      geometries[i] = this.geometries[i].reverse();
    }
    return new GeometryCollection(geometries, factory);
  }
  
  @override
  bool equalsExactWithTolerance(Geometry other, double tolerance) {
    // TODO: @ruier add .implement equalsExactWithTolerance
    throw UnimplementedError();
  }
}

