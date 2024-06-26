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
 * @version 1.7
 */
class SweepLineInterval {

 /**private */double min, max;
 /**private */Object item;

  SweepLineInterval(double min, double max)
  {
    this(min, max, null);
  }

  SweepLineInterval(double min, double max, Object item)
  {
    this.min = min < max ? min : max;
    this.max = max > min ? max : min;
    this.item = item;
  }

  double getMin() { return min;  }
  double getMax() { return max;  }
  Object getItem() { return item; }

}
