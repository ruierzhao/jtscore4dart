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

import "package:jtscore4dart/src/geom/Coordinate.dart";
import "package:jtscore4dart/src/geom/LineSegment.dart";

import 'BasicSegmentString.dart';
import 'Noder.dart';
import 'SegmentString.dart';

/**
 * A noder which extracts chains of boundary segments 
 * as {@link SegmentString}s from a polygonal coverage.
 * Boundary segments are those which are not duplicated in the input polygonal coverage.
 * Extracting chains of segments minimize the number of segment strings created,
 * which produces a more efficient topological graph structure.
 * <p>
 * This enables fast overlay of polygonal coverages in {@link CoverageUnion}.
 * Using this noder is faster than {@link SegmentExtractingNoder}
 * and {@link BoundarySegmentNoder}.
 * <p>
 * No precision reduction is carried out. 
 * If that is required, another noder must be used (such as a snap-rounding noder),
 * or the input must be precision-reduced beforehand.
 * 
 * @author Martin Davis
 *
 */
class BoundaryChainNoder implements Noder {
  /**private */ List<SegmentString> chainList = [];

  /**
   * Creates a new boundary-extracting noder.
   */
  // BoundaryChainNoder() {

  // }

  @override
  void computeNodes(Iterable<SegmentString> segStrings) {
    HashSet<Segment> segSet = new HashSet<Segment>();
    // List<BoundaryChainMap> boundaryChains = new BoundaryChainMap[segStrings.size()];

    var _boundaryChains = __addSegments(segStrings, segSet);
    _markBoundarySegments(segSet);
    chainList = _extractChains(_boundaryChains);
  }

  static List<BoundaryChainMap> __addSegments(
      Iterable<SegmentString> segStrings, HashSet<Segment> segSet) {
    List<SegmentString> cc = List.from(segStrings, growable: false);
    List<BoundaryChainMap> _boundaryChains =
        List.generate(segStrings.length, (index) {
      return BoundaryChainMap(cc[index]);
    }, growable: false);
    // int i = 0;
    // for (SegmentString ss in segStrings) {
    //   BoundaryChainMap chainMap = new BoundaryChainMap(ss);
    //   boundaryChains[i++] = chainMap;
    //   _addSegments( ss, chainMap, segSet );
    // }
    return _boundaryChains;
  }

  static void _addSegments(SegmentString segString, BoundaryChainMap chainMap,
      HashSet<Segment> segSet) {
    for (int i = 0; i < segString.size() - 1; i++) {
      Coordinate p0 = segString.getCoordinate(i);
      Coordinate p1 = segString.getCoordinate(i + 1);
      Segment seg = new Segment(p0, p1, chainMap, i);
      if (segSet.contains(seg)) {
        segSet.remove(seg);
      } else {
        segSet.add(seg);
      }
    }
  }

  static void _markBoundarySegments(HashSet<Segment> segSet) {
    for (Segment seg in segSet) {
      seg.markBoundary();
    }
  }

  static List<SegmentString> _extractChains(
      List<BoundaryChainMap> boundaryChains) {
    // List<SegmentString> chainList = new ArrayList<SegmentString>();
    List<SegmentString> chainList = <SegmentString>[];
    for (BoundaryChainMap chainMap in boundaryChains) {
      chainMap.createChains(chainList);
    }
    return chainList;
  }

  @override
  Iterable<SegmentString> getNodedSubstrings() {
    return chainList;
  }
}

/**private static */
class BoundaryChainMap {
  /**private */ SegmentString segString;
  /**private */ List<bool> isBoundary;

  BoundaryChainMap(this.segString)
      :
        // isBoundary = new bool[ss.size() - 1];
        isBoundary = List.filled(segString.size() - 1, false);

  void setBoundarySegment(int index) {
    isBoundary[index] = true;
  }

  void createChains(List<SegmentString> chainList) {
    int endIndex = 0;
    while (true) {
      int startIndex = findChainStart(endIndex);
      if (startIndex >= segString.size() - 1) {
        break;
      }
      endIndex = findChainEnd(startIndex);
      SegmentString ss = _createChain(segString, startIndex, endIndex);
      chainList.add(ss);
    }
  }

  /**private */ static SegmentString _createChain(
      SegmentString segString, int startIndex, int endIndex) {
    // List<Coordinate> pts = new Coordinate[endIndex - startIndex + 1];
    List<Coordinate> pts = [];

    // int ipts = 0;
    for (int i = startIndex; i < endIndex + 1; i++) {
      // pts[ipts++] = segString.getCoordinate(i).copy();
      /// TODO: @ruier edit. Array 优化。。。。
      pts.add(segString.getCoordinate(i).copy());
    }

    return new BasicSegmentString(pts, segString.getData());
  }

  /**private */ int findChainStart(int index) {
    while (index < isBoundary.length && !isBoundary[index]) {
      index++;
    }
    return index;
  }

  /**private */ int findChainEnd(int index) {
    index++;
    while (index < isBoundary.length && isBoundary[index]) {
      index++;
    }
    return index;
  }
}

/**private static*/
class Segment extends LineSegment {
  /**private */ BoundaryChainMap segMap;
  /**private */ int index;

  Segment(super.p0, super.p1, this.segMap, this.index) {
    normalize();
  }

  void markBoundary() {
    segMap.setBoundarySegment(index);
  }
}
