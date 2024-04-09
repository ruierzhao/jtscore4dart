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


// import org.locationtech.jts.index.ItemVisitor;

import 'dart:math' as math;

import 'package:jtscore4dart/src/index/ItemVisitor.dart';

import 'IntervalRTreeNode.dart';

class IntervalRTreeBranchNode extends IntervalRTreeNode
{
	/**private */ IntervalRTreeNode node1;
	/**private */ IntervalRTreeNode node2;
	
	IntervalRTreeBranchNode(this.node1,this.node2)
	{
		_buildExtent(node1, node2);
	}
	
  void _buildExtent(IntervalRTreeNode n1, IntervalRTreeNode n2)
	{
		super.min = math.min(n1.min, n2.min);
		super.max = math.max(n1.max, n2.max);
	}
	
	void queryByVisitor(double queryMin, double queryMax, ItemVisitor visitor)
	{
		if (! intersects(queryMin, queryMax)) {
//			System.out.println("Does NOT Overlap branch: " + this);
			return;
		}
//		System.out.println("Overlaps branch: " + this);
		if (node1 != null) node1.queryByVisitor(queryMin, queryMax, visitor);
		if (node2 != null) node2.queryByVisitor(queryMin, queryMax, visitor);
	}
  
}
