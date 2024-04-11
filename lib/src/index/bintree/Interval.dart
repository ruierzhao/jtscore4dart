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

/// Represents an (1-dimensional) closed interval on the Real number line.
///
/// @version 1.7
class Interval {
  double min, max;

  Interval(this.min, this.max) {
    var _temp = min;
    if (min > max) {
      min = max;
      max = _temp;
    }
  }

  Interval.empty()
      : max = 0.0,
        min = 0.0;

  Interval.fromAnother(Interval interval)
      : min = interval.getMin(),
        max = interval.getMax();

  void init(double min, double max) {
    this.min = min;
    this.max = max;
    if (min > max) {
      this.min = max;
      this.max = min;
    }
  }

  double getMin() {
    return min < max ? min : max;
  }

  double getMax() {
    return min < max ? max : min;
  }

  double getWidth() {
    return getMax() - getMin();
  }

  void expandToInclude(Interval interval) {
    if (interval.max > max) max = interval.max;
    if (interval.min < min) min = interval.min;
  }

  bool overlaps(Interval interval) {
    if (min > interval.max || max < interval.min) return false;
    return true;
  }

  // @ruier edit
  bool overlaps2number(double min, double max) {
    return overlaps(Interval(min, max));
  }

  bool contains(Interval interval) {
    return contains2number(interval.min, interval.max);
  }

  bool contains2number(double min, double max) {
    return (min >= this.min && max <= this.max);
  }

  bool contains1number(double p) {
    return (p >= min && p <= max);
  }

  String toString() {
    return "[$min, $max]";
  }
}
