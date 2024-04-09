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


import 'MonotoneChainEdge.dart';
import 'SegmentIntersector.dart';

/**
 * @version 1.7
 */
class MonotoneChain {

  MonotoneChainEdge mce;
  int chainIndex;

  MonotoneChain(this.mce, this.chainIndex);

  void computeIntersections(MonotoneChain mc, SegmentIntersector si)
  {
    this.mce.computeIntersectsForChain(chainIndex, mc.mce, mc.chainIndex, si);
  }
}
