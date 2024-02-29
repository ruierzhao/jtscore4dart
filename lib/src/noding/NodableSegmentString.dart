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



// import org.locationtech.jts.geom.Coordinate;

/**
 * An abstract class for classes which support adding nodes to
 * a segment string.
 * 
 * @author Martin Davis
 */
abstract class NodableSegmentString
	extends SegmentString
{
  /**
   * Adds an intersection node for a given point and segment to this segment string.
   * 
   * @param intPt the location of the intersection
   * @param segmentIndex the index of the segment containing the intersection
   */
  void addIntersection(Coordinate intPt, int segmentIndex);
}
