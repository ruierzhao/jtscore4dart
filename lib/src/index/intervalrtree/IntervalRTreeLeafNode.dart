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

import '../ItemVisitor.dart';
import 'IntervalRTreeNode.dart';

class IntervalRTreeLeafNode extends IntervalRTreeNode
{
 /**private */Object item;
	
	IntervalRTreeLeafNode(double min, double max, this.item)
	{
		this.min = min;
		this.max = max;
	}
	
	@override
  void queryByVisitor(double queryMin, double queryMax, ItemVisitor visitor)
	{
		if (! intersects(queryMin, queryMax)) {
		  return;
		}
		
		visitor.visitItem(item);
	}
  
	
}
