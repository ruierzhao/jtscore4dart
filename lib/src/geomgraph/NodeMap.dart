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
// import java.util.Map;
// import java.util.TreeMap;

// import org.locationtech.jts.geom.Coordinate;
// import org.locationtech.jts.geom.Location;

import 'dart:collection';

import 'package:jtscore4dart/src/geom/Coordinate.dart';
import 'package:jtscore4dart/src/geom/Location.dart';

import 'EdgeEnd.dart';
import 'Node.dart';
import 'NodeFactory.dart';

import 'package:jtscore4dart/src/patch/Map.dart';
/**
 * A map of nodes, indexed by the coordinate of the node
 * @version 1.7
 */
class NodeMap

{
  //Map nodeMap = new Map();
  // Map nodeMap = new TreeMap();
  Map nodeMap = new SplayTreeMap();
  NodeFactory nodeFact;

  NodeMap(this.nodeFact);

  /**
   * Factory function - subclasses can override to create their own types of nodes
   */
   /*
 /**protected */Node createNode(Coordinate coord)
  {
    return new Node(coord);
  }
  */
  /**
   * This method expects that a node has a coordinate value.
   * @param coord Coordinate
   * @return node for the provided coord
   */
  Node addNodeCoord(Coordinate coord)
  {
    Node? node = nodeMap.get(coord) as Node?;
    if (node == null) {
      node = nodeFact.createNode(coord);
      nodeMap.put(coord, node);
    }
    return node;
  }

  Node addNode(Node n)
  {
    Node? node = nodeMap.get(n.getCoordinate());
    if (node == null) {
      nodeMap.put(n.getCoordinate(), n);
      return n;
    }
    node.mergeLabel(n);
    return node;
  }

  /**
   * Adds a node for the start point of this EdgeEnd
   * (if one does not already exist in this map).
   * Adds the EdgeEnd to the (possibly new) node.
   *
   * @param e EdgeEnd
   */
  void add(EdgeEnd e)
  {
    Coordinate p = e.getCoordinate();
    Node n = addNodeCoord(p);
    n.add(e);
  }
  /**
   * Find coordinate.
   *
   * @param coord Coordinate to find
   * @return the node if found; null otherwise
   */
  Node? find(Coordinate coord)  {    return  nodeMap.get(coord) as Node;  }

  Iterator iterator()
  {
    return nodeMap.values.iterator;
  }
  Iterable values()
  {
    return nodeMap.values;
  }

  Iterable getBoundaryNodes(int geomIndex)
  {
    // Collection bdyNodes = [];
    List bdyNodes = [];
    for (Iterator i = iterator(); i.moveNext(); ) {
      Node node =  i.current;
      if (node.getLabel().getLocation(geomIndex) == Location.BOUNDARY)
        bdyNodes.add(node);
    }
    return bdyNodes;
  }

  // void print(PrintStream out)
  // {
  //   for (Iterator it = iterator(); it.moveNext(); )
  //   {
  //     Node n = (Node) it.current;
  //     n.print(out);
  //   }
  // }
  void printOut()
  {
    for (Iterator it = iterator(); it.moveNext(); )
    {
      Node n = it.current;
      n.printOut();
    }
  }
}
