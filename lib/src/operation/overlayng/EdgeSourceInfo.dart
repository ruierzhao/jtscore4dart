/*
 * Copyright (c) 2019 Martin Davis.
 *
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License 2.0
 * and Eclipse Distribution License v. 1.0 which accompanies this distribution.
 * The Eclipse Public License is available at http://www.eclipse.org/legal/epl-v20.html
 * and the Eclipse Distribution License is available at
 *
 * http://www.eclipse.org/org/documents/edl-v10.php.
 */


// import org.locationtech.jts.geom.Dimension;

import 'package:jtscore4dart/src/geom/Dimension.dart';

import 'Edge.dart';

/**
 * Records topological information about an 
 * edge representing a piece of linework (lineString or polygon ring)
 * from a single source geometry.
 * This information is carried through the noding process
 * (which may result in many noded edges sharing the same information object).
 * It is then used to populate the topology info fields
 * in {@link Edge}s (possibly via merging).
 * That information is used to construct the topology graph {@link OverlayLabel}s.
 * 
 * @author mdavis
 *
 */
class EdgeSourceInfo {
 /**private */int index;
 /**private */int dim = -999;
 /**private */bool _isHole = false;
 /**private */int depthDelta = 0;
  
  EdgeSourceInfo(this.index, [this.depthDelta=0, this._isHole=false]) :
    this.dim = Dimension.A;
  

  int getIndex() {
    return index;
  }
  
  int getDimension() {
    return dim;
  }
  int getDepthDelta() {
    return depthDelta;
  }
  
  bool isHole() {
    return _isHole;
  }
  
  @override
  String toString() {
    return Edge.infoString(index, dim, _isHole, depthDelta);
  }
}
