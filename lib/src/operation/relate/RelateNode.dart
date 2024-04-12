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


// import org.locationtech.jts.geom.Coordinate;
// import org.locationtech.jts.geom.IntersectionMatrix;
// import org.locationtech.jts.geomgraph.EdgeEndStar;
// import org.locationtech.jts.geomgraph.Node;

import "package:jtscore4dart/src/geom/Coordinate.dart";
import "package:jtscore4dart/src/geom/IntersectionMatrix.dart";
import 'package:jtscore4dart/src/geomgraph/Node.dart';
import 'package:jtscore4dart/src/geomgraph/EdgeEndStar.dart';

import 'EdgeEndBundleStar.dart';

/**
 * Represents a node in the topological graph used to compute spatial relationships.
 *
 * @version 1.7
 */
class RelateNode
  extends Node
{

  RelateNode(Coordinate coord, EdgeEndStar edges)
    :super(coord, edges);

  /**
   * Update the IM with the contribution for this component.
   * A component only contributes if it has a labelling for both parent geometries
   */
 /**protected */
  @override
  void computeIM(IntersectionMatrix im)
  {
    im.setAtLeastIfValid(label.getLocation(0), label.getLocation(1), 0);
  }
  /**
   * Update the IM with the contribution for the EdgeEnds incident on this node.
   */
  void updateIMFromEdges(IntersectionMatrix im)
  {
    ( edges as EdgeEndBundleStar).updateIM(im);
  }

}
