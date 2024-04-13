/*
 * Copyright (c) 2020 Martin Davis.
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
// import org.locationtech.jts.geom.CoordinateList;
// import org.locationtech.jts.math.MathUtil;
// import org.locationtech.jts.noding.MCIndexNoder;
// import org.locationtech.jts.noding.NodedSegmentString;
// import org.locationtech.jts.noding.Noder;
// import org.locationtech.jts.noding.SegmentString;

import 'package:jtscore4dart/src/geom/Coordinate.dart';
import 'package:jtscore4dart/src/geom/CoordinateList.dart';
import 'package:jtscore4dart/src/math/MathUtil.dart';
import 'package:jtscore4dart/src/noding/MCIndexNoder.dart';
import 'package:jtscore4dart/src/noding/NodedSegmentString.dart';
import 'package:jtscore4dart/src/noding/Noder.dart';
import 'package:jtscore4dart/src/noding/SegmentString.dart';

import 'SnappingIntersectionAdder.dart';
import 'SnappingPointIndex.dart';

/**
 * Nodes a set of segment strings
 * snapping vertices and intersection points together if
 * they lie within the given snap tolerance distance.
 * Vertices take priority over intersection points for snapping.
 * Input segment strings are generally only split at true node points
 * (i.e. the output segment strings are of maximal length in the output arrangement).
 * <p>
 * The snap tolerance should be chosen to be as small as possible
 * while still producing a correct result.
 * It probably only needs to be small enough to eliminate 
 * "nearly-coincident" segments, for which intersection points cannot be computed accurately.
 * This implies a factor of about 10e-12
 * smaller than the magnitude of the segment coordinates. 
 * <p>
 * With an appropriate snap tolerance this algorithm appears to be very robust.
 * So far no failure cases have been found, 
 * given a small enough snap tolerance.
 * <p>
 * The correctness of the output is not verified by this noder. 
 * If required this can be done by {@link org.locationtech.jts.noding.ValidatingNoder}.
 * 
 * @version 1.17
 */
class SnappingNoder implements Noder {
  /**private */ SnappingPointIndex snapIndex;
  /**private */ double snapTolerance;
  /**private */ List<NodedSegmentString>? nodedResult;

  /**
   * Creates a snapping noder using the given snap distance tolerance.
   * 
   * @param snapTolerance points are snapped if within this distance
   */
  SnappingNoder(this.snapTolerance)
      : snapIndex = new SnappingPointIndex(snapTolerance);

  /**
   * Gets the noded result.
   * 
	 * @return a Collection of NodedSegmentStrings representing the substrings
	 */
  @override
  Iterable<NodedSegmentString> getNodedSubstrings() {
    return nodedResult!;
  }

  /**
   * Computes the noding of a set of {@link SegmentString}s.
   * 
   * @param [inputSegStrings] a Collection of SegmentStrings
   */
  @override
  void computeNodes(Iterable<SegmentString> inputSegStrings) {
    List<NodedSegmentString> snappedSS = snapVertices(inputSegStrings);
    nodedResult = _snapIntersections(snappedSS) as List<NodedSegmentString>;
  }

  List<NodedSegmentString> snapVertices(Iterable<SegmentString> segStrings) {
    //Stopwatch sw = new Stopwatch(); sw.start();
    _seedSnapIndex(segStrings);

    List<NodedSegmentString> nodedStrings = <NodedSegmentString>[];
    for (SegmentString ss in segStrings) {
      nodedStrings.add(_snapVertices(ss));
    }
    //System.out.format("Index depth = %d   Time: %s\n", snapIndex.depth(), sw.getTimeString());
    return nodedStrings;
  }

  /**
   * Seeds the snap index with a small set of vertices 
   * chosen quasi-randomly using a low-discrepancy sequence.
   * Seeding the snap index KdTree induces a more balanced tree. 
   * This prevents monotonic runs of vertices
   * unbalancing the tree and causing poor query performance.
   *  
   * @param [segStrings] the segStrings to be noded
   */
  void _seedSnapIndex(Iterable<SegmentString> segStrings) {
    const int SEED_SIZE_FACTOR = 100;

    for (SegmentString ss in segStrings) {
      List<Coordinate> pts = ss.getCoordinates();
      int numPtsToLoad = pts.length ~/ SEED_SIZE_FACTOR;
      double rand = 0.0;
      for (int i = 0; i < numPtsToLoad; i++) {
        rand = MathUtil.quasirandom(rand);
        int index = (pts.length * rand).toInt();
        snapIndex.snap(pts[index]);
      }
    }
  }

  NodedSegmentString _snapVertices(SegmentString ss) {
    List<Coordinate> snapCoords = _snap(ss.getCoordinates());
    return new NodedSegmentString(snapCoords, ss.getData());
  }

  List<Coordinate> _snap(List<Coordinate> coords) {
    CoordinateList snapCoords = new CoordinateList();
    for (int i = 0; i < coords.length; i++) {
      Coordinate pt = snapIndex.snap(coords[i]);
      snapCoords.add(pt, false);
    }
    return snapCoords.toCoordinateArray();
  }

  /**
   * Computes all interior intersections in the collection of {@link SegmentString}s,
   * and returns their {@link Coordinate}s.
   *
   * Also adds the intersection nodes to the segments.
   *
   * @return a list of Coordinates for the intersections
   */
  Iterable _snapIntersections(List<NodedSegmentString> inputSS) {
    SnappingIntersectionAdder intAdder =
        new SnappingIntersectionAdder(snapTolerance, snapIndex);
    /**
     * Use an overlap tolerance to ensure all 
     * possible snapped intersections are found
     */
    MCIndexNoder noder = new MCIndexNoder(intAdder, 2 * snapTolerance);
    noder.computeNodes(inputSS);
    return noder.getNodedSubstrings();
  }
}
