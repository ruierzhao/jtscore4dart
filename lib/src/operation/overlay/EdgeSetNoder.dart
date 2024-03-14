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
// import java.util.Iterator;
// import java.util.List;

// import org.locationtech.jts.algorithm.LineIntersector;
// import org.locationtech.jts.geomgraph.Edge;
// import org.locationtech.jts.geomgraph.index.EdgeSetIntersector;
// import org.locationtech.jts.geomgraph.index.SegmentIntersector;
// import org.locationtech.jts.geomgraph.index.SimpleMCSweepLineIntersector;

/**
 * Nodes a set of edges.
 * Takes one or more sets of edges and constructs a
 * new set of edges consisting of all the split edges created by
 * noding the input edges together
 * @version 1.7
 */
class EdgeSetNoder {

 /**private */LineIntersector li;
 /**private */List inputEdges = new ArrayList();

  EdgeSetNoder(LineIntersector li) {
    this.li = li;
  }

  void addEdges(List edges)
  {
    inputEdges.addAll(edges);
  }

  List getNodedEdges()
  {
    EdgeSetIntersector esi = new SimpleMCSweepLineIntersector();
    SegmentIntersector si = new SegmentIntersector(li, true, false);
    esi.computeIntersections(inputEdges, si, true);
//Debug.println("has proper int = " + si.hasProperIntersection());

    List splitEdges = new ArrayList();
    for (Iterator i = inputEdges.iterator(); i.moveNext(); ) {
      Edge e = (Edge) i.current;
      e.getEdgeIntersectionList().addSplitEdges(splitEdges);
    }
    return splitEdges;
  }
}
