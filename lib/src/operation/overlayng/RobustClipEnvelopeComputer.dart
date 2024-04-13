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

// import org.locationtech.jts.geom.Coordinate;
// import org.locationtech.jts.geom.CoordinateSequence;
// import org.locationtech.jts.geom.Envelope;
// import org.locationtech.jts.geom.Geometry;
// import org.locationtech.jts.geom.GeometryCollection;
// import org.locationtech.jts.geom.LinearRing;
// import org.locationtech.jts.geom.Polygon;

import 'package:jtscore4dart/geometry.dart';

/**
 * Computes a robust clipping envelope for a pair of polygonal geometries.
 * The envelope is computed to be large enough to include the full
 * length of all geometry line segments which intersect 
 * a given target envelope.
 * This ensures that line segments which might intersect are
 * not perturbed when clipped using {@link RingClipper}.
 *  
 * @author Martin Davis
 *
 */
class RobustClipEnvelopeComputer {
  static Envelope getEnvelope(Geometry a, Geometry b, Envelope targetEnv) {
    RobustClipEnvelopeComputer cec = new RobustClipEnvelopeComputer(targetEnv);
    cec.add(a);
    cec.add(b);
    return cec.getEnvelope_();
  }

  /**private */ Envelope targetEnv;
  /**private */ Envelope clipEnv;

  RobustClipEnvelopeComputer(this.targetEnv) : clipEnv = targetEnv.copy();

  Envelope getEnvelope_() {
    return clipEnv;
  }

  void add(Geometry g) {
    if (g == null || g.isEmpty()) {
      return;
    }

    if (g is Polygon) {
      _addPolygon(g);
    } else if (g is GeometryCollection) {
      _addCollection(g);
    }
  }

  void _addCollection(GeometryCollection gc) {
    for (int i = 0; i < gc.getNumGeometries(); i++) {
      Geometry g = gc.getGeometryN(i);
      add(g);
    }
  }

  void _addPolygon(Polygon poly) {
    LinearRing shell = poly.getExteriorRing();
    _addPolygonRing(shell);

    for (int i = 0; i < poly.getNumInteriorRing(); i++) {
      LinearRing hole = poly.getInteriorRingN(i);
      _addPolygonRing(hole);
    }
  }

  /**
   * Adds a polygon ring to the graph. Empty rings are ignored.
   */
  void _addPolygonRing(LinearRing ring) {
    // don't add empty lines
    if (ring.isEmpty()) {
      return;
    }

    CoordinateSequence seq = ring.getCoordinateSequence();
    for (int i = 1; i < seq.size(); i++) {
      _addSegment(seq.getCoordinate(i - 1), seq.getCoordinate(i));
    }
  }

  void _addSegment(Coordinate p1, Coordinate p2) {
    if (_intersectsSegment(targetEnv, p1, p2)) {
      clipEnv.expandToIncludeCoordinate(p1);
      clipEnv.expandToIncludeCoordinate(p2);
    }
  }

  static bool _intersectsSegment(Envelope env, Coordinate p1, Coordinate p2) {
    /**
     * This is a crude test of whether segment intersects envelope.
     * It could be refined by checking exact intersection.
     * This could be based on the algorithm in the HotPixel.intersectsScaled method.
     */
    return env.intersectsEnvelopeByCoord(p1, p2);
  }
}
