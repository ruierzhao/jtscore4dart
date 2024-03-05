/*
 * Copyright (c) 2018 Vivid Solutions
 *
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License 2.0
 * and Eclipse Distribution License v. 1.0 which accompanies this distribution.
 * The Eclipse Public License is available at http://www.eclipse.org/legal/epl-v20.html
 * and the Eclipse Distribution License is available at
 *
 * http://www.eclipse.org/org/documents/edl-v10.php.
 */

import 'package:jtscore4dart/src/geom/Coordinate.dart';

/// Coordinate subclass supporting XY ordinates.
/// <p>
/// This data object is suitable for use with coordinate sequences with <tt>dimension</tt> = 2.
/// <p>
/// The {@link Coordinate#z} field is visible, but intended to be ignored.
///
/// @since 1.16
class CoordinateXY extends Coordinate {
  ///**private */static final int serialVersionUID = 3532307803472313082L;

  /// Standard ordinate index value for X
  static const int X = 0;

  /// Standard ordinate index value for Y
  static const int Y = 1;

  /// CoordinateXY does not support Z values.
  static const int Z = -1;

  /// CoordinateXY does not support M measures.
  static const int M = -1;

  /// Default constructor
  CoordinateXY.empty() : super.empty2D();

  /// Constructs a CoordinateXY instance with the given ordinates.
  ///
  /// @param x the X ordinate
  /// @param y the Y ordinate
  CoordinateXY(double x, double y) : super(x, y, Coordinate.NULL_ORDINATE);

  /// Constructs a CoordinateXY instance with the x and y ordinates of the given Coordinate.
  ///
  /// @param coord the Coordinate providing the ordinates
  CoordinateXY.fromCoord(Coordinate coord) : super(coord.x, coord.y);

  /// Constructs a CoordinateXY instance with the x and y ordinates of the given CoordinateXY.
  ///
  /// @param coord the CoordinateXY providing the ordinates
  CoordinateXY.fromAnother(CoordinateXY coord) : super(coord.x, coord.y);

  /// Creates a copy of this CoordinateXY.
  ///
  /// @return a copy of this CoordinateXY
  @override
  CoordinateXY copy() {
    return CoordinateXY.fromAnother(this);
  }

  /// Create a new Coordinate of the same type as this Coordinate, but with no values.
  ///
  /// @return a new Coordinate
  // TODO: ruier edit.
  // @Override
  Coordinate create() {
    return CoordinateXY.empty();
  }

  /// The z-ordinate is not supported
  @override
  double getZ() {
    return Coordinate.NULL_ORDINATE;
  }

  /// The z-ordinate is not supported
  @override
  void setZ(double z) {
    throw ArgumentError(
        "CoordinateXY dimension 2 does not support z-ordinate");
  }

  @override
  void setCoordinate(Coordinate other) {
    x = other.x;
    y = other.y;
    z = other.getZ();
  }

  @override
  double getOrdinate(int ordinateIndex) {
    switch (ordinateIndex) {
      case Coordinate.X:
        return x;
      case Coordinate.Y:
        return y;
    }
    return double.nan;
    // disable for now to avoid regression issues
    //throw new ArgumentError("Invalid ordinate index: " + ordinateIndex);
  }

  @override
  void setOrdinate(int ordinateIndex, double value) {
    switch (ordinateIndex) {
      case Coordinate.X:
        x = value;
        break;
      case Coordinate.Y:
        y = value;
        break;
      default:
        throw ArgumentError("Invalid ordinate index: $ordinateIndex");
    }
  }

    String toString() {
    return "($x, $y)";
  }
}
