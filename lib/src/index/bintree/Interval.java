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


/**
 * Represents an (1-dimensional) closed interval on the Real number line.
 *
 * @version 1.7
 */
class Interval {

  double min, max;

  Interval()
  {
    min = 0.0;
    max = 0.0;
  }

  Interval(double min, double max)
  {
    init(min, max);
  }
  Interval(Interval interval)
  {
    init(interval.min, interval.max);
  }
  void init(double min, double max)
  {
    this.min = min;
    this.max = max;
    if (min > max) {
      this.min = max;
      this.max = min;
    }
  }
  double getMin() { return min; }
  double getMax() { return max; }
  double getWidth() { return max - min; }

  void expandToInclude(Interval interval)
  {
    if (interval.max > max) max = interval.max;
    if (interval.min < min) min = interval.min;
  }
  bool overlaps(Interval interval)
  {
    return overlaps(interval.min, interval.max);
  }

  bool overlaps(double min, double max)
  {
    if (this.min > max || this.max < min) return false;
    return true;
  }

  bool contains(Interval interval)
  {
    return contains(interval.min, interval.max);
  }
  bool contains(double min, double max)
  {
    return (min >= this.min && max <= this.max);
  }
  bool contains(double p)
  {
    return (p >= this.min && p <= this.max);
  }

  String toString()
  {
    return "[" + min + ", " + max + "]";
  }
}
