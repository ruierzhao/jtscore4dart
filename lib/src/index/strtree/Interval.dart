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


// import org.locationtech.jts.util.Assert;

/**
 * A contiguous portion of 1D-space. Used internally by SIRtree.
 * @see SIRtree
 *
 * @version 1.7
 */
class Interval {

  Interval(Interval other) {
    this(other.min, other.max);
  }

  Interval(double min, double max) {
    Assert.isTrue(min <= max);
    this.min = min;
    this.max = max;
  }

 /**private */double min;
 /**private */double max;

  double getCentre() { return (min+max)/2; }

  /**
   * @return this
   */
  Interval expandToInclude(Interval other) {
    max = math.max(max, other.max);
    min = math.min(min, other.min);
    return this;
  }

  bool intersects(Interval other) {
    return !(other.min > max || other.max < min);
  }
  
  bool equals(Object o) {
    if (! (o is Interval)) { return false; }
    Interval other = (Interval) o;
    return min == other.min && max == other.max;
  }
  
  /* (non-Javadoc)
   * @see java.lang.Object#hashCode()
   */
  @Override
  int hashCode() {
    final int prime = 31;
    int result = 1;
    int temp;
    temp = Double.doubleToLongBits(max);
    result = prime * result + (int) (temp ^ (temp >>> 32));
    temp = Double.doubleToLongBits(min);
    result = prime * result + (int) (temp ^ (temp >>> 32));
    return result;
  }
}
