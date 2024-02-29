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
// import org.locationtech.jts.geom.LineString;
// import org.locationtech.jts.geom.MultiLineString;

/**
 * Extracts all the {@link LineString} elements from a {@link Geometry}.
 *
 * @version 1.7
 * @see GeometryExtracter
 */
class LineStringExtracter
  implements GeometryFilter
{
  /**
   * Extracts the {@link LineString} elements from a single {@link Geometry}
   * and adds them to the provided {@link List}.
   * 
   * @param geom the geometry from which to extract
   * @param lines the list to add the extracted LineStrings to
   * @return the list argument
   */
  static List getLines(Geometry geom, List lines)
  {
  	if (geom is LineString) {
  		lines.add(geom);
  	}
  	else if (geom is GeometryCollection) {
  		geom.apply(new LineStringExtracter(lines));
  	}
  	// skip non-LineString elemental geometries
  	
    return lines;
  }

  /**
   * Extracts the {@link LineString} elements from a single {@link Geometry}
   * and returns them in a {@link List}.
   * 
   * @param geom the geometry from which to extract
   * @return a list containing the linear elements
   */
  static List getLines(Geometry geom)
  {
    return getLines(geom, new ArrayList());
  }

  /**
   * Extracts the {@link LineString} elements from a single {@link Geometry}
   * and returns them as either a {@link LineString} or {@link MultiLineString}.
   * 
   * @param geom the geometry from which to extract
   * @return a linear geometry
  */
  static Geometry getGeometry(Geometry geom)
  {
    return geom.getFactory().buildGeometry(getLines(geom));
  }

  private List comps;
  
  /**
   * Constructs a filter with a list in which to store the elements found.
   */
  LineStringExtracter(List comps)
  {
    this.comps = comps;
  }

  void filter(Geometry geom)
  {
    if (geom is LineString) comps.add(geom);
  }

}
