// ignore_for_file: unnecessary_new

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
// import org.locationtech.jts.geom.CoordinateSequence;
// import org.locationtech.jts.geom.CoordinateSequenceFactory;
// import org.locationtech.jts.geom.Coordinates;

import 'package:jtscore4dart/src/geom/Coordinate.dart';

import 'package:jtscore4dart/src/geom/CoordinateSequence.dart';
import 'package:jtscore4dart/src/geom/Coordinates.dart';

import '../CoordinateSequenceFactory.dart';
import 'PackedCoordinateSequence.dart';

/// Builds packed array coordinate sequences. 
/// The array data type can be either
/// <code>double</code> or <code>float</code>, 
/// and defaults to <code>double</code>.
class PackedCoordinateSequenceFactory implements
    CoordinateSequenceFactory
{
//  /**private */static final int serialVersionUID = -3558264771905224525L;
  
  /// Type code for arrays of type <code>double</code>.
  static const int DOUBLE = 0;
  
  /// Type code for arrays of type <code>float</code>.
  static const int FLOAT = 1;

  /// A factory using array type {@link #DOUBLE}
  static final PackedCoordinateSequenceFactory DOUBLE_FACTORY =
      new PackedCoordinateSequenceFactory(DOUBLE);
  
  /// A factory using array type {@link #FLOAT}
  static final PackedCoordinateSequenceFactory FLOAT_FACTORY =
      new PackedCoordinateSequenceFactory(FLOAT);

 static final int DEFAULT_MEASURES = 0;

 static final int DEFAULT_DIMENSION = 3;

  final int _type;

  /// Creates a new PackedCoordinateSequenceFactory
  /// of type DOUBLE.
  // PackedCoordinateSequenceFactory(){
  //   this(DOUBLE);
  // }

  /// Creates a new PackedCoordinateSequenceFactory
  /// of the given type.
  /// Acceptable type values are
  /// {@linkplain PackedCoordinateSequenceFactory#FLOAT}or
  /// {@linkplain PackedCoordinateSequenceFactory#DOUBLE}
  PackedCoordinateSequenceFactory([this._type=DOUBLE]);

  /// Gets the type of packed coordinate sequence this factory builds, either
  /// {@linkplain PackedCoordinateSequenceFactory#FLOAT} or
  /// {@linkplain PackedCoordinateSequenceFactory#DOUBLE}
  /// 
  /// @return the type of packed array built
  int getType() {
    return _type;
  }

  /// @see CoordinateSequenceFactory#create(List<Coordinate>)
  @override
  CoordinateSequence createFromListCoord(List<Coordinate> coordinates) {
    int dimension = DEFAULT_DIMENSION;
    int measures = DEFAULT_MEASURES;
    if (coordinates != null && coordinates.length > 0 && coordinates[0] != null) {
      Coordinate first = coordinates[0];
      dimension = Coordinates.dimension(first);
      measures = Coordinates.measures(first);
    }
    if (_type == DOUBLE) {
      return new PackedCoordinateSequence.Double(coordinates, dimension, measures);
    } else {
      return new PackedCoordinateSequence.Float(coordinates,  dimension, measures);
    }
  }

  /// @see CoordinateSequenceFactory#create(CoordinateSequence)
  @override
  CoordinateSequence createFromAnother(CoordinateSequence coordSeq) {
    int dimension = coordSeq.getDimension();
    int measures = coordSeq.getMeasures();
    if (_type == DOUBLE) {
      return new PackedCoordinateSequence.Double(coordSeq.toCoordinateArray(), dimension, measures);
    } else {
      return new PackedCoordinateSequence.Float(coordSeq.toCoordinateArray(), dimension, measures);
    }
  }

  /// Creates a packed coordinate sequence of type {@link #DOUBLE}
  /// from the provided array
  /// using the given coordinate dimension and a measure count of 0. 
  /// 
  /// @param packedCoordinates the array containing coordinate values
  /// @param dimension the coordinate dimension
  /// @return a packed coordinate sequence of type {@link #DOUBLE}
  @override
  CoordinateSequence create(double[] packedCoordinates, int dimension) {
    return create( packedCoordinates, dimension, DEFAULT_MEASURES );
  }
  
  /// Creates a packed coordinate sequence of type {@link #DOUBLE}
  /// from the provided array
  /// using the given coordinate dimension and measure count. 
  /// 
  /// @param packedCoordinates the array containing coordinate values
  /// @param dimension the coordinate dimension
  /// @param measures the coordinate measure count
  /// @return a packed coordinate sequence of type {@link #DOUBLE}
  @override
  CoordinateSequence create(double[] packedCoordinates, int dimension, int measures) {
    if (_type == DOUBLE) {
      return new PackedCoordinateSequence.Double(packedCoordinates, dimension, measures);
    } else {
      return new PackedCoordinateSequence.Float(packedCoordinates, dimension, measures);
    }
  }
  /// Creates a packed coordinate sequence of type {@link #FLOAT}
  /// from the provided array. 
  /// 
  /// @param packedCoordinates the array containing coordinate values
  /// @param dimension the coordinate dimension
  /// @return a packed coordinate sequence of type {@link #FLOAT}
  @override
  CoordinateSequence create(float[] packedCoordinates, int dimension) {
    return create( packedCoordinates, dimension, math.max(DEFAULT_MEASURES, dimension-3) );
  }
  
  /// Creates a packed coordinate sequence of type {@link #FLOAT}
  /// from the provided array. 
  /// 
  /// @param packedCoordinates the array containing coordinate values
  /// @param dimension the coordinate dimension
  /// @param measures the coordinate measure count
  /// @return a packed coordinate sequence of type {@link #FLOAT}
  @override
  CoordinateSequence create(float[] packedCoordinates, int dimension, int measures) {
    if (_type == DOUBLE) {
      return new PackedCoordinateSequence.Double(packedCoordinates, dimension, measures);
    } else {
      return new PackedCoordinateSequence.Float(packedCoordinates, dimension, measures);
    }
  }

  /// @see org.locationtech.jts.geom.CoordinateSequenceFactory#create(int, int)
  @override
  CoordinateSequence createBySize(int size, int dimension) {
    if (_type == DOUBLE) {
      return new PackedCoordinateSequence.Double(
              size, dimension, math.max(DEFAULT_MEASURES, dimension-3));
    } else {
      return new PackedCoordinateSequence.Float(
              size, dimension, math.max(DEFAULT_MEASURES, dimension-3));
    }
  }
  
  /// @see org.locationtech.jts.geom.CoordinateSequenceFactory#create(int, int, int)
  @override
  CoordinateSequence create(int size, int dimension, int measures) {
    if (_type == DOUBLE) {
      return new PackedCoordinateSequence.Double(size, dimension, measures);
    } else {
      return new PackedCoordinateSequence.Float(size, dimension, measures);
    }
  }


}
