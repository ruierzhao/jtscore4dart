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


/**
 * Coordinate subclass supporting XY ordinates.
 * <p>
 * This data object is suitable for use with coordinate sequences with <tt>dimension</tt> = 2.
 * <p>
 * The {@link Coordinate#z} field is visible, but intended to be ignored.
 *
 * @since 1.16
 */
class CoordinateXY extends Coordinate {
  private static final long serialVersionUID = 3532307803472313082L;

  /** Standard ordinate index value for X */
  static final int X = 0;

  /** Standard ordinate index value for Y */
  static final int Y = 1;

  /** CoordinateXY does not support Z values. */
  static final int Z = -1;

  /** CoordinateXY does not support M measures. */
  static final int M = -1;

  /** Default constructor */
  CoordinateXY() {
    super();
  }

  /**
   * Constructs a CoordinateXY instance with the given ordinates.
   * 
   * @param x the X ordinate
   * @param y the Y ordinate
   */
  CoordinateXY(double x, double y) {
    super(x, y, Coordinate.NULL_ORDINATE);
  }

  /**
   * Constructs a CoordinateXY instance with the x and y ordinates of the given Coordinate.
   * 
   * @param coord the Coordinate providing the ordinates
   */
  CoordinateXY(Coordinate coord) {
    super(coord.x,coord.y);
  }

  /**
   * Constructs a CoordinateXY instance with the x and y ordinates of the given CoordinateXY.
   * 
   * @param coord the CoordinateXY providing the ordinates
   */
  CoordinateXY(CoordinateXY coord) {
    super(coord.x,coord.y);  
  }

  /**
   * Creates a copy of this CoordinateXY.
   * 
   * @return a copy of this CoordinateXY
   */
  CoordinateXY copy() {
    return new CoordinateXY(this);
  }
  
  /**
   * Create a new Coordinate of the same type as this Coordinate, but with no values.
   * 
   * @return a new Coordinate
   */
  @Override
  Coordinate create() {
      return new CoordinateXY();
  }

  /** The z-ordinate is not supported */
  @Override
  double getZ() {
      return NULL_ORDINATE;
  }

  /** The z-ordinate is not supported */
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
  }
  
  @Override
  double getOrdinate(int ordinateIndex) {
      switch (ordinateIndex) {
      case X: return x;
      case Y: return y;
      }
      return double.nan;
      // disable for now to avoid regression issues
      //throw new ArgumentError("Invalid ordinate index: " + ordinateIndex);
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
      default:
        throw new ArgumentError("Invalid ordinate index: " + ordinateIndex);
    }
  }
  
  String toString() {
    return "(" + x + ", " + y + ")";
  }
}
