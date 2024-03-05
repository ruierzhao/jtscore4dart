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


/**
 * Builds an edge graph from geometries containing edges.
 * 
 * @author mdavis
 *
 */
class EdgeGraphBuilder 
{
  static EdgeGraph build(Collection geoms) {
    EdgeGraphBuilder builder = new EdgeGraphBuilder();
    builder.add(geoms);
    return builder.getGraph();
  }

 /**private */EdgeGraph graph = new EdgeGraph();

  EdgeGraphBuilder()
  {
    
  }
  
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
    geometry.apply(new GeometryComponentFilter() {
      void filter(Geometry component) {
        if (component is LineString) {
          add((LineString)component);
        }
      }      
    });
  }
  /**
   * Adds the edges in a collection of {@link Geometry}s to the graph. 
   * May be called multiple times.
   * Any dimension of Geometry may be added.
   * 
   * @param geometries the geometries to be added
   */
  void add(Collection geometries) 
  {
    for (Iterator i = geometries.iterator(); i.hasNext(); ) {
      Geometry geometry = (Geometry) i.next();
      add(geometry);
    }
  }
  
 /**private */void add(LineString lineString) {
    CoordinateSequence seq = lineString.getCoordinateSequence();
    for (int i = 1; i < seq.size(); i++) {
      graph.addEdge(seq.getCoordinate(i-1), seq.getCoordinate(i));
    }
  }

  
}
