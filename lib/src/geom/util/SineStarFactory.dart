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



// import org.locationtech.jts.geom.Coordinate;
// import org.locationtech.jts.geom.Envelope;
// import org.locationtech.jts.geom.Geometry;
// import org.locationtech.jts.geom.GeometryFactory;
// import org.locationtech.jts.geom.LinearRing;
// import org.locationtech.jts.geom.Polygon;
// import org.locationtech.jts.util.GeometricShapeFactory;

import "dart:math" as math;

import 'package:jtscore4dart/src/geom/Coordinate.dart';
import 'package:jtscore4dart/src/geom/Envelope.dart';
import 'package:jtscore4dart/src/geom/Geometry.dart';
import 'package:jtscore4dart/src/geom/GeometryFactory.dart';
import 'package:jtscore4dart/src/geom/LinearRing.dart';
import 'package:jtscore4dart/src/geom/Polygon.dart';
import 'package:jtscore4dart/src/util/GeometricShapeFactory.dart';

/**
 * Creates geometries which are shaped like multi-armed stars
 * with each arm shaped like a sine wave.
 * These kinds of geometries are useful as a more complex 
 * geometry for testing algorithms.
 * 
 * @author Martin Davis
 *
 */
class SineStarFactory
	extends GeometricShapeFactory
{
  /**
   * Creates a sine star with the given parameters.
   * 
   * @param origin the origin point
   * @param size the size of the star
   * @param nPts the number of points in the star
   * @param nArms the number of arms to generate
   * @param armLengthRatio the arm length ratio
   * @return a sine star shape
   */
  static Geometry create(Coordinate origin, double size, int nPts, int nArms, double armLengthRatio) {
    SineStarFactory gsf = new SineStarFactory();
    gsf.setCentre(origin);
    gsf.setSize(size);
    gsf.setNumPoints(nPts);
    gsf.setArmLengthRatio(armLengthRatio);
    gsf.setNumArms(nArms);
    Geometry poly = gsf.createSineStar();
    return poly;
  }
  
	/**protected */ int numArms = 8;
	/**protected */ double armLengthRatio = 0.5;
	
  /**
   * Creates a factory which will create sine stars using the default
   * {@link GeometryFactory}.
   */
	// SineStarFactory()
	// :
	// 	super();
	
	
  /**
   * Creates a factory which will create sine stars using the given
   * {@link GeometryFactory}.
   *
   * @param geomFact the factory to use
   */
  SineStarFactory([GeometryFactory? geomFact])
  :
    super(geomFact);

  /**
   * Sets the number of arms in the star
   * 
   * @param numArms the number of arms to generate
   */
  void setNumArms(int numArms)
  {
  	this.numArms = numArms;
  }
  
  /**
   * Sets the ratio of the length of each arm to the radius of the star.
   * A smaller number makes the arms shorter.
   * Value should be between 0.0 and 1.0
   * 
   * @param armLengthRatio the ratio determining the length of them arms.
   */
  void setArmLengthRatio(double armLengthRatio)
  {
  	this.armLengthRatio = armLengthRatio;
  }
  
  /**
   * Generates the geometry for the sine star
   * 
   * @return the geometry representing the sine star
   */
  Geometry createSineStar()
  {
    Envelope env = dim.getEnvelope();
    double radius = env.getWidth() / 2.0;

  	double armRatio = armLengthRatio;
    if (armRatio < 0.0) {
      armRatio = 0.0;
    }
    if (armRatio > 1.0) {
      armRatio = 1.0;
    }

    double armMaxLen = armRatio * radius;
    double insideRadius = (1 - armRatio) * radius;

    double centreX = env.getMinX() + radius;
    double centreY = env.getMinY() + radius;

    /// TODO: @ruier edit.
    // List<Coordinate> pts = new Coordinate[nPts + 1];
    // int iPt = 0;
    
    List<Coordinate> pts = [];

    for (int i = 0; i < nPts; i++) {
      // the fraction of the way through the current arm - in [0,1]
      double ptArcFrac = (i / nPts.toDouble()) * numArms;
      double armAngFrac = ptArcFrac - (ptArcFrac).floor();
      
      // the angle for the current arm - in [0,2Pi]  
      // (each arm is a complete sine wave cycle)
      double armAng = 2 * math.pi * armAngFrac;
      // the current length of the arm
      double armLenFrac = (math.cos(armAng) + 1.0) / 2.0;
      
      // the current radius of the curve (core + arm)
      double curveRadius = insideRadius + armMaxLen * armLenFrac;

      // the current angle of the curve
      double ang = i * (2 * math.pi / nPts);
      double x = curveRadius * math.cos(ang) + centreX;
      double y = curveRadius * math.sin(ang) + centreY;
      // pts[iPt++] = coord(x, y);
      pts.add(coord(x, y));
    }
    // pts[iPt] = new Coordinate(pts[0]);
    pts.add(pts[0]);

    LinearRing ring = geomFact.createLinearRing(pts);
    Polygon poly = geomFact.createPolygon(ring);
    return poly;
  }
}
