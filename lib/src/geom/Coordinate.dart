
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

// import java.io.Serializable;
// import java.util.Comparator;

// import org.locationtech.jts.util.Assert;
// import org.locationtech.jts.util.NumberUtil;


import 'package:jtscore4dart/src/utils.dart';
import "dart:math" as math;
/// A lightweight class used to store coordinates on the 2-dimensional Cartesian plane.
/// <p>
/// It is distinct from {@link Point}, which is a subclass of {@link Geometry}. 
/// Unlike objects of type {@link Point} (which contain additional
/// information such as an envelope, a precision model, and spatial reference
/// system information), a <code>Coordinate</code> only contains ordinate values
/// and accessor methods. </p>
/// <p>
/// <code>Coordinate</code>s are two-dimensional points, with an additional Z-ordinate. 
/// If an Z-ordinate value is not specified or not defined, 
/// constructed coordinates have a Z-ordinate of <code>NaN</code>
/// (which is also the value of <code>NULL_ORDINATE</code>).  
/// The standard comparison functions ignore the Z-ordinate.
/// Apart from the basic accessor functions, JTS supports
/// only specific operations involving the Z-ordinate.</p> 
/// <p>
/// Implementations may optionally support Z-ordinate and M-measure values
/// as appropriate for a {@link CoordinateSequence}. 
/// Use of {@link #getZ()} and {@link #getM()}
/// accessors, or {@link #getOrdinate(int)} are recommended.</p> 
///
/// @version 1.16
class Coordinate implements Comparable<Coordinate> {
  final int serialVersionUID = 6683108902428366910;
  
  /// The value used to indicate a null or missing ordinate value.
  /// In particular, used for the value of ordinates for dimensions 
  /// greater than the defined dimension of a coordinate.
  static const double NULL_ORDINATE = double.nan;
  
  /// Standard ordinate index value for, where X is 0
  static const int X = 0;

  /// Standard ordinate index value for, where Y is 1
  static const int Y = 1;
  
  /// Standard ordinate index value for, where Z is 2.
  ///
  /// <p>This constant assumes XYZM coordinate sequence definition, please check this assumption
  /// using {@link CoordinateSequence#getDimension()} and {@link CoordinateSequence#getMeasures()}
  /// before use.
  static const int Z = 2;

  /// Standard ordinate index value for, where M is 3.
  ///
  /// <p>This constant assumes XYZM coordinate sequence definition, please check this assumption
  /// using {@link CoordinateSequence#getDimension()} and {@link CoordinateSequence#getMeasures()}
  /// before use.
  static const int M = 3;
  
  /// The x-ordinate.
  late double x;
  
  /// The y-ordinate.
  late double y;
  
  /// The z-ordinate.
  /// <p>
  /// Direct access to this field is discouraged; use {@link #getZ()}.
  double? z=NULL_ORDINATE;

  ///  Constructs a <code>Coordinate</code> at (x,y,z).
  ///
  ///@param  x  the x-ordinate
  ///@param  y  the y-ordinate
  ///@param  z  the z-ordinate
  // Coordinate(this.x, this.y,[double? z]);
  Coordinate(this.x, this.y,[this.z]);

  ///  Constructs a <code>Coordinate</code> at (0,0,NaN).
  Coordinate empty2D() {
    return Coordinate(0.0, 0.0);
  }

  ///  Constructs a <code>Coordinate</code> having the same (x,y,z) values as
  ///  <code>other</code>.
  ///
  ///@param  c  the <code>Coordinate</code> to copy.
  Coordinate fromCoordinate(Coordinate c) {
    return Coordinate(c.x, c.y, z);
  }


  ///  Sets this <code>Coordinate</code>s (x,y,z) values to that of <code>other</code>.
  ///
  ///@param  other  the <code>Coordinate</code> to copy
  void setCoordinate(Coordinate other) {
    x = other.x;
    y = other.y;
    z = other.getZ();
  }

  ///  Retrieves the value of the X ordinate.
  ///  
  ///  @return the value of the X ordinate  
  double getX() {
    return x;
  }

  /// Sets the X ordinate value.
  /// 
  /// @param x the value to set as X
  void setX(double x) {
    this.x = x;
  }
  
  ///  Retrieves the value of the Y ordinate.
  ///  
  ///  @return the value of the Y ordinate  
  double getY() {
      return y;      
  }

  /// Sets the Y ordinate value.
  /// 
  /// @param y the value to set as Y
  void setY(double y) {
    this.y = y;
  }
  
  ///  Retrieves the value of the Z ordinate, if present.
  ///  If no Z value is present returns <tt>NaN</tt>.
  ///  
  ///  @return the value of the Z ordinate, or <tt>NaN</tt>   
  double? getZ() {
      return z;      
  }
  
  /// Sets the Z ordinate value.
  /// 
  /// @param z the value to set as Z
  void setZ(double z) {
    this.z = z;
  }
  
  ///  Retrieves the value of the measure, if present.
  ///  If no measure value is present returns <tt>NaN</tt>.
  ///  
  ///  @return the value of the measure, or <tt>NaN</tt>    
  double getM() {
    return double.nan;     
  }
  
  
  /// Gets the ordinate value for the given index.
  /// 
  /// The base implementation supports values for the index are 
  /// {@link #X}, {@link #Y}, and {@link #Z}.
  /// 
  /// @param ordinateIndex the ordinate index
  /// @return the value of the ordinate
  /// @throws IllegalArgumentException if the index is not valid
  double getOrdinate(int ordinateIndex) {
    switch (ordinateIndex) {
    case X: return x;
    case Y: return y;
    case Z: return getZ()?? 0; // sure to delegate to subclass rather than offer direct field access
    }
    // throw new IllegalArgumentException("Invalid ordinate index: " + ordinateIndex);
    throw ArgumentError("Invalid ordinate index: $ordinateIndex");
  }
  
  /// Sets the ordinate for the given index
  /// to a given value.
  /// 
  /// The base implementation supported values for the index are 
  /// {@link #X}, {@link #Y}, and {@link #Z}.
  /// 
  /// @param ordinateIndex the ordinate index
  /// @param value the value to set
  /// @throws IllegalArgumentException if the index is not valid
  void setOrdinate(int ordinateIndex, double value)
  {
    switch (ordinateIndex) {
      case X:
        x = value;
        break;
      case Y:
        y = value;
        break;
      case Z:
        setZ(value); // delegate to subclass rather than offer direct field access
        break;
      default:
        throw ArgumentError("Invalid ordinate index: $ordinateIndex");
    }
  }

  /// Tests if the coordinate has valid X and Y ordinate values.
  /// An ordinate value is valid iff it is finite.
  /// 
  /// @return true if the coordinate is valid
  /// @see Double#isFinite(double)
  bool isValid() {
    if (! x.isFinite) return false;
    if (! y.isFinite) return false;
    return true;
  }

  
  ///  Returns whether the planar projections of the two <code>Coordinate</code>s
  ///  are equal.
  ///
  ///@param  other  a <code>Coordinate</code> with which to do the 2D comparison.
  ///@return        <code>true</code> if the x- and y-coordinates are equal; the
  ///      z-coordinates do not have to be equal.
  bool equals2D(Coordinate other) {
    if (x != other.x) {
      return false;
    }
    if (y != other.y) {
      return false;
    }
    return true;
  }

  /// Tests if another Coordinate has the same values for the X and Y ordinates,
  /// within a specified tolerance value.
  /// The Z ordinate is ignored.
  ///
  ///@param c a <code>Coordinate</code> with which to do the 2D comparison.
  ///@param tolerance the tolerance value to use
  ///@return true if <code>other</code> is a <code>Coordinate</code>
  ///      with the same values for X and Y.
  // bool equals2D(Coordinate c, double tolerance){
  //   if (! NumberUtil.equalsWithTolerance(this.x, c.x, tolerance)) {
  //     return false;
  //   }
  //   if (! NumberUtil.equalsWithTolerance(this.y, c.y, tolerance)) {
  //     return false;
  //   }
  //   return true;
  // }

  /// @add
  bool equals2DWithTolerance(Coordinate c, double tolerance) {
    if (equalsWithTolerance(this.x, c.x, tolerance)) {
      return false;
    }
    if (equalsWithTolerance(this.y, c.y, tolerance)) {
      return false;
    }
    return true;
  }
  
  /// Tests if another coordinate has the same values for the X, Y and Z ordinates.
  ///
  ///@param other a <code>Coordinate</code> with which to do the 3D comparison.
  ///@return true if <code>other</code> is a <code>Coordinate</code>
  ///      with the same values for X, Y and Z.
  bool equals3D(Coordinate other) {
    return (x == other.x) &&
        (y == other.y) &&
        ((getZ() == other.getZ()) || (getZ()!.isNaN && other.getZ()!.isNaN));
  }
  
  /// Tests if another coordinate has the same value for Z, within a tolerance.
  /// 
  /// @param c a coordinate
  /// @param tolerance the tolerance value
  /// @return true if the Z ordinates are within the given tolerance
  // bool equalInZ(Coordinate c, double tolerance){
  //   return equalsWithTolerance(this.getZ(), c.getZ(), tolerance);
  // }
  
  ///  Returns <code>true</code> if <code>other</code> has the same values for
  ///  the x and y ordinates.
  ///  Since Coordinates are 2.5D, this routine ignores the z value when making the comparison.
  ///
  ///@param  other  a <code>Coordinate</code> with which to do the comparison.
  ///@return        <code>true</code> if <code>other</code> is a <code>Coordinate</code>
  ///      with the same values for the x and y ordinates.
  bool equals(Object other) {
    if (other is! Coordinate) {
      return false;
    }
    return equals2D(other);
  }

  ///  Compares this {@link Coordinate} with the specified {@link Coordinate} for order.
  ///  This method ignores the z value when making the comparison.
  ///  Returns:
  ///  <UL>
  ///    <LI> -1 : this.x &lt; other.x || ((this.x == other.x) &amp;&amp; (this.y &lt; other.y))
  ///    <LI> 0 : this.x == other.x &amp;&amp; this.y = other.y
  ///    <LI> 1 : this.x &gt; other.x || ((this.x == other.x) &amp;&amp; (this.y &gt; other.y))
  ///
  ///  </UL>
  ///  Note: This method assumes that ordinate values
  /// are valid numbers.  NaN values are not handled correctly.
  ///
  ///@param  o  the <code>Coordinate</code> with which this <code>Coordinate</code>
  ///      is being compared
  ///@return    -1, zero, or 1 as this <code>Coordinate</code>
  ///      is less than, equal to, or greater than the specified <code>Coordinate</code>
  int compareTo(Coordinate o) {
    Coordinate other = o;

    if (x < other.x) return -1;
    if (x > other.x) return 1;
    if (y < other.y) return -1;
    if (y > other.y) return 1;
    return 0;
  }

  ///  Returns a <code>String</code> of the form <I>(x,y,z)</I> .
  ///
  ///@return    a <code>String</code> of the form <I>(x,y,z)</I>
  String toString() {
    return "($x , $y ${getZ()})";
  }

  // Object clone() {
  //   try {
  //     Coordinate coord = (Coordinate) super.clone();

  //     return coord; // return the clone
  //   } catch (CloneNotSupportedException e) {
  //     Assert.shouldNeverReachHere(
  //         "this shouldn't happen because this class is Cloneable");

  //     return null;
  //   }
  // }
  
  /// Creates a copy of this Coordinate.
  /// 
  /// @return a copy of this coordinate.
  Coordinate copy() {
    return Coordinate(x,y,z);
  }
  
  /// Create a new Coordinate of the same type as this Coordinate, but with no values.
  /// 
  /// @return a new Coordinate
  // Coordinate create() {
  //     return new Coordinate();
  // }

  /// Computes the 2-dimensional Euclidean distance to another location.
  /// The Z-ordinate is ignored.
  /// 
  /// @param c a point
  /// @return the 2-dimensional Euclidean distance between the locations
  double distance(Coordinate c) {
    double dx = x - c.x;
    double dy = y - c.y;
    return hypot(dx, dy);
  }

  /// Computes the 3-dimensional Euclidean distance to another location.
  /// 
  /// @param c a coordinate
  /// @return the 3-dimensional Euclidean distance between the locations
  double distance3D(Coordinate c) {
    double dx = x - c.x;
    double dy = y - c.y;
    double dz = getZ()! - c.getZ()!;
    return math.sqrt(dx * dx + dy * dy + dz * dz);
  }

  /// Gets a hashcode for this coordinate.
  /// 
  /// @return a hashcode for this coordinate
  @override
  int get hashCode {
    //Algorithm from Effective Java by Joshua Bloch [Jon Aquino]
    int result = 17;
    result = 37 * result + x.hashCode;
    result = 37 * result + y.hashCode;
    return result;
  }

/// dart_jts
  // int get hashCode {
  //   //Algorithm from Effective Java by Joshua Bloch [Jon Aquino]
  //   const prime = 31;
  //   int result = 1;
  //   result = prime * result + x.hashCode;
  //   result = prime * result + y.hashCode;
  //   return result;
  // }

  /// Computes a hash code for a double value, using the algorithm from
  /// Joshua Bloch's book <i>Effective Java"</i>
  /// 
  /// @param x the value to compute for
  /// @return a hashcode for x
  // static int hashCode(double x) {
  //   long f = Double.doubleToLongBits(x);
  //   return (int)(f^(f>>>32));
  // }

/** ruier
  /// Compares two {@link Coordinate}s, allowing for either a 2-dimensional
  /// or 3-dimensional comparison, and handling NaN values correctly.
  static class DimensionalComparator
      implements Comparator<Coordinate>
  
  {
     /// Compare two <code>double</code>s, allowing for NaN values.
     /// NaN is treated as being less than any valid number.
     ///
     /// @param a a <code>double</code>
     /// @param b a <code>double</code>
     /// @return -1, 0, or 1 depending on whether a is less than, equal to or greater than b
    static int compare(double a, double b)
    {
      if (a < b) return -1;
      if (a > b) return 1;

      if (Double.isNaN(a)) {
        if (Double.isNaN(b)) return 0;
        return -1;
      }

      if (Double.isNaN(b)) return 1;
      return 0;
    }

    private int dimensionsToTest = 2;

     /// Creates a comparator for 2 dimensional coordinates.
    DimensionalComparator()
    {
      this(2);
    }

     /// Creates a comparator for 2 or 3 dimensional coordinates, depending
     /// on the value provided.
     ///
     /// @param dimensionsToTest the number of dimensions to test
    DimensionalComparator(int dimensionsToTest)
    {
      if (dimensionsToTest != 2 && dimensionsToTest != 3)
        throw new IllegalArgumentException("only 2 or 3 dimensions may be specified");
      this.dimensionsToTest = dimensionsToTest;
    }

     /// Compares two {@link Coordinate}s along to the number of
     /// dimensions specified.
     ///
     /// @param c1 a {@link Coordinate}
     /// @param c2 a {link Coordinate}
     /// @return -1, 0, or 1 depending on whether o1 is less than,
     /// equal to, or greater than 02
    int compare(Coordinate c1, Coordinate c2)
    {
      int compX = compare(c1.x, c2.x);
      if (compX != 0) return compX;

      int compY = compare(c1.y, c2.y);
      if (compY != 0) return compY;

      if (dimensionsToTest <= 2) return 0;

      int compZ = compare(c1.getZ(), c2.getZ());
      return compZ;
    }
  }
*/
}
