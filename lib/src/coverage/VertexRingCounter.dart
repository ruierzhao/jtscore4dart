/*
 * Copyright (c) 2022 Martin Davis.
 *
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License 2.0
 * and Eclipse Distribution License v. 1.0 which accompanies this distribution.
 * The Eclipse Public License is available at http://www.eclipse.org/legal/epl-v20.html
 * and the Eclipse Distribution License is available at
 *
 * http://www.eclipse.org/org/documents/edl-v10.php.
 */


// import java.util.Map;
// import java.util.Map;

// import org.locationtech.jts.geom.Coordinate;
// import org.locationtech.jts.geom.CoordinateSequence;
// import org.locationtech.jts.geom.CoordinateSequenceFilter;
// import org.locationtech.jts.geom.CoordinateSequences;
// import org.locationtech.jts.geom.Geometry;

/**
 * Counts the number of rings containing each vertex.
 * Vertices which are contained by 3 or more rings are nodes in the coverage topology
 * (although not the only ones - 
 * boundary vertices with 3 or more incident edges are also nodes).
 * @author mdavis
 *
 */
class VertexRingCounter implements CoordinateSequenceFilter {

  static Map<Coordinate, Integer> count(List<Geometry> geoms) {
    Map<Coordinate, Integer> vertexRingCount = new Map<Coordinate, Integer>();
    VertexRingCounter counter = new VertexRingCounter(vertexRingCount);
    for (Geometry geom : geoms) {
      geom.apply(counter);
    }
    return vertexRingCount;
  }

  private Map<Coordinate, Integer> vertexRingCount;
  
  VertexRingCounter(Map<Coordinate, Integer> vertexRingCount) {
    this.vertexRingCount = vertexRingCount;
  }

  @Override
  void filter(CoordinateSequence seq, int i) {
    //-- for rings don't double-count duplicate endpoint
    if (CoordinateSequences.isRing(seq) && i == 0)
      return;
    Coordinate v = seq.getCoordinate(i);
    int count = vertexRingCount.containsKey(v) ? vertexRingCount.get(v) : 0;
    count++;
    vertexRingCount.put(v, count);
  }

  @Override
  bool isDone() {
    return false;
  }

  @Override
  bool isGeometryChanged() {
    return false;
  }

}
