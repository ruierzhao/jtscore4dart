// ignore_for_file: unnecessary_non_null_assertion

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

// import org.locationtech.jts.algorithm.Area;
// import org.locationtech.jts.algorithm.Orientation;


import 'package:jtscore4dart/src/algorithm/Area.dart';
import 'package:jtscore4dart/src/algorithm/Orientation.dart';
import 'package:jtscore4dart/src/geom/CoordinateSequenceComparator.dart';

import 'Coordinate.dart';
import 'CoordinateSequence.dart';
import 'CoordinateSequences.dart';
import 'Geometry.dart';
import 'GeometryComponentFilter.dart';
import 'GeometryFactory.dart';
import 'GeometryFilter.dart';
import 'LinearRing.dart';
import 'Polygonal.dart';
import 'CoordinateFilter.dart';
import 'CoordinateSequenceFilter.dart';
import 'Envelope.dart';
import 'PrecisionModel.dart';

/// Represents a polygon with linear edges, which may include holes.
/// The outer boundary (shell)
/// and inner boundaries (holes) of the polygon are represented by {@link LinearRing}s.
/// The boundary rings of the polygon may have any orientation.
/// Polygons are closed, simple geometries by definition.
/// <p>
/// The polygon model conforms to the assertions specified in the
/// <A HREF="http://www.opengis.org/techno/specs.htm">OpenGIS Simple Features
/// Specification for SQL</A>.
/// <p>
/// A <code>Polygon</code> is topologically valid if and only if:
/// <ul>
/// <li>the coordinates which define it are valid coordinates
/// <li>the linear rings for the shell and holes are valid
/// (i.e. are closed and do not self-intersect)
/// <li>holes touch the shell or another hole at at most one point
/// (which implies that the rings of the shell and holes must not cross)
/// <li>the interior of the polygon is connected,
/// or equivalently no sequence of touching holes
/// makes the interior of the polygon disconnected
/// (i.e. effectively split the polygon into two pieces).
/// </ul>
///
///@version 1.7 
class Polygon
	extends Geometry
	implements Polygonal
{
  ///**private */static final int serialVersionUID = -3494792200821764533L;

  ///  The exterior boundary,
  /// or <code>null</code> if this <code>Polygon</code>
  ///  is empty.
  LinearRing shell;

  /// The interior boundaries, if any.
  /// This instance var is never null.
  /// If there are no holes, the array is of zero length.
  List<LinearRing> holes;

  ///  Constructs a <code>Polygon</code> with the given exterior boundary.
  ///
  ///@param  shell           the outer boundary of the new <code>Polygon</code>,
  ///      or <code>null</code> or an empty <code>LinearRing</code> if the empty
  ///      geometry is to be created.
  ///@param  precisionModel  the specification of the grid of allowable points
  ///      for this <code>Polygon</code>
  ///@param  SRID            the ID of the Spatial Reference System used by this
  ///      <code>Polygon</code>
  /// @deprecated Use GeometryFactory instead
  Polygon.FromPM(LinearRing shell, PrecisionModel precisionModel, int SRID) 
   : this(shell, <LinearRing>[], new GeometryFactory(precisionModel, SRID));
  

  ///  Constructs a <code>Polygon</code> with the given exterior boundary and
  ///  interior boundaries.
  ///
  ///@param  shell           the outer boundary of the new <code>Polygon</code>,
  ///      or <code>null</code> or an empty <code>LinearRing</code> if the empty
  ///      geometry is to be created.
  ///@param  holes           the inner boundaries of the new <code>Polygon</code>
  ///      , or <code>null</code> or empty <code>LinearRing</code>s if the empty
  ///      geometry is to be created.
  ///@param  precisionModel  the specification of the grid of allowable points
  ///      for this <code>Polygon</code>
  ///@param  SRID            the ID of the Spatial Reference System used by this
  ///      <code>Polygon</code>
  /// @deprecated Use GeometryFactory instead
  Polygon.WithHolePM(LinearRing shell, List<LinearRing> holes, PrecisionModel precisionModel, int SRID) 
     : this(shell, holes, new GeometryFactory(precisionModel, SRID));
  

  ///  Constructs a <code>Polygon</code> with the given exterior boundary and
  ///  interior boundaries.
  ///
  ///@param  shell           the outer boundary of the new <code>Polygon</code>,
  ///      or <code>null</code> or an empty <code>LinearRing</code> if the empty
  ///      geometry is to be created.
  ///@param  holes           the inner boundaries of the new <code>Polygon</code>
  ///      , or <code>null</code> or empty <code>LinearRing</code>s if the empty
  ///      geometry is to be created.
  Polygon(this.shell, this.holes, GeometryFactory factory): super(factory) {
    
    shell ??= getFactory().createLinearRing([]);
    holes ??= <LinearRing>[];
    if (Geometry.hasNullElements(holes!)) {
      throw new ArgumentError("holes must not contain null elements");
    }
    if (shell!.isEmpty() && Geometry.hasNonEmptyElements(holes!)) {
      throw new ArgumentError("shell is empty but holes are not");
    }
  }

  @override
  Coordinate? getCoordinate() {
    return shell!.getCoordinate();
  }

  @override
  List<Coordinate> getCoordinates() {
    if (isEmpty()) {
      return [];
    }
    // List<Coordinate> coordinates = new Coordinate[getNumPoints()];
    List<Coordinate> coordinates = [];
    int k = -1;
    List<Coordinate> shellCoordinates = shell!.getCoordinates();
    for (int x = 0; x < shellCoordinates.length; x++) {
      k++;
      coordinates[k] = shellCoordinates[x];
    }
    for (int i = 0; i < holes!.length; i++) {
      List<Coordinate> childCoordinates = holes![i].getCoordinates();
      for (int j = 0; j < childCoordinates.length; j++) {
        k++;
        coordinates[k] = childCoordinates[j];
      }
    }
    return coordinates;
  }

  @override
  int getNumPoints() {
    int numPoints = shell!.getNumPoints();
    for (int i = 0; i < holes!.length; i++) {
      numPoints += holes![i].getNumPoints();
    }
    return numPoints;
  }

  @override
  int getDimension() {
    return 2;
  }

  @override
  int getBoundaryDimension() {
    return 1;
  }

  @override
  bool isEmpty() {
    return shell!.isEmpty();
  }

  @override
  bool isRectangle()
  {
    if (getNumInteriorRing() != 0) return false;
    if (shell == null) return false;
    if (shell!.getNumPoints() != 5) return false;

    CoordinateSequence seq = shell!.getCoordinateSequence();

    // check vertices have correct values
    Envelope env = getEnvelopeInternal();
    for (int i = 0; i < 5; i++) {
      double x = seq.getX(i);
      if (! (x == env.getMinX() || x == env.getMaxX())) return false;
      double y = seq.getY(i);
      if (! (y == env.getMinY() || y == env.getMaxY())) return false;
    }

    // check vertices are in right order
    double prevX = seq.getX(0);
    double prevY = seq.getY(0);
    for (int i = 1; i <= 4; i++) {
      double x = seq.getX(i);
      double y = seq.getY(i);
      bool xChanged = x != prevX;
      bool yChanged = y != prevY;
      if (xChanged == yChanged) {
        return false;
      }
      prevX = x;
      prevY = y;
    }
    return true;
  }

  LinearRing getExteriorRing() {
    return shell!;
  }

  int getNumInteriorRing() {
    return holes!.length;
  }

  LinearRing getInteriorRingN(int n) {
    return holes![n];
  }

  @override
  String getGeometryType() {
    return Geometry.TYPENAME_POLYGON;
  }

  ///  Returns the area of this <code>Polygon</code>
  ///
  ///@return the area of the polygon
  @override
  double getArea()
  {
    double area = 0.0;
    // area += Area.ofRing(shell.getCoordinateSequence());
    area += Area.ofRing(shell!.getCoordinates());
    for (int i = 0; i < holes!.length; i++) {
      area -= Area.ofRing(holes![i].getCoordinates());
    }
    return area;
  }

  ///  Returns the perimeter of this <code>Polygon</code>
  ///
  ///@return the perimeter of the polygon
  @override
  double getLength()
  {
    double len = 0.0;
    len += shell!.getLength();
    for (int i = 0; i < holes!.length; i++) {
      len += holes![i].getLength();
    }
    return len;
  }

  /// Computes the boundary of this geometry
  ///
  /// @return a lineal geometry (which may be empty)
  /// @see Geometry#getBoundary
  @override
  Geometry getBoundary() {
    if (isEmpty()) {
      return getFactory().createMultiLineString([]);
    }
    // List<LinearRing> rings = new LinearRing[holes.length + 1];
    List<LinearRing> rings = [];
    // rings[0] = shell;
    rings.add(shell!);
    for (int i = 0; i < holes!.length; i++) {
      // rings[i + 1] = holes[i];
      rings.add(holes![i]);
    }
    // create LineString or MultiLineString as appropriate
    if (rings.length <= 1) {
      return getFactory().createLinearRingFromCoordSeq(rings[0].getCoordinateSequence());
    }
    return getFactory().createMultiLineString(rings);
  }

 /**protected */@override
  Envelope computeEnvelopeInternal() {
    return shell!.getEnvelopeInternal();
  }

  @override
  bool equalsExactWithTolerance(Geometry other, double tolerance) {
    if (!isEquivalentClass(other)) {
      return false;
    }
    Polygon otherPolygon =  other as Polygon;
    Geometry thisShell = shell!;
    Geometry otherPolygonShell = otherPolygon.shell!;
    if (!thisShell.equalsExactWithTolerance(otherPolygonShell, tolerance)) {
      return false;
    }
    if (holes!.length != otherPolygon.holes!.length) {
      return false;
    }
    for (int i = 0; i < holes!.length; i++) {
      if (!( holes![i] as Geometry).equalsExactWithTolerance(otherPolygon.holes![i], tolerance)) {
        return false;
      }
    }
    return true;
  }

  @override
  void applyCoord(CoordinateFilter filter) {
	    shell!.applyCoord(filter);
	    for (int i = 0; i < holes!.length; i++) {
	      holes![i].applyCoord(filter);
	    }
	  }

  @override
  void applyCoordSeq(CoordinateSequenceFilter filter)
  {
	    shell!.applyCoordSeq(filter);
      if (! filter.isDone()) {
        for (int i = 0; i < holes!.length; i++) {
          holes![i].applyCoordSeq(filter);
          if (filter.isDone()) {
            break;
          }
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
    shell!.applyGeometryComonent(filter);
    for (int i = 0; i < holes!.length; i++) {
      holes![i].applyGeometryComonent(filter);
    }
  }

  /// Creates and returns a full copy of this {@link Polygon} object.
  /// (including all coordinates contained by it).
  ///
  /// @return a clone of this instance
  /// @deprecated
  @override
  Object clone() {

    return copy();
  }

 /**protected */@override
  Polygon copyInternal() {
    LinearRing shellCopy = shell!.copy() as LinearRing; 
    // List<LinearRing> holeCopies = new LinearRing[this.holes.length];
    List<LinearRing> holeCopies = [];
    for (int i = 0; i < holes!.length; i++) {
    	// holeCopies[i] = (LinearRing) holes![i].copy();
      holeCopies.add( holes![i].copy() as LinearRing);
    }
    return new Polygon(shellCopy, holeCopies, factory);
  }
  @override
  Geometry convexHull() {
    return getExteriorRing().convexHull();
  }

  @override
  void normalize() {
    shell = normalized(shell!, true);
    for (int i = 0; i < holes!.length; i++) {
      holes![i] = normalized(holes![i], false);
    }
    // TODO: ruier edit.
    // Arrays.sort(holes);
  }

 /**protected */@override
  int compareToSameClass(Object o) {
    Polygon poly =  o as Polygon;

    LinearRing thisShell = shell!;
    LinearRing otherShell = poly.shell!;
    int shellComp = thisShell.compareToSameClass(otherShell);
    if (shellComp != 0) return shellComp;

    int nHole1 = getNumInteriorRing();
    int nHole2 = ((Polygon) o).getNumInteriorRing();
    int i = 0;
    while (i < nHole1 && i < nHole2) {
      LinearRing thisHole = (LinearRing) getInteriorRingN(i);
      LinearRing otherHole = (LinearRing) poly.getInteriorRingN(i);
      int holeComp = thisHole.compareToSameClass(otherHole);
      if (holeComp != 0) return holeComp;
      i++;
    }
    if (i < nHole1) return 1;
    if (i < nHole2) return -1;
    return 0;
  }

 /**protected */
  @override
  int compareToSameClassWithCompar(Object o, CoordinateSequenceComparator comp) {
    Polygon poly = (Polygon) o;

    LinearRing thisShell = shell;
    LinearRing otherShell = poly.shell;
    int shellComp = thisShell.compareToSameClassWithCompar(otherShell, comp);
    if (shellComp != 0) return shellComp;

    int nHole1 = getNumInteriorRing();
    int nHole2 = poly.getNumInteriorRing();
    int i = 0;
    while (i < nHole1 && i < nHole2) {
      LinearRing thisHole = (LinearRing) getInteriorRingN(i);
      LinearRing otherHole = (LinearRing) poly.getInteriorRingN(i);
      int holeComp = thisHole.compareToSameClassWithCompar(otherHole, comp);
      if (holeComp != 0) return holeComp;
      i++;
    }
    if (i < nHole1) return 1;
    if (i < nHole2) return -1;
    return 0;
  }
  
 /**protected */@override
  int getTypeCode() {
    return Geometry.TYPECODE_POLYGON;
  }

 /**private */LinearRing normalized(LinearRing ring, bool clockwise) {
    LinearRing res = (LinearRing) ring.copy();
    normalize(res, clockwise);
    return res;
  }

 /**private */@override
  void normalize(LinearRing ring, bool clockwise) {
    if (ring.isEmpty()) {
      return;
    }

    CoordinateSequence seq = ring.getCoordinateSequence();
    int minCoordinateIndex = CoordinateSequences.minCoordinateIndex(seq, 0, seq.size()-2);
    CoordinateSequences.scroll(seq, minCoordinateIndex, true);
    if (Orientation.isCCW(seq) == clockwise) {
      CoordinateSequences.reverse(seq);
    }
  }

  @override
  Polygon reverse() {
    return super.reverse() as Polygon;
  }

 /**protected */@override
  Polygon reverseInternal()
  {
    LinearRing shell = getExteriorRing().reverse();
    // List<LinearRing> holes = new LinearRing[getNumInteriorRing()];
    // for (int i = 0; i < holes.length; i++) {
    //   holes[i] = getInteriorRingN(i).reverse();
    // }
    List<LinearRing> holes = List.generate(getNumInteriorRing(), (index) => getInteriorRingN(index).reverse());

    return getFactory().createPolygon(shell, holes);
  }
  
}

