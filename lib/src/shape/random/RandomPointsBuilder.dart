/*
 * Copyright (c) 2016 Martin Davis.
 *
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License 2.0
 * and Eclipse Distribution License v. 1.0 which accompanies this distribution.
 * The Eclipse Public License is available at http://www.eclipse.org/legal/epl-v20.html
 * and the Eclipse Distribution License is available at
 *
 * http://www.eclipse.org/org/documents/edl-v10.php.
 */



// import org.locationtech.jts.algorithm.locate.IndexedPointInAreaLocator;
// import org.locationtech.jts.algorithm.locate.PointOnGeometryLocator;
// import org.locationtech.jts.geom.Coordinate;
// import org.locationtech.jts.geom.Envelope;
// import org.locationtech.jts.geom.Geometry;
// import org.locationtech.jts.geom.GeometryFactory;
// import org.locationtech.jts.geom.Location;
// import org.locationtech.jts.geom.Polygonal;
// import org.locationtech.jts.shape.GeometricShapeBuilder;

/**
 * Creates random point sets contained in a 
 * region defined by either a rectangular or a polygonal extent. 
 * 
 * @author mbdavis
 *
 */
class RandomPointsBuilder 
extends GeometricShapeBuilder
{
 /**protected */Geometry maskPoly = null;
 /**private */PointOnGeometryLocator extentLocator;

  /**
   * Create a shape factory which will create shapes using the default
   * {@link GeometryFactory}.
   */
  RandomPointsBuilder()
  {
    super(new GeometryFactory());
  }

  /**
   * Create a shape factory which will create shapes using the given
   * {@link GeometryFactory}.
   *
   * @param geomFact the factory to use
   */
  RandomPointsBuilder(GeometryFactory geomFact)
  {
  	super(geomFact);
  }

  /**
   * Sets a polygonal mask.
   * 
   * @param mask
   * @throws ArgumentError if the mask is not polygonal
   */
  void setExtent(Geometry mask)
  {
  	if (! (mask is Polygonal))
  		throw new ArgumentError("Only polygonal extents are supported");
  	this.maskPoly = mask;
  	setExtent(mask.getEnvelopeInternal());
  	extentLocator = new IndexedPointInAreaLocator(mask);
  }
  
  Geometry getGeometry()
  {
  	List<Coordinate> pts = new Coordinate[numPts];
  	int i = 0;
  	while (i < numPts) {
  		Coordinate p = createRandomCoord(getExtent());
  		if (extentLocator != null && ! isInExtent(p))
  			continue;
  		pts[i++] = p;
  	}
  	return geomFactory.createMultiPointFromCoords(pts);
  }
  
 /**protected */bool isInExtent(Coordinate p)
  {
  	if (extentLocator != null) 
  		return extentLocator.locate(p) != Location.EXTERIOR;
  	return getExtent().contains(p);
  }
  
 /**protected */Coordinate createCoord(double x, double y)
  {
  	Coordinate pt = new Coordinate(x, y);
  	geomFactory.getPrecisionModel().makePrecise(pt);
    return pt;
  }
  
 /**protected */Coordinate createRandomCoord(Envelope env)
  {
    double x = env.getMinX() + env.getWidth() * math.random();
    double y = env.getMinY() + env.getHeight() * math.random();
    return createCoord(x, y);
  }

}
