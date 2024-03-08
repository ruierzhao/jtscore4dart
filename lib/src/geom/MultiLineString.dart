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


// import org.locationtech.jts.operation.BoundaryOp;

import 'package:jtscore4dart/src/operation/BoundaryOp.dart';

import 'Dimension.dart';
import 'Geometry.dart';
import 'GeometryCollection.dart';
import 'GeometryFactory.dart';
import 'LineString.dart';
import 'Lineal.dart';
import 'PrecisionModel.dart';

/// Models a collection of {@link LineString}s.
/// <p>
/// Any collection of LineStrings is a valid MultiLineString.
///
///@version 1.7
class MultiLineString
	extends GeometryCollection
	implements Lineal
	{
//  /**private */static final int serialVersionUID = 8166665132445433741L;
  ///  Constructs a <code>MultiLineString</code>.
  ///
  ///@param  lineStrings     the <code>LineString</code>s for this <code>MultiLineString</code>
  ///      , or <code>null</code> or an empty array to create the empty geometry.
  ///      Elements may be empty <code>LineString</code>s, but not <code>null</code>
  ///      s.
  ///@param  precisionModel  the specification of the grid of allowable points
  ///      for this <code>MultiLineString</code>
  ///@param  SRID            the ID of the Spatial Reference System used by this
  ///      <code>MultiLineString</code>
  /// @deprecated Use GeometryFactory instead
  MultiLineString.FromPM(List<LineString> lineStrings, PrecisionModel precisionModel, int SRID) 
    :super(lineStrings, new GeometryFactory(precisionModel, SRID));
  



  /// @param lineStrings
  ///            the <code>LineString</code>s for this <code>MultiLineString</code>,
  ///            or <code>null</code> or an empty array to create the empty
  ///            geometry. Elements may be empty <code>LineString</code>s,
  ///            but not <code>null</code>s.
  MultiLineString(List<LineString> lineStrings, GeometryFactory factory) 
    :super(lineStrings, factory);
  

  @override
  int getDimension() {
    return 1;
  }

  @override
  bool hasDimension(int dim) {
    return dim == 1;
  }
  
  @override
  int getBoundaryDimension() {
    if (isClosed()) {
      return Dimension.FALSE;
    }
    return 0;
  }

  @override
  String getGeometryType() {
    return Geometry.TYPENAME_MULTILINESTRING;
  }

  bool isClosed() {
    if (isEmpty()) {
      return false;
    }
    for (int i = 0; i < geometries!.length; i++) {
      if (!( geometries![i] as LineString).isClosed()) {
        return false;
      }
    }
    return true;
  }

  /// Gets the boundary of this geometry.
  /// The boundary of a lineal geometry is always a zero-dimensional geometry (which may be empty).
  ///
  /// @return the boundary geometry
  /// @see Geometry#getBoundary
  @override
  Geometry getBoundary()
  {
    return (new BoundaryOp(this)).getBoundary();
  }

  /// Creates a {@link MultiLineString} in the reverse
  /// order to this object.
  /// Both the order of the component LineStrings
  /// and the order of their coordinate sequences
  /// are reversed.
  ///
  /// @return a {@link MultiLineString} in the reverse order
  @override
  MultiLineString reverse() {
    return  super.reverse() as MultiLineString;
  }

 /**protected */@override
  MultiLineString reverseInternal() {
    // List<LineString> lineStrings = new LineString[this.geometries.length];
    List<LineString> lineStrings = [];
    for (int i = 0; i < lineStrings.length; i++) {
      // lineStrings[i] =  this.geometries[i].reverse() as LineString;
      lineStrings.add(this.geometries![i].reverse() as LineString);
    }
    return new MultiLineString(lineStrings, factory);
  }
  
 /**protected */@override
  MultiLineString copyInternal() {
    List<LineString> lineStrings = List.generate(this.geometries!.length,(i) => this.geometries![i].copy() as LineString);
    
    // List<LineString> lineStrings = new LineString[this.geometries.length];
    // for (int i = 0; i < lineStrings.length; i++) {
    //   lineStrings[i] = this.geometries[i].copy() as LineString;
    // }
    return MultiLineString(lineStrings, factory);
  }

  @override
  bool equalsExactWithTolerance(Geometry other, double tolerance) {
    if (!isEquivalentClass(other)) {
      return false;
    }
    return super.equalsExactWithTolerance(other, tolerance);
  }

 /**protected */@override
  int getTypeCode() {
    return Geometry.TYPECODE_MULTILINESTRING;
  }
}

