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


// import java.util.ArrayList;
// import java.util.Collection;
// import java.util.List;

// import org.locationtech.jts.algorithm.LineIntersector;
// import org.locationtech.jts.geom.Coordinate;
// import org.locationtech.jts.geom.impl.CoordinateArraySequence;
// import org.locationtech.jts.io.WKTWriter;

import 'package:jtscore4dart/src/algorithm/LineIntersector.dart';
import 'package:jtscore4dart/src/geom/Coordinate.dart';
import 'package:jtscore4dart/src/geomgraph/Label.dart';

import 'BasicSegmentString.dart';
import 'NodableSegmentString.dart';
import 'Octant.dart';
import 'SegmentNode.dart';
import 'SegmentNodeList.dart';
import 'SegmentString.dart';

/**
 * 代表一系列相邻的可连接线串
 * 支持链接起来
 * 
 * [SegmentString]s可以携带保存了拓扑信息和来源信息的上下文对象（maybe [Label]）
 * 对于只读的应用程序(?) - 应该使用更加轻量化的[BasicSegmentString]
 * 
 * Represents a list of contiguous line segments,
 * and supports noding the segments.
 * The line segments are represented by an array of {@link Coordinate}s.
 * Intended to optimize the noding of contiguous segments by
 * reducing the number of allocated objects.
 * {@link SegmentString}s can carry a context object, which is useful
 * for preserving topological or parentage information.
 * All noded substrings are initialized with the same context object.
 * <p>
 * For read-only applications use {@link BasicSegmentString}, 
 * which is (slightly) more lightweight.
 *
 * @version 1.7
 * @see BasicSegmentString
 */
class NodedSegmentString extends NodableSegmentString
	// implements NodableSegmentString
{
	/**
	 * Gets the {@link SegmentString}s which result from splitting this string at node points.
	 * 
	 * @param segStrings a Collection of NodedSegmentStrings
	 * @return a Collection of NodedSegmentStrings representing the substrings
	 */
  // static List getNodedSubstrings(Iterable segStrings)
  // {
  //   List resultEdgelist = [];
  //   getNodedSubstrings(segStrings, resultEdgelist);
  //   return resultEdgelist;
  // }

	/**
	 * Adds the noded {@link SegmentString}s which result from splitting this string at node points.
	 * 
	 * @param segStrings a Collection of NodedSegmentStrings
	 * @param resultEdgelist a List which will collect the NodedSegmentStrings representing the substrings
	 */
 static List getNodedSubstrings(Iterable segStrings, [Iterable? resultEdgelist])
  {
    // ignore: prefer_conditional_assignment
    if (resultEdgelist == null) resultEdgelist = [];
    for (Object segString in segStrings) {
      NodedSegmentString ss = segString as NodedSegmentString;
      ss.getNodeList().addSplitEdges(resultEdgelist  as List);
    }
    return resultEdgelist.toList();
  }

//  /**private */SegmentNodeList nodeList = SegmentNodeList(this);
 /**private */late SegmentNodeList nodeList;
 /**private */List<Coordinate> pts;
 /**private */Object? data;

  /**
   * Creates a instance from a list of vertices and optional data object.
   *
   * @param pts the vertices of the segment string
   * @param data the user-defined data of this segment string (may be null)
   */
  // NodedSegmentString(this.pts, this.data);
  NodedSegmentString(this.pts, this.data){
    nodeList = SegmentNodeList(this);
  }

  /**
   * Creates a new instance from a {@link SegmentString}.
   *
   * @param ss the segment string to use
   */
  NodedSegmentString.FromSS(SegmentString ss)
    :this.pts = ss.getCoordinates(),
    this.data = ss.getData();
  

  /**
   * Gets the user-defined data for this segment string.
   *
   * @return the user-defined data
   */
  @override
  Object? getData() { return data; }

  /**
   * Sets the user-defined data for this segment string.
   *
   * @param data an Object containing user-defined data
   */
  @override
  void setData(Object data) { this.data = data; }

  SegmentNodeList getNodeList() { return nodeList; }
  @override
  int size() { return pts.length; }
  @override
  Coordinate getCoordinate(int i) { return pts[i]; }
  @override
  List<Coordinate> getCoordinates() { return pts; }

  /**
   * Gets a list of coordinates with all nodes included.
   * 
   * @return an array of coordinates include nodes
   */
  List<Coordinate> getNodedCoordinates() {
    return nodeList.getSplitCoordinates();
  }
  
  @override
  bool isClosed()
  {
    return pts[0].equals(pts[pts.length - 1]);
  }

  /**
   * Tests whether any nodes have been added.
   * 
   * @return true if the segment string has nodes
   */
  bool hasNodes() {
    return nodeList.size() > 0;
  }
  /**
   * Gets the octant of the segment starting at vertex {@code index}.
   *
   * @param index the index of the vertex starting the segment.  Must not be
   * the last index in the vertex list
   * @return the octant of the segment at the vertex
   */
  int getSegmentOctant(int index)
  {
    if (index == pts.length - 1) return -1;
    return safeOctant(getCoordinate(index), getCoordinate(index + 1));
//    return Octant.octant(getCoordinate(index), getCoordinate(index + 1));
  }

 /**private */int safeOctant(Coordinate p0, Coordinate p1)
  {
  	if (p0.equals2D(p1)) return 0;
  	return Octant.octant(p0, p1);
  }
  
  /**
   * Adds EdgeIntersections for one or both
   * intersections found for a segment of an edge to the edge intersection list.
   */
  void addIntersections(LineIntersector li, int segmentIndex, int geomIndex)
  {
    for (int i = 0; i < li.getIntersectionNum(); i++) {
      addIntersection$1(li, segmentIndex, geomIndex, i);
    }
  }
  /**
   * Add an SegmentNode for intersection intIndex.
   * An intersection that falls exactly on a vertex
   * of the SegmentString is normalized
   * to use the higher of the two possible segmentIndexes
   */
  void addIntersection$1(LineIntersector li, int segmentIndex, int geomIndex, int intIndex)
  {
    Coordinate intPt = li.getIntersection(intIndex).copy();
    addIntersectionNode(intPt, segmentIndex);
  }

  /**
   * Adds an intersection node for a given point and segment to this segment string.
   * 
   * @param intPt the location of the intersection
   * @param segmentIndex the index of the segment containing the intersection
   */
  @override
  void  addIntersection(Coordinate intPt, int segmentIndex) {
  	addIntersectionNode(intPt, segmentIndex);
  }
  	
  /**
   * Adds an intersection node for a given point and segment to this segment string.
   * If an intersection already exists for this exact location, the existing
   * node will be returned.
   * 
   * @param intPt the location of the intersection
   * @param segmentIndex the index of the segment containing the intersection
   * @return the intersection node for the point
   */
  SegmentNode addIntersectionNode(Coordinate intPt, int segmentIndex) {
		int normalizedSegmentIndex = segmentIndex;
		//Debug.println("edge intpt: " + intPt + " dist: " + dist);
		// normalize the intersection point location
		int nextSegIndex = normalizedSegmentIndex + 1;
		if (nextSegIndex < pts.length) {
			Coordinate nextPt = pts[nextSegIndex];
			//Debug.println("next pt: " + nextPt);

			// Normalize segment index if intPt falls on vertex
			// The check for point equality is 2D only - Z values are ignored
			if (intPt.equals2D(nextPt)) {
				//Debug.println("normalized distance");
				normalizedSegmentIndex = nextSegIndex;
			}
		}
		/*
		  Add the intersection point to edge intersection list.
		 */
		SegmentNode ei = nodeList.add(intPt, normalizedSegmentIndex);
		return ei;
	}
  
  
  // TODO: ruier edit.
  // @override
  // String toString()
  // {
  // 	return WKTWriter.toLineString(new CoordinateArraySequence(pts));
  // }
}
