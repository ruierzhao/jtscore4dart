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


// import org.locationtech.jts.geom.Envelope;
// import org.locationtech.jts.shape.fractal.HilbertCode;

import 'dart:math';

import 'package:jtscore4dart/src/geom/Envelope.dart';
import 'package:jtscore4dart/src/shape/fractal/HilbertCode.dart';

class HilbertEncoder {
 /**private */int level;
 /**private */double minx;
 /**private */double miny;
 /**private */double strideX;
 /**private */double strideY;

  HilbertEncoder(this.level, Envelope extent) :
    // int hside = pow(2, level).toInt() - 1,
    
    minx = extent.getMinX(),
    strideX = extent.getWidth() / (pow(2, level).toInt() - 1),
    
    miny = extent.getMinY(),
    strideY = extent.getHeight() / (pow(2, level).toInt() - 1);

  int encode(Envelope env) {
    double midx = env.getWidth()/2 + env.getMinX();
    int x = ((midx - minx) ~/ strideX);

    double midy = env.getHeight()/2 + env.getMinY();
    int y = ((midy - miny) ~/ strideY);
      
    return HilbertCode.encode(level, x, y);
  }

}
