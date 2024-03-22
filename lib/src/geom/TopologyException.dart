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


import 'package:jtscore4dart/src/geom/Coordinate.dart';

/// Indicates an invalid or inconsistent topological situation encountered during processing
///
/// @version 1.7
// TODO: ruier edit.
class TopologyException
  // implements Error
  implements Exception
{

  static String _msgWithCoord(String msg, [Coordinate? pt])
  {
    if (pt != null) {
      return "$msg [ $pt ]";
    }
    return msg;
  }

  String msg;
  Coordinate? pt;

  TopologyException(this.msg, [this.pt]);

  // TopologyException(String msg, [this.pt])
  // {
  //   if (pt == null) {
  //     super(msg);
  //   }
  //   pt = Coordinate.fromAnother(pt!);
  //   super(_msgWithCoord(msg, pt));
  // }

  Coordinate? getCoordinate() { return pt; }

  @override
  String toString() {
    return _msgWithCoord(msg, getCoordinate());
  }
  
}
