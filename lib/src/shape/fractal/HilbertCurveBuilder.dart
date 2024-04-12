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
// import org.locationtech.jts.geom.Geometry;
// import org.locationtech.jts.geom.GeometryFactory;
// import org.locationtech.jts.geom.LineSegment;
// import org.locationtech.jts.geom.LineString;
// import org.locationtech.jts.shape.GeometricShapeBuilder;

// import static org.locationtech.jts.shape.fractal.HilbertCode.decode;
// import static org.locationtech.jts.shape.fractal.HilbertCode.level;
// import static org.locationtech.jts.shape.fractal.HilbertCode.maxOrdinate;
// import static org.locationtech.jts.shape.fractal.HilbertCode.size;

import 'package:jtscore4dart/src/geom/Coordinate.dart';
import 'package:jtscore4dart/src/geom/Geometry.dart';
import 'package:jtscore4dart/src/geom/GeometryFactory.dart';
import 'package:jtscore4dart/src/geom/LineSegment.dart';

import '../GeometricShapeBuilder.dart';
import 'HilbertCode.dart';

/**
 * Generates a {@link LineString} representing the Hilbert Curve
 * at a given level.
 * 
 * @author Martin Davis
 * @see HilbertCode
 */
class HilbertCurveBuilder
extends GeometricShapeBuilder
{
 /**private */int order = -1;

  /**
   * Creates a new instance using the provided {@link GeometryFactory}.
   * 
   * @param geomFactory the geometry factory to use
   */
  HilbertCurveBuilder(GeometryFactory geomFactory)
    :super(geomFactory)
  {
    // use a null extent to indicate no transformation
    // (may be set by client)
    extent = null;
  }
  
  /**
   * Sets the level of curve to generate.
   * The level must be in the range [0 - 16].
   * 
   * @param level the order of the curve
   */
  void setLevel(int level) {
    this.numPts = HilbertCode.size(level);  }
  
  @override
  Geometry getGeometry() {
    int _level = HilbertCode.level(numPts);
    int nPts = HilbertCode.size(_level);
    
    double scale = 1;
    double baseX = 0;
    double baseY = 0;
    if (extent != null) {
      LineSegment baseLine = getSquareBaseLine();
      baseX = baseLine.minX();
      baseY = baseLine.minY();
      double width = baseLine.getLength();
      int _maxOrdinate = HilbertCode.maxOrdinate(_level);
      scale = width / _maxOrdinate;
    }
    
    // List<Coordinate> pts = new Coordinate[nPts];
    List<Coordinate> pts = List.filled(nPts, Coordinate.empty2D(), growable: false);
    for (int i = 0; i < nPts; i++) {
       Coordinate pt = HilbertCode.decode(_level, i);
       double x = transform(pt.getX(), scale, baseX );
       double y = transform(pt.getY(), scale, baseY );
      //  pts[i] = new Coordinate(x, y);
      /// TODO: @ruier edit.
       pts[i].setX(x);
       pts[i].setY(y);
    }
    return geomFactory.createLineString(pts);
  }
  
 /**private */static double transform(double val, double scale, double offset) {
    return val * scale + offset;
  }
  
}
