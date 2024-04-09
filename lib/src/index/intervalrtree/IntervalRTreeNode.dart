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


// import java.util.Comparator;

// import org.locationtech.jts.geom.Coordinate;
// import org.locationtech.jts.index.ItemVisitor;
// import org.locationtech.jts.io.WKTWriter;


import '../ItemVisitor.dart';

abstract class IntervalRTreeNode 
{
  /// 代替 [NodeComparator] class
  static Comparator<IntervalRTreeNode> NodeComparator = (IntervalRTreeNode n1, IntervalRTreeNode n2){
    double mid1 = (n1.min + n1.max) / 2;
    double mid2 = (n2.min + n2.max) / 2;
    if (mid1 < mid2) return -1;
    if (mid1 > mid2) return 1;
    return 0;
  };

	// /**protected */ double min = Double.POSITIVE_INFINITY;
	/**protected */ double min = double.infinity;
	// /**protected */ double max = Double.NEGATIVE_INFINITY;
	/**protected */ double max = double.infinity;

	double getMin() { return min; }
	double getMax() { return max; }
	
	/**abstract */ void queryByVisitor(double queryMin, double queryMax, ItemVisitor visitor);
	
	/**protected */ bool intersects(double queryMin, double queryMax)
	{
		if (min > queryMax || max < queryMin) {
		  return false;
		}
		return true;
	}
  /// TODO: @ruier edit.
	// String toString()
	// {
	// 	return WKTWriter.toLineString(new Coordinate(min, 0), new Coordinate(max, 0));
	// }
  
}

// /**static */ class NodeComparator implements Comparator
// {
//   int compare(Object o1, Object o2)
//   {
//     IntervalRTreeNode n1 = o1 as IntervalRTreeNode;
//     IntervalRTreeNode n2 = o2 as IntervalRTreeNode;
//     double mid1 = (n1.min + n1.max) / 2;
//     double mid2 = (n2.min + n2.max) / 2;
//     if (mid1 < mid2) return -1;
//     if (mid1 > mid2) return 1;
//     return 0;
//   }
// }




