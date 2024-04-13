/*
 * Copyright (c) 2019 Martin Davis.
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
// import java.util.List;

// import org.locationtech.jts.geom.Coordinate;

import 'package:jtscore4dart/src/geom/Coordinate.dart';

import 'BasicSegmentString.dart';
import 'Noder.dart';
import 'SegmentString.dart';

/**
 * A noder which extracts all line segments 
 * as {@link SegmentString}s.
 * This enables fast overlay of geometries which are known to be already fully noded.
 * In particular, it provides fast union of polygonal and linear coverages.
 * Unioning a noded set of lines is an effective way 
 * to perform line merging and line dissolving.
 * <p>
 * No precision reduction is carried out. 
 * If that is required, another noder must be used (such as a snap-rounding noder),
 * or the input must be precision-reduced beforehand.
 * 
 * @author Martin Davis
 *
 */
class SegmentExtractingNoder implements Noder {
  /**private */ List<SegmentString> segList = [];

  /**
   * Creates a new segment-extracting noder.
   */
  // SegmentExtractingNoder() {

  // }

  @override
  void computeNodes(Iterable<SegmentString> segStrings) {
    segList = extractSegments(segStrings);
  }

  /**private */ static List<SegmentString> extractSegments(
      Iterable<SegmentString> segStrings) {
    List<SegmentString> segList = <SegmentString>[];
    for (SegmentString ss in segStrings) {
      _extractSegments(ss, segList);
    }
    return segList;
  }

  /**private */ static void _extractSegments(
      SegmentString ss, List<SegmentString> segList) {
    for (int i = 0; i < ss.size() - 1; i++) {
      Coordinate p0 = ss.getCoordinate(i);
      Coordinate p1 = ss.getCoordinate(i + 1);
      SegmentString seg = new BasicSegmentString(
          new List<Coordinate>.from([p0, p1], growable: false), ss.getData());
      segList.add(seg);
    }
  }

  @override
  Iterable<SegmentString> getNodedSubstrings() {
    return segList;
  }
}
