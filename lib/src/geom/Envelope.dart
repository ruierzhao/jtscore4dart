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

import 'dart:math' as math;
import 'dart:math';

import 'package:jtscore4dart/src/geom/Coordinate.dart';
import 'package:jtscore4dart/src/utils.dart';

///  Defines a rectangular region of the 2D coordinate plane.
///  It is often used to represent the bounding box of a {@link Geometry},
///  e.g. the minimum and maximum x and y values of the {@link Coordinate}s.
///  <p>
///  Envelopes support infinite or half-infinite regions, by using the values of
///  <code>Double.POSITIVE_INFINITY</code> and <code>Double.NEGATIVE_INFINITY</code>.
///  Envelope objects may have a null value.
///  <p>
///  When Envelope objects are created or initialized,
///  the supplies extent values are automatically sorted into the correct order.
///
///@version 1.7
class Envelope
    implements Comparable
{
    // static const int serialVersionUID = 5873921885273102420;
    // TODO: ruier add for Envelop init.
  static ((double,double),(double,double)) _adjustXY(double x1, double x2, double y1, double y2)
  {
    final double minx,maxx,miny,maxy;
    if (x1 < x2) {
      minx = x1;
      maxx = x2;
    }else {
      minx = x2;
      maxx = x1;
    }
    if (y1 < y2) {
      miny = y1;
      maxy = y2;
    }else {
      miny = y2;
      maxy = y1;
    }
    return ((minx,maxx),(miny,maxy));
  }

  // TODO: ruier add.
  static bool intersects(Coordinate p1, Coordinate p2, Coordinate q1, [Coordinate? q2]){
    if (q2 == null) {
      return _intersects$1(p1, p2, q1);
    }
    return _intersects$2(p1, p2, q1, q2);
  }
  /// Test the point q to see whether it intersects the Envelope defined by p1-p2
  /// @param p1 one extremal point of the envelope
  /// @param p2 another extremal point of the envelope
  /// @param q the point to test for intersection
  /// @return <code>true</code> if q intersects the envelope p1-p2
  /// @ruier 判断[p] 点和[p1] 和 [q1]组成的矩形是否相交
  static bool _intersects$1(Coordinate p1, Coordinate p2, Coordinate q)
  {
	//OptimizeIt shows that Math#min and Math#max here are a bottleneck.
    //Replace with direct comparisons. [Jon Aquino]
    if (((q.x >= (p1.x < p2.x ? p1.x : p2.x)) && (q.x <= (p1.x > p2.x ? p1.x : p2.x))) &&
        ((q.y >= (p1.y < p2.y ? p1.y : p2.y)) && (q.y <= (p1.y > p2.y ? p1.y : p2.y)))) {
      return true;
    }
    return false;
  }

  /// Tests whether the envelope defined by p1-p2
  /// and the envelope defined by q1-q2
  /// intersect.
  /// 
  /// @param p1 one extremal point of the envelope P
  /// @param p2 another extremal point of the envelope P
  /// @param q1 one extremal point of the envelope Q
  /// @param q2 another extremal point of the envelope Q
  /// @return <code>true</code> if Q intersects P
  /// @ruier 判断两个envelop 是否相交
  static bool _intersects$2(Coordinate p1, Coordinate p2, Coordinate q1, Coordinate q2)
  {
    double minq = math.min(q1.x, q2.x);
    double maxq = math.max(q1.x, q2.x);
    double minp = math.min(p1.x, p2.x);
    double maxp = math.max(p1.x, p2.x);

    if( minp > maxq ) {
      return false;
    }
    if( maxp < minq ) {
      return false;
    }

    minq = math.min(q1.y, q2.y);
    maxq = math.max(q1.y, q2.y);
    minp = math.min(p1.y, p2.y);
    maxp = math.max(p1.y, p2.y);

    if( minp > maxq ) {
      return false;
    }
    if( maxp < minq ) {
      return false;
    }
    return true;
  }

  ///  the minimum x-coordinate
  double _minx;

  ///  the maximum x-coordinate
  double _maxx;

  ///  the minimum y-coordinate
  double _miny;

  ///  the maximum y-coordinate
  double _maxy;

  ///  Creates a null <code>Envelope</code>.
  Envelope.init(): 
    _minx = 0,
    _maxx = -1,
    _miny = 0,
    _maxy = -1; 
  ///  Creates an <code>Envelope</code> for a region defined by maximum and minimum values.
  ///
  ///@param  x1  the first x-value
  ///@param  x2  the second x-value
  ///@param  y1  the first y-value
  ///@param  y2  the second y-value
  Envelope(double x1, double x2, double y1, double y2)
      : _minx = min<double>(x1, x2),
        _maxx = max<double>(x1, x2),
        _miny = min<double>(y1, y2),
        _maxy = max<double>(y1, y2);
  


  ///  Creates an <code>Envelope</code> for a region defined by two Coordinates.
  ///
  ///@param  p1  the first Coordinate
  ///@param  p2  the second Coordinate
  Envelope.fromCoord2(Coordinate p1, Coordinate p2):this(p1.x, p2.x, p1.y, p2.y);
    // : _minx = min<double>(p1.x, p2.x),
    // _maxx = max(p1.x, p2.x),
    // _miny = min(p1.y, p2.y),
    // _maxy = max(p1.y, p2.y);

  ///  Creates an <code>Envelope</code> for a region defined by a single Coordinate.
  ///
  ///@param  p  the Coordinate
  Envelope.fromCoord1(Coordinate p):this(p.x, p.x, p.y, p.y);
  // {
  //   init(p.x, p.x, p.y, p.y);
  // }

  ///  Create an <code>Envelope</code> from an existing Envelope.
  ///
  ///@param  env  the Envelope to initialize from
  Envelope.fromAnother(Envelope env):   
    _maxx = env._maxx,
    _miny = env._miny,
    _maxy = env._maxy, 
    _minx = env._minx;


  ///  Initialize to a null <code>Envelope</code>.
  // TODO: ruier edit.
  // void init()
  // {
  //   setToNull();
  // }

  ///  Initialize an <code>Envelope</code> for a region defined by maximum and minimum values.
  ///
  ///@param  x1  the first x-value
  ///@param  x2  the second x-value
  ///@param  y1  the first y-value
  ///@param  y2  the second y-value


  /// Creates a copy of this envelope object.
  /// 
  /// @return a copy of this envelope
  Envelope copy() {
    return Envelope.fromAnother(this);
  }
  
  ///  Initialize an <code>Envelope</code> to a region defined by two Coordinates.
  ///
  ///@param  p1  the first Coordinate
  ///@param  p2  the second Coordinate
  // void init(Coordinate p1, Coordinate p2)
  // {
  //   init(p1.x, p2.x, p1.y, p2.y);
  // }

  ///  Initialize an <code>Envelope</code> to a region defined by a single Coordinate.
  ///
  ///@param  p  the coordinate
  // void init(Coordinate p)
  // {
  //   init(p.x, p.x, p.y, p.y);
  // }

  ///  Initialize an <code>Envelope</code> from an existing Envelope.
  ///
  ///@param  env  the Envelope to initialize from
  // void init(Envelope env)
  // {
  //   this._minx = env._minx;
  //   this._maxx = env._maxx;
  //   this._miny = env._miny;
  //   this._maxy = env._maxy;
  // }


  ///  Makes this <code>Envelope</code> a "null" envelope, that is, the envelope
  ///  of the empty geometry.
  void setToNull() {
    _minx = 0;
    _maxx = -1;
    _miny = 0;
    _maxy = -1;
  }

  ///  Returns <code>true</code> if this <code>Envelope</code> is a "null"
  ///  envelope.
  ///
  ///@return    <code>true</code> if this <code>Envelope</code> is uninitialized
  ///      or is the envelope of the empty geometry.
  bool isNull() {
    return _maxx < _minx;
  }

  ///  Returns the difference between the maximum and minimum x values.
  ///
  ///@return    max x - min x, or 0 if this is a null <code>Envelope</code>
  double getWidth() {
    if (isNull()) {
      return 0;
    }
    return _maxx - _minx;
  }

  ///  Returns the difference between the maximum and minimum y values.
  ///
  ///@return    max y - min y, or 0 if this is a null <code>Envelope</code>
  double getHeight() {
    if (isNull()) {
      return 0;
    }
    return _maxy - _miny;
  }

  /// Gets the length of the diameter (diagonal) of the envelope.
  /// 
  /// @return the diameter length
  double getDiameter() {
    if (isNull()) {
      return 0;
    }
    double w = getWidth();
    double h = getHeight();
    return hypot(w, h);
  }
  ///  Returns the <code>Envelope</code>s minimum x-value. min x &gt; max x
  ///  indicates that this is a null <code>Envelope</code>.
  ///
  ///@return    the minimum x-coordinate
  double getMinX() {
    return _minx;
  }

  ///  Returns the <code>Envelope</code>s maximum x-value. min x &gt; max x
  ///  indicates that this is a null <code>Envelope</code>.
  ///
  ///@return    the maximum x-coordinate
  double getMaxX() {
    return _maxx;
  }

  ///  Returns the <code>Envelope</code>s minimum y-value. min y &gt; max y
  ///  indicates that this is a null <code>Envelope</code>.
  ///
  ///@return    the minimum y-coordinate
  double getMinY() {
    return _miny;
  }

  ///  Returns the <code>Envelope</code>s maximum y-value. min y &gt; max y
  ///  indicates that this is a null <code>Envelope</code>.
  ///
  ///@return    the maximum y-coordinate
  double getMaxY() {
    return _maxy;
  }

  /// Gets the area of this envelope.
  /// 
  /// @return the area of the envelope
  /// @return 0.0 if the envelope is null
  double getArea()
  {
    return getWidth() * getHeight();
  }
  
  /// Gets the minimum extent of this envelope across both dimensions.
  /// 
  /// @return the minimum extent of this envelope
	double minExtent()
	{
		if (isNull()) return 0.0;
		double w = getWidth();
		double h = getHeight();
		if (w < h) return w;
		return h;
	}
	
  /// Gets the maximum extent of this envelope across both dimensions.
  /// 
  /// @return the maximum extent of this envelope
	double maxExtent()
	{
		if (isNull()) return 0.0;
		double w = getWidth();
		double h = getHeight();
		if (w > h) return w;
		return h;
	}
  
  ///  Enlarges this <code>Envelope</code> so that it contains
  ///  the given {@link Coordinate}. 
  ///  Has no effect if the point is already on or within the envelope.
  ///
  ///@param  p  the Coordinate to expand to include
  void expandToIncludeCoordinate(Coordinate p)
  {
    expandToIncludeXY(p.x, p.y);
  }

  /// Expands this envelope by a given distance in all directions.
  /// Both positive and negative distances are supported.
  ///
  /// @param distance the distance to expand the envelope
  void expandByDistance(double distance)
  {
    expandByDelXY(distance, distance);
  }

  /// Expands this envelope by a given distance in all directions.
  /// Both positive and negative distances are supported.
  ///
  /// @param deltaX the distance to expand the envelope along the the X axis
  /// @param deltaY the distance to expand the envelope along the the Y axis
  void expandByDelXY(double deltaX, double deltaY)
  {
    if (isNull()) return;

    _minx -= deltaX;
    _maxx += deltaX;
    _miny -= deltaY;
    _maxy += deltaY;

    // check for envelope disappearing
    if (_minx > _maxx || _miny > _maxy) {
      setToNull();
    }
  }

  ///  Enlarges this <code>Envelope</code> so that it contains
  ///  the given point. 
  ///  Has no effect if the point is already on or within the envelope.
  ///
  ///@param  x  the value to lower the minimum x to or to raise the maximum x to
  ///@param  y  the value to lower the minimum y to or to raise the maximum y to
  void expandToIncludeXY(double x, double y) {
    if (isNull()) {
      _minx = x;
      _maxx = x;
      _miny = y;
      _maxy = y;
    }
    else {
      if (x < _minx) {
        _minx = x;
      }
      if (x > _maxx) {
        _maxx = x;
      }
      if (y < _miny) {
        _miny = y;
      }
      if (y > _maxy) {
        _maxy = y;
      }
    }
  }

  ///  Enlarges this <code>Envelope</code> so that it contains
  ///  the <code>other</code> Envelope. 
  ///  Has no effect if <code>other</code> is wholly on or
  ///  within the envelope.
  ///
  ///@param  other  the <code>Envelope</code> to expand to include
  void expandToIncludeEnvelope(Envelope other) {
    if (other.isNull()) {
      return;
    }
    if (isNull()) {
      _minx = other.getMinX();
      _maxx = other.getMaxX();
      _miny = other.getMinY();
      _maxy = other.getMaxY();
    }
    else {
      if (other._minx < _minx) {
        _minx = other._minx;
      }
      if (other._maxx > _maxx) {
        _maxx = other._maxx;
      }
      if (other._miny < _miny) {
        _miny = other._miny;
      }
      if (other._maxy > _maxy) {
        _maxy = other._maxy;
      }
    }
  }

  /// Translates this envelope by given amounts in the X and Y direction.
  ///
  /// @param transX the amount to translate along the X axis
  /// @param transY the amount to translate along the Y axis
  void translate(double transX, double transY) {
    if (isNull()) {
      return;
    }
    _minx = getMinX() + transX; 
    _maxx = getMaxX() + transX;
    _miny = getMinY() + transY; 
    _maxy = getMaxY() + transY;
  }

  /// Computes the coordinate of the centre of this envelope (as int as it is non-null
  ///
  /// @return the centre coordinate of this envelope
  /// <code>null</code> if the envelope is null
  Coordinate? centre() {
    if (isNull()) return null;
    return Coordinate(
        (getMinX() + getMaxX()) / 2.0,
        (getMinY() + getMaxY()) / 2.0);
  }

  /// Computes the intersection of two {@link Envelope}s.
  ///
  /// @param env the envelope to intersect with
  /// @return a new Envelope representing the intersection of the envelopes (this will be
  /// the null envelope if either argument is null, or they do not intersect
  Envelope intersection(Envelope env)
  {
    if (isNull() || env.isNull() || ! intersectsWith(env)) return Envelope.init();

    double intMinX = _minx > env._minx ? _minx : env._minx;
    double intMinY = _miny > env._miny ? _miny : env._miny;
    double intMaxX = _maxx < env._maxx ? _maxx : env._maxx;
    double intMaxY = _maxy < env._maxy ? _maxy : env._maxy;
    return Envelope(intMinX, intMaxX, intMinY, intMaxY);
  }

  /// Tests if the region defined by <code>other</code>
  /// intersectsWith the region of this <code>Envelope</code>.
  /// <p>
  /// A null envelope never intersectsWith.
  ///
  ///@param  other  the <code>Envelope</code> which this <code>Envelope</code> is
  ///          being checked for intersecting
  ///@return        <code>true</code> if the <code>Envelope</code>s intersect
  bool intersectsWith(Envelope other) {
      if (isNull() || other.isNull()) { return false; }
    return !(other._minx > _maxx ||
        other._maxx < _minx ||
        other._miny > _maxy ||
        other._maxy < _miny);
  }
  
  
  /// Tests if the extent defined by two extremal points
  /// intersects the extent of this <code>Envelope</code>.
  ///
  ///@param a a point
  ///@param b another point
  ///@return   <code>true</code> if the extents intersect
  bool intersectsEnvelopeByCoord(Coordinate a, Coordinate b) {
    if (isNull()) { return false; }
    
    double envminx = (a.x < b.x) ? a.x : b.x;
    if (envminx > _maxx) return false;
    
    double envmaxx = (a.x > b.x) ? a.x : b.x;
    if (envmaxx < _minx) return false;
    
    double envminy = (a.y < b.y) ? a.y : b.y;
    if (envminy > _maxy) return false;
    
    double envmaxy = (a.y > b.y) ? a.y : b.y;
    if (envmaxy < _miny) return false;
    
    return true;
  }
  
  /// Tests if the region defined by <code>other</code>
  /// is disjoint from the region of this <code>Envelope</code>.
  /// <p>
  /// A null envelope is always disjoint.
  ///
  ///@param  other  the <code>Envelope</code> being checked for disjointness
  ///@return        <code>true</code> if the <code>Envelope</code>s are disjoint
  ///
  ///@see #intersects(Envelope)
  bool disjoint(Envelope other) {
    return !intersectsWith(other);
  }
  
  /// @deprecated Use #intersects instead. In the future, #overlaps may be
  /// changed to be a true overlap check; that is, whether the intersection is
  /// two-dimensional.
  bool overlaps(Envelope other) {
    return intersectsWith(other);
  }

  /// Tests if the point <code>p</code>
  /// intersects (lies inside) the region of this <code>Envelope</code>.
  ///
  ///@param  p  the <code>Coordinate</code> to be tested
  ///@return <code>true</code> if the point intersects this <code>Envelope</code>
  bool intersectsWithCoord(Coordinate p) {
    return intersectsXY(p.x, p.y);
  }
  ///  Check if the point <code>(x, y)</code>
  ///  intersects (lies inside) the region of this <code>Envelope</code>.
  ///
  ///@param  x  the x-ordinate of the point
  ///@param  y  the y-ordinate of the point
  ///@return        <code>true</code> if the point overlaps this <code>Envelope</code>
  bool intersectsXY(double x, double y) {
  	if (isNull()) return false;
    return ! (x > _maxx ||
        x < _minx ||
        y > _maxy ||
        y < _miny);
  }

  /// @deprecated Use #intersects instead.
  @Deprecated("Use #intersects instead")
  bool overlapsCoord(Coordinate p) {
    return intersectsWithCoord(p);
  }
  /// @deprecated Use #intersects instead.
  @Deprecated("Use #intersects instead")
  bool overlapsXY(double x, double y) {
    return intersectsXY(x, y);
  }

  /// Tests if the <code>Envelope other</code>
  /// lies wholely inside this <code>Envelope</code> (inclusive of the boundary).
  /// <p>
  /// Note that this is <b>not</b> the same definition as the SFS <tt>contains</tt>,
  /// which would exclude the envelope boundary.
  ///
  ///@param  other the <code>Envelope</code> to check
  ///@return true if <code>other</code> is contained in this <code>Envelope</code>
  ///
  ///@see #covers(Envelope)
  bool contains(Envelope other) {
  	return covers(other);
  }

  /// Tests if the given point lies in or on the envelope.
  /// <p>
  /// Note that this is <b>not</b> the same definition as the SFS <tt>contains</tt>,
  /// which would exclude the envelope boundary.
  ///
  ///@param  [p]  the point which this <code>Envelope</code> is
  ///      being checked for containing
  ///@return    <code>true</code> if the point lies in the interior or
  ///      on the boundary of this <code>Envelope</code>.
  ///      
  ///@see #covers(Coordinate)
  bool containsCoord(Coordinate p) {
    return coversCoord(p);
  }

  /// Tests if the given point lies in or on the envelope.
  /// <p>
  /// Note that this is <b>not</b> the same definition as the SFS <tt>contains</tt>,
  /// which would exclude the envelope boundary.
  ///
  ///@param  [x]  the x-coordinate of the point which this <code>Envelope</code> is
  ///      being checked for containing
  ///@param  [y]  the y-coordinate of the point which this <code>Envelope</code> is
  ///      being checked for containing
  ///@return    <code>true</code> if <code>(x, y)</code> lies in the interior or
  ///      on the boundary of this <code>Envelope</code>.
  ///      
  ///@see #covers(double, double)
  bool containsXY(double x, double y) {
  	return coversXY(x, y);
  }

  /// Tests if an envelope is properly contained in this one.
  /// The envelope is properly contained if it is contained 
  /// by this one but not equal to it.
  /// 
  /// @param [other] the envelope to test
  /// @return true if the envelope is properly contained
  bool containsProperly(Envelope other) {
    if (equals(other)) {
      return false;
    }
    return covers(other);
  }
  
  /// Tests if the given point lies in or on the envelope.
  ///
  ///@param  x  the x-coordinate of the point which this <code>Envelope</code> is
  ///      being checked for containing
  ///@param  y  the y-coordinate of the point which this <code>Envelope</code> is
  ///      being checked for containing
  ///@return    <code>true</code> if <code>(x, y)</code> lies in the interior or
  ///      on the boundary of this <code>Envelope</code>.
  bool coversXY(double x, double y) {
  	if (isNull()) return false;
    return x >= _minx &&
        x <= _maxx &&
        y >= _miny &&
        y <= _maxy;
  }

  /// Tests if the given point lies in or on the envelope.
  ///
  ///@param  p  the point which this <code>Envelope</code> is
  ///      being checked for containing
  ///@return    <code>true</code> if the point lies in the interior or
  ///      on the boundary of this <code>Envelope</code>.
  bool coversCoord(Coordinate p) {
    return coversXY(p.x, p.y);
  }

  /// Tests if the <code>Envelope other</code>
  /// lies wholely inside this <code>Envelope</code> (inclusive of the boundary).
  ///
  ///@param  other the <code>Envelope</code> to check
  ///@return true if this <code>Envelope</code> covers the <code>other</code> 
  bool covers(Envelope other) {
    if (isNull() || other.isNull()) { return false; }
    return other.getMinX() >= _minx &&
        other.getMaxX() <= _maxx &&
        other.getMinY() >= _miny &&
        other.getMaxY() <= _maxy;
  }

  /// Computes the distance between this and another
  /// <code>Envelope</code>.
  /// The distance between overlapping Envelopes is 0.  Otherwise, the
  /// distance is the Euclidean distance between the closest points.
  double distance(Envelope env)
  {
    if (intersectsWith(env)) return 0;
    
    double dx = 0.0;
    if (_maxx < env._minx) {
      dx = env._minx - _maxx;
    } else if (_minx > env._maxx) {
      dx = _minx - env._maxx;
    }
      
    
    double dy = 0.0;
    if (_maxy < env._miny) {
      dy = env._miny - _maxy;
    } else if (_miny > env._maxy) {
      dy = _miny - env._maxy;
    }

    // if either is zero, the envelopes overlap either vertically or horizontally
    if (dx == 0.0) return dy;
    if (dy == 0.0) return dx;
    return hypot(dx, dy);
  }

  bool equals(Object other) {
    if (other is! Envelope) {
      return false;
    }
    Envelope otherEnvelope = other;
    if (isNull()) {
      return otherEnvelope.isNull();
    }
    return _maxx == otherEnvelope.getMaxX() &&
        _maxy == otherEnvelope.getMaxY() &&
        _minx == otherEnvelope.getMinX() &&
        _miny == otherEnvelope.getMinY();
  }

  @override
  String toString(){
    return "Env[$_minx : $_maxx, $_miny : $_maxy]";
  }

  /// Compares two envelopes using lexicographic ordering.
  /// The ordering comparison is based on the usual numerical
  /// comparison between the sequence of ordinates.
  /// Null envelopes are less than all non-null envelopes.
  /// 
  /// @param o an Envelope object
  @override
  int compareTo(o) {
    Envelope env ;
    if (o is! Envelope) {
      return 0;
    }else{
      env = o;
    }
    // compare nulls if present
    if (isNull()) {
      if (env.isNull()) return 0;
      return -1;
    }
    else {
      if (env.isNull()) return 1;
    }
    // compare based on numerical ordering of ordinates
    if (_minx < env._minx) return -1;
    if (_minx > env._minx) return 1;
    if (_miny < env._miny) return -1;
    if (_miny > env._miny) return 1;
    if (_maxx < env._maxx) return -1;
    if (_maxx > env._maxx) return 1;
    if (_maxy < env._maxy) return -1;
    if (_maxy > env._maxy) return 1;
    return 0;
    
    
  }
  
  // @override
  // int get hashCode {
  //     //Algorithm from Effective Java by Joshua Bloch [Jon Aquino]
  //     int result = 17;
  //     result = 37 * result + Coordinate.hashCode(minx);
  //     result = 37 * result + Coordinate.hashCode(maxx);
  //     result = 37 * result + Coordinate.hashCode(miny);
  //     result = 37 * result + Coordinate.hashCode(maxy);
  //     return result;
  // }
  // @override
  // bool operator ==(Object other) {
  //   // TODO: implement ==
  //   return super == other;
  // }
}

