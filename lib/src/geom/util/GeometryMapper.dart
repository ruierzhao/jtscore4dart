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


// import java.util.ArrayList;
// import java.util.Collection;
// import java.util.Iterator;
// import java.util.List;

// import org.locationtech.jts.geom.Geometry;
// import org.locationtech.jts.geom.GeometryCollection;

import '../Geometry.dart';
import '../GeometryCollection.dart';

/**
 * Methods to map various collections 
 * of {@link Geometry}s  
 * via defined mapping functions.
 * 
 * @author Martin Davis
 *
 */
class GeometryMapper 
{
  /**
   * Maps the members of a {@link Geometry}
   * (which may be atomic or composite)
   * into another <tt>Geometry</tt> of most specific type.
   * <tt>null</tt> results are skipped.
   * In the case of hierarchical {@link GeometryCollection}s,
   * only the first level of members are mapped.
   *  
   * @param geom the input atomic or composite geometry
   * @param op the mapping operation
   * @return a result collection or geometry of most specific type
   */
  static Geometry map(Geometry geom, MapOp op)
  {
    List<Geometry> mapped = [];
    for (int i = 0; i < geom.getNumGeometries(); i++) {
      Geometry? g = op.map(geom.getGeometryN(i));
      if (g != null) {
        mapped.add(g);
      }
    }
    return geom.getFactory().buildGeometry(mapped);
  }
  
  static Iterable mapAll(Iterable geoms, MapOp op)
  {
    List mapped = [];
    for (Iterator i = geoms.iterator; i.moveNext(); ) {
      Geometry g = i.current;
      Geometry? gr = op.map(g);
      if (gr != null) {
        mapped.add(gr);
      }
    }
    return mapped;
  }
  
  /**
   * Maps the atomic elements of a {@link Geometry}
   * (which may be atomic or composite)
   * using a {@link MapOp} mapping operation
   * into an atomic <tt>Geometry</tt> or a flat collection
   * of the most specific type.
   * <tt>null</tt> and empty values returned from the mapping operation
   * are discarded.
   * 
   * @param [geom] the geometry to map
   * @param [emptyDim] the dimension of empty geometry to create
   * @param [op] the mapping operation
   * @return the mapped result
   */
  static Geometry flatMap(Geometry geom, int emptyDim, MapOp op)
  {
    // List<Geometry> mapped = new ArrayList<Geometry>();
    List<Geometry> mapped = <Geometry>[];
    _flatMap(geom, op, mapped);

    if (mapped.isEmpty) {
      return geom.getFactory().createEmpty(emptyDim);
    }
    if (mapped.length == 1) {
      return mapped[0];
    }
    return geom.getFactory().buildGeometry(mapped);
  }
  
  static void _flatMap(Geometry geom, MapOp op, List<Geometry> mapped)
  {
    for (int i = 0; i < geom.getNumGeometries(); i++) {
      Geometry g = geom.getGeometryN(i);
      if (g is GeometryCollection) {
        _flatMap(g, op, mapped);
      }
      else {
        Geometry? res = op.map(g);
        /// TODO: @ruier edit.maybe null.
        if (res != null && ! res.isEmpty()) {
          addFlat(res, mapped);
        }
      }
    }
  }
  
 /**private */static void addFlat(Geometry geom, List<Geometry> geomList) {
    if (geom.isEmpty()) return;
    if (geom is GeometryCollection) {
      for (int i = 0; i < geom.getNumGeometries(); i++) {
        addFlat(geom.getGeometryN(i), geomList);
      }
    }
    else {
      geomList.add(geom);
    }
  }
  

}

  /**
   * An abstract class for geometry functions that map a geometry input to a geometry output.
   * The output may be <tt>null</tt> if there is no valid output value for 
   * the given input value.
   * 
   * @author Martin Davis
   *
   */
  abstract class MapOp 
  {
    /**
     * Maps a geometry value into another value.
     * 
     * @param [geom] the input geometry
     * @return a result geometry
     */
    Geometry map(Geometry geom);
  }