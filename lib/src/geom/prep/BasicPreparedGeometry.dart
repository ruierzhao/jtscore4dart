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

// import org.locationtech.jts.algorithm.PointLocator;
// import org.locationtech.jts.geom.Coordinate;
// import org.locationtech.jts.geom.Geometry;
// import org.locationtech.jts.geom.GeometryCollection;
// import org.locationtech.jts.geom.util.ComponentCoordinateExtracter;


import 'package:jtscore4dart/src/algorithm/PointLocator.dart';
import 'package:jtscore4dart/src/geom/Coordinate.dart';
import 'package:jtscore4dart/src/geom/Geometry.dart';
import 'package:jtscore4dart/src/geom/util/ComponentCoordinateExtracter.dart';

import 'PreparedGeometry.dart';

/**
 * A base class for {@link PreparedGeometry} subclasses.
 * Contains default implementations for methods, which simply delegate
 * to the equivalent {@link Geometry} methods.
 * This class may be used as a "no-op" class for Geometry types
 * which do not have a corresponding {@link PreparedGeometry} implementation.
 * 
 * @author Martin Davis
 *
 */
class BasicPreparedGeometry 
  implements PreparedGeometry
{
 /**private */final Geometry baseGeom;
 /**private */final List representativePts;  // List<Coordinate>

  // BasicPreparedGeometry(Geometry geom) 
  // {
  //   baseGeom = geom;
  //   representativePts = ComponentCoordinateExtracter.getCoordinates(geom);
  // }
  BasicPreparedGeometry(this.baseGeom) :representativePts = ComponentCoordinateExtracter.getCoordinates(baseGeom);


  @override
  Geometry getGeometry() { return baseGeom; }

  /**
   * Gets the list of representative points for this geometry.
   * One vertex is included for every component of the geometry
   * (i.e. including one for every ring of polygonal geometries).
   * 
   * Do not modify the returned list!
   * 
   * @return a List of Coordinate
   */
  List getRepresentativePoints()
  {
	//TODO wrap in unmodifiable?
    return representativePts;
  }
  
	/**
	 * Tests whether any representative of the target geometry 
	 * intersects the test geometry.
	 * This is useful in A/A, A/L, A/P, L/P, and P/P cases.
	 * 
	 * @param testGeom the test geometry
	 * @return true if any component intersects the areal test geometry
	 */
	bool isAnyTargetComponentInTest(Geometry testGeom)
	{
		PointLocator locator = new PointLocator();
    // for (Iterator i = representativePts.iterator(); i.moveNext(); ) {
    for (Iterator i = representativePts.iterator; i.moveNext(); ) {
      // Coordinate p =  i.current;
      Coordinate p =  i.current;
      if (locator.intersects(p, testGeom)) {
        return true;
      }
    }
		return false;
	}

  /**
   * Determines whether a Geometry g interacts with 
   * this geometry by testing the geometry envelopes.
   *  
   * @param g a Geometry
   * @return true if the envelopes intersect
   */
 /**protected */bool envelopesIntersect(Geometry g)
  {
    if (! baseGeom.getEnvelopeInternal().intersectsWith(g.getEnvelopeInternal())) {
      return false;
    }
    return true;
  }
  
  /**
   * Determines whether the envelope of 
   * this geometry covers the Geometry g.
   * 
   *  
   * @param g a Geometry
   * @return true if g is contained in this envelope
   */
 /**protected */bool envelopeCovers(Geometry g)
  {
    if (! baseGeom.getEnvelopeInternal().covers(g.getEnvelopeInternal())) {
      return false;
    }
    return true;
  }
  
  /**
   * Default implementation.
   */
  @override
  bool contains(Geometry g)
  {
    return baseGeom.contains(g);
  }

  /**
   * Default implementation.
   */
  @override
  bool containsProperly(Geometry g)
  {
  	// since raw relate is used, provide some optimizations
  	
    // short-circuit test
    if (! baseGeom.getEnvelopeInternal().contains(g.getEnvelopeInternal())) {
      return false;
    }
  	
    // otherwise, compute using relate mask
    return baseGeom.relate(g, "T**FF*FF*");
  }

  /**
   * Default implementation.
   */
  @override
  bool coveredBy(Geometry g)
  {
    return baseGeom.coveredBy(g);
  }

  /**
   * Default implementation.
   */
  @override
  bool covers(Geometry g)
  {
    return baseGeom.covers(g);
  }

  /**
   * Default implementation.
   */
  @override
  bool crosses(Geometry g)
  {
    return baseGeom.crosses(g);
  }
  
  /**
   * Standard implementation for all geometries.
   * Supports {@link GeometryCollection}s as input.
   */
  @override
  bool disjoint(Geometry g)
  {
    return ! intersects(g);
  }
  
  /**
   * Default implementation.
   */
  @override
  bool intersects(Geometry g)
  {
    return baseGeom.intersects(g);
  }
  
  /**
   * Default implementation.
   */
  @override
  bool overlaps(Geometry g)
  {
    return baseGeom.overlaps(g);
  }
  
  /**
   * Default implementation.
   */
  @override
  bool touches(Geometry g)
  {
    return baseGeom.touches(g);
  }
  
  /**
   * Default implementation.
   */
  @override
  bool within(Geometry g)
  {
    return baseGeom.within(g);
  }
  
  @override
  String toString()
  {
  	return baseGeom.toString();
  }
}
