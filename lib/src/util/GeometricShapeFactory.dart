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


// import org.locationtech.jts.algorithm.Angle;
// import org.locationtech.jts.geom.Coordinate;
// import org.locationtech.jts.geom.Envelope;
// import org.locationtech.jts.geom.Geometry;
// import org.locationtech.jts.geom.GeometryFactory;
// import org.locationtech.jts.geom.LineString;
// import org.locationtech.jts.geom.LinearRing;
// import org.locationtech.jts.geom.Polygon;
// import org.locationtech.jts.geom.PrecisionModel;
// import org.locationtech.jts.geom.util.AffineTransformation;

/**
 * Computes various kinds of common geometric shapes.
 * Provides various ways of specifying the location and extent
 * and rotations of the generated shapes,
 * as well as number of line segments used to form them.
 * <p>
 * <b>Example of usage:</b>
 * <pre>
 *  GeometricShapeFactory gsf = new GeometricShapeFactory();
 *  gsf.setSize(100);
 *  gsf.setNumPoints(100);
 *  gsf.setBase(new Coordinate(100, 100));
 *  gsf.setRotation(0.5);
 *  Polygon rect = gsf.createRectangle();
 * </pre>
 *
 * @version 1.7
 */
class GeometricShapeFactory
{
  protected GeometryFactory geomFact;
  protected PrecisionModel precModel = null;
  protected Dimensions dim = new Dimensions();
  protected int nPts = 100;
  
  /**
   * Default is no rotation.
   */
  protected double rotationAngle = 0.0;

  /**
   * Create a shape factory which will create shapes using the default
   * {@link GeometryFactory}.
   */
  GeometricShapeFactory()
  {
    this(new GeometryFactory());
  }

  /**
   * Create a shape factory which will create shapes using the given
   * {@link GeometryFactory}.
   *
   * @param geomFact the factory to use
   */
  GeometricShapeFactory(GeometryFactory geomFact)
  {
    this.geomFact = geomFact;
    precModel = geomFact.getPrecisionModel();
  }

  void setEnvelope(Envelope env)
  {
  	dim.setEnvelope(env);
  }
  
  /**
   * Sets the location of the shape by specifying the base coordinate
   * (which in most cases is the
   * lower left point of the envelope containing the shape).
   *
   * @param base the base coordinate of the shape
   */
  void setBase(Coordinate base)  {  dim.setBase(base);    }
  /**
   * Sets the location of the shape by specifying the centre of
   * the shape's bounding box
   *
   * @param centre the centre coordinate of the shape
   */
  void setCentre(Coordinate centre)  {  dim.setCentre(centre);    }

  /**
   * Sets the total number of points in the created {@link Geometry}.
   * The created geometry will have no more than this number of points,
   * unless more are needed to create a valid geometry.
   */
  void setNumPoints(int nPts) { this.nPts = nPts; }

  /**
   * Sets the size of the extent of the shape in both x and y directions.
   *
   * @param size the size of the shape's extent
   */
  void setSize(double size) { dim.setSize(size); }

  /**
   * Sets the width of the shape.
   *
   * @param width the width of the shape
   */
  void setWidth(double width) { dim.setWidth(width); }

  /**
   * Sets the height of the shape.
   *
   * @param height the height of the shape
   */
  void setHeight(double height) { dim.setHeight(height); }

  /**
   * Sets the rotation angle to use for the shape.
   * The rotation is applied relative to the centre of the shape.
   * 
   * @param radians the rotation angle in radians.
   */
  void setRotation(double radians)
  {
    rotationAngle = radians;
  }
  
  protected Geometry rotate(Geometry geom)
  {
    if (rotationAngle != 0.0) {
      AffineTransformation trans = AffineTransformation.rotationInstance(rotationAngle, 
          dim.getCentre().x, dim.getCentre().y);
      geom.apply(trans);
    }
    return geom;
  }
  
  /**
   * Creates a rectangular {@link Polygon}.
   *
   * @return a rectangular Polygon
   *
   */
  Polygon createRectangle()
  {
    int i;
    int ipt = 0;
    int nSide = nPts / 4;
    if (nSide < 1) nSide = 1;
    double XsegLen = dim.getEnvelope().getWidth() / nSide;
    double YsegLen = dim.getEnvelope().getHeight() / nSide;

    List<Coordinate> pts = new Coordinate[4 * nSide + 1];
    Envelope env = dim.getEnvelope();

    //double maxx = env.getMinX() + nSide * XsegLen;
    //double maxy = env.getMinY() + nSide * XsegLen;

    for (i = 0; i < nSide; i++) {
      double x = env.getMinX() + i * XsegLen;
      double y = env.getMinY();
      pts[ipt++] = coord(x, y);
    }
    for (i = 0; i < nSide; i++) {
      double x = env.getMaxX();
      double y = env.getMinY() + i * YsegLen;
      pts[ipt++] = coord(x, y);
    }
    for (i = 0; i < nSide; i++) {
      double x = env.getMaxX() - i * XsegLen;
      double y = env.getMaxY();
      pts[ipt++] = coord(x, y);
    }
    for (i = 0; i < nSide; i++) {
      double x = env.getMinX();
      double y = env.getMaxY() - i * YsegLen;
      pts[ipt++] = coord(x, y);
    }
    pts[ipt++] = new Coordinate(pts[0]);

    LinearRing ring = geomFact.createLinearRing(pts);
    Polygon poly = geomFact.createPolygon(ring);
    return (Polygon) rotate(poly);
  }

//* @deprecated use {@link createEllipse} instead
  /**
   * Creates a circular or elliptical {@link Polygon}.
   *
   * @return a circle or ellipse
   */
  Polygon createCircle()
  {
    return createEllipse();
  }
  
  /**
   * Creates an elliptical {@link Polygon}.
   * If the supplied envelope is square the 
   * result will be a circle. 
   *
   * @return an ellipse or circle
   */
  Polygon createEllipse()
  {

    Envelope env = dim.getEnvelope();
    double xRadius = env.getWidth() / 2.0;
    double yRadius = env.getHeight() / 2.0;

    double centreX = env.getMinX() + xRadius;
    double centreY = env.getMinY() + yRadius;

    List<Coordinate> pts = new Coordinate[nPts + 1];
    int iPt = 0;
    for (int i = 0; i < nPts; i++) {
        double ang = i * (2 * math.PI / nPts);
        double x = xRadius * Angle.cosSnap(ang) + centreX;
        double y = yRadius * Angle.sinSnap(ang) + centreY;
        pts[iPt++] = coord(x, y);
    }
    pts[iPt] = new Coordinate(pts[0]);

    LinearRing ring = geomFact.createLinearRing(pts);
    Polygon poly = geomFact.createPolygon(ring);
    return (Polygon) rotate(poly);
  }
  /**
   * Creates a squircular {@link Polygon}.
   *
   * @return a squircle
   */
  Polygon createSquircle()
  /**
   * Creates a squircular {@link Polygon}.
   *
   * @return a squircle
   */
  {
  	return createSupercircle(4);
  }
  
  /**
   * Creates a supercircular {@link Polygon}
   * of a given positive power.
   *
   * @return a supercircle
   */
  Polygon createSupercircle(double power)
  {
  	double recipPow = 1.0 / power;
  	
    double radius = dim.getMinSize() / 2;
    Coordinate centre = dim.getCentre();
    
    double r4 = math.pow(radius, power);
    double y0 = radius;
    
    double xyInt = math.pow(r4 / 2, recipPow);
    
    int nSegsInOct = nPts / 8;
    int totPts = nSegsInOct * 8 + 1;
    List<Coordinate> pts = new Coordinate[totPts];
    double xInc = xyInt / nSegsInOct;
    
    for (int i = 0; i <= nSegsInOct; i++) {
  		double x = 0.0;
  		double y = y0;
    	if (i != 0) {
    		x = xInc * i;
    		double x4 = math.pow(x, power);
    		y = math.pow(r4 - x4, recipPow);
    	}
      pts[i] = coordTrans(x, y, centre);
      pts[2 * nSegsInOct - i] = coordTrans(y, x, centre);
      
      pts[2 * nSegsInOct + i] = coordTrans(y, -x, centre);
      pts[4 * nSegsInOct - i] = coordTrans(x, -y, centre);
      
      pts[4 * nSegsInOct + i] = coordTrans(-x, -y, centre);
      pts[6 * nSegsInOct - i] = coordTrans(-y, -x, centre);
      
      pts[6 * nSegsInOct + i] = coordTrans(-y, x, centre);
      pts[8 * nSegsInOct - i] = coordTrans(-x, y, centre);
    }
    pts[pts.length-1] = new Coordinate(pts[0]);

    LinearRing ring = geomFact.createLinearRing(pts);
    Polygon poly = geomFact.createPolygon(ring);
    return (Polygon) rotate(poly);
  }

   /**
    * Creates an elliptical arc, as a {@link LineString}.
    * The arc is always created in a counter-clockwise direction.
    * This can easily be reversed if required by using 
    * {#link LineString.reverse()}
    *
    * @param startAng start angle in radians
    * @param angExtent size of angle in radians
    * @return an elliptical arc
    */
  LineString createArc(
     double startAng,
     double angExtent)
  {
    Envelope env = dim.getEnvelope();
    double xRadius = env.getWidth() / 2.0;
    double yRadius = env.getHeight() / 2.0;

    double centreX = env.getMinX() + xRadius;
    double centreY = env.getMinY() + yRadius;

     double angSize = angExtent;
     if (angSize <= 0.0 || angSize > Angle.PI_TIMES_2)
       angSize = Angle.PI_TIMES_2;
     double angInc = angSize / (nPts - 1);

     List<Coordinate> pts = new Coordinate[nPts];
     int iPt = 0;
     for (int i = 0; i < nPts; i++) {
         double ang = startAng + i * angInc;
         double x = xRadius * Angle.cosSnap(ang) + centreX;
         double y = yRadius * Angle.sinSnap(ang) + centreY;
         pts[iPt++] = coord(x, y);
     }
     LineString line = geomFact.createLineString(pts);
     return (LineString) rotate(line);
   }

  /**
   * Creates an elliptical arc polygon.
   * The polygon is formed from the specified arc of an ellipse
   * and the two radii connecting the endpoints to the centre of the ellipse.
   *
   * @param startAng start angle in radians
   * @param angExtent size of angle in radians
   * @return an elliptical arc polygon
   */
  Polygon createArcPolygon(double startAng, double angExtent) {
    Envelope env = dim.getEnvelope();
    double xRadius = env.getWidth() / 2.0;
    double yRadius = env.getHeight() / 2.0;

    double centreX = env.getMinX() + xRadius;
    double centreY = env.getMinY() + yRadius;

    double angSize = angExtent;
    if (angSize <= 0.0 || angSize > Angle.PI_TIMES_2)
      angSize = Angle.PI_TIMES_2;
    double angInc = angSize / (nPts - 1);
    // double check = angInc * nPts;
    // double checkEndAng = startAng + check;

    List<Coordinate> pts = new Coordinate[nPts + 2];

    int iPt = 0;
    pts[iPt++] = coord(centreX, centreY);
    for (int i = 0; i < nPts; i++) {
      double ang = startAng + angInc * i;

      double x = xRadius * Angle.cosSnap(ang) + centreX;
      double y = yRadius * Angle.sinSnap(ang) + centreY;
      pts[iPt++] = coord(x, y);
    }
    pts[iPt++] = coord(centreX, centreY);
    LinearRing ring = geomFact.createLinearRing(pts);
    Polygon poly = geomFact.createPolygon(ring);
    return (Polygon) rotate(poly);
  }

  protected Coordinate coord(double x, double y)
  {
  	Coordinate pt = new Coordinate(x, y);
    precModel.makePrecise(pt);
    return pt;
  }
  
  protected Coordinate coordTrans(double x, double y, Coordinate trans)
  {
  	return coord(x + trans.x, y + trans.y);
  }
  
  static protected class Dimensions
  {
    Coordinate base;
    Coordinate centre;
    double width;
    double height;

    void setBase(Coordinate base)  {  this.base = base;    }
    Coordinate getBase() { return base; }
    
    void setCentre(Coordinate centre)  {  this.centre = centre;    }
    Coordinate getCentre() 
    { 
      if (centre == null) {
        centre = new Coordinate(base.x + width/2, base.y + height/2);
      }
      return centre; 
    }
   
    void setSize(double size)
    {
      height = size;
      width = size;
    }

    double getMinSize()
    {
    	return math.min(width, height);
    }
    void setWidth(double width) { this.width = width; }
    double getWidth() { return width; }
    double getHeight() { return height; }
    
    void setHeight(double height) { this.height = height; }

    void setEnvelope(Envelope env)
    {
    	this.width = env.getWidth();
    	this.height = env.getHeight();
    	this.base = new Coordinate(env.getMinX(), env.getMinY());
    	this.centre = new Coordinate(env.centre());
    }
    
    Envelope getEnvelope() {
      if (base != null) {
        return new Envelope(base.x, base.x + width, base.y, base.y + height);
      }
      if (centre != null) {
        return new Envelope(centre.x - width/2, centre.x + width/2,
                            centre.y - height/2, centre.y + height/2);
      }
      return new Envelope(0, width, 0, height);
    }
    
  }
}