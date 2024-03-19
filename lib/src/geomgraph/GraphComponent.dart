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
// import org.locationtech.jts.util.Assert;

import 'package:jtscore4dart/src/geom/Coordinate.dart';
import 'package:jtscore4dart/src/geom/IntersectionMatrix.dart';
import 'package:jtscore4dart/src/util/Assert.dart';

import 'Label.dart';

/**
 * A GraphComponent is the parent class for the objects'
 * that form a graph.  Each GraphComponent can carry a
 * Label.
 * @version 1.7
 */
abstract class GraphComponent {

 /**protected */Label label;
  /**
   * isInResult indicates if this component has already been included in the result
   */
 /**private */bool _isInResult = false;
 /**private */bool _isCovered = false;
 /**private */bool _isCoveredSet = false;
 /**private */bool _isVisited = false;


  // GraphComponent() {
  // }

  GraphComponent(this.label);

  Label getLabel() { return label!; }

  void setLabel(Label label) { this.label = label; }
  
  void setInResult(bool isInResult) { this._isInResult = isInResult;}
  bool isInResult() { return _isInResult; }
  void setCovered(bool isCovered)
  {
    this._isCovered = isCovered;
    this._isCoveredSet = true;
  }

  bool isCovered()    { return _isCovered; }
  bool isCoveredSet() { return _isCoveredSet; }
  bool isVisited() { return _isVisited; }
  void setVisited(bool isVisited) { this._isVisited = isVisited; }
  /**
   * @return a coordinate in this component (or null, if there are none)
   */
   Coordinate? getCoordinate([int? i]);
  /**
   * Compute the contribution to an IM for this component.
   *
   * @param im Intersection matrix
   */
  /**protected */
  void computeIM(IntersectionMatrix im);
  /**
   * An isolated component is one that does not intersect or touch any other
   * component.  This is the case if the label has valid locations for
   * only a single Geometry.
   *
   * @return true if this component is isolated
   */
   bool isIsolated();
  /**
   * Update the IM with the contribution for this component.
   * A component only contributes if it has a labelling for both parent geometries
   * @param im Intersection matrix
   */
  void updateIM(IntersectionMatrix im)
  {
    Assert.isTrue(label!.getGeometryCount() >= 2, "found partial label");
    computeIM(im);
  }

}
