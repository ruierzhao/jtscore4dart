/*
 * Copyright (c) 2020 Martin Davis, and others.
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

import 'OverlayNG.dart';
import 'OverlayUtil.dart';

class FastOverlayFilter {
  // superceded by overlap clipping?
  // TODO: perhaps change this to RectangleClipping, with fast/looser semantics?

  /**private */ Geometry _targetGeom;
  /**private */ bool _isTargetRectangle;

  FastOverlayFilter(this._targetGeom)
      : _isTargetRectangle = _targetGeom.isRectangle();

  /**
   * Computes the overlay operation on the input geometries,
   * if it can be determined that the result is either
   * empty or equal to one of the input values.
   * Otherwise <code>null</code> is returned, indicating
   * that a full overlay operation must be performed.
   * 
   * @param [geom]
   * @param [overlayOpCode]
   * @return overlay of the input geometries
   */
  Geometry? overlay(Geometry geom, int overlayOpCode) {
    // for now only INTERSECTION is handled
    if (overlayOpCode != OverlayNG.INTERSECTION) {
      return null;
    }
    return _intersection(geom);
  }

  Geometry? _intersection(Geometry geom) {
    // handle rectangle case
    Geometry? resultForRect = _intersectionRectangle(geom);
    if (resultForRect != null) {
      return resultForRect;
    }

    // handle general case
    if (!_isEnvelopeIntersects(_targetGeom, geom)) {
      return _createEmpty(geom);
    }

    return null;
  }

  Geometry _createEmpty(Geometry geom) {
    // empty result has dimension of non-rectangle input
    return OverlayUtil.createEmptyResult(
        geom.getDimension(), geom.getFactory());
  }

  Geometry? _intersectionRectangle(Geometry geom) {
    if (!_isTargetRectangle) {
      return null;
    }

    if (_isEnvelopeCovers(_targetGeom, geom)) {
      return geom.copy();
    }
    if (!_isEnvelopeIntersects(_targetGeom, geom)) {
      return _createEmpty(geom);
    }
    return null;
  }

  bool _isEnvelopeIntersects(Geometry a, Geometry b) {
    return a.getEnvelopeInternal().intersects(b.getEnvelopeInternal());
  }

  /**private */ bool _isEnvelopeCovers(Geometry a, Geometry b) {
    return a.getEnvelopeInternal().covers(b.getEnvelopeInternal());
  }
}
