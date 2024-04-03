/*
 * Copyright (c) 2019 Martin Davis.
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
// import java.util.Collection;
// import java.util.List;

// import org.locationtech.jts.geom.Dimension;
// import org.locationtech.jts.geom.Geometry;
// import org.locationtech.jts.geom.GeometryCollection;
// import org.locationtech.jts.geom.GeometryFactory;
// import org.locationtech.jts.geom.GeometryFilter;
// import org.locationtech.jts.geom.LineString;
// import org.locationtech.jts.geom.Point;
// import org.locationtech.jts.geom.Polygon;
// import org.locationtech.jts.util.Assert;


import 'package:jtscore4dart/src/geom/Dimension.dart';
import 'package:jtscore4dart/src/geom/Geometry.dart';
import 'package:jtscore4dart/src/geom/GeometryCollection.dart';
import 'package:jtscore4dart/src/geom/GeometryFactory.dart';
import 'package:jtscore4dart/src/geom/GeometryFilter.dart';
import 'package:jtscore4dart/src/geom/LineString.dart';
import 'package:jtscore4dart/src/geom/Point.dart';
import 'package:jtscore4dart/src/geom/Polygon.dart';
import 'package:jtscore4dart/src/util/Assert.dart';

/**
 * Extracts atomic elements from 
 * input geometries or collections, 
 * recording the dimension found.
 * Empty geometries are discarded since they 
 * do not contribute to the result of {@link UnaryUnionOp}.
 * 
 * @author Martin Davis
 *
 */
class InputExtracter implements GeometryFilter 
{
  /**
   * Extracts elements from a collection of geometries.
   * 
   * @param [geoms] a collection of geometries
   * @return an extracter over the geometries
   */
  static InputExtracter extractAll(Iterable<Geometry> geoms) {
    InputExtracter extracter = new InputExtracter();
    extracter.addAll(geoms);
    return extracter;
  }
  
  /**
   * Extracts elements from a geometry.
   * 
   * @param [geoms] a geometry to extract from
   * @return an extracter over the geometry
   */
  static InputExtracter extract(Geometry geom) {
    InputExtracter extracter = new InputExtracter();
    extracter.add(geom);
    return extracter;
  }
  
 /**private */GeometryFactory? geomFactory;
//  /**private */List<Polygon> polygons = new ArrayList<Polygon>();
//  /**private */List<LineString> lines = new ArrayList<LineString>();
//  /**private */List<Point> points = new ArrayList<Point>();
  List<Polygon> polygons = <Polygon>[];
  List<LineString> lines = <LineString>[];
  List<Point> points = <Point>[];
  
  /**
   * The default dimension for an empty GeometryCollection
   */
 /**private */int dimension = Dimension.FALSE;
  
  InputExtracter();
  
  /**
   * Tests whether there were any non-empty geometries extracted.
   * 
   * @return true if there is a non-empty geometry present
   */
  bool isEmpty() {
    return polygons.isEmpty 
        && lines.isEmpty
        && points.isEmpty;
  }
  
  /**
   * Gets the maximum dimension extracted.
   * 
   * @return the maximum extracted dimension
   */
  int getDimension() {
    return dimension;
  }
  
  /**
   * Gets the geometry factory from the extracted geometry,
   * if there is one.
   * If an empty collection was extracted, will return <code>null</code>.
   * 
   * @return a geometry factory, or null if one could not be determined
   */
  GeometryFactory? getFactory() {
    return geomFactory;
  }
  
  /**
   * Gets the extracted atomic geometries of the given dimension <code>dim</code>.
   * 
   * @param [dim] the dimension of geometry to return
   * @return a list of the extracted geometries of dimension dim.
   */
  List<Geometry> getExtract(int dim) {
    switch (dim) {
      case 0: return points;
      case 1: return lines;
      case 2: return polygons;
    }
    Assert.shouldNeverReachHere("Invalid dimension: $dim" );
    return [];
  }
  
 /**private */void addAll(Iterable<Geometry> geoms) {
    for (Geometry geom in geoms) {
      add(geom);
    }
  }
  
 /**private */void add(Geometry geom) {
    geomFactory ??= geom.getFactory();
    
    geom.apply(this);
  }

  @override
  void filter(Geometry geom) {
    _recordDimension( geom.getDimension() );
    
    if (geom is GeometryCollection) {
      return;
    }
    /**
     * Don't keep empty geometries
     */
    if (geom.isEmpty()) {
      return;
    }
    
    if (geom is Polygon) {
      polygons.add( geom);
      return;
    }
    else if (geom is LineString) {
      lines.add( geom);
      return;
    }
    else if (geom is Point) {
      points.add( geom);
      return;
    }
    Assert.shouldNeverReachHere("Unhandled geometry type: ${geom.getGeometryType()}");
  }

 void _recordDimension(int dim) {
    if (dim > dimension ) {
      dimension = dim;
    }
  }
}
