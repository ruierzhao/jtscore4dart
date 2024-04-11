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

// import org.locationtech.jts.geom.Coordinate;
// import org.locationtech.jts.geom.CoordinateArrays;
// import org.locationtech.jts.geom.CoordinateSequence;
// import org.locationtech.jts.geom.Coordinates;
// import org.locationtech.jts.geom.Envelope;
// import org.locationtech.jts.geom.Geometry;

import 'package:jtscore4dart/src/geom/Coordinate.dart';
import 'package:jtscore4dart/src/geom/CoordinateArrays.dart';
import 'package:jtscore4dart/src/geom/CoordinateSequence.dart';
import 'package:jtscore4dart/src/geom/Coordinates.dart';
import 'package:jtscore4dart/src/geom/Envelope.dart';

/// A {@link CoordinateSequence} backed by an array of {@link Coordinate}s.
/// This is the implementation that {@link Geometry}s use by default.
/// Coordinates returned by #toArray and #getCoordinate are live --
/// modifications to them are actually changing the
/// CoordinateSequence's underlying data.
/// A dimension may be specified for the coordinates in the sequence,
/// which may be 2 or 3.
/// The actual coordinates will always have 3 ordinates,
/// but the dimension is useful as metadata in some situations. 
///
/// @version 1.7
class CoordinateArraySequence extends CoordinateSequence{
  //With contributions from Markus Schaber [schabios@logi-track.com] 2004-03-26
  ///**private */static final int serialVersionUID = -915438501601840650L;

  /// The actual dimension of the coordinates in the sequence.
  /// Allowable values are 2, 3 or 4.
  int _dimension = 3;
  /// The number of measures of the coordinates in the sequence.
  /// Allowable values are 0 or 1.
  int _measures = 0;
  
  late List<Coordinate> _coordinates;

  /// Constructs a sequence based on the given array
  /// of {@link Coordinate}s (the
  /// array is not copied).
  /// The coordinate dimension defaults to 3.
  ///
  /// @param coordinates the coordinate array that will be referenced.
  // CoordinateArraySequence(List<Coordinate> coordinates)
  // {
  //   this(coordinates, CoordinateArrays.dimension(coordinates), CoordinateArrays.measures(coordinates));
  // }

  /// Constructs a sequence based on the given array 
  /// of {@link Coordinate}s (the
  /// array is not copied).
  ///
  /// @param coordinates the coordinate array that will be referenced.
  /// @param dimension the dimension of the coordinates
  // CoordinateArraySequence(List<Coordinate> coordinates, int dimension) {
  //   this(coordinates, dimension, CoordinateArrays.measures(coordinates));    
  // }
  
  /// Constructs a sequence based on the given array 
  /// of {@link Coordinate}s (the array is not copied).
  /// <p>
  /// It is your responsibility to ensure the array contains Coordinates of the
  /// indicated dimension and measures (See 
  /// {@link CoordinateArrays#enforceConsistency(List<Coordinate>)} ).</p>
  ///
  /// @param coordinates the coordinate array that will be referenced.
  /// @param dimension the dimension of the coordinates
  // CoordinateArraySequence(List<Coordinate> coordinates, int dimension, int measures)
  // {
  //   this._dimension = dimension;
  //   this._measures = measures;
  //   if (coordinates == null) {
  //     this._coordinates = new Coordinate[0];
  //   }
  //   else {
  //     this._coordinates = coordinates;
  //   }
  // }
  // TODO: ruier edit.
  /// TODO: @ruier edit.coordinates can not be null,so getCoordinate can not be null.
  CoordinateArraySequence(List<Coordinate> coordinates, [int? dimension, int? measures]){
    _coordinates = coordinates;
    dimension ??= CoordinateArrays.dimension(coordinates);
    measures ??= CoordinateArrays.measures(coordinates);
    _dimension = dimension;
    _measures = measures;
  }

  /// Constructs a sequence of a given size, populated
  /// with new {@link Coordinate}s.
  ///
  /// @param size the size of the sequence to create
  // CoordinateArraySequence.init(int size) {
  //   _coordinates = List<Coordinate>.filled(size, Coordinate.empty2D());
  // }

  /// Constructs a sequence of a given size, populated
  /// with new {@link Coordinate}s.
  ///
  /// @param size the size of the sequence to create
  /// @param dimension the dimension of the coordinates
  CoordinateArraySequence.init(int size, [int? dimension]) {
    if (dimension == null) {
      _coordinates = List<Coordinate>.filled(size, Coordinate.empty2D());
    }else{
      // _coordinates = new Coordinate[size];
      _coordinates = List.filled(size, Coordinate.empty2D(),growable: false);
      _dimension = dimension;
      for (int i = 0; i < size; i++) {
        _coordinates[i] = Coordinates.create(dimension);
      }
    }

  }
  /// Constructs a sequence of a given size, populated
  /// with new {@link Coordinate}s.
  ///
  /// @param size the size of the sequence to create
  /// @param dimension the dimension of the coordinates
  CoordinateArraySequence.init2(int size, int dimension,int measures) {
    // _coordinates = new Coordinate[size];
    _coordinates = List.filled(size, Coordinate.empty2D(), growable: false);

    _dimension = dimension;
    _measures = measures;
    for (int i = 0; i < size; i++) {
      _coordinates[i] = createCoordinate();
    }
  }

  /// Creates a new sequence based on a deep copy of the given {@link CoordinateSequence}.
  /// The coordinate dimension is set to equal the dimension of the input.
  ///
  /// @param coordSeq the coordinate sequence that will be copied.
  CoordinateArraySequence.fromAnother(CoordinateSequence coordSeq)
  {
    // NOTE: this will make a sequence of the default dimension
    // if (coordSeq == null) {
    //   _coordinates = [];
    //   return;
    // }
    _dimension = coordSeq.getDimension();
    _measures = coordSeq.getMeasures();    
    _coordinates = List.generate(coordSeq.size(), (i) => coordSeq.getCoordinateCopy(i)) ;

    // for (int i = 0; i < _coordinates.length; i++) {
    //   _coordinates[i] = coordSeq.getCoordinateCopy(i);
    // }
  }

  /// @see org.locationtech.jts.geom.CoordinateSequence#getDimension()
  @override
  int getDimension()
  {
    return _dimension;
  }
  
  @override
  int getMeasures()
  {
    return _measures;
  }

  /// Get the Coordinate with index i.
  ///
  /// @param i
  ///                  the index of the coordinate
  /// @return the requested Coordinate instance
  @override
  Coordinate getCoordinate(int i) {
    return _coordinates[i];
  }

  /// Get a copy of the Coordinate with index i.
  ///
  /// @param i  the index of the coordinate
  /// @return a copy of the requested Coordinate
  @override
  Coordinate getCoordinateCopy(int i) {
    Coordinate copy = createCoordinate();
    copy.setCoordinate(_coordinates[i]);
    return copy;
  }

  /// @see org.locationtech.jts.geom.CoordinateSequence#getX(int)
  @override
  void getCoordinateTo(int index, Coordinate coord) {
    coord.setCoordinate(_coordinates[index]);
  }

  /// @see org.locationtech.jts.geom.CoordinateSequence#getX(int)
  @override
  double getX(int index) {
    return _coordinates[index].x;
  }

  /// @see org.locationtech.jts.geom.CoordinateSequence#getY(int)
  @override
  double getY(int index) {
    return _coordinates[index].y;
  }

  /// @see org.locationtech.jts.geom.CoordinateSequence#getZ(int)
  @override
  double getZ(int index)
  {
    if (hasZ()) {
      return _coordinates[index].getZ();
    } else {
      return double.nan;
    }

  }
  
  /// @see org.locationtech.jts.geom.CoordinateSequence#getM(int)
  @override
  double getM(int index) {
    if (hasM()) {
      return _coordinates[index].getM();
    }
    else {
        return double.nan;
    }    
  }
  
  /// @see org.locationtech.jts.geom.CoordinateSequence#getOrdinate(int, int)
  @override
  double getOrdinate(int index, int ordinateIndex)
  {
    switch (ordinateIndex) {
      case CoordinateSequence.X:  return _coordinates[index].x;
      case CoordinateSequence.Y:  return _coordinates[index].y;
      default:
	      return _coordinates[index].getOrdinate(ordinateIndex)!;
    }
  }

  /// Creates a deep copy of the Object
  ///
  /// @return The deep copy
  /// @deprecated
  @override
  Object clone() {
    return copy();
  }
  /// Creates a deep copy of the CoordinateArraySequence
  ///
  /// @return The deep copy
  // TODO: ruier edit.
  @override
  CoordinateArraySequence copy() {
    // TODO: ruier replace.
    List<Coordinate> cloneCoordinates = List<Coordinate>.generate(size(),(index) {
      Coordinate duplicate = createCoordinate();
      duplicate.setCoordinate(_coordinates[index]);
      return duplicate;
    });
    // List<Coordinate> cloneCoordinates = Coordinate[size()];
    // for (int i = 0; i < _coordinates.length; i++) {
    //   Coordinate duplicate = createCoordinate();
    //   duplicate.setCoordinate(_coordinates[i]);
    //   cloneCoordinates[i] = duplicate;
    // }
    return CoordinateArraySequence(cloneCoordinates, _dimension, _measures);
  }

  /// Returns the size of the coordinate sequence
  ///
  /// @return the number of coordinates
  @override
  int size() {
    return _coordinates.length;
  }

  /// @see org.locationtech.jts.geom.CoordinateSequence#setOrdinate(int, int, double)
  @override
  void setOrdinate(int index, int ordinateIndex, double value)
  {
    switch (ordinateIndex) {
      case CoordinateSequence.X:
        _coordinates[index].x = value;
        break;
      case CoordinateSequence.Y:
        _coordinates[index].y = value;
        break;
      default:
        _coordinates[index].setOrdinate(ordinateIndex, value);
    }
  }

  /// This method exposes the internal Array of Coordinate Objects
  ///
  /// @return the List<Coordinate> array.
  @override
  List<Coordinate> toCoordinateArray() {
    return _coordinates;
  }

  @override
  Envelope expandEnvelope(Envelope env)
  {
    for (int i = 0; i < _coordinates.length; i++ ) {
      env.expandToIncludeCoordinate(_coordinates[i]);
    }
    return env;
  }
  
  /// Returns the string Representation of the coordinate array
  ///
  /// @return The string
  // TODO: ruier edit.
  @override
  String toString() {
    if (_coordinates.isNotEmpty) {
      StringBuffer strBuilder = new StringBuffer(17 * _coordinates.length);
      strBuilder.write('(');
      strBuilder.write(_coordinates[0]);
      for (int i = 1; i < _coordinates.length; i++) {
        strBuilder.write(", ");
        strBuilder.write(_coordinates[i]);
      }
      strBuilder.write(')');
      return strBuilder.toString();
    } else {
      return "()";
    }
  }
}
