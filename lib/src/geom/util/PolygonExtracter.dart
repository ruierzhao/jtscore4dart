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


// import java.util.ArrayList;
// import java.util.List;

// import org.locationtech.jts.geom.Geometry;
// import org.locationtech.jts.geom.GeometryCollection;
// import org.locationtech.jts.geom.GeometryFilter;
// import org.locationtech.jts.geom.Polygon;

/**
 * Extracts all the {@link Polygon} elements from a {@link Geometry}.
 *
 * @version 1.7
 * @see GeometryExtracter
 */
class PolygonExtracter
  implements GeometryFilter
{
  /**
   * Extracts the {@link Polygon} elements from a single {@link Geometry}
   * and adds them to the provided {@link List}.
   * 
   * @param geom the geometry from which to extract
   * @param list the list to add the extracted elements to
   */
  static List getPolygons(Geometry geom, List list)
  {
  	if (geom is Polygon) {
  		list.add(geom);
  	}
  	else if (geom is GeometryCollection) {
  		geom.apply(new PolygonExtracter(list));
  	}
  	// skip non-Polygonal elemental geometries
  	
    return list;
  }

  /**
   * Extracts the {@link Polygon} elements from a single {@link Geometry}
   * and returns them in a {@link List}.
   * 
   * @param geom the geometry from which to extract
   */
  static List getPolygons(Geometry geom)
  {
    return getPolygons(geom, new ArrayList());
  }

  private List comps;
  /**
   * Constructs a PolygonExtracterFilter with a list in which to store Polygons found.
   */
  PolygonExtracter(List comps)
  {
    this.comps = comps;
  }

  void filter(Geometry geom)
  {
    if (geom is Polygon) comps.add(geom);
  }

}
