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


// import java.io.Serializable;
// import java.util.Collection;
// import java.util.Iterator;

// import org.locationtech.jts.geom.impl.CoordinateArraySequenceFactory;
// import org.locationtech.jts.geom.util.GeometryEditor;
// import org.locationtech.jts.util.Assert;

import 'package:jtscore4dart/src/geom/Coordinate.dart';
import 'package:jtscore4dart/src/geom/CoordinateSequence.dart';
import 'package:jtscore4dart/src/geom/CoordinateSequenceFactory.dart';
import 'package:jtscore4dart/src/geom/Envelope.dart';
import 'package:jtscore4dart/src/geom/Geometry.dart';
import 'package:jtscore4dart/src/geom/Point.dart';
import 'package:jtscore4dart/src/geom/PrecisionModel.dart';

import 'GeometryCollection.dart';
import 'LineString.dart';
import 'LinearRing.dart';
import 'MultiLineString.dart';
import 'MultiPoint.dart';
import 'MultiPolygon.dart';
import 'Polygon.dart';
import 'impl/CoordinateArraySequenceFactory.dart';
import 'util/GeometryEditor.dart' show GeometryEditor, CoordinateSequenceOperation;

/// Supplies a set of utility methods for building Geometry objects from lists
/// of Coordinates.
/// <p>
/// Note that the factory constructor methods do <b>not</b> change the input coordinates in any way.
/// In particular, they are not rounded to the supplied <tt>PrecisionModel</tt>.
/// It is assumed that input Coordinates meet the given precision.
/// <p>
/// Instances of this class are thread-safe.
///
/// @version 1.7
class GeometryFactory{
  ///**private */static final int serialVersionUID = -6820524753094095635L;
  /**private */ PrecisionModel precisionModel;

  /**private */ CoordinateSequenceFactory coordinateSequenceFactory;
  
  /**private */ int SRID;


  static Point createPointFromInternalCoord(Coordinate coord, Geometry exemplar)
  {
    exemplar.getPrecisionModel().makePreciseFromCoord(coord);
    return exemplar.getFactory().createPoint(coord);
  }


  // TODO: ruier edit.
    // GeometryFactory({
    //   this.precisionModel,
    //   this.SRID = 0 ,
    //   this.coordinateSequenceFactory,
    //   }) 
    //   {
    //     precisionModel ??= PrecisionModel();
    //     coordinateSequenceFactory ??= getDefaultCoordinateSequenceFactory();
    //   }
    GeometryFactory([PrecisionModel? _precisionModel, this.SRID=0, CoordinateSequenceFactory? coordinateSequenceFactory]): 
    this.precisionModel = _precisionModel ??= PrecisionModel(),
    coordinateSequenceFactory = coordinateSequenceFactory ??= getDefaultCoordinateSequenceFactory();



  /**private */ static CoordinateSequenceFactory getDefaultCoordinateSequenceFactory()
  {
    return CoordinateArraySequenceFactory.instance();
  }

  ///  Converts the <code>List</code> to an array.
  ///
  ///@param  points  the <code>List</code> of Points to convert
  ///@return         the <code>List</code> in array format
  // TODO: ruier edit.
  // static List<Point> toPointArray(Collection points) {
  //   List<Point> pointArray = new Point[points.size()];
  //   return (List<Point>) points.toArray(pointArray);
  // }
  static List<Point> toPointArray(Iterable points) {
    return points.toList() as List<Point>;
  }

  ///  Converts the <code>List</code> to an array.
  ///
  ///@param  geometries  the list of <code>Geometry's</code> to convert
  ///@return            the <code>List</code> in array format
  // static List<Geometry> toGeometryArray(Collection geometries) {
  //   if (geometries == null) return null;
  //   List<Geometry> geometryArray = new Geometry[geometries.size()];
  //   return (List<Geometry>) geometries.toArray(geometryArray);
  // }
  static List<Geometry>? toGeometryArray(Iterable geometries) {
    return geometries.toList() as  List<Geometry>;
  }

  ///  Converts the <code>List</code> to an array.
  ///
  ///@param  linearRings  the <code>List</code> of LinearRings to convert
  ///@return              the <code>List</code> in array format
  static List<LinearRing> toLinearRingArray(Iterable linearRings) {
    // List<LinearRing> linearRingArray = new LinearRing[linearRings.size()];
    return linearRings.toList() as List<LinearRing>;
  }
  // static List<LinearRing> toLinearRingArray(Collection linearRings) {
  //   List<LinearRing> linearRingArray = new LinearRing[linearRings.size()];
  //   return (List<LinearRing>) linearRings.toArray(linearRingArray);
  // }

  ///  Converts the <code>List</code> to an array.
  ///
  ///@param  lineStrings  the <code>List</code> of LineStrings to convert
  ///@return              the <code>List</code> in array format
  // static List<LineString> toLineStringArray(Collection lineStrings) {
  //   List<LineString> lineStringArray = new LineString[lineStrings.size()];
  //   return (List<LineString>) lineStrings.toArray(lineStringArray);
  // }
  static List<LineString> toLineStringArray(Iterable lineStrings) {
    // List<LineString> lineStringArray = new LineString[lineStrings.size()];
    return lineStrings.toList() as List<LineString>;
  }

  ///  Converts the <code>List</code> to an array.
  ///
  ///@param  polygons  the <code>List</code> of Polygons to convert
  ///@return           the <code>List</code> in array format
  // static List<Polygon> toPolygonArray(Collection polygons) {
  //   List<Polygon> polygonArray = new Polygon[polygons.size()];
  //   return (List<Polygon>) polygons.toArray(polygonArray);
  // }
  static List<Polygon> toPolygonArray(Iterable polygons) {
    // List<Polygon> polygonArray = new Polygon[polygons.size()];
    return polygons.toList() as  List<Polygon>; 
  }

  ///  Converts the <code>List</code> to an array.
  ///
  ///@param  multiPolygons  the <code>List</code> of MultiPolygons to convert
  ///@return                the <code>List</code> in array format
  static List<MultiPolygon> toMultiPolygonArray(Iterable multiPolygons) {
    // List<MultiPolygon> multiPolygonArray = new MultiPolygon[multiPolygons.size()];
    return multiPolygons.toList() as  List<MultiPolygon>; 
  }
  // static MultiList<Polygon> toMultiPolygonArray(Collection multiPolygons) {
  //   MultiList<Polygon> multiPolygonArray = new MultiPolygon[multiPolygons.size()];
  //   return (MultiList<Polygon>) multiPolygons.toArray(multiPolygonArray);
  // }
   

  ///  Converts the <code>List</code> to an array.
  ///
  ///@param  multiLineStrings  the <code>List</code> of MultiLineStrings to convert
  ///@return                   the <code>List</code> in array format
  static List<MultiLineString> toMultiLineStringArray(Iterable multiLineStrings) {
    // List<MultiLineString> multiLineStringArray = new MultiLineString[multiLineStrings.size()];
    return multiLineStrings.toList() as List<MultiLineString>;
  }

  ///  Converts the <code>List</code> to an array.
  ///
  ///@param  multiPoints  the <code>List</code> of MultiPoints to convert
  ///@return              the <code>List</code> in array format
  static List<MultiPoint> toMultiPointArray(Iterable multiPoints) {
    // List<MultiPoint> multiPointArray = new MultiPoint[multiPoints.size()];
    return multiPoints.toList() as List<MultiPoint>;
  }

  /// Creates a {@link Geometry} with the same extent as the given envelope.
  /// The Geometry returned is guaranteed to be valid.  
  /// To provide this behaviour, the following cases occur:
  /// <p>
  /// If the <code>Envelope</code> is:
  /// <ul>
  /// <li>null : returns an empty {@link Point}
  /// <li>a point : returns a non-empty {@link Point}
  /// <li>a line : returns a two-point {@link LineString}
  /// <li>a rectangle : returns a {@link Polygon} whose points are (minx, miny),
  ///  (minx, maxy), (maxx, maxy), (maxx, miny), (minx, miny).
  /// </ul>
  /// 
  ///@param  envelope the <code>Envelope</code> to convert
  ///@return an empty <code>Point</code> (for null <code>Envelope</code>s), 
  ///	a <code>Point</code> (when min x = max x and min y = max y) or a
  ///      <code>Polygon</code> (in all other cases)
  Geometry toGeometry(Envelope envelope) {
  	// null envelope - return empty point geometry
    if (envelope.isNull()) {
      return createPoint();
    }
    
    // point?
    if (envelope.getMinX() == envelope.getMaxX() && envelope.getMinY() == envelope.getMaxY()) {
      return createPoint(Coordinate(envelope.getMinX(), envelope.getMinY()));
    }
    
    // vertical or horizontal line?
    if (envelope.getMinX() == envelope.getMaxX()
    		|| envelope.getMinY() == envelope.getMaxY()) {
    	return createLineString(<Coordinate>[
          new Coordinate(envelope.getMinX(), envelope.getMinY()),
          new Coordinate(envelope.getMaxX(), envelope.getMaxY())
          ]);
    }

    // create a CW ring for the polygon 
    return createPolygon(createLinearRing(<Coordinate>[
        Coordinate(envelope.getMinX(), envelope.getMinY()),
        Coordinate(envelope.getMinX(), envelope.getMaxY()),
        Coordinate(envelope.getMaxX(), envelope.getMaxY()),
        Coordinate(envelope.getMaxX(), envelope.getMinY()),
        Coordinate(envelope.getMinX(), envelope.getMinY())
        ]), null);
  }

  /// Returns the PrecisionModel that Geometries created by this factory
  /// will be associated with.
  /// 
  /// @return the PrecisionModel for this factory
  PrecisionModel getPrecisionModel() {
    return precisionModel;
  }

  /// Constructs an empty {@link Point} geometry.
  /// 
  /// @return an empty Point
  // Point createPoint() {
	// return createPoint(getCoordinateSequenceFactory().createFromListCoord(<Coordinate>[]));
  // }
  
  /// Creates a Point using the given Coordinate.
  /// A null Coordinate creates an empty Geometry.
  /// 
  /// @param coordinate a Coordinate, or null
  /// @return the created Point
  Point createPoint([Coordinate? coordinate]) {
    return createPointFromCoordSeq(coordinate != null 
    ? getCoordinateSequenceFactory().create([coordinate]) : 
    getCoordinateSequenceFactory().create(<Coordinate>[]));
  }

  /// Creates a Point using the given CoordinateSequence; a null or empty
  /// CoordinateSequence will create an empty Point.
  /// 
  /// @param coordinates a CoordinateSequence (possibly empty), or null
  /// @return the created Point
  Point createPointFromCoordSeq(CoordinateSequence coordinates) {
  	return new Point(coordinates, this);
  }
  
  /// Constructs an empty {@link MultiLineString} geometry.
  /// 
  /// @return an empty MultiLineString
  // TODO: ruier edit. 不能为null，至少是一个空数组
  // MultiLineString createMultiLineString() {
  //   return new MultiLineString(null, this);
  // }

  /// Creates a MultiLineString using the given LineStrings; a null or empty
  /// array will create an empty MultiLineString.
  /// 
  /// @param lineStrings LineStrings, each of which may be empty but not null
  /// @return the created MultiLineString
  MultiLineString createMultiLineString(List<LineString> lineStrings) {
  	return new MultiLineString(lineStrings, this);
  }
  
  /// Constructs an empty {@link GeometryCollection} geometry.
  /// 
  /// @return an empty GeometryCollection
  // GeometryCollection createGeometryCollection() {
  //   return new GeometryCollection(null, this);
  // }

  /// Creates a GeometryCollection using the given Geometries; a null or empty
  /// array will create an empty GeometryCollection.
  /// 
  /// @param geometries an array of Geometries, each of which may be empty but not null, or null
  /// @return the created GeometryCollection
  GeometryCollection createGeometryCollection([List<Geometry>? geometries]) {
  	return new GeometryCollection(geometries, this);
  }
  
  /// Constructs an empty {@link MultiPolygon} geometry.
  /// 
  /// @return an empty MultiPolygon
  MultiPolygon createMultiPolygon() {
    return MultiPolygon(null, this);
  }

  /// Creates a MultiPolygon using the given Polygons; a null or empty array
  /// will create an empty Polygon. The polygons must conform to the
  /// assertions specified in the <A
  /// HREF="http://www.opengis.org/techno/specs.htm">OpenGIS Simple Features
  /// Specification for SQL</A>.
  ///
  /// @param polygons
  ///            Polygons, each of which may be empty but not null
  /// @return the created MultiPolygon
  MultiPolygon createMultiPolygon(List<Polygon> polygons) {
    return new MultiPolygon(polygons, this);
  }
  
  /// Constructs an empty {@link LinearRing} geometry.
  /// 
  /// @return an empty LinearRing
  LinearRing createLinearRingEmpty() {
    return createLinearRingFromCoordSeq(getCoordinateSequenceFactory().create(<Coordinate>[]));
  }

  /// Creates a {@link LinearRing} using the given {@link Coordinate}s.
  /// A null or empty array creates an empty LinearRing. 
  /// The points must form a closed and simple linestring. 
  /// @param coordinates an array without null elements, or an empty array, or null
  /// @return the created LinearRing
  /// @throws ArgumentError if the ring is not closed, or has too few points
  LinearRing createLinearRing(List<Coordinate> coordinates) {
    // return createLinearRingFromCoordSeq(coordinates != null ? getCoordinateSequenceFactory().create(coordinates) : null);
    return createLinearRingFromCoordSeq(getCoordinateSequenceFactory().create(coordinates));
  }

  /// Creates a {@link LinearRing} using the given {@link CoordinateSequence}. 
  /// A null or empty array creates an empty LinearRing. 
  /// The points must form a closed and simple linestring. 
  /// 
  /// @param coordinates a CoordinateSequence (possibly empty), or null
  /// @return the created LinearRing
  /// @throws ArgumentError if the ring is not closed, or has too few points
  LinearRing createLinearRingFromCoordSeq(CoordinateSequence coordinates) {
    return new LinearRing.FromCoordSeq(coordinates, this);
  }
  
  /// Constructs an empty {@link MultiPoint} geometry.
  /// 
  /// @return an empty MultiPoint
  MultiPoint createMultiPoint() {
    return new MultiPoint(null, this);
  }

  /// Creates a {@link MultiPoint} using the given {@link Point}s.
  /// A null or empty array will create an empty MultiPoint.
  ///
  /// @param point an array of Points (without null elements), or an empty array, or <code>null</code>
  /// @return a MultiPoint object
  MultiPoint createMultiPoint(List<Point> point) {
  	return new MultiPoint(point, this);
  }

  /// Creates a {@link MultiPoint} using the given {@link Coordinate}s.
  /// A null or empty array will create an empty MultiPoint.
  ///
  /// @param coordinates an array (without null elements), or an empty array, or <code>null</code>
  /// @return a MultiPoint object
  /// @deprecated Use {@link GeometryFactory#createMultiPointFromCoords} instead
  MultiPoint createMultiPoint(List<Coordinate> coordinates) {
      return createMultiPoint(coordinates != null
                              ? getCoordinateSequenceFactory().create(coordinates)
                              : null);
  }

  /// Creates a {@link MultiPoint} using the given {@link Coordinate}s.
  /// A null or empty array will create an empty MultiPoint.
  ///
  /// @param coordinates an array (without null elements), or an empty array, or <code>null</code>
  /// @return a MultiPoint object
  MultiPoint createMultiPointFromCoords(List<Coordinate> coordinates) {
      return createMultiPoint(coordinates != null
                              ? getCoordinateSequenceFactory().create(coordinates)
                              : null);
  }

  /// Creates a {@link MultiPoint} using the 
  /// points in the given {@link CoordinateSequence}.
  /// A <code>null</code> or empty CoordinateSequence creates an empty MultiPoint.
  ///
  /// @param coordinates a CoordinateSequence (possibly empty), or <code>null</code>
  /// @return a MultiPoint geometry
  MultiPoint createMultiPoint(CoordinateSequence coordinates) {
    if (coordinates == null) {
      return createMultiPoint(new Point[0]);
    }
   List<Point>points = new Point[coordinates.size()];
    for (int i = 0; i < coordinates.size(); i++) {
      CoordinateSequence ptSeq = getCoordinateSequenceFactory()
        .create(1, coordinates.getDimension(), coordinates.getMeasures());
      CoordinateSequences.copy(coordinates, i, ptSeq, 0, 1);
      points[i] = createPoint(ptSeq);
    }
    return createMultiPoint(points);
  }

  /// Constructs a <code>Polygon</code> with the given exterior boundary and
  /// interior boundaries.
  ///
  /// @param shell
  ///            the outer boundary of the new <code>Polygon</code>, or
  ///            <code>null</code> or an empty <code>LinearRing</code> if
  ///            the empty geometry is to be created.
  /// @param holes
  ///            the inner boundaries of the new <code>Polygon</code>, or
  ///            <code>null</code> or empty <code>LinearRing</code> s if
  ///            the empty geometry is to be created.
  /// @throws ArgumentError if a ring is invalid
  Polygon createPolygon(LinearRing shell, [List<LinearRing>? holes]) {
    return Polygon(shell, holes, this);
  }

  /// Constructs a <code>Polygon</code> with the given exterior boundary.
  ///
  /// @param shell
  ///            the outer boundary of the new <code>Polygon</code>, or
  ///            <code>null</code> or an empty <code>LinearRing</code> if
  ///            the empty geometry is to be created.
  /// @throws ArgumentError if the boundary ring is invalid
  Polygon createPolygonFromCoordSeq(CoordinateSequence shell) {
    return createPolygon(createLinearRingFromCoordSeq(shell));
  }

  /// Constructs a <code>Polygon</code> with the given exterior boundary.
  ///
  /// @param shell
  ///            the outer boundary of the new <code>Polygon</code>, or
  ///            <code>null</code> or an empty <code>LinearRing</code> if
  ///            the empty geometry is to be created.
  /// @throws ArgumentError if the boundary ring is invalid
  Polygon createPolygonFromCoords(List<Coordinate> shell) {
    return createPolygon(createLinearRing(shell));
  }

  /// Constructs a <code>Polygon</code> with the given exterior boundary.
  ///
  /// @param shell
  ///            the outer boundary of the new <code>Polygon</code>, or
  ///            <code>null</code> or an empty <code>LinearRing</code> if
  ///            the empty geometry is to be created.
  /// @throws ArgumentError if the boundary ring is invalid
  Polygon createPolygon(LinearRing shell) {
    return createPolygon(shell, null);
  }
  
  /// Constructs an empty {@link Polygon} geometry.
  /// 
  /// @return an empty polygon
  Polygon createPolygonEmpty() {
    return createPolygon(null, null);
  }

  ///  Build an appropriate <code>Geometry</code>, <code>MultiGeometry</code>, or
  ///  <code>GeometryCollection</code> to contain the <code>Geometry</code>s in
  ///  it.
  /// For example:<br>
  ///
  ///  <ul>
  ///    <li> If <code>geomList</code> contains a single <code>Polygon</code>,
  ///    the <code>Polygon</code> is returned.
  ///    <li> If <code>geomList</code> contains several <code>Polygon</code>s, a
  ///    <code>MultiPolygon</code> is returned.
  ///    <li> If <code>geomList</code> contains some <code>Polygon</code>s and
  ///    some <code>LineString</code>s, a <code>GeometryCollection</code> is
  ///    returned.
  ///    <li> If <code>geomList</code> is empty, an empty <code>GeometryCollection</code>
  ///    is returned
  ///  </ul>
  ///
  /// Note that this method does not "flatten" Geometries in the input, and hence if
  /// any MultiGeometries are contained in the input a GeometryCollection containing
  /// them will be returned.
  ///
  ///@param  geomList  the <code>Geometry</code>s to combine
  ///@return           a <code>Geometry</code> of the "smallest", "most
  ///      type-specific" class that can contain the elements of <code>geomList</code>
  ///      .
  Geometry buildGeometry(Collection geomList) {
  	
  	/**
  	 * Determine some facts about the geometries in the list
  	 */
    Class geomClass = null;
    bool isHeterogeneous = false;
    bool hasGeometryCollection = false;
    for (Iterator i = geomList.iterator(); i.hasNext(); ) {
      Geometry geom = (Geometry) i.next();
      Class partClass = geom.getClass();
      if (geomClass == null) {
        geomClass = partClass;
      }
      if (partClass != geomClass) {
        isHeterogeneous = true;
      }
      if (geom is GeometryCollection)
        hasGeometryCollection = true;
    }
    
    /**
     * Now construct an appropriate geometry to return
     */
    // for the empty geometry, return an empty GeometryCollection
    if (geomClass == null) {
      return createGeometryCollection();
    }
    if (isHeterogeneous || hasGeometryCollection) {
      return createGeometryCollection(toGeometryArray(geomList));
    }
    // at this point we know the collection is hetereogenous.
    // Determine the type of the result from the first Geometry in the list
    // this should always return a geometry, since otherwise an empty collection would have already been returned
    Geometry geom0 = (Geometry) geomList.iterator().next();
    bool isCollection = geomList.size() > 1;
    if (isCollection) {
      if (geom0 is Polygon) {
        return createMultiPolygon(toPolygonArray(geomList));
      }
      else if (geom0 is LineString) {
        return createMultiLineString(toLineStringArray(geomList));
      }
      else if (geom0 is Point) {
        return createMultiPoint(toPointArray(geomList));
      }
      Assert.shouldNeverReachHere("Unhandled class: " + geom0.getClass().getName());
    }
    return geom0;
  }
  
  /// Constructs an empty {@link LineString} geometry.
  /// 
  /// @return an empty LineString
  LineString createLineStringEmpty() {
    return createLineStringFromSeq(getCoordinateSequenceFactory().create(<Coordinate>[]));
  }

  /// Creates a LineString using the given Coordinates.
  /// A null or empty array creates an empty LineString. 
  /// 
  /// @param coordinates an array without null elements, or an empty array, or null
  LineString createLineString(List<Coordinate> coordinates) {
    // return createLineStringFromSeq(coordinates != null ? getCoordinateSequenceFactory().create(coordinates) : null);
    return createLineStringFromSeq(getCoordinateSequenceFactory().create(coordinates));
  }
  /// Creates a LineString using the given CoordinateSequence.
  /// A null or empty CoordinateSequence creates an empty LineString. 
  /// 
  /// @param coordinates a CoordinateSequence (possibly empty), or null
  LineString createLineStringFromSeq(CoordinateSequence coordinates) {
	return new LineString(coordinates, this);
  }

  /// Creates an empty atomic geometry of the given dimension.
  /// If passed a dimension of -1 will create an empty {@link GeometryCollection}.
  /// 
  /// @param dimension the required dimension (-1, 0, 1 or 2)
  /// @return an empty atomic geometry of given dimension
  Geometry createEmpty(int dimension) {
    switch (dimension) {
    case -1: return createGeometryCollection();
    case 0: return createPoint();
    case 1: return createLineString();
    case 2: return createPolygon();
    default:
      throw new ArgumentError("Invalid dimension: " + dimension);
    }
  }
  
  /// Creates a deep copy of the input {@link Geometry}.
  /// The {@link CoordinateSequenceFactory} defined for this factory
  /// is used to copy the {@link CoordinateSequence}s
  /// of the input geometry.
  /// <p>
  /// This is a convenient way to change the <tt>CoordinateSequence</tt>
  /// used to represent a geometry, or to change the 
  /// factory used for a geometry.
  /// <p>
  /// {@link Geometry#copy()} can also be used to make a deep copy,
  /// but it does not allow changing the CoordinateSequence type.
  /// 
  /// @return a deep copy of the input geometry, using the CoordinateSequence type of this factory
  /// 
  /// @see Geometry#copy() 
  Geometry createGeometry(Geometry g)
  {
    GeometryEditor editor = new GeometryEditor(this);
    return editor.edit(g, new CoordSeqCloneOp(coordinateSequenceFactory));
  }


  /// Gets the SRID value defined for this factory.
  /// 
  /// @return the factory SRID value
  int getSRID() {
    return SRID;
  }


  CoordinateSequenceFactory getCoordinateSequenceFactory() {
    return coordinateSequenceFactory;
  }

}


// TODO: ruier edit. 内部类
 /**private static*/ class CoordSeqCloneOp extends CoordinateSequenceOperation {
    CoordinateSequenceFactory coordinateSequenceFactory;
    CoordSeqCloneOp(CoordinateSequenceFactory coordinateSequenceFactory) {
      this.coordinateSequenceFactory = coordinateSequenceFactory;
    }
    CoordinateSequence edit(CoordinateSequence coordSeq, Geometry geometry) {
      return coordinateSequenceFactory.createFromCoordSeq(coordSeq);
    }
  }
