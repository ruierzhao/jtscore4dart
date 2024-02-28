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
 * Indicates an invalid or inconsistent topological situation encountered during processing
 *
 * @version 1.7
 */
class TopologyException
  extends RuntimeException
{
  private static String msgWithCoord(String msg, Coordinate pt)
  {
    if (pt != null)
      return msg + " [ " + pt + " ]";
    return msg;
  }

  private Coordinate pt = null;

  TopologyException(String msg)
  {
    super(msg);
  }

  TopologyException(String msg, Coordinate pt)
  {
    super(msgWithCoord(msg, pt));
    this.pt = new Coordinate(pt);
  }

  Coordinate getCoordinate() { return pt; }

}
