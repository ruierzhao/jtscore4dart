/*
 * Copyright (c) 2020 Martin Davis.
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
// import org.locationtech.jts.index.kdtree.KdNode;
// import org.locationtech.jts.index.kdtree.KdTree;

import 'package:jtscore4dart/src/geom/Coordinate.dart';
import 'package:jtscore4dart/src/index/kdtree/KdNode.dart';
import 'package:jtscore4dart/src/index/kdtree/KdTree.dart';

/**
 * An index providing fast creation and lookup of snap points.
 * 
 * @author mdavis
 *
 */
class SnappingPointIndex {
  double _snapTolerance;

  /**
   * Since points are added incrementally, this index needs to be dynamic.
   * This class also makes use of the KdTree support for a tolerance distance
   * for point equality.
   */
  KdTree _snapPointIndex;

  /**
   * Creates a snap point index using a specified distance tolerance.
   * 
   * @param [snapTolerance] points are snapped if within this distance
   */
  SnappingPointIndex(this._snapTolerance)
      : _snapPointIndex = new KdTree(_snapTolerance);

  /**
   * Snaps a coordinate to an existing snap point, 
   * if it is within the snap tolerance distance.
   * Otherwise adds the coordinate to the snap point index.
   * 
   * @param p the point to snap
   * @return the point it snapped to, or the input point
   */
  Coordinate snap(Coordinate p) {
    /**
     * Inserting the coordinate snaps it to any existing
     * one within tolerance, or adds it if not.
     */
    KdNode node = _snapPointIndex.insert(p);
    return node.getCoordinate();
  }

  /**
   * Gets the snapping tolerance value for the index.
   * 
   * @return the snapping tolerance value
   */
  double getTolerance() {
    return _snapTolerance;
  }

  /**
   * Computes the depth of the index tree.
   * 
   * @return the depth of the index tree
   */
  int depth() {
    return _snapPointIndex.depth();
  }
}
