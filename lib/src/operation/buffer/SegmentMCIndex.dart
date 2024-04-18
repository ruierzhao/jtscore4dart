/*
 * Copyright (c) 2021 Martin Davis.
 *
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License 2.0
 * and Eclipse Distribution License v. 1.0 which accompanies this distribution.
 * The Eclipse Public License is available at http://www.eclipse.org/legal/epl-v20.html
 * and the Eclipse Distribution License is available at
 *
 * http://www.eclipse.org/org/documents/edl-v10.php.
 */


// import java.util.List;

// import org.locationtech.jts.geom.Coordinate;
// import org.locationtech.jts.geom.Envelope;
// import org.locationtech.jts.index.ItemVisitor;
// import org.locationtech.jts.index.chain.MonotoneChain;
// import org.locationtech.jts.index.chain.MonotoneChainBuilder;
// import org.locationtech.jts.index.chain.MonotoneChainSelectAction;
// import org.locationtech.jts.index.strtree.STRtree;

import 'package:jtscore4dart/src/geom/Coordinate.dart';
import 'package:jtscore4dart/src/geom/Envelope.dart';
import 'package:jtscore4dart/src/index/ItemVisitor.dart';
import 'package:jtscore4dart/src/index/chain/MonotoneChain.dart';
import 'package:jtscore4dart/src/index/chain/MonotoneChainBuilder.dart';
import 'package:jtscore4dart/src/index/chain/MonotoneChainSelectAction.dart';
import 'package:jtscore4dart/src/index/strtree/STRtree.dart';

/**
 * A spatial index over a segment sequence 
 * using {@link MonotoneChain}s.
 * 
 * @author mdavis
 *
 */
class SegmentMCIndex {
 /**private */STRtree index;
  
  SegmentMCIndex(List<Coordinate> segs) :
    index = buildIndex(segs);
  
 /**private */
 static STRtree buildIndex(List<Coordinate> segs) {
    STRtree index = new STRtree();
    List<MonotoneChain> segChains = MonotoneChainBuilder.getChains(segs, segs);
    for (MonotoneChain mc in segChains ) {
      index.insert(mc.getEnvelope(), mc);
    }
    return index;
  }

  void query(Envelope env, MonotoneChainSelectAction action) {
    index.queryByVisitor(env, _ItemVisitor(env,action));
  }
}

class _ItemVisitor implements ItemVisitor {
  Envelope env;
  MonotoneChainSelectAction action;

  _ItemVisitor(this.env,this.action);
  
  @override
  void visitItem(Object item) {
    MonotoneChain testChain =  item as MonotoneChain;
    testChain.select(env, action);
  }
}
