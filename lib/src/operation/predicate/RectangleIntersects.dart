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

// import java.util.Iterator;
// import java.util.List;

// import org.locationtech.jts.algorithm.RectangleLineIntersector;
// import org.locationtech.jts.algorithm.locate.SimplePointInAreaLocator;
// import org.locationtech.jts.geom.Coordinate;
// import org.locationtech.jts.geom.CoordinateSequence;
// import org.locationtech.jts.geom.Envelope;
// import org.locationtech.jts.geom.Geometry;
// import org.locationtech.jts.geom.GeometryCollection;
// import org.locationtech.jts.geom.LineString;
// import org.locationtech.jts.geom.Polygon;
// import org.locationtech.jts.geom.util.LinearComponentExtracter;
// import org.locationtech.jts.geom.util.ShortCircuitedGeometryVisitor;

import 'package:jtscore4dart/geometry.dart';
import 'package:jtscore4dart/src/algorithm/RectangleLineIntersector.dart';
import 'package:jtscore4dart/src/algorithm/locate/SimplePointInAreaLocator.dart';
import 'package:jtscore4dart/src/geom/util/LinearComponentExtracter.dart';
import 'package:jtscore4dart/src/geom/util/ShortCircuitedGeometryVisitor.dart';

/**
 * Implementation of the <tt>intersects</tt> spatial predicate
 * optimized for the case where one {@link Geometry} is a rectangle. 
 * This class works for all
 * input geometries, including {@link GeometryCollection}s.
 * <p>
 * As a further optimization, 
 * this class can be used in batch style
 * to test many geometries
 * against a single rectangle.
 * 
 * @version 1.7
 */
class RectangleIntersects {
  /**
   * Tests whether a rectangle intersects a given geometry.
   * 
   * @param rectangle
   *          a rectangular Polygon
   * @param b
   *          a Geometry of any type
   * @return true if the geometries intersect
   */
  static bool intersects(Polygon rectangle, Geometry b) {
    RectangleIntersects rp = new RectangleIntersects(rectangle);
    return rp.intersects_(b);
  }

  /**private */ Polygon rectangle;

  /**private */ Envelope rectEnv;

  /**
   * Create a new intersects computer for a rectangle.
   * 
   * @param rectangle
   *          a rectangular Polygon
   */
  RectangleIntersects(this.rectangle)
      : rectEnv = rectangle.getEnvelopeInternal();

  /**
   * Tests whether the given Geometry intersects
   * the query rectangle.
   * 
   * @param geom the Geometry to test (may be of any type)
   * @return true if the geometry intersects the query rectangle
   */
  bool intersects_(Geometry geom) {
    if (!rectEnv.intersects(geom.getEnvelopeInternal())) {
      return false;
    }

    /**
     * Test if rectangle envelope intersects any component envelope.
     * This handles Point components as well
     */
    EnvelopeIntersectsVisitor visitor = new EnvelopeIntersectsVisitor(rectEnv);
    visitor.applyTo(geom);
    if (visitor.intersects()) {
      return true;
    }

    /**
     * Test if any rectangle vertex is contained in the target geometry
     */
    GeometryContainsPointVisitor ecpVisitor =
        new GeometryContainsPointVisitor(rectangle);
    ecpVisitor.applyTo(geom);
    if (ecpVisitor.containsPoint()) {
      return true;
    }

    /**
     * Test if any target geometry line segment intersects the rectangle
     */
    RectangleIntersectsSegmentVisitor riVisitor =
        new RectangleIntersectsSegmentVisitor(rectangle);
    riVisitor.applyTo(geom);
    if (riVisitor.intersects()) {
      return true;
    }

    return false;
  }
}

/**
 * Tests whether it can be concluded that a rectangle intersects a geometry,
 * based on the relationship of the envelope(s) of the geometry.
 * 
 * @author Martin Davis
 * @version 1.7
 */
class EnvelopeIntersectsVisitor extends ShortCircuitedGeometryVisitor {
  /**private */ Envelope rectEnv;

  /**private */ bool _intersects = false;

  EnvelopeIntersectsVisitor(this.rectEnv);

  /**
   * Reports whether it can be concluded that an intersection occurs, 
   * or whether further testing is required.
   * 
   * @return true if an intersection must occur 
   * or false if no conclusion about intersection can be made
   */
  bool intersects() {
    return _intersects;
  }

  /**protected */ @override
  void visit(Geometry element) {
    Envelope elementEnv = element.getEnvelopeInternal();

    // disjoint => no intersection
    if (!rectEnv.intersects(elementEnv)) {
      return;
    }
    // rectangle contains target env => must intersect
    if (rectEnv.contains(elementEnv)) {
      _intersects = true;
      return;
    }
    /**
     * Since the envelopes intersect and the test element is connected, if the
     * test envelope is completely bisected by an edge of the rectangle the
     * element and the rectangle must touch (This is basically an application of
     * the Jordan Curve Theorem). The alternative situation is that the test
     * envelope is "on a corner" of the rectangle envelope, i.e. is not
     * completely bisected. In this case it is not possible to make a conclusion
     * about the presence of an intersection.
     */
    if (elementEnv.getMinX() >= rectEnv.getMinX() &&
        elementEnv.getMaxX() <= rectEnv.getMaxX()) {
      _intersects = true;
      return;
    }
    if (elementEnv.getMinY() >= rectEnv.getMinY() &&
        elementEnv.getMaxY() <= rectEnv.getMaxY()) {
      _intersects = true;
      return;
    }
  }

  /**protected */ @override
  bool isDone() {
    return _intersects;
  }
}

/**
 * A visitor which tests whether it can be 
 * concluded that a geometry contains a vertex of
 * a query geometry.
 * 
 * @author Martin Davis
 * @version 1.7
 */
class GeometryContainsPointVisitor extends ShortCircuitedGeometryVisitor {
  /**private */ CoordinateSequence rectSeq;

  /**private */ Envelope rectEnv;

  /**private */ bool _containsPoint = false;

  GeometryContainsPointVisitor(Polygon rectangle)
      : this.rectSeq = rectangle.getExteriorRing().getCoordinateSequence(),
        rectEnv = rectangle.getEnvelopeInternal();

  /**
   * Reports whether it can be concluded that a corner point of the rectangle is
   * contained in the geometry, or whether further testing is required.
   * 
   * @return true if a corner point is contained 
   * or false if no conclusion about intersection can be made
   */
  bool containsPoint() {
    return _containsPoint;
  }

  /**protected */ @override
  void visit(Geometry geom) {
    // if test geometry is not polygonal this check is not needed
    if (!(geom is Polygon)) {
      return;
    }

    // skip if envelopes do not intersect
    Envelope elementEnv = geom.getEnvelopeInternal();
    if (!rectEnv.intersects(elementEnv)) {
      return;
    }

    // test each corner of rectangle for inclusion
    Coordinate rectPt = new Coordinate.empty2D();
    for (int i = 0; i < 4; i++) {
      rectSeq.getCoordinateTo(i, rectPt);
      if (!elementEnv.containsCoord(rectPt)) {
        continue;
      }
      // check rect point in poly (rect is known not to touch polygon at this
      // point)
      if (SimplePointInAreaLocator.containsPointInPolygon(rectPt, geom)) {
        _containsPoint = true;
        return;
      }
    }
  }

  /**protected */ @override
  bool isDone() {
    return _containsPoint;
  }
}

/**
 * A visitor to test for intersection between the query
 * rectangle and the line segments of the geometry.
 * 
 * @author Martin Davis
 *
 */
class RectangleIntersectsSegmentVisitor extends ShortCircuitedGeometryVisitor {
  /**private */ Envelope rectEnv;
  /**private */ late RectangleLineIntersector rectIntersector;

  /**private */ bool hasIntersection = false;

  /**
   * Creates a visitor for checking rectangle intersection
   * with segments
   * 
   * @param rectangle the query rectangle 
   */
  RectangleIntersectsSegmentVisitor(Polygon rectangle)
      : rectEnv = rectangle.getEnvelopeInternal() {
    rectIntersector = new RectangleLineIntersector(rectEnv);
  }

  /**
   * Reports whether any segment intersection exists.
   * 
   * @return true if a segment intersection exists
   * or false if no segment intersection exists
   */
  bool intersects() {
    return hasIntersection;
  }

  /**protected */ @override
  void visit(Geometry geom) {
    /**
     * It may be the case that the rectangle and the 
     * envelope of the geometry component are disjoint,
     * so it is worth checking this simple condition.
     */
    Envelope elementEnv = geom.getEnvelopeInternal();
    if (!rectEnv.intersects(elementEnv)) {
      return;
    }

    // check segment intersections
    // get all lines from geometry component
    // (there may be more than one if it's a multi-ring polygon)
    List lines = LinearComponentExtracter.getLines(geom);
    checkIntersectionWithLineStrings(lines);
  }

  /**private */ void checkIntersectionWithLineStrings(List lines) {
    for (Iterator i = lines.iterator; i.moveNext();) {
      LineString testLine = i.current;
      checkIntersectionWithSegments(testLine);
      if (hasIntersection) {
        return;
      }
    }
  }

  /**private */ void checkIntersectionWithSegments(LineString testLine) {
    CoordinateSequence seq1 = testLine.getCoordinateSequence();
    Coordinate p0 = seq1.createCoordinate();
    Coordinate p1 = seq1.createCoordinate();
    for (int j = 1; j < seq1.size(); j++) {
      seq1.getCoordinateTo(j - 1, p0);
      seq1.getCoordinateTo(j, p1);

      if (rectIntersector.intersects(p0, p1)) {
        hasIntersection = true;
        return;
      }
    }
  }

  /**protected */
  @override
  bool isDone() {
    return hasIntersection;
  }
}
