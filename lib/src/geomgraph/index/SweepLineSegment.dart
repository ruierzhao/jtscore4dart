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
// import org.locationtech.jts.geomgraph.Edge;

import 'package:jtscore4dart/src/geom/Coordinate.dart';
import 'package:jtscore4dart/src/geomgraph/Edge.dart';

import 'SegmentIntersector.dart';

/**
 * @version 1.7
 */
class SweepLineSegment {
  Edge edge;
  List<Coordinate> pts;
  int ptIndex;

  SweepLineSegment(this.edge, this.ptIndex) : pts = edge.getCoordinates();

  double getMinX() {
    double x1 = pts[ptIndex].x;
    double x2 = pts[ptIndex + 1].x;
    return x1 < x2 ? x1 : x2;
  }

  double getMaxX() {
    double x1 = pts[ptIndex].x;
    double x2 = pts[ptIndex + 1].x;
    return x1 > x2 ? x1 : x2;
  }

  void computeIntersections(SweepLineSegment ss, SegmentIntersector si) {
    si.addIntersections(edge, ptIndex, ss.edge, ss.ptIndex);
  }
}
