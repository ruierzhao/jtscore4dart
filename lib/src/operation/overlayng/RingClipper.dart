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
// import org.locationtech.jts.geom.CoordinateList;
// import org.locationtech.jts.geom.Envelope;

import 'package:jtscore4dart/src/geom/Coordinate.dart';
import 'package:jtscore4dart/src/geom/CoordinateList.dart';
import 'package:jtscore4dart/src/geom/Envelope.dart';

/**
 * Clips rings of points to a rectangle.
 * Uses a variant of Cohen-Sutherland clipping.
 * <p>
 * In general the output is not topologically valid.
 * In particular, the output may contain coincident non-noded line segments
 * along the clip rectangle sides.
 * However, the output is sufficiently well-structured
 * that it can be used as input to the {@link OverlayNG} algorithm
 * (which is able to process coincident linework due
 * to the need to handle topology collapse under precision reduction).
 * <p>
 * Because of the likelihood of creating 
 * extraneous line segments along the clipping rectangle sides, 
 * this class is not suitable for clipping linestrings.
 * <p>
 * The clipping envelope should be generated using {@link RobustClipEnvelopeComputer},
 * to ensure that intersecting line segments are not perturbed
 * by clipping.
 * This is required to ensure that the overlay of the
 * clipped geometry is robust and correct (i.e. the same as 
 * if clipping was not used).
 * 
 * @see LineLimiter
 * 
 * @author Martin Davis
 *
 */
class RingClipper {
  /**private */ static const int BOX_LEFT = 3;
  /**private */ static const int BOX_TOP = 2;
  /**private */ static const int BOX_RIGHT = 1;
  /**private */ static const int BOX_BOTTOM = 0;

  /**private */ Envelope clipEnv;
  /**private */ double clipEnvMinY;
  /**private */ double clipEnvMaxY;
  /**private */ double clipEnvMinX;
  /**private */ double clipEnvMaxX;

  /**
   * Creates a new clipper for the given envelope.
   * 
   * @param clipEnv the clipping envelope
   */
  RingClipper(this.clipEnv)
      : clipEnvMinY = clipEnv.getMinY(),
        clipEnvMaxY = clipEnv.getMaxY(),
        clipEnvMinX = clipEnv.getMinX(),
        clipEnvMaxX = clipEnv.getMaxX();

  /**
   * Clips a list of points to the clipping rectangle box.
   * 
   * @param pts
   * @return clipped pts array
   */
  List<Coordinate> clip(List<Coordinate> pts) {
    for (int edgeIndex = 0; edgeIndex < 4; edgeIndex++) {
      bool closeRing = edgeIndex == 3;
      pts = _clipToBoxEdge(pts, edgeIndex, closeRing);
      if (pts.isEmpty) return pts;
    }
    return pts;
  }

  /**
   * Clips line to the axis-parallel line defined by a single box edge.
   * 
   * @param [pts]
   * @param [edgeIndex]
   * @param [closeRing] 
   * @return
   */
  List<Coordinate> _clipToBoxEdge(
      List<Coordinate> pts, int edgeIndex, bool closeRing) {
    // TODO: is it possible to avoid copying array 4 times?
    CoordinateList ptsClip = new CoordinateList();

    Coordinate p0 = pts[pts.length - 1];
    for (int i = 0; i < pts.length; i++) {
      Coordinate p1 = pts[i];
      if (_isInsideEdge(p1, edgeIndex)) {
        if (!_isInsideEdge(p0, edgeIndex)) {
          Coordinate intPt = _intersection(p0, p1, edgeIndex);
          ptsClip.add(intPt, false);
        }
        // TODO: avoid copying so much?
        ptsClip.add(p1.copy(), false);
      } else if (_isInsideEdge(p0, edgeIndex)) {
        Coordinate intPt = _intersection(p0, p1, edgeIndex);
        ptsClip.add(intPt, false);
      }
      // else p0-p1 is outside box, so it is dropped

      p0 = p1;
    }

    // add closing point if required
    if (closeRing && ptsClip.size() > 0) {
      Coordinate start = ptsClip.get(0);
      if (!start.equals2D(ptsClip.get(ptsClip.size() - 1))) {
        ptsClip.add(start.copy(), true);
      }
    }
    return ptsClip.toCoordinateArray();
  }

  /**
   * Computes the intersection point of a segment 
   * with an edge of the clip box.
   * The segment must be known to intersect the edge.
   * 
   * @param a first endpoint of the segment
   * @param b second endpoint of the segment
   * @param edgeIndex index of box edge
   * @return the intersection point with the box edge
   */
  Coordinate _intersection(Coordinate a, Coordinate b, int edgeIndex) {
    Coordinate intPt;
    switch (edgeIndex) {
      case BOX_BOTTOM:
        intPt =
            new Coordinate(_intersectionLineY(a, b, clipEnvMinY), clipEnvMinY);
        break;
      case BOX_RIGHT:
        intPt =
            new Coordinate(clipEnvMaxX, _intersectionLineX(a, b, clipEnvMaxX));
        break;
      case BOX_TOP:
        intPt =
            new Coordinate(_intersectionLineY(a, b, clipEnvMaxY), clipEnvMaxY);
        break;
      case BOX_LEFT:
      default:
        intPt =
            new Coordinate(clipEnvMinX, _intersectionLineX(a, b, clipEnvMinX));
    }
    return intPt;
  }

  double _intersectionLineY(Coordinate a, Coordinate b, double y) {
    double m = (b.x - a.x) / (b.y - a.y);
    double intercept = (y - a.y) * m;
    return a.x + intercept;
  }

  double _intersectionLineX(Coordinate a, Coordinate b, double x) {
    double m = (b.y - a.y) / (b.x - a.x);
    double intercept = (x - a.x) * m;
    return a.y + intercept;
  }

  bool _isInsideEdge(Coordinate p, int edgeIndex) {
    bool isInside = false;
    switch (edgeIndex) {
      case BOX_BOTTOM: // bottom
        isInside = p.y > clipEnvMinY;
        break;
      case BOX_RIGHT: // right
        isInside = p.x < clipEnvMaxX;
        break;
      case BOX_TOP: // top
        isInside = p.y < clipEnvMaxY;
        break;
      case BOX_LEFT:
      default: // left
        isInside = p.x > clipEnvMinX;
    }
    return isInside;
  }
}
