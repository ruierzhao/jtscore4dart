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
// import org.locationtech.jts.geom.Puntal;


import '../Geometry.dart';
import '../Puntal.dart';
import 'BasicPreparedGeometry.dart';

/**
 * A prepared version for {@link Puntal} geometries.
 * <p>
 * Instances of this class are thread-safe.
 * 
 * @author Martin Davis
 *
 */
class PreparedPoint extends BasicPreparedGeometry
{
  PreparedPoint(Puntal point) {
    super((Geometry) point);
  }

  /**
   * Tests whether this point intersects a {@link Geometry}.
   * <p>
   * The optimization here is that computing topology for the test geometry
   * is avoided.  This can be significant for large geometries.
   */
  bool intersects(Geometry g)
  {
  	if (! envelopesIntersect(g)) return false;
  	
  	/**
  	 * This avoids computing topology for the test geometry
  	 */
    return isAnyTargetComponentInTest(g);
  }  
}
