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
// import org.locationtech.jts.geom.impl.CoordinateArraySequence;
// import org.locationtech.jts.io.WKTWriter;

import 'package:jtscore4dart/io.dart';
import 'package:jtscore4dart/src/geom/Coordinate.dart';
import 'package:jtscore4dart/src/geom/impl/CoordinateArraySequence.dart';

import 'Octant.dart';
import 'SegmentString.dart';

/**
 * Represents a read-only list of contiguous line segments.
 * This can be used for detection of intersections or nodes.
 * {@link SegmentString}s can carry a context object, which is useful
 * for preserving topological or parentage information.
 * <p>
 * If adding nodes is required use {@link NodedSegmentString}.
 *
 * @version 1.7
 * @see NodedSegmentString
 */
class BasicSegmentString
	extends SegmentString 
	// implements SegmentString 
{
 /**private */List<Coordinate> pts;
 /**private */Object data;

  /**
   * Creates a new segment string from a list of vertices.
   *
   * @param pts the vertices of the segment string
   * @param data the user-defined data of this segment string (may be null)
   */
  BasicSegmentString(this.pts, this.data);

  /**
   * Gets the user-defined data for this segment string.
   *
   * @return the user-defined data
   */
  @override
  Object getData() { return data; }

  /**
   * Sets the user-defined data for this segment string.
   *
   * @param data an Object containing user-defined data
   */
  @override
  void setData(Object data) { this.data = data; }

  @override
  int size() { return pts.length; }
  @override
  Coordinate getCoordinate(int i) { return pts[i]; }
  @override
  List<Coordinate> getCoordinates() { return pts; }

  @override
  bool isClosed()
  {
    return pts[0].equals(pts[pts.length - 1]);
  }

  /**
   * Gets the octant of the segment starting at vertex <code>index</code>.
   *
   * @param index the index of the vertex starting the segment.  Must not be
   * the last index in the vertex list
   * @return the octant of the segment at the vertex
   */
  int getSegmentOctant(int index)
  {
    if (index == pts.length - 1) return -1;
    return Octant.octant(getCoordinate(index), getCoordinate(index + 1));
  }

  @override
  String toString()
  {
    // return WKTWriter.toLineString(new CoordinateArraySequence(pts));
    return WKTWriter.toLineString(pts);
  }
}
