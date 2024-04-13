/*
 * Copyright (c) 2022 Martin Davis.
 *
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License 2.0
 * and Eclipse Distribution License v. 1.0 which accompanies this distribution.
 * The Eclipse Public License is available at http://www.eclipse.org/legal/epl-v20.html
 * and the Eclipse Distribution License is available at
 *
 * http://www.eclipse.org/org/documents/edl-v10.php.
 */

// import java.util.ArrayList;
// import java.util.Collection;
// import java.util.HashSet;
// import java.util.List;

// import org.locationtech.jts.geom.Coordinate;
// import org.locationtech.jts.geom.LineSegment;

import 'dart:collection';

import 'package:jtscore4dart/src/geom/Coordinate.dart';
import 'package:jtscore4dart/src/geom/LineSegment.dart';

import 'BasicSegmentString.dart';
import 'Noder.dart';
import 'SegmentString.dart';

/**
 * A noder which extracts boundary line segments 
 * as {@link SegmentString}s.
 * Boundary segments are those which are not duplicated in the input.
 * It is appropriate for use with valid polygonal coverages.
 * <p>
 * No precision reduction is carried out. 
 * If that is required, another noder must be used (such as a snap-rounding noder),
 * or the input must be precision-reduced beforehand.
 * 
 * @author Martin Davis
 *
 */
class BoundarySegmentNoder implements Noder {
  /**private */ List<SegmentString>? segList;

  /**
   * Creates a new segment-dissolving noder.
   */
  // BoundarySegmentNoder() {

  // }

  @override
  void computeNodes(Iterable<SegmentString> segStrings) {
    HashSet<Segment> segSet = new HashSet<Segment>();
    addSegments(segStrings, segSet);
    segList = extractSegments(segSet);
  }

  /**private */ static void addSegments(
      Iterable<SegmentString> segStrings, HashSet<Segment> segSet) {
    for (SegmentString ss in segStrings) {
      _addSegments(ss, segSet);
    }
  }

  /**private */ static void _addSegments(
      SegmentString segString, HashSet<Segment> segSet) {
    for (int i = 0; i < segString.size() - 1; i++) {
      Coordinate p0 = segString.getCoordinate(i);
      Coordinate p1 = segString.getCoordinate(i + 1);
      Segment seg = new Segment(p0, p1, segString, i);
      if (segSet.contains(seg)) {
        segSet.remove(seg);
      } else {
        segSet.add(seg);
      }
    }
  }

  /**private */ static List<SegmentString> extractSegments(
      HashSet<Segment> segSet) {
    List<SegmentString> segList = <SegmentString>[];
    for (Segment seg in segSet) {
      SegmentString ss = seg.getSegmentString();
      int i = seg.getIndex();
      Coordinate p0 = ss.getCoordinate(i);
      Coordinate p1 = ss.getCoordinate(i + 1);
      SegmentString segStr = new BasicSegmentString(
          List.from([p0, p1], growable: false), ss.getData());
      segList.add(segStr);
    }
    return segList;
  }

  @override
  Iterable<SegmentString> getNodedSubstrings() {
    return segList!;
  }
}

/**static */
class Segment extends LineSegment {
  /**private */ SegmentString segStr;
  /**private */ int index;

  Segment(super.p0, super.p1, this.segStr, this.index) {
    normalize();
  }

  SegmentString getSegmentString() {
    return segStr;
  }

  int getIndex() {
    return index;
  }
}
