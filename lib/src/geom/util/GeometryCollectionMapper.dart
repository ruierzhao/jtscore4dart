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
// import org.locationtech.jts.geom.GeometryFactory;
// import org.locationtech.jts.geom.util.GeometryMapper.MapOp;

import 'package:jtscore4dart/src/geom/Geometry.dart';

import '../GeometryCollection.dart';
import '../GeometryFactory.dart';
import 'GeometryMapper.dart' show MapOp;

/**
 * Maps the members of a {@link GeometryCollection}
 * into another <tt>GeometryCollection</tt> via a defined
 * mapping function.
 * 
 * @author Martin Davis
 *
 */
class GeometryCollectionMapper 
{
  static GeometryCollection map(GeometryCollection gc, MapOp op)
  {
    GeometryCollectionMapper mapper = new GeometryCollectionMapper(op);
    return mapper.map(gc);
  }
  
 /**private */MapOp? mapOp = null;
  
  GeometryCollectionMapper(MapOp mapOp) {
    this.mapOp = mapOp;
  }

  GeometryCollection map(GeometryCollection gc)
  {
    List mapped = [];
    for (int i = 0; i < gc.getNumGeometries(); i++) {
      Geometry g = mapOp.map(gc.getGeometryN(i));
      if (!g.isEmpty()) {
        mapped.add(g);
      }
    }
    return gc.getFactory().createGeometryCollection(
        GeometryFactory.toGeometryArray(mapped));
  }
}
