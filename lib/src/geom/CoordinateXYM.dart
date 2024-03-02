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


/// Coordinate subclass supporting XYM ordinates.
/// <p>
/// This data object is suitable for use with coordinate sequences with <tt>dimension</tt> = 3 and <tt>measures</tt> = 1.
/// <p>
/// The {@link Coordinate#z} field is visible, but intended to be ignored.
/// 
/// @since 1.16
class CoordinateXYM extends Coordinate {
  private static final long serialVersionUID = 2842127537691165613L;

  /// Standard ordinate index value for X
  static final int X = 0;

  /// Standard ordinate index value for Y
  static final int Y = 1;

  /// CoordinateXYM does not support Z values.
  static final int Z = -1;

  /// Standard ordinate index value for M in XYM sequences.
  ///
  /// <p>This constant assumes XYM coordinate sequence definition.  Check this assumption using
  /// {@link CoordinateSequence#getDimension()} and {@link CoordinateSequence#getMeasures()} before use.
  static final int M = 2;

  /// Default constructor
  CoordinateXYM() {
    super();
    this.m = 0.0;
  }

  /// Constructs a CoordinateXYM instance with the given ordinates and measure.
  /// 
  /// @param x the X ordinate
  /// @param y the Y ordinate
  /// @param m the M measure value
  CoordinateXYM(double x, double y, double m) {
    super(x, y, Coordinate.NULL_ORDINATE);
    this.m = m;
  }

  /// Constructs a CoordinateXYM instance with the x and y ordinates of the given Coordinate.
  /// 
  /// @param coord the coordinate providing the ordinates
  CoordinateXYM(Coordinate coord) {
    super(coord.x,coord.y);
    m = getM();
  }

  /// Constructs a CoordinateXY instance with the x and y ordinates of the given CoordinateXYM.
  /// 
  /// @param coord the coordinate providing the ordinates
  CoordinateXYM(CoordinateXYM coord) {
    super(coord.x,coord.y);
    m = coord.m;
  }
  
  /// Creates a copy of this CoordinateXYM.
  /// 
  /// @return a copy of this CoordinateXYM
  CoordinateXYM copy() {
    return new CoordinateXYM(this);
  }
  
  /// Create a new Coordinate of the same type as this Coordinate, but with no values.
  /// 
  /// @return a new Coordinate
  @Override
  Coordinate create() {
      return new CoordinateXYM();
  }
    
  /// The m-measure.
  protected double m;

  /// The m-measure, if available.
  double getM() {
    return m;
  }

  void setM(double m) {
    this.m = m;
  }
  
  /// The z-ordinate is not supported
  @Override
  double getZ() {
      return NULL_ORDINATE;
  }

  /// The z-ordinate is not supported
  @Override
  void setZ(double z) {
      throw new ArgumentError("CoordinateXY dimension 2 does not support z-ordinate");
  }
  
  @Override
  void setCoordinate(Coordinate other)
  {
    x = other.x;
    y = other.y;
    z = other.getZ();
    m = other.getM();
  }
  
  @Override
  double getOrdinate(int ordinateIndex) {
      switch (ordinateIndex) {
      case X: return x;
      case Y: return y;
      case M: return m;
      }
      throw new ArgumentError("Invalid ordinate index: " + ordinateIndex);
  }
  
  @Override
  void setOrdinate(int ordinateIndex, double value) {
      switch (ordinateIndex) {
      case X:
        x = value;
        break;
      case Y:
        y = value;
        break;
      case M:
        m = value;
        break;
      default:
        throw new ArgumentError("Invalid ordinate index: " + ordinateIndex);
    }
  }
  
  String toString() {
    return "(" + x + ", " + y + " m=" + getM() + ")";
  }
}
