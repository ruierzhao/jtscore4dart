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
// import java.util.HashSet;
// import java.util.List;
// import java.util.Set;

// import org.locationtech.jts.geom.Coordinate;
// import org.locationtech.jts.geom.CoordinateSequence;
// import org.locationtech.jts.geom.CoordinateSequenceFilter;
// import org.locationtech.jts.geom.Envelope;
// import org.locationtech.jts.geom.Geometry;
// import org.locationtech.jts.geom.GeometryFactory;
// import org.locationtech.jts.geom.LineSegment;
// import org.locationtech.jts.geom.util.GeometryCombiner;

import 'package:jtscore4dart/geometry.dart';
import 'package:jtscore4dart/src/geom/CoordinateSequenceFilter.dart';
import 'package:jtscore4dart/src/geom/util/GeometryCombiner.dart';
import 'package:jtscore4dart/src/patch/ArrayList.dart';

import 'CascadedPolygonUnion.dart';
import 'UnionStrategy.dart';

/**
 * Unions MultiPolygons efficiently by
 * using full topological union only for polygons which may overlap,
 * and combining with the remaining polygons.
 * Polygons which may overlap are those which intersect the common extent of the inputs.
 * Polygons wholly outside this extent must be disjoint to the computed union.
 * They can thus be simply combined with the union result,
 * which is much more performant.
 * (There is one caveat to this, which is discussed below).
 * <p>
 * This situation is likely to occur during cascaded polygon union,
 * since the partitioning of polygons is done heuristically
 * and thus may group disjoint polygons which can lie far apart.
 * It may also occur in real world data which contains many disjoint polygons
 * (e.g. polygons representing parcels on different street blocks).
 * 
 * <h2>Algorithm</h2>
 * The overlap region is determined as the common envelope of intersection.
 * The input polygons are partitioned into two sets:
 * <ul>
 * <li>Overlapping: Polygons which intersect the overlap region, and thus potentially overlap each other
 * <li>Disjoint: Polygons which are disjoint from (lie wholly outside) the overlap region
 * </ul>
 * The Overlapping set is fully unioned, and then combined with the Disjoint set.
 * Performing a simple combine works because 
 * the disjoint polygons do not interact with each
 * other (since the inputs are valid MultiPolygons).
 * They also do not interact with the Overlapping polygons, 
 * since they are outside their envelope.
 * 
 * <h2>Discussion</h2>
 * In general the Overlapping set of polygons will 
 * extend beyond the overlap envelope.  This means that the union result
 * will extend beyond the overlap region.
 * There is a small chance that the topological 
 * union of the overlap region will shift the result linework enough
 * that the result geometry intersects one of the Disjoint geometries.
 * This situation is detected and if it occurs 
 * is remedied by falling back to performing a full union of the original inputs.
 * Detection is done by a fairly efficient comparison of edge segments which
 * extend beyond the overlap region.  If any segments have changed
 * then there is a risk of introduced intersections, and full union is performed.
 * <p>
 * This situation has not been observed in JTS using floating precision, 
 * but it could happen due to snapping.  It has been observed 
 * in other APIs (e.g. GEOS) due to more aggressive snapping.
 * It is more likely to happen if a Snap-Rounding overlay is used.
 * <p>
 * <b>NOTE: Test has shown that using this heuristic impairs performance.
 * It has been removed from use.</b>
 * 
 * 
 * @author mbdavis
 * 
 * @deprecated due to impairing performance
 * 
 */
class OverlapUnion {
  /**
   * Union a pair of geometries,
   * using the more performant overlap union algorithm if possible.
   * 
   * @param [g0] a geometry to union
   * @param [g1] a geometry to union
   * @param [unionFun] 
   * @return the union of the inputs
   */
  static Geometry unionS(Geometry g0, Geometry g1, UnionStrategy unionFun) {
    OverlapUnion union = new OverlapUnion(g0, g1, unionFun);
    return union.union();
  }

  /**private */ GeometryFactory geomFactory;

  /**private */ Geometry g0;
  /**private */ Geometry g1;

  /**private */ late bool isUnionSafe;

  /**private */ UnionStrategy unionFun;

  /**
   * Creates a new instance for unioning the given geometries.
   * 
   * @param g0 a geometry to union
   * @param g1 a geometry to union
   */
  // OverlapUnion(Geometry g0, Geometry g1)
  // {
  // 	this(g0, g1, CascadedPolygonUnion.CLASSIC_UNION);
  // }

  OverlapUnion(this.g0, this.g1, [UnionStrategy? unionFun])
      : geomFactory = g0.getFactory(),
        this.unionFun = (unionFun ??= CascadedPolygonUnion.CLASSIC_UNION);

  /**
   * Unions the input geometries,
   * using the more performant overlap union algorithm if possible.	 
   * 
   * @return the union of the inputs
	 */
  Geometry union() {
    // 获取相交部分的Envelop
    Envelope overlapEnv = overlapEnvelope(g0, g1);

    /**
     * If no overlap, can just combine the geometries
     */
    if (overlapEnv.isNull()) {
      Geometry g0Copy = g0.copy();
      Geometry g1Copy = g1.copy();
      return GeometryCombiner.combine(g0Copy, g1Copy);
    }

    // 收集不相交的部分
    List<Geometry> disjointPolys = <Geometry>[];

    Geometry g0Overlap = _extractByEnvelope(overlapEnv, g0, disjointPolys);
    Geometry g1Overlap = _extractByEnvelope(overlapEnv, g1, disjointPolys);

//    System.out.println("# geoms in common: " + intersectingPolys.size());
    Geometry unionGeom = unionFull(g0Overlap, g1Overlap);
    print('>>>>>>>>> unionGeom: ${ unionGeom } <<<<<<<<<<<<<<<<<<<<');

    Geometry? result = null;
    isUnionSafe = isBorderSegmentsSame(unionGeom, overlapEnv);
    // if (!isUnionSafe) {
    if (!isUnionSafe) {
      // overlap union changed border segments... need to do full union
      //System.out.println("OverlapUnion: Falling back to full union");
      result = unionFull(g0, g1);
    } else {
      //System.out.println("OverlapUnion: fast path");
      result = combine(unionGeom, disjointPolys);
      print('>>>>>>>>> result2: ${result} <<<<<<<<<<<<<<<<<<<<');
    }
    return result;
  }

  /**
	 * Allows checking whether the optimized
	 * or full union was performed.
	 * Used for unit testing.
	 * 
	 * @return true if the optimized union was performed
	 */
  bool isUnionOptimized() {
    return isUnionSafe;
  }

  /**private */ static Envelope overlapEnvelope(Geometry g0, Geometry g1) {
    Envelope g0Env = g0.getEnvelopeInternal();
    Envelope g1Env = g1.getEnvelopeInternal();
    Envelope overlapEnv = g0Env.intersection(g1Env);
    return overlapEnv;
  }

  /**private */ Geometry combine(
      Geometry unionGeom, List<Geometry> disjointPolys) {
    // if (disjointPolys.size() <= 0)
    if (disjointPolys.isEmpty) {
      return unionGeom;
    }

    disjointPolys.add(unionGeom);
    Geometry result = GeometryCombiner.combineAll(disjointPolys);
    return result;
  }

  /// 通过envelop 抽取相交和不相交的Geometry
  /**private */ Geometry _extractByEnvelope(
      Envelope env, Geometry geom, List<Geometry> disjointGeoms) {
    // List<Geometry> intersectingGeoms = new ArrayList<Geometry>();
    List<Geometry> intersectingGeoms = <Geometry>[];
    for (int i = 0; i < geom.getNumGeometries(); i++) {
      Geometry elem = geom.getGeometryN(i);
      if (elem.getEnvelopeInternal().intersects(env)) {
        intersectingGeoms.add(elem);
      } else {
        Geometry copy = elem.copy();
        disjointGeoms.add(copy);
      }
    }
    return geomFactory.buildGeometry(intersectingGeoms);
  }

  /**private */ Geometry unionFull(Geometry geom0, Geometry geom1) {
    // if both are empty collections, just return a copy of one of them
    if (geom0.getNumGeometries() == 0 && geom1.getNumGeometries() == 0) {
      return geom0.copy();
    }

    Geometry union = unionFun.union(geom0, geom1);
    return union;
  }

  /**private */ bool isBorderSegmentsSame(Geometry result, Envelope env) {
    List<LineSegment> segsBefore = __extractBorderSegments(g0, g1, env);
    // print("before");
    // for (final it = segsBefore.iterator; it.moveNext();) {
    //   print(it.current);
    // }

    List<LineSegment> segsAfter = <LineSegment>[];
    _extractBorderSegments(result, env, segsAfter);
    // print("after");
    // for (final it = segsAfter.iterator; it.moveNext();) {
    //   print(it.current);
    // }

    //System.out.println("# seg before: " + segsBefore.size() + " - # seg after: " + segsAfter.size());
    return _isEqual(segsBefore, segsAfter);
  }

  bool _isEqual(List<LineSegment> segs0, List<LineSegment> segs1) {
    if (segs0.size() != segs1.size()) {
      return false;
    }

    // Set<LineSegment> segIndex = new HashSet<LineSegment>(segs0);
    Set<LineSegment> segIndex = new Set<LineSegment>.from(segs0);

    for (LineSegment seg in segs1) {
      if (!segIndex.contains(seg)) {
        //System.out.println("Found changed border seg: " + seg);
        return false;
      }
    }
    return true;
  }

  List<LineSegment> __extractBorderSegments(
      Geometry geom0, Geometry? geom1, Envelope env) {
    List<LineSegment> segs = [];
    _extractBorderSegments(geom0, env, segs);
    print('>>>>>>>>> it.current: <<<<<<<<<<<<<<<<<<<<');
    for (final it = segs.iterator; it.moveNext();){
      print(it.current);
    }
    if (geom1 != null) {
      _extractBorderSegments(geom1, env, segs);
    }
    return segs;
  }

  static bool _intersects(Envelope env, Coordinate p0, Coordinate p1) {
    return env.intersectsWithCoord(p0) || env.intersectsWithCoord(p1);
  }

  /**private */ static bool containsProperly(
      Envelope env, Coordinate p0, Coordinate p1) {
    return _containsProperly(env, p0) && _containsProperly(env, p1);
  }

  static bool _containsProperly(Envelope env, Coordinate p) {
    if (env.isNull()) return false;
    return p.getX() > env.getMinX() &&
        p.getX() < env.getMaxX() &&
        p.getY() > env.getMinY() &&
        p.getY() < env.getMaxY();
  }

  static void _extractBorderSegments(
      Geometry geom, Envelope env, List<LineSegment> segs) {
    geom.applyCoordSeq(_(env, segs));
  }
}

class _ implements CoordinateSequenceFilter {
  final Envelope env;
  final List<LineSegment> segs;

  _(this.env, this.segs);

  @override
  void filter(CoordinateSequence seq, int i) {
    if (i <= 0) return;

    // extract LineSegment
    Coordinate p0 = seq.getCoordinate(i - 1);
    Coordinate p1 = seq.getCoordinate(i);
    bool isBorder = OverlapUnion._intersects(env, p0, p1) &&
        !OverlapUnion.containsProperly(env, p0, p1);
    if (isBorder) {
      LineSegment seg = new LineSegment(p0, p1);
      segs.add(seg);
    }
  }

  @override
  bool isDone() {
    return false;
  }

  @override
  bool isGeometryChanged() {
    return false;
  }
}
