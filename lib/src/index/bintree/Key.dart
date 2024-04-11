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

// import org.locationtech.jts.index.quadtree.DoubleBits;

import 'package:jtscore4dart/src/index/quadtree/DoubleBits.dart';

import 'Interval.dart';

/// A Key is a unique identifier for a node in a tree.
/// It contains a lower-left point and a level number. The level number
/// is the power of two for the size of the node envelope
///
/// @version 1.7
class Key {

  static int computeLevel(Interval interval)
  {
    double dx = interval.getWidth();
    //int level = BinaryPower.exponent(dx) + 1;
    int level = DoubleBits.exponent(dx) + 1;
    return level;
  }


  // the fields which make up the key
  double _pt = 0.0;
  int _level = 0;
  // auxiliary data which is derived from the key for use in computation
  late Interval _interval;

  Key(Interval interval)
  {
    computeKey(interval);
  }

  double getPoint() { return _pt; }
  int getLevel() { return _level; }
  Interval getInterval() { return _interval; }

  /// return a square envelope containing the argument envelope,
  /// whose extent is a power of two and which is based at a power of 2
  void computeKey(Interval itemInterval)
  {
    _level = computeLevel(itemInterval);
    _interval = Interval.empty();
    _computeInterval(_level, itemInterval);
    // MD - would be nice to have a non-iterative form of this algorithm
    while (! _interval.contains(itemInterval)) {
      _level += 1;
      _computeInterval(_level, itemInterval);
    }
  }

  void _computeInterval(int level, Interval itemInterval)
  {
    double size = DoubleBits.powerOf2(level);
    //double size = pow2.power(level);
    _pt = (itemInterval.getMin() / size).floor() * size;
    _interval.init(_pt, _pt + size);
  }
}
