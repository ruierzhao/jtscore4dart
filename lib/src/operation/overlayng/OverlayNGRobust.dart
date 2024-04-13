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

// import java.util.Collection;

// import org.locationtech.jts.geom.Envelope;
// import org.locationtech.jts.geom.Geometry;
// import org.locationtech.jts.geom.GeometryFactory;
// import org.locationtech.jts.geom.PrecisionModel;
// import org.locationtech.jts.geom.TopologyException;
// import org.locationtech.jts.noding.ValidatingNoder;
// import org.locationtech.jts.noding.snap.SnappingNoder;
// import org.locationtech.jts.operation.union.UnaryUnionOp;
// import org.locationtech.jts.operation.union.UnionStrategy;

import "dart:math";

import "package:jtscore4dart/src/geom/Envelope.dart";
import "package:jtscore4dart/src/geom/Geometry.dart";
import "package:jtscore4dart/src/geom/GeometryFactory.dart";
import "package:jtscore4dart/src/geom/PrecisionModel.dart";
import "package:jtscore4dart/src/geom/TopologyException.dart";
import "package:jtscore4dart/src/noding/snap/SnappingNoder.dart";

import "../union/UnaryUnionOp.dart";
import "../union/UnionStrategy.dart";
import "OverlayNG.dart";
import "PrecisionUtil.dart";

class _UnionStrategy implements UnionStrategy {
  @override
  Geometry union(Geometry g0, Geometry g1) {
    return OverlayNGRobust.overlay(g0, g1, OverlayNG.UNION);
  }

  @override
  bool isFloatingPrecision() {
    return true;
  }
}

/**
 * Performs an overlay operation using {@link [OverlayNG]}, 
 * providing full robustness by using a series of
 * increasingly robust (but slower) noding strategies.
 * <p>
 * The noding strategies used are:
 * <ol>
 * <li>A simple, fast noder using FLOATING precision.
 * <li>A {@link [SnappingNoder]} using an automatically-determined snap tolerance
 * <li>First snapping each geometry to itself, 
 * and then overlaying them using a <code>[SnappingNoder]</code>.
 * <li>The above two strategies are repeated with increasing snap tolerance, up to a limit.
 * <li>Finally a {@link org.locationtech.jts.noding.snapround.[SnapRoundingNoder]} is used with a automatically-determined scale factor
 *     intended to preserve input precision while still preventing robustness problems.
 * </ol>
 * If all of the above attempts fail to compute a valid overlay, 
 * the original {@link [TopologyException]} is thrown. 
 * In practice this is extremely unlikely to occur.
 * <p>
 * This algorithm relies on each overlay operation execution 
 * throwing a {@link [TopologyException]} if it is unable
 * to compute the overlay correctly.
 * Generally this occurs because the noding phase does 
 * not produce a valid noding.
 * This requires the use of a {@link [ValidatingNoder]}
 * in order to check the results of using a floating noder.
 * 
 * @author Martin Davis
 * 
 * @see [OverlayNG]
 */
class OverlayNGRobust {
  /**
   * Computes the unary union of a geometry using robust computation.
   * 
   * @param [geom] the geometry to union
   * @return the union result
   * 
   * @see UnaryUnionOp
   */
  static Geometry union(Geometry geom) {
    UnaryUnionOp op = new UnaryUnionOp(geom);
    op.setUnionFunction(OVERLAY_UNION);
    return op.union_();
  }

  /**
   * Computes the unary union of a collection of geometries using robust computation.
   * 
   * @param geoms the collection of geometries to union
   * @return the union result
   * 
   * @see UnaryUnionOp
   */
  // static Geometry unionAll(Iterable<Geometry> geoms) {
  //   UnaryUnionOp op = new UnaryUnionOp.all(geoms);
  //   op.setUnionFunction(OVERLAY_UNION);
  //   return op.union_();
  // }

  /**
   * Computes the unary union of a collection of geometries using robust computation.
   * 
   * @param [geoms] the collection of geometries to union
   * @param [geomFact] the geometry factory to use
   * @return the union of the geometries
   */
  static Geometry unionAll(Iterable<Geometry> geoms,
      [GeometryFactory? geomFact]) {
    UnaryUnionOp op = new UnaryUnionOp.all(geoms, geomFact);
    op.setUnionFunction(OVERLAY_UNION);
    return op.union_();
  }

  /**private */ static UnionStrategy OVERLAY_UNION = _UnionStrategy();

  /**
   * Overlay two geometries, using heuristics to ensure
   * computation completes correctly.
   * In practice the heuristics are observed to be fully correct.
   * 
   * @param geom0 a geometry
   * @param geom1 a geometry
   * @param opCode the overlay operation code (from {@link OverlayNG}
   * @return the overlay result geometry
   * 
   * @see OverlayNG
   */
  static Geometry overlay(Geometry geom0, Geometry geom1, int opCode) {
    Geometry? result;
    // RuntimeException exOriginal;
    /// TODO: @ruier edit.
    Exception exOriginal;

    /**
     * First try overlay with a FLOAT noder, which is fast and causes least
     * change to geometry coordinates
     * By default the noder is validated, which is required in order
     * to detect certain invalid noding situations which otherwise
     * cause incorrect overlay output.
     */
    try {
      result = OverlayNG.overlay(geom0, geom1, opCode);
      return result;
    } on /**RuntimeException */ Exception catch (ex) {
      /**
       * Capture original exception,
       * so it can be rethrown if the remaining strategies all fail.
       */
      exOriginal = ex;
    }

    /**
     * On failure retry using snapping noding with a "safe" tolerance.
     * if this throws an exception just let it go,
     * since it is something that is not a TopologyException
     */
    result = _overlaySnapTries(geom0, geom1, opCode);
    if (result != null) return result;

    /**
     * On failure retry using snap-rounding with a heuristic scale factor (grid size).
     */
    result = _overlaySR(geom0, geom1, opCode);
    if (result != null) return result;

    /**
     * Just can't get overlay to work, so throw original error.
     */
    throw exOriginal;
  }

  /**private */ static const int NUM_SNAP_TRIES = 5;

  /**
   * Attempt overlay using snapping with repeated tries with increasing snap tolerances.
   * 
   * @param [geom0]
   * @param [geom1]
   * @param [opCode]
   * @return the computed overlay result, or null if the overlay fails
   */
  static Geometry? _overlaySnapTries(
      Geometry geom0, Geometry geom1, int opCode) {
    Geometry? result;
    double snapTol = _snapTolerance(geom0, geom1);

    for (int i = 0; i < NUM_SNAP_TRIES; i++) {
      result = _overlaySnapping(geom0, geom1, opCode, snapTol);
      if (result != null) return result;

      /**
       * Now try snapping each input individually, 
       * and then doing the overlay.
       */
      result = _overlaySnapBoth(geom0, geom1, opCode, snapTol);
      if (result != null) return result;

      // increase the snap tolerance and try again
      snapTol = snapTol * 10;
    }
    // failed to compute overlay
    return null;
  }

  /**
   * Attempt overlay using a {@link SnappingNoder}.
   * 
   * @param [geom0]
   * @param [geom1]
   * @param [opCode]
   * @param [snapTol]
   * @return the computed overlay result, or null if the overlay fails
   */
  static Geometry? _overlaySnapping(
      Geometry geom0, Geometry geom1, int opCode, double snapTol) {
    try {
      return _overlaySnapTol(geom0, geom1, opCode, snapTol);
    } on TopologyException catch (ex) {
      //---- ignore exception, return null result to indicate failure

      //System.out.println("Snapping with " + snapTol + " - FAILED");
      //log("Snapping with " + snapTol + " - FAILED", geom0, geom1);
      print('>>>>>>>>> $ex <<<<<<<<<<<<<<<<<<<<');
    }
    return null;
  }

  /**
   * Attempt overlay with first snapping each geometry individually.
   * 
   * @param [geom0]
   * @param [geom1]
   * @param [opCode]
   * @param [snapTol]
   * @return the computed overlay result, or null if the overlay fails
   */
  static Geometry? _overlaySnapBoth(
      Geometry geom0, Geometry geom1, int opCode, double snapTol) {
    try {
      Geometry snap0 = _snapSelf(geom0, snapTol);
      Geometry snap1 = _snapSelf(geom1, snapTol);
      //log("Snapping BOTH with " + snapTol, geom0, geom1);

      return _overlaySnapTol(snap0, snap1, opCode, snapTol);
    } on TopologyException catch (ex) {
      //---- ignore exception, return null result to indicate failure
      print('>>>>>>>>> ${ex} <<<<<<<<<<<<<<<<<<<<');
    }
    return null;
  }

  /**
   * Self-snaps a geometry by running a union operation with it as the only input.
   * This helps to remove narrow spike/gore artifacts to simplify the geometry,
   * which improves robustness.
   * Collapsed artifacts are removed from the result to allow using
   * it in further overlay operations.
   * 
   * @param [geom] geometry to self-snap
   * @param [snapTol] snap tolerance
   * @return the snapped geometry (homogeneous)
   */
  static Geometry _snapSelf(Geometry geom, double snapTol) {
    OverlayNG ov = new OverlayNG.Union(geom, null);
    SnappingNoder snapNoder = new SnappingNoder(snapTol);
    ov.setNoder(snapNoder);
    /**
     * Ensure the result is not mixed-dimension,
     * since it will be used in further overlay computation.
     * It may however be lower dimension, if it collapses completely due to snapping.
     */
    ov.setStrictMode(true);
    return ov.getResult();
  }

  static Geometry _overlaySnapTol(
      Geometry geom0, Geometry geom1, int opCode, double snapTol) {
    SnappingNoder snapNoder = new SnappingNoder(snapTol);
    return OverlayNG.overlayWithNoder(geom0, geom1, opCode, snapNoder);
  }

  //============================================

  /**
   * A factor for a snapping tolerance distance which 
   * should allow noding to be computed robustly.
   */
  /**private */ static const double SNAP_TOL_FACTOR = 1e12;

  /**
   * Computes a heuristic snap tolerance distance
   * for overlaying a pair of geometries using a {@link SnappingNoder}.
   * 
   * @param geom0
   * @param geom1
   * @return the snap tolerance
   */
  static double _snapTolerance(Geometry geom0, Geometry geom1) {
    double tol0 = _snapTolerance$1(geom0);
    double tol1 = _snapTolerance$1(geom1);
    double snapTol = max(tol0, tol1);
    return snapTol;
  }

  static double _snapTolerance$1(Geometry geom) {
    double magnitude = _ordinateMagnitude(geom);
    return magnitude / SNAP_TOL_FACTOR;
  }

  /**
   * Computes the largest magnitude of the ordinates of a geometry,
   * based on the geometry envelope.
   * 
   * @param geom a geometry
   * @return the magnitude of the largest ordinate
   */
  static double _ordinateMagnitude(Geometry geom) {
    if (geom == null || geom.isEmpty()) return 0;
    Envelope env = geom.getEnvelopeInternal();
    double magMax = max((env.getMaxX().abs()), (env.getMaxY().abs()));
    double magMin = max((env.getMinX().abs()), (env.getMinY().abs()));
    return max(magMax, magMin);
  }

  //===============================================
  /*
 /**private */static void log(String msg, Geometry geom0, Geometry geom1) {
    System.out.println(msg);
    System.out.println(geom0);
    System.out.println(geom1);
  }
  */

  /**
   * Attempt Overlay using Snap-Rounding with an automatically-determined
   * scale factor.
   * 
   * @param [geom0]
   * @param [geom1]
   * @param [opCode]
   * @return the computed overlay result, or null if the overlay fails
   */
  static Geometry? _overlaySR(Geometry geom0, Geometry geom1, int opCode) {
    Geometry result;
    try {
      //System.out.println("OverlaySnapIfNeeded: trying snap-rounding");
      double scaleSafe = PrecisionUtil.safeScale2(geom0, geom1);
      PrecisionModel pmSafe = new PrecisionModel.Fixed(scaleSafe);
      result = OverlayNG.overlayWithPM(geom0, geom1, opCode, pmSafe);
      return result;
    } on TopologyException catch (ex) {
      //---- ignore exception, return null result to indicate failure
      print('>>>>>>>>> ${ex} <<<<<<<<<<<<<<<<<<<<');
    }
    return null;
  }
}
