/*
 * Copyright (c) 2016 Martin Davis.
 *
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License 2.0
 * and Eclipse Distribution License v. 1.0 which accompanies this distribution.
 * The Eclipse Public License is available at http://www.eclipse.org/legal/epl-v20.html
 * and the Eclipse Distribution License is available at
 *
 * http://www.eclipse.org/org/documents/edl-v10.php.
 */


// import org.locationtech.jts.algorithm.Angle;
// import org.locationtech.jts.algorithm.CGAlgorithmsDD;
// import org.locationtech.jts.geom.Coordinate;
// import org.locationtech.jts.util.Assert;

import 'dart:math';

import 'package:jtscore4dart/src/algorithm/Angle.dart';
import 'package:jtscore4dart/src/geom/Coordinate.dart';
import 'package:jtscore4dart/src/utils.dart';

/// A 2-dimensional mathematical vector represented by double-precision X and Y components.
/// 
/// @author mbdavis
/// 
class Vector2D {
  /// Creates a new vector with given X and Y components.
  /// 
  /// @param x the x component
  /// @param y the y component
  /// @return a new vector
	// static Vector2D create(double x, double y) {
	// 	return new Vector2D(x, y);
	// }

  /// Creates a new vector from an existing one.
  /// 
  /// @param v the vector to copy
  /// @return a new vector
	// static Vector2D create(Vector2D v) {
	// 	return new Vector2D(v);
	// }

  /// Creates a vector from a {@link Coordinate}. 
  /// 
  /// @param coord the Coordinate to copy
  /// @return a new vector
	// static Vector2D create(Coordinate coord) {
	// 	return Vector2D(coord);
	// }

  /// Creates a vector with the direction and magnitude
  /// of the difference between the 
  /// <tt>to</tt> and <tt>from</tt> {@link Coordinate}s.
  /// 
  /// @param from the origin Coordinate
  /// @param to the destination Coordinate
  /// @return a new vector
	// static Vector2D create(Coordinate from, Coordinate to) {
	// 	return new Vector2D(from, to);
	// }

	/// The X component of this vector.
	final double _x;

	/// The Y component of this vector.
	final double _y;

	Vector2D(this._x, this._y);

	Vector2D.empty():_x=0.0,_y=0.0;

	Vector2D.fromAnother(Vector2D v):
		_x = v._x,
		_y = v._y;
	

	Vector2D.from2(Coordinate from, Coordinate to):
		_x = to.x - from.x,
		_y = to.y - from.y;
	

	Vector2D.from1(Coordinate v):
		_x = v.x,
		_y = v.y;
	

	double getX() {
		return _x;
	}

	double getY() {
		return _y;
	}

	double getComponent(int index) {
		if (index == 0) {
		  return _x;
		}
		return _y;
	}

	Vector2D add(Vector2D v) {
		return Vector2D(_x + v._x, _y + v._y);
	}

	Vector2D subtract(Vector2D v) {
		return Vector2D(_x - v._x, _y - v._y);
	}

  /// Multiplies the vector by a scalar value.
  /// 
  /// @param d the value to multiply by
  /// @return a new vector with the value v * d
	Vector2D multiply(double d) {
		return Vector2D(_x * d, _y * d);
	}

  /// Divides the vector by a scalar value.
  /// 
  /// @param d the value to divide by
  /// @return a new vector with the value v / d
	Vector2D divide(double d) {
		return Vector2D(_x / d, _y / d);
	}

	Vector2D negate() {
		return Vector2D(-_x , -_y);
	}

	double length() {
		return hypot(_x, _y);
	}

	double lengthSquared() {
		return _x * _x + _y * _y;
	}

	Vector2D normalize() {
		double _length = length();
		if (_length > 0.0) {
		  return divide(_length);
		}
		return Vector2D(0.0, 0.0);
	}

	Vector2D average(Vector2D v) {
		return weightedSum(v, 0.5);
	}
  
	/// Computes the weighted sum of this vector
	/// with another vector,
	/// with this vector contributing a fraction
	/// of <tt>frac</tt> to the total.
	/// <p>
	/// In other words, 
	/// <pre>
	/// sum = frac * this + (1 - frac) * v
	/// </pre>
	/// 
	/// @param v the vector to sum
	/// @param frac the fraction of the total contributed by this vector
	/// @return the weighted sum of the two vectors
	Vector2D weightedSum(Vector2D v, double frac) {
		return Vector2D(
				frac * _x + (1.0 - frac) * v._x, 
				frac * _y + (1.0 - frac) * v._y);
	}

  /// Computes the distance between this vector and another one.
  /// @param v a vector
  /// @return the distance between the vectors
  double distance(Vector2D v)
  {
    double delx = v._x - _x;
    double dely = v._y - _y;
    return hypot(delx, dely);
  }
  
	/// Computes the dot-product of two vectors
	/// 
	/// @param v a vector
	/// @return the dot product of the vectors
	double dot(Vector2D v) {
		return _x * v._x + _y * v._y;
	}

  /// 和 x 轴的角度
	double angle()
	{
		return atan2(_y, _x);
	}
	
  // double angle(Vector2D v)
  // {
  //   return Angle.diff(v.angle(), angle());
  // }
  double angleTo$1(Vector2D v){
    return Angle.diff(v.angle(), angle());
  }
  
  double angleTo(Vector2D v){
    double a1 = angle();
    double a2 = v.angle();
    double angDel = a2 - a1;
    
    // normalize, maintaining orientation
    if (angDel <= - pi) {
      return angDel + Angle.PI_TIMES_2;
    }
    if (angDel > pi) {
      return angDel - Angle.PI_TIMES_2;
    }
    return angDel;
  }
  
	Vector2D rotate(double angle)
	{
		double _cos = cos(angle);
		double _sin = sin(angle);
		return Vector2D(
				_x * _cos - _y * _sin,
				_x * _sin + _y * _cos
				);
	}
	
	/// Rotates a vector by a given number of quarter-circles (i.e. multiples of 90
	/// degrees or Pi/2 radians). A positive number rotates counter-clockwise, a
	/// negative number rotates clockwise. Under this operation the magnitude of
	/// the vector and the absolute values of the ordinates do not change, only
	/// their sign and ordinate index.
	/// 
	/// @param numQuarters
	///          the number of quarter-circles to rotate by
	/// @return the rotated vector.
	Vector2D rotateByQuarterCircle(int numQuarters) {
		int nQuad = numQuarters % 4;
		if (numQuarters < 0 && nQuad != 0) {
			nQuad = nQuad + 4;
		}
		switch (nQuad) {
		case 0:
			return Vector2D(_x, _y);
		case 1:
			return Vector2D(-_y, _x);
		case 2:
			return Vector2D(-_x, -_y);
		case 3:
			return Vector2D(_y, -_x);
		}
    // TODO: ruier edit.
    throw Exception("Vector2D.rotateByQuarterCircle");
		// Assert.shouldNeverReachHere();
		// return null;
	}

  bool isParallel(Vector2D v)
  {
    // TODO: ruier edit.
    throw UnimplementedError();
    // return 0.0 == CGAlgorithmsDD.signOfDet2x2(_x, _y, v._x, v._y);
  }
  
	Coordinate translate(Coordinate coord) {
		return Coordinate(_x + coord.x, _y + coord.y);
	}

	Coordinate toCoordinate() {
		return Coordinate(_x, _y);
	}

  /// Creates a copy of this vector
  /// 
  /// @return a copy of this vector
  Object clone()
  {
    return Vector2D.fromAnother(this);
  }
  
  /// Gets a string representation of this vector
  /// 
  /// @return a string representing this vector
	@override
   String toString() {
		return "[$_x , $_y]";
	}
	
	/// Tests if a vector <tt>o</tt> has the same values for the x and y
	/// components.
	/// 
	/// @param o
	///          a <tt>Vector2D</tt> with which to do the comparison.
	/// @return true if <tt>other</tt> is a <tt>Vector2D</tt> with the same
	///         values for the x and y components.
	bool equals(Object o) {
		if (o is! Vector2D) {
			return false;
		}
		Vector2D v = o;
		return _x == v._x && _y == v._y;
	}
  /// TODO: ruier edit. copy from equals for [hashCode]
	// @override
  //  bool operator ==(Object o) {
	// 	if (o is! Vector2D) {
	// 		return false;
	// 	}
	// 	Vector2D v = o;
	// 	return _x == v._x && _y == v._y;
	// }

	/// Gets a hashcode for this vector.
	/// 
	/// @return a hashcode for this vector
  // TODO: ruier edit. 
	// @override
  //  int get hashCode {
	// 	// Algorithm from Effective Java by Joshua Bloch
	// 	int result = 17;
	// 	result = 37 * result + Coordinate.hashCode(_x);
	// 	result = 37 * result + Coordinate.hashCode(_y);
	// 	return result;
	// }


}
