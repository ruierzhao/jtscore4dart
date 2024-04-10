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

// import org.locationtech.jts.geom.Coordinate;
// import org.locationtech.jts.geom.CoordinateSequence;
// import org.locationtech.jts.geom.Geometry;
// import org.locationtech.jts.geom.GeometryCollection;
// import org.locationtech.jts.geom.GeometryFactory;
// import org.locationtech.jts.geom.LineString;
// import org.locationtech.jts.geom.LinearRing;
// import org.locationtech.jts.geom.MultiLineString;
// import org.locationtech.jts.geom.MultiPoint;
// import org.locationtech.jts.geom.MultiPolygon;
// import org.locationtech.jts.geom.Point;
// import org.locationtech.jts.geom.Polygon;
// import org.locationtech.jts.util.Assert;


import 'package:jtscore4dart/geometry.dart';
import 'package:jtscore4dart/src/patch/ArrayList.dart';
import 'package:jtscore4dart/src/util/Assert.dart';

/// A class which supports creating new {@link Geometry}s 
/// which are modifications of existing ones,
/// maintaining the same type structure.
/// Geometry objects are intended to be treated as immutable.
/// This class "modifies" Geometrys
/// by traversing them, applying a user-defined
/// {@link GeometryEditorOperation}, {@link CoordinateSequenceOperation} or {@link CoordinateOperation}  
/// and creating new Geometrys with the same structure but
/// (possibly) modified components.
/// <p>
/// Examples of the kinds of modifications which can be made are:
/// <ul>
/// <li>the values of the coordinates may be changed.
///     The editor does not check whether changing coordinate values makes the result Geometry invalid
/// <li>the coordinate lists may be changed
///     (e.g. by adding, deleting or modifying coordinates).
///     The modified coordinate lists must be consistent with their original parent component
///     (e.g. a <tt>LinearRing</tt> must always have at least 4 coordinates, and the first and last
///     coordinate must be equal)
/// <li>components of the original geometry may be deleted
///    (e.g. holes may be removed from a Polygon, or LineStrings removed from a MultiLineString).
///     Deletions will be propagated up the component tree appropriately.
/// </ul>
/// All changes must be consistent with the original Geometry's structure
/// (e.g. a <tt>Polygon</tt> cannot be collapsed into a <tt>LineString</tt>).
/// If changing the structure is required, use a {@link GeometryTransformer}.
/// <p>
/// This class supports creating an edited Geometry
/// using a different <code>GeometryFactory</code> via the {@link #GeometryEditor(GeometryFactory)}
/// constructor.  
/// Examples of situations where this is required is if the geometry is 
/// transformed to a new SRID and/or a new PrecisionModel.
/// <p>
/// <b>Usage Notes</b>
/// <ul>
/// <li>The resulting Geometry is not checked for validity.
/// If validity needs to be enforced, the new Geometry's 
/// {@link Geometry#isValid} method should be called.
/// <li>By default the UserData of the input geometry is not copied to the result.
/// </ul>
/// 
/// @see GeometryTransformer
/// @see Geometry#isValid
///
/// @version 1.7
class GeometryEditor
{
  /// The factory used to create the modified Geometry.
  /// If <tt>null</tt> the GeometryFactory of the input is used.
  GeometryFactory? _factory;
  bool _isUserDataCopied = false;

  /// Creates a new GeometryEditor object which will create
  /// edited {@link Geometry}s with the same {@link GeometryFactory} as the input Geometry.
  // GeometryEditor()
  // {
  // }

  /// Creates a new GeometryEditor object which will create
  /// edited {@link Geometry}s with the given {@link GeometryFactory}.
  ///
  /// @param factory the GeometryFactory to create  edited Geometrys with
  GeometryEditor([this._factory]);

  /// 
  /// Sets whether the User Data is copied to the edit result.
  /// Only the object reference is copied.
  /// 
  /// @param isUserDataCopied true if the input user data should be copied.
  void setCopyUserData(bool isUserDataCopied)
  {
    this._isUserDataCopied = isUserDataCopied;
  }
  
  /// Edit the input {@link Geometry} with the given edit operation.
  /// Clients can create subclasses of {@link GeometryEditorOperation} or
  /// {@link CoordinateOperation} to perform required modifications.
  ///
  /// @param [geometry] the Geometry to edit
  /// @param [operation] the edit operation to carry out
  /// @return a new {@link Geometry} which is the result of the editing (which may be empty)
  Geometry edit(Geometry geometry, GeometryEditorOperation operation)
  {
    // nothing to do
    // TODO: ruier edit.
    // if (geometry == null) return null;
    
    Geometry result = editInternal(geometry, operation)!;
    if (_isUserDataCopied) {
      result.setUserData(geometry.getUserData());
    }
    return result;
  }
  
 /**private */Geometry? editInternal(Geometry geometry, GeometryEditorOperation operation)
  {
    // if client did not supply a GeometryFactory, use the one from the input Geometry
    _factory ??= geometry.getFactory();

    if (geometry is GeometryCollection) {
      return editGeometryCollection( geometry, operation);
    }

    if (geometry is Polygon) {
      return editPolygon( geometry, operation);
    }

    if (geometry is Point) {
      return operation.edit(geometry, _factory!);
    }

    if (geometry is LineString) {
      return operation.edit(geometry, _factory!);
    }

    // Assert.shouldNeverReachHere("Unsupported Geometry class: " + geometry.getClass().getName());
    Assert.shouldNeverReachHere("Unsupported Geometry class:  ${geometry.runtimeType}");
    return null;
  }

 /**private */Polygon editPolygon(Polygon polygon, GeometryEditorOperation operation) {
    Polygon? newPolygon = operation.edit(polygon, _factory!) as Polygon?;
    // create one if needed
    newPolygon ??= _factory!.createPolygon();
    if (newPolygon.isEmpty()) {
      //RemoveSelectedPlugIn relies on this behaviour. [Jon Aquino]
      return newPolygon;
    }

    LinearRing? shell = edit(newPolygon.getExteriorRing(), operation) as LinearRing?;
    if (shell == null || shell.isEmpty()) {
      //RemoveSelectedPlugIn relies on this behaviour. [Jon Aquino]
      return _factory!.createPolygon();
    }

    List<LinearRing> holes = [];
    for (int i = 0; i < newPolygon.getNumInteriorRing(); i++) {
      LinearRing? hole = edit(newPolygon.getInteriorRingN(i), operation) as LinearRing?;
      if (hole == null || hole.isEmpty()) {
        continue;
      }
      holes.add(hole);
    }

    return _factory!.createPolygon(shell, holes);
  }

 /**private */
 GeometryCollection editGeometryCollection(GeometryCollection collection, GeometryEditorOperation operation) {
    // first edit the entire collection
    // MD - not sure why this is done - could just check original collection?
    GeometryCollection collectionForType = operation.edit(collection, _factory!) as GeometryCollection;
    
    // edit the component geometries
    List<Geometry> geometries = [];
    for (int i = 0; i < collectionForType.getNumGeometries(); i++) {
      Geometry geometry = edit(collectionForType.getGeometryN(i), operation);
      if (geometry == null || geometry.isEmpty()) {
        continue;
      }
      geometries.add(geometry);
    }

    // if (collectionForType.getClass() == MultiPoint.class) {
    if (collectionForType.runtimeType == MultiPoint) {
      // return factory.createMultiPoint(geometries.toArray(new Point[] {  }));
      return _factory!.createMultiPointFromPoints(geometries as List<Point>);
    }
    if (collectionForType.runtimeType == MultiLineString) {
      return _factory!.createMultiLineString(geometries.toList(growable: false) as List<LineString>);
    }
    if (collectionForType.runtimeType == MultiPolygon) {
      return _factory!.createMultiPolygon( geometries.toArray() as List<Polygon>);
    }
    return _factory!.createGeometryCollection( geometries.toArray());
  }

  
}

  /**
   * A abstract class which specifies an edit operation for Geometries.
   *
   * @version 1.7
   */
  abstract class GeometryEditorOperation
  {
    /**
     * Edits a Geometry by returning a new Geometry with a modification.
     * The returned geometry may be:
     * <ul>
     * <li>the input geometry itself.
     * The returned Geometry might be the same as the Geometry passed in.
     * <li><code>null</code> if the geometry is to be deleted.
     * </ul>
     *
     * @param geometry the Geometry to modify
     * @param factory the factory with which to construct the modified Geometry
     * (may be different to the factory of the input geometry)
     * @return a new Geometry which is a modification of the input Geometry
     * @return null if the Geometry is to be deleted completely
     */
    Geometry? edit(Geometry geometry, GeometryFactory factory);
    /// TODO: @ruier edit.
    // Geometry edit(var geometry, GeometryFactory factory);
  }


  /**
   * 修改属性，不修改坐标
   * 
   * A GeometryEditorOperation which does not modify
   * the input geometry.
   * This can be used for simple changes of 
   * GeometryFactory (including PrecisionModel and SRID).
   * 
   * @author mbdavis
   *
   */
class NoOpGeometryOperation implements GeometryEditorOperation
  {
  @override
  Geometry edit(Geometry geometry, GeometryFactory factory)
  	{
  		return geometry;
  	}
  }
  /**
   * A {@link GeometryEditorOperation} which edits the coordinate list of a {@link Geometry}.
   * Operates on Geometry subclasses which contains a single coordinate list.
   */
  abstract class CoordinateOperation implements GeometryEditorOperation
  {
    /**final */ 
    @override
    Geometry edit(Geometry geometry, GeometryFactory factory) {
      if (geometry is LinearRing) {
        return factory.createLinearRing(editCoord(geometry.getCoordinates(), geometry));
      }

      if (geometry is LineString) {
        return factory.createLineString(editCoord(geometry.getCoordinates(),geometry));
      }

      if (geometry is Point) {
        List<Coordinate> newCoordinates = editCoord(geometry.getCoordinates(),geometry);

        return factory.createPoint((newCoordinates.isNotEmpty) ? newCoordinates[0] : null);
      }

      return geometry;
    }

    /**
     * Edits the array of {@link Coordinate}s from a {@link Geometry}.
     * <p>
     * If it is desired to preserve the immutability of Geometrys,
     * if the coordinates are changed a new array should be created
     * and returned.
     *
     * @param coordinates the coordinate array to operate on
     * @param geometry the geometry containing the coordinate list
     * @return an edited coordinate array (which may be the same as the input)
     */
    // List<Coordinate> edit(List<Coordinate> coordinates, Geometry geometry);
    List<Coordinate> editCoord(List<Coordinate> coordinates, Geometry geometry);
  }
  

  /**
   * A {@link GeometryEditorOperation} which edits the {@link CoordinateSequence}
   * of a {@link Geometry}.
   * Operates on Geometry subclasses which contains a single coordinate list.
   */
  /**abstract static */ 
abstract class CoordinateSequenceOperation extends GeometryEditorOperation
  {
  @override
  Geometry edit(Geometry geometry, GeometryFactory factory) {
      if (geometry is LinearRing) {
        return factory.createLinearRingFromCoordSeq(editCoordSeq(
            geometry.getCoordinateSequence(),
            geometry));
      }

      if (geometry is LineString) {
        return factory.createLineStringFromSeq(editCoordSeq(
            (geometry).getCoordinateSequence(),
            geometry));
      }

      if (geometry is Point) {
        return factory.createPointFromCoordSeq(editCoordSeq(
            (geometry).getCoordinateSequence(),
            geometry));
      }

      return geometry;
    }

    /**
     * Edits a {@link CoordinateSequence} from a {@link Geometry}.
     *
     * @param coordSeq the coordinate array to operate on
     * @param geometry the geometry containing the coordinate list
     * @return an edited coordinate sequence (which may be the same as the input)
     */
    /**abstract */ 
  // CoordinateSequence edit(CoordinateSequence coordSeq,Geometry geometry);
  CoordinateSequence editCoordSeq(CoordinateSequence coordSeq,Geometry geometry);
  }
