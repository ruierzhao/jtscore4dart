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


import 'package:jtscore4dart/src/geom/Coordinate.dart';

/// Coordinate subclass supporting XYZM ordinates.
/// <p>
/// This data object is suitable for use with coordinate sequences with <tt>dimension</tt> = 4 and <tt>measures</tt> = 1.
///
/// @since 1.16
class CoordinateXYZM extends Coordinate {
  // private static final long serialVersionUID = -8763329985881823442L;

  /// Default constructor
  CoordinateXYZM.empty():_m = 0.0,super.empty2D(); 

  /// Constructs a CoordinateXYZM instance with the given ordinates and measure.
  /// 
  /// @param x the X ordinate
  /// @param y the Y ordinate
  /// @param z the Z ordinate
  /// @param m the M measure value
  CoordinateXYZM(double x, double y, double z,  this._m):super(x, y, z);


  /// Constructs a CoordinateXYZM instance with the ordinates of the given Coordinate.
  /// 
  /// @param coord the coordinate providing the ordinates
  CoordinateXYZM.fromCoord(Coordinate coord) {
    super(coord);
    _m = getM();
  }
  
  /// Constructs a CoordinateXYZM instance with the ordinates of the given CoordinateXYZM.
  /// 
  /// @param coord the coordinate providing the ordinates
  CoordinateXYZM(CoordinateXYZM coord) {
    super(coord);
    _m = coord._m;
  }

  /// Creates a copy of this CoordinateXYZM.
  /// 
  /// @return a copy of this CoordinateXYZM
  CoordinateXYZM copy() {
    return new CoordinateXYZM(this);
  }
  
  /// Create a new Coordinate of the same type as this Coordinate, but with no values.
  /// 
  /// @return a new Coordinate
  // TODO: ruier edit.
  // @override
  // Coordinate create() {
  //     return new CoordinateXYZM();
  // }

  /// The m-measure.
  double _m;

  /// The m-measure, if available.
  double getM() {
    return _m;
  }

  void setM(double m) {
    this._m = m;
  }

  double getOrdinate(int ordinateIndex)
  {
    switch (ordinateIndex) {
    case X: return x;
    case Y: return y;
    case Z: return getZ(); // sure to delegate to subclass rather than offer direct field access
    case M: return getM(); // sure to delegate to subclass rather than offer direct field access
    }
    throw new ArgumentError("Invalid ordinate index: " + ordinateIndex);
  }
  
  @override
  void setCoordinate(Coordinate other)
  {
    x = other.x;
    y = other.y;
    z = other.getZ();
    _m = other.getM();
  }
  
  @override
  void setOrdinate(int ordinateIndex, double value) {
      switch (ordinateIndex) {
      case X:
        x = value;
        break;
      case Y:
        y = value;
        break;
      case Z:
        z = value;
        break;
      case M:
        _m = value;
        break;
      default:
        throw new ArgumentError("Invalid ordinate index: " + ordinateIndex);
    }
  }
  
  String toString() {
    return "(" + x + ", " + y + ", " + getZ() + " m="+getM()+")";
  }
}
