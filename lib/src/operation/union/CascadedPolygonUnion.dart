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
// import java.util.Iterator;
// import java.util.List;

// import org.locationtech.jts.geom.Geometry;
// import org.locationtech.jts.geom.GeometryCollection;
// import org.locationtech.jts.geom.GeometryFactory;
// import org.locationtech.jts.geom.Polygon;
// import org.locationtech.jts.geom.Polygonal;
// import org.locationtech.jts.geom.TopologyException;
// import org.locationtech.jts.geom.util.PolygonExtracter;
// import org.locationtech.jts.index.strtree.STRtree;
// import org.locationtech.jts.operation.overlay.snap.SnapIfNeededOverlayOp;
// import org.locationtech.jts.operation.overlayng.OverlayNG;
// import org.locationtech.jts.operation.overlayng.OverlayNGRobust;
// import org.locationtech.jts.util.Debug;


import 'package:jtscore4dart/src/geom/Geometry.dart';
import 'package:jtscore4dart/src/geom/GeometryFactory.dart';
import 'package:jtscore4dart/src/geom/Polygon.dart';
import 'package:jtscore4dart/src/geom/Polygonal.dart';
import 'package:jtscore4dart/src/geom/TopologyException.dart';
import 'package:jtscore4dart/src/geom/util/PolygonExtracter.dart';
import 'package:jtscore4dart/src/index/strtree/STRtree.dart';
import 'package:jtscore4dart/src/operation/overlay/snap/SnapIfNeededOverlayOp.dart';
import 'package:jtscore4dart/src/operation/overlayng/OverlayNG.dart';
import 'package:jtscore4dart/src/operation/overlayng/OverlayNGRobust.dart';
// import 'package:jtscore4dart/src/util/Debug.dart';

import 'UnionStrategy.dart';

import 'package:jtscore4dart/src/patch/ArrayList.dart';


class _ implements UnionStrategy {
    @override
    Geometry union(Geometry g0, Geometry g1) {
      try {
        print('>>>>>>>>> SnapIfNeededOverlayOp.union(g0, g1): ${ SnapIfNeededOverlayOp.union(g0, g1) } <<<<<<<<<<<<<<<<<<<<');
        return SnapIfNeededOverlayOp.union(g0, g1);
      }
      on TopologyException catch (__) {
        return OverlayNGRobust.overlay(g0, g1, OverlayNG.UNION);
      }
    }

    @override
    bool isFloatingPrecision() {
      return true;
    }
  }

/**
 * Provides an efficient method of unioning a collection of
 * {@link Polygonal} geometries.
 * The geometries are indexed using a spatial index,
 * and unioned recursively in index order.
 * For geometries with a high degree of overlap,
 * this has the effect of reducing the number of vertices
 * early in the process, which increases speed
 * and robustness.
 * <p>
 * This algorithm is faster and more robust than
 * the simple iterated approach of
 * repeatedly unioning each polygon to a result geometry.
 *
 * @author Martin Davis
 *
 */
class CascadedPolygonUnion
{
  /**
   * A union strategy that uses the classic JTS {@link SnapIfNeededOverlayOp},
   * with a robustness fallback to OverlayNG.
   */
  static final  UnionStrategy CLASSIC_UNION = _();

  
  /**
   * Computes the union of
   * a collection of {@link Polygonal} {@link Geometry}s.
   *
   * @param polys a collection of {@link Polygonal} {@link Geometry}s
   */
  // static Geometry union(Iterable polys)
  // {
  //   CascadedPolygonUnion op = new CascadedPolygonUnion(polys);
  //   return op.union();
  // }

  /**
   * Computes the union of
   * a collection of {@link Polygonal} {@link Geometry}s.
   *
   * @param polys a collection of {@link Polygonal} {@link Geometry}s
   */
  // static Geometry union(Iterable polys, [UnionStrategy? unionFun])
  // {
  //   CascadedPolygonUnion op = new CascadedPolygonUnion(polys, unionFun);
  //   return op.union();
  // }
  // Alias of CascadedPolygonUnion.union()
  static Geometry? of(Iterable polys, [UnionStrategy? unionFun])
  {
    CascadedPolygonUnion op = new CascadedPolygonUnion(polys, unionFun);
    return op.union();
  }

	/**private */ Iterable? inputPolys;
	/**private */ GeometryFactory? geomFactory;
  /**private */ UnionStrategy unionFun;

 /**private */ int countRemainder = 0;
 /**private */ int countInput = 0;

  /**
   * Creates a new instance to union
   * the given collection of {@link Geometry}s.
   *
   * @param polys a collection of {@link Polygonal} {@link Geometry}s
   */
  // CascadedPolygonUnion(Iterable polys)
  // {
  //   this(polys, CLASSIC_UNION );
  // }

	 /**
   * Creates a new instance to union
   * the given collection of {@link Geometry}s.
   *
   * @param polys a collection of {@link Polygonal} {@link Geometry}s
   */
  // CascadedPolygonUnion(Iterable polys, UnionStrategy unionFun)
  // {
  //   this.inputPolys = polys;
  //   this.unionFun = unionFun;
  //   // guard against null input
  //   if (inputPolys == null)
  //     inputPolys = [];
  //   this.countInput = inputPolys.size();
  //   this.countRemainder = countInput;
  // }
   CascadedPolygonUnion(this.inputPolys, [UnionStrategy? unionFun])
    :this.unionFun = (unionFun??= CLASSIC_UNION),
      // this.countInput = inputPolys.size();
      this.countInput = inputPolys!.length,
      this.countRemainder = inputPolys.length;
  
  /**
   * The effectiveness of the index is somewhat sensitive
   * to the node capacity.
   * Testing indicates that a smaller capacity is better.
   * For an STRtree, 4 is probably a good number (since
   * this produces 2x2 "squares").
   */
 static const int _STRTREE_NODE_CAPACITY = 4;

	/**
	 * Computes the union of the input geometries.
	 * <p>
	 * This method discards the input geometries as they are processed.
	 * In many input cases this reduces the memory retained
	 * as the operation proceeds.
	 * Optimal memory usage is achieved
	 * by disposing of the original input collection
	 * before calling this method.
	 *
	 * @return the union of the input geometries
	 * or null if no input geometries were provided
	 * @throws IllegalStateException if this method is called more than once
	 */
	Geometry? union()
	{
	  if (inputPolys == null) {
	    throw new Exception("IllegalStateException: union() method cannot be called twice");
	  }
		if (inputPolys!.isEmpty) {
		  return null;
		}
		// geomFactory = ( inputPolys!.iterator.current as Geometry).getFactory();
    var it = inputPolys!.iterator;
    it.moveNext();
		geomFactory = ( it.current as Geometry).getFactory();

		/**
		 * A spatial index to organize the collection
		 * into groups of close geometries.
		 * This makes unioning more efficient, since vertices are more likely
		 * to be eliminated on each round.
		 */
//    STRtree index = new STRtree();
    STRtree index = new STRtree(_STRTREE_NODE_CAPACITY);
    for (Iterator i = inputPolys!.iterator; i.moveNext(); ) {
      Geometry item = i.current as Geometry;
      index.insert(item.getEnvelopeInternal(), item);
    }
    // To avoiding holding memory remove references to the input geometries,
    inputPolys = null;

    List itemTree = index.itemsTree();
//    printItemEnvelopes(itemTree);
    Geometry unionAll = unionTree(itemTree);
    return unionAll;
	}

 /**private */Geometry unionTree(List geomTree)
  {
    /**
     * Recursively unions all subtrees in the list into single geometries.
     * The result is a list of Geometrys only
     */
    List geoms = reduceToGeometries(geomTree);
//    Geometry union = bufferUnion(geoms);
    Geometry union = binaryUnion(geoms);

    // print out union (allows visualizing hierarchy)
//    System.out.println(union);

    return union;
  }

  //========================================================
  /*
   * The following methods are for experimentation only
   */
/*
 /**private */Geometry repeatedUnion(List geoms)
  {
  	Geometry union = null;
  	for (Iterator i = geoms.iterator(); i.moveNext(); ) {
  		Geometry g = (Geometry) i.current;
  		if (union == null)
  			union = g.copy();
  		else
  			union = unionFun.union(union, g);
  	}
  	return union;
  }
  */

  //=======================================

  /**
   * Unions a list of geometries
   * by treating the list as a flattened binary tree,
   * and performing a cascaded union on the tree.
   */
 /**private */Geometry binaryUnion(List geoms)
  {
  	return binaryUnion$1(geoms, 0, geoms.size());
  }

  /**
   * Unions a section of a list using a recursive binary union on each half
   * of the section.
   *
   * @param [geoms] the list of geometries containing the section to union
   * @param [start] the start index of the section
   * @param [end] the index after the end of the section
   * @return the union of the list section
   */
 /**private */Geometry binaryUnion$1(List geoms, int start, int end)
  {
  	if (end - start <= 1) {
  		Geometry g0 = getGeometry(geoms, start)!;
  		return unionSafe(g0, null);
  	}
  	else if (end - start == 2) {
  		return unionSafe(getGeometry(geoms, start)!, getGeometry(geoms, start + 1));
  	}
  	else {
  		// recurse on both halves of the list
  		// int mid = (end + start) / 2;
  		int mid = (end + start) ~/ 2;
  		Geometry g0 = binaryUnion$1(geoms, start, mid);
  		Geometry g1 = binaryUnion$1(geoms, mid, end);
  		return unionSafe(g0, g1);
  	}
  }

  /**
   * Gets the element at a given list index, or
   * null if the index is out of range.
   *
   * @param list
   * @param index
   * @return the geometry at the given index
   * or null if the index is out of range
   */
 /**private */static Geometry? getGeometry(List list, int index)
  {
  	if (index >= list.size()) return null;
  	return list.get(index) as Geometry;
  }

  /**
   * Reduces a tree of geometries to a list of geometries
   * by recursively unioning the subtrees in the list.
   *
   * @param geomTree a tree-structured list of geometries
   * @return a list of Geometrys
   */
 /**private */List reduceToGeometries(List geomTree)
  {
    List geoms = [];
    for (Iterator i = geomTree.iterator; i.moveNext(); ) {
      Object o = i.current;
      Geometry? geom = null;
      if (o is List) {
        geom = unionTree( o as List);
      }
      else if (o is Geometry) {
        geom =  o;
      }
      geoms.add(geom);
    }
    return geoms;
  }

  /**
   * Computes the union of two geometries,
   * either or both of which may be null.
   *
   * @param [g0] a Geometry
   * @param [g1] a Geometry
   * @return the union of the input(s)
   * or null if both inputs are null
   */
 /**private */Geometry unionSafe(Geometry g0, [Geometry? g1])
  {
  	// if (g0 == null && g1 == null) {
  	//   return null;
  	// }

  	// if (g0 == null) {
  	//   return g1!.copy();
  	// }
  	if (g1 == null) {
  	  return g0.copy();
  	}

  	countRemainder--;
    /// TODO: @ruier edit.应该是调试用的
  	// if (Debug.isDebugging()) {
  	//   Debug.println("Remainder: $countRemainder out of $countInput");
    //   Debug.print("Union: A: ${g0.getNumPoints()} / B: ${g1.getNumPoints()}  ---  "  );
  	// }

  	Geometry union = unionActual( g0, g1 );
  	/// TODO: @ruier edit.
    // if (Debug.isDebugging()) Debug.println(" Result: ${union.getNumPoints()}");
    //if (TestBuilderProxy.isActive()) TestBuilderProxy.showIndicator(union);
    
    return union;
  }

  /**
   * Encapsulates the actual unioning of two polygonal geometries.
   *
   * @param g0
   * @param g1
   * @return
   */
 /**private */Geometry unionActual(Geometry g0, Geometry g1)
  {
    Geometry union = unionFun.union(g0, g1);
    Geometry unionPoly = restrictToPolygons( union );
  	return unionPoly;
  }

  /**
   * Computes a {@link Geometry} containing only {@link Polygonal} components.
   * Extracts the {@link Polygon}s from the input
   * and returns them as an appropriate {@link Polygonal} geometry.
   * <p>
   * If the input is already <tt>Polygonal</tt>, it is returned unchanged.
   * <p>
   * A particular use case is to filter out non-polygonal components
   * returned from an overlay operation.
   *
   * @param g the geometry to filter
   * @return a Polygonal geometry
   */
 /**private */static Geometry restrictToPolygons(Geometry g)
  {
    if (g is Polygonal) {
      return g;
    }
    List<Geometry> polygons = PolygonExtracter.getPolygons(g);
    if (polygons.size() == 1) {
      return polygons.get(0) as Polygon;
    }
    return g.getFactory().createMultiPolygon(GeometryFactory.toPolygonArray(polygons));
  }
}
