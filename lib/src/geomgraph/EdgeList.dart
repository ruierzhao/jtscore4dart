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


// import java.io.PrintStream;
// import java.util.ArrayList;
// import java.util.Collection;
// import java.util.Iterator;
// import java.util.List;
// import java.util.Map;
// import java.util.TreeMap;

// import org.locationtech.jts.geom.Coordinate;
// import org.locationtech.jts.noding.OrientedCoordinateArray;


/**
 * A EdgeList is a list of Edges.  It supports locating edges
 * that are pointwise equals to a target edge.
 * @version 1.7
 */
class EdgeList
{
  private List edges = new ArrayList();
  /**
   * An index of the edges, for fast lookup.
   *
   */
  private Map ocaMap = new TreeMap();

  EdgeList() {
  }

  /**
   * Insert an edge unless it is already in the list
   *
   * @param e Edge
   */
  void add(Edge e)
  {
    edges.add(e);
    OrientedCoordinateArray oca = new OrientedCoordinateArray(e.getCoordinates());
    ocaMap.put(oca, e);
  }

  void addAll(Collection edgeColl)
  {
    for (Iterator i = edgeColl.iterator(); i.hasNext(); ) {
      add((Edge) i.next());
    }
  }

  List getEdges() { return edges; }

  /**
   * If there is an edge equal to e already in the list, return it.
   * Otherwise return null.
   * @param e Edge
   * @return  equal edge, if there is one already in the list
   *          null otherwise
   */
  Edge findEqualEdge(Edge e)
  {
    OrientedCoordinateArray oca = new OrientedCoordinateArray(e.getCoordinates());
    // will return null if no edge matches
    Edge matchEdge = (Edge) ocaMap.get(oca);
    return matchEdge; 
  }
  
  Iterator iterator() { return edges.iterator(); }

  Edge get(int i) { return (Edge) edges.get(i); }

  /**
   * If the edge e is already in the list, return its index.
   * @param e Edge
   * @return  index, if e is already in the list
   *          -1 otherwise
   */
  int findEdgeIndex(Edge e)
  {
    for (int i = 0; i < edges.size(); i++) {
      if ( ((Edge) edges.get(i)).equals(e) ) return i;
    }
    return -1;
  }

  void print(PrintStream out)
  {
    out.print("MULTILINESTRING ( ");
    for (int j = 0; j < edges.size(); j++) {
      Edge e = (Edge) edges.get(j);
      if (j > 0) out.print(",");
      out.print("(");
      List<Coordinate> pts = e.getCoordinates();
      for (int i = 0; i < pts.length; i++) {
        if (i > 0) out.print(",");
        out.print(pts[i].x + " " + pts[i].y);
      }
      out.println(")");
    }
    out.print(")  ");
  }


}