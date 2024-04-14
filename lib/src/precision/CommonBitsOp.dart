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

// import org.locationtech.jts.geom.Geometry;

import 'package:jtscore4dart/src/geom/Geometry.dart';

import 'CommonBitsRemover.dart';

/**
 * Provides versions of Geometry spatial functions which use
 * common bit removal to reduce the likelihood of robustness problems.
 * <p>
 * In the current implementation no rounding is performed on the
 * reshifted result geometry, which means that it is possible
 * that the returned Geometry is invalid.
 * Client classes should check the validity of the returned result themselves.
 *
 * @version 1.7
 */
class CommonBitsOp {
  /**private */ bool returnToOriginalPrecision = true;
  /**private */ CommonBitsRemover cbr = new CommonBitsRemover();

  /**
   * Creates a new instance of class, which reshifts result {@link Geometry}s.
   */
  // CommonBitsOp()
  // {
  //   this(true);
  // }

  /**
   * Creates a new instance of class, specifying whether
   * the result {@link Geometry}s should be reshifted.
   *
   * @param returnToOriginalPrecision
   */
  CommonBitsOp([this.returnToOriginalPrecision = true]);

  /**
   * Computes the set-theoretic intersection of two {@link Geometry}s, using enhanced precision.
   * @param geom0 the first Geometry
   * @param geom1 the second Geometry
   * @return the Geometry representing the set-theoretic intersection of the input Geometries.
   */
  Geometry intersection(Geometry geom0, Geometry geom1) {
    List<Geometry> geom = _removeCommonBits(geom0, geom1);
    return _computeResultPrecision(geom[0].intersection(geom[1]));
  }

  /**
   * Computes the set-theoretic union of two {@link Geometry}s, using enhanced precision.
   * @param geom0 the first Geometry
   * @param geom1 the second Geometry
   * @return the Geometry representing the set-theoretic union of the input Geometries.
   */
  Geometry union(Geometry geom0, Geometry geom1) {
    List<Geometry> geom = _removeCommonBits(geom0, geom1);
    return _computeResultPrecision(geom[0].unionWith(geom[1]));
  }

  /**
   * Computes the set-theoretic difference of two {@link Geometry}s, using enhanced precision.
   * @param geom0 the first Geometry
   * @param geom1 the second Geometry, to be subtracted from the first
   * @return the Geometry representing the set-theoretic difference of the input Geometries.
   */
  Geometry difference(Geometry geom0, Geometry geom1) {
    List<Geometry> geom = _removeCommonBits(geom0, geom1);
    return _computeResultPrecision(geom[0].difference(geom[1]));
  }

  /**
   * Computes the set-theoretic symmetric difference of two geometries,
   * using enhanced precision.
   * @param geom0 the first Geometry
   * @param geom1 the second Geometry
   * @return the Geometry representing the set-theoretic symmetric difference of the input Geometries.
   */
  Geometry symDifference(Geometry geom0, Geometry geom1) {
    List<Geometry> geom = _removeCommonBits(geom0, geom1);
    return _computeResultPrecision(geom[0].symDifference(geom[1]));
  }

  /**
   * Computes the buffer a geometry,
   * using enhanced precision.
   * @param geom0 the Geometry to buffer
   * @param distance the buffer distance
   * @return the Geometry representing the buffer of the input Geometry.
   */
  Geometry buffer(Geometry geom0, double distance) {
    Geometry geom = _removeCommonBits1(geom0);
    return _computeResultPrecision(geom.buffer(distance));
  }

  /**
   * If required, returning the result to the original precision if required.
   * <p>
   * In this current implementation, no rounding is performed on the
   * reshifted result geometry, which means that it is possible
   * that the returned Geometry is invalid.
   *
   * @param result the result Geometry to modify
   * @return the result Geometry with the required precision
   */
  Geometry _computeResultPrecision(Geometry result) {
    if (returnToOriginalPrecision) cbr.addCommonBits(result);
    return result;
  }

  /**
   * Computes a copy of the input {@link Geometry} with the calculated common bits
   * removed from each coordinate.
   * @param geom0 the Geometry to remove common bits from
   * @return a copy of the input Geometry with common bits removed
   */
  Geometry _removeCommonBits1(Geometry geom0) {
    cbr = new CommonBitsRemover();
    cbr.add(geom0);
    Geometry geom = cbr.removeCommonBits(geom0.copy());
    return geom;
  }

  /**
   * Computes a copy of each input {@link Geometry}s with the calculated common bits
   * removed from each coordinate.
   * @param [geom0] a Geometry to remove common bits from
   * @param [geom1] a Geometry to remove common bits from
   * @return an array containing copies
   * of the input Geometry's with common bits removed
   */
  List<Geometry> _removeCommonBits(Geometry geom0, Geometry geom1) {
    cbr = new CommonBitsRemover();
    cbr.add(geom0);
    cbr.add(geom1);
    // Geometry geom[] = new Geometry[2];
    // geom[0] = cbr.removeCommonBits(geom0.copy());
    // geom[1] = cbr.removeCommonBits(geom1.copy());
    List<Geometry> geom = List.from([
      cbr.removeCommonBits(geom0.copy()),
      cbr.removeCommonBits(geom1.copy())
    ], growable: false);
    return geom;
  }
}
