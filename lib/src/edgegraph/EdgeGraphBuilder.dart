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



// import java.util.Collection;
// import java.util.Iterator;

// import org.locationtech.jts.geom.CoordinateSequence;
// import org.locationtech.jts.geom.Geometry;
// import org.locationtech.jts.geom.GeometryComponentFilter;
// import org.locationtech.jts.geom.LineString;


import 'package:jtscore4dart/src/geom/CoordinateSequence.dart';
import 'package:jtscore4dart/src/geom/Geometry.dart';
import 'package:jtscore4dart/src/geom/GeometryComponentFilter.dart';
import 'package:jtscore4dart/src/geom/LineString.dart';

import 'EdgeGraph.dart';

/**
 * Builds an edge graph from geometries containing edges.
 * 
 * @author mdavis
 *
 */
class EdgeGraphBuilder 
{
  static EdgeGraph build(Iterable geoms) {
    EdgeGraphBuilder builder = new EdgeGraphBuilder();
    builder.addAll(geoms);
    return builder.getGraph();
  }

 /**private */EdgeGraph graph = new EdgeGraph();

  // EdgeGraphBuilder()
  // {
    
  // }
  
  EdgeGraph getGraph()
  {
    return graph;
  }
  
  /**
   * Adds the edges of a Geometry to the graph. 
   * May be called multiple times.
   * Any dimension of Geometry may be added; the constituent edges are
   * extracted.
   * 
   * @param geometry geometry to be added
   */  
  void add(Geometry geometry) {
    geometry.applyGeometryComonent(_(graph));
  }
  /**
   * Adds the edges in a collection of {@link Geometry}s to the graph. 
   * May be called multiple times.
   * Any dimension of Geometry may be added.
   * 
   * @param geometries the geometries to be added
   */
  void addAll(Iterable geometries) 
  {
    for (Iterator i = geometries.iterator; i.moveNext(); ) {
      Geometry geometry = i.current;
      add(geometry);
    }
  }
  

  
}

class _ implements GeometryComponentFilter {
  /// TODO: @ruier edit.或许有指针指向变化bugs。
  final EdgeGraph graph;
  _(this.graph);
  /**private */void _add(LineString lineString) {
    CoordinateSequence seq = lineString.getCoordinateSequence();
    for (int i = 1; i < seq.size(); i++) {
      graph.addEdge(seq.getCoordinate(i-1), seq.getCoordinate(i));
    }
  }
  void filter(Geometry component) {
    if (component is LineString) {
      _add(component as LineString);
    }
  }      
}
