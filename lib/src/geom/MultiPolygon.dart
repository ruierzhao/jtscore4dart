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


import 'Geometry.dart';
import 'GeometryCollection.dart';
import 'GeometryFactory.dart';
import 'LineString.dart';
import 'Polygon.dart';
import 'Polygonal.dart';
import 'PrecisionModel.dart';

/// Models a collection of {@link Polygon}s.
/// <p>
/// As per the OGC SFS specification,
/// the Polygons in a MultiPolygon may not overlap,
/// and may only touch at single points.
/// This allows the topological point-set semantics
/// to be well-defined.
///
///
///@version 1.7
class MultiPolygon
	extends GeometryCollection
	implements Polygonal
{
//  /**private */static final int serialVersionUID = -551033529766975875L;
  ///  Constructs a <code>MultiPolygon</code>.
  ///
  ///@param  polygons        the <code>Polygon</code>s for this <code>MultiPolygon</code>
  ///      , or <code>null</code> or an empty array to create the empty geometry.
  ///      Elements may be empty <code>Polygon</code>s, but not <code>null</code>
  ///      s. The polygons must conform to the assertions specified in the <A
  ///      HREF="http://www.opengis.org/techno/specs.htm">OpenGIS Simple Features
  ///      Specification for SQL</A> .
  ///@param  precisionModel  the specification of the grid of allowable points
  ///      for this <code>MultiPolygon</code>
  ///@param  SRID            the ID of the Spatial Reference System used by this
  ///      <code>MultiPolygon</code>
  /// @deprecated Use GeometryFactory instead
  MultiPolygon.FromPM(List<Polygon> polygons, PrecisionModel precisionModel, int SRID) : super.FromPM(polygons, precisionModel, SRID) ;
    


  /// @param polygons
  ///            the <code>Polygon</code>s for this <code>MultiPolygon</code>,
  ///            or <code>null</code> or an empty array to create the empty
  ///            geometry. Elements may be empty <code>Polygon</code>s, but
  ///            not <code>null</code>s. The polygons must conform to the
  ///            assertions specified in the <A
  ///            HREF="http://www.opengis.org/techno/specs.htm">OpenGIS Simple
  ///            Features Specification for SQL</A>.
  MultiPolygon(List<Polygon> polygons, GeometryFactory factory):
    super(polygons, factory);
  

  @override
  int getDimension() {
    return 2;
  }

  @override
  bool hasDimension(int dim) {
    return dim == 2;
  }
  
  @override
  int getBoundaryDimension() {
    return 1;
  }

  @override
  String getGeometryType() {
    return Geometry.TYPENAME_MULTIPOLYGON;
  }

  /*
  bool isSimple() {
    return true;
  }
*/

  /// Computes the boundary of this geometry
  ///
  /// @return a lineal geometry (which may be empty)
  /// @see Geometry#getBoundary
  @override
  Geometry getBoundary() {
    if (isEmpty()) {
      return getFactory().createMultiLineString([]);
    }
    // ArrayList allRings = new ArrayList();
    List allRings = [];
    for (int i = 0; i < geometries.length; i++) {
      Polygon polygon =  geometries[i] as Polygon;
      Geometry rings = polygon.getBoundary();
      for (int j = 0; j < rings.getNumGeometries(); j++) {
        allRings.add(rings.getGeometryN(j));
      }
    }
    // List<LineString> allRingsArray = new LineString[allRings!.length];
    // return getFactory().createMultiLineString((List<LineString>) allRings.toArray(allRingsArray));
    return getFactory().createMultiLineString(allRings as List<LineString>);
  }

  @override
  bool equalsExactWithTolerance(Geometry other, double tolerance) {
    if (!isEquivalentClass(other)) {
      return false;
    }
    return super.equalsExactWithTolerance(other, tolerance);
  }

  /// Creates a {@link MultiPolygon} with
  /// every component reversed.
  /// The order of the components in the collection are not reversed.
  ///
  /// @return a MultiPolygon in the reverse order
  @override
  MultiPolygon reverse() {
    return super.reverse() as MultiPolygon;
  }

 /**protected */@override
  MultiPolygon reverseInternal() {
    // List<Polygon> polygons = new Polygon[this.geometries.length];
    List<Polygon> polygons = [];
    for (int i = 0; i < polygons.length; i++) {
      // polygons[i] = (Polygon) this.geometries[i].reverse();
      polygons.add(this.geometries[i].reverse() as Polygon);
    }
    return new MultiPolygon(polygons, factory);
  }
  
 /**protected */@override
  MultiPolygon copyInternal() {
    // List<Polygon> polygons = new Polygon[this.geometries.length];
    List<Polygon> polygons = [];
    for (int i = 0; i < polygons.length; i++) {
      // polygons[i] = (Polygon) this.geometries[i].copy();
      polygons.add(this.geometries[i].copy() as Polygon);
    }
    return new MultiPolygon(polygons, factory);
  }

 /**protected */@override
  int getTypeCode() {
    return Geometry.TYPECODE_MULTIPOLYGON;
  }
}


