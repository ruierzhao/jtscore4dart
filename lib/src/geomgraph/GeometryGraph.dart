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


// import java.util.Collection;
// import java.util.Map;
// import java.util.Iterator;
// import java.util.List;
// import java.util.Map;

// import org.locationtech.jts.algorithm.BoundaryNodeRule;
// import org.locationtech.jts.algorithm.LineIntersector;
// import org.locationtech.jts.algorithm.Orientation;
// import org.locationtech.jts.algorithm.PointLocator;
// import org.locationtech.jts.algorithm.locate.IndexedPointInAreaLocator;
// import org.locationtech.jts.algorithm.locate.PointOnGeometryLocator;
// import org.locationtech.jts.geom.Coordinate;
// import org.locationtech.jts.geom.CoordinateArrays;
// import org.locationtech.jts.geom.Geometry;
// import org.locationtech.jts.geom.GeometryCollection;
// import org.locationtech.jts.geom.LineString;
// import org.locationtech.jts.geom.LinearRing;
// import org.locationtech.jts.geom.Location;
// import org.locationtech.jts.geom.MultiLineString;
// import org.locationtech.jts.geom.MultiPoint;
// import org.locationtech.jts.geom.MultiPolygon;
// import org.locationtech.jts.geom.Point;
// import org.locationtech.jts.geom.Polygon;
// import org.locationtech.jts.geom.Polygonal;
// import org.locationtech.jts.geom.Position;
// import org.locationtech.jts.geomgraph.index.EdgeSetIntersector;
// import org.locationtech.jts.geomgraph.index.SegmentIntersector;
// import org.locationtech.jts.geomgraph.index.SimpleMCSweepLineIntersector;
// import org.locationtech.jts.util.Assert;


import 'package:jtscore4dart/geometry.dart';
import 'package:jtscore4dart/src/algorithm/BoundaryNodeRule.dart';
import 'package:jtscore4dart/src/algorithm/PointLocator.dart';
import 'package:jtscore4dart/src/algorithm/locate/PointOnGeometryLocator.dart';
import 'package:jtscore4dart/src/geom/Location.dart';

import 'PlanarGraph.dart';
import 'index/EdgeSetIntersector.dart';
import 'index/SimpleMCSweepLineIntersector.dart';

/**
 * A GeometryGraph is a graph that models a given Geometry
 * @version 1.7
 */
class GeometryGraph
  extends PlanarGraph
{
/**
 * This method implements the Boundary Determination Rule
 * for determining whether
 * a component (node or edge) that appears multiple times in elements
 * of a MultiGeometry is in the boundary or the interior of the Geometry
 * <br>
 * The SFS uses the "Mod-2 Rule", which this function implements
 * <br>
 * An alternative (and possibly more intuitive) rule would be
 * the "At Most One Rule":
 *    isInBoundary = (componentCount == 1)
 */
/*
  static bool isInBoundary(int boundaryCount)
  {
    // the "Mod-2 Rule"
    return boundaryCount % 2 == 1;
  }
  static int determineBoundary(int boundaryCount)
  {
    return isInBoundary(boundaryCount) ? Location.BOUNDARY : Location.INTERIOR;
  }
*/

  /**
   * Determine boundary
   *
   * @param boundaryNodeRule Boundary node rule
   * @param boundaryCount the number of component boundaries that this point occurs in
   * @return boundary or interior
   */
  static int determineBoundary(BoundaryNodeRule boundaryNodeRule, int boundaryCount)
  {
    return boundaryNodeRule.isInBoundary(boundaryCount)
        ? Location.BOUNDARY : Location.INTERIOR;
  }

 /**private */Geometry parentGeom;

  /**
   * The lineEdgeMap is a map of the linestring components of the
   * parentGeometry to the edges which are derived from them.
   * This is used to efficiently perform findEdge queries
   */
 /**private */Map lineEdgeMap = new Map();

 /**private */BoundaryNodeRule boundaryNodeRule = null;

  /**
   * If this flag is true, the Boundary Determination Rule will used when deciding
   * whether nodes are in the boundary or not
   */
 /**private */bool useBoundaryDeterminationRule = true;
 /**private */int argIndex;  // the index of this geometry as an argument to a spatial function (used for labelling)
 /**private */Collection boundaryNodes;
 /**private */bool hasTooFewPoints = false;
 /**private */Coordinate invalidPoint = null;

 /**private */PointOnGeometryLocator areaPtLocator = null;
  // for use if geometry is not Polygonal
 /**private */final PointLocator ptLocator = new PointLocator();
  
 /**private */EdgeSetIntersector createEdgeSetIntersector()
  {
  // various options for computing intersections, from slowest to fastest

  //private EdgeSetIntersector esi = new SimpleEdgeSetIntersector();
  //private EdgeSetIntersector esi = new MonotoneChainIntersector();
  //private EdgeSetIntersector esi = new NonReversingChainIntersector();
  //private EdgeSetIntersector esi = new SimpleSweepLineIntersector();
  //private EdgeSetIntersector esi = new MCSweepLineIntersector();

    //return new SimpleEdgeSetIntersector();
    return new SimpleMCSweepLineIntersector();
  }

  // GeometryGraph(int argIndex, Geometry parentGeom)
  // {
  //   this(argIndex, parentGeom,
  //        BoundaryNodeRule.OGC_SFS_BOUNDARY_RULE
  //        );
  // }

  GeometryGraph(this.argIndex, this.parentGeom, [BoundaryNodeRule? boundaryNodeRule]) {
    // TODO: ruier edit.
//     if (parentGeom != null) {
// //      precisionModel = parentGeom.getPrecisionModel();
// //      SRID = parentGeom.getSRID();
//       add(parentGeom);
//     }
  if (boundaryNodeRule == null ) {
    this.boundaryNodeRule = BoundaryNodeRule.OGC_SFS_BOUNDARY_RULE;
  }
    add(parentGeom);
  }

  /*
   * This constructor is used by clients that wish to add Edges explicitly,
   * rather than adding a Geometry.  (An example is BufferOp).
   */
  // no longer used
//  GeometryGraph(int argIndex, PrecisionModel precisionModel, int SRID) {
//    this(argIndex, null);
//    this.precisionModel = precisionModel;
//    this.SRID = SRID;
//  }
//  PrecisionModel getPrecisionModel()
//  {
//    return precisionModel;
//  }
//  int getSRID() { return SRID; }

  bool hasTooFewPoints() { return hasTooFewPoints; }

  Coordinate getInvalidPoint() { return invalidPoint; }

  Geometry getGeometry() { return parentGeom; }

  BoundaryNodeRule getBoundaryNodeRule() { return boundaryNodeRule; }

  Collection getBoundaryNodes()
  {
    if (boundaryNodes == null)
      boundaryNodes = nodes.getBoundaryNodes(argIndex);
    return boundaryNodes;
  }

  List<Coordinate> getBoundaryPoints()
  {
    Collection coll = getBoundaryNodes();
    List<Coordinate> pts = new Coordinate[coll.size()];
    int i = 0;
    for (Iterator it = coll.iterator(); it.moveNext(); ) {
      Node node = (Node) it.current;
      pts[i++] = node.getCoordinate().copy();
    }
    return pts;
  }

  Edge findEdge(LineString line)
  {
    return (Edge) lineEdgeMap.get(line);
  }

  void computeSplitEdges(List edgelist)
  {
    for (Iterator i = edges.iterator(); i.moveNext(); ) {
      Edge e = (Edge) i.current;
      e.eiList.addSplitEdges(edgelist);
    }
  }
 /**private */void add(Geometry g)
  {
    if (g.isEmpty()) return;

    // check if this Geometry should obey the Boundary Determination Rule
    // all collections except MultiPolygons obey the rule
    if (g is MultiPolygon)
      useBoundaryDeterminationRule = false;

    if (g is Polygon)                 addPolygon((Polygon) g);
                        // LineString also handles LinearRings
    else if (g is LineString)         addLineString((LineString) g);
    else if (g is Point)              addPoint((Point) g);
    else if (g is MultiPoint)         addCollection((MultiPoint) g);
    else if (g is MultiLineString)    addCollection((MultiLineString) g);
    else if (g is MultiPolygon)       addCollection((MultiPolygon) g);
    else if (g is GeometryCollection) addCollection((GeometryCollection) g);
    else  throw new UnsupportedOperationException(g.getClass().getName());
  }

 /**private */void addCollection(GeometryCollection gc)
  {
    for (int i = 0; i < gc.getNumGeometries(); i++) {
      add(gc.getGeometryN(i));
    }
  }
  
  /**
   * Add a Point to the graph.
   */
 /**private */void addPoint(Point p)
  {
    Coordinate coord = p.getCoordinate();
    insertPoint(argIndex, coord, Location.INTERIOR);
  }
  
  /**
   * Adds a polygon ring to the graph.
   * Empty rings are ignored.
   * 
   * The left and right topological location arguments assume that the ring is oriented CW.
   * If the ring is in the opposite orientation,
   * the left and right locations must be interchanged.
   */
 /**private */void addPolygonRing(LinearRing lr, int cwLeft, int cwRight)
  {
  	// don't bother adding empty holes
  	if (lr.isEmpty()) return;
  	
    List<Coordinate> coord = CoordinateArrays.removeRepeatedPoints(lr.getCoordinates());

    if (coord.length < 4) {
      hasTooFewPoints = true;
      invalidPoint = coord[0];
      return;
    }

    int left  = cwLeft;
    int right = cwRight;
    if (Orientation.isCCW(coord)) {
      left = cwRight;
      right = cwLeft;
    }
    Edge e = new Edge(coord,
                        new Label(argIndex, Location.BOUNDARY, left, right));
    lineEdgeMap.put(lr, e);

    insertEdge(e);
    // insert the endpoint as a node, to mark that it is on the boundary
    insertPoint(argIndex, coord[0], Location.BOUNDARY);
  }

 /**private */void addPolygon(Polygon p)
  {
    addPolygonRing(
            p.getExteriorRing(),
            Location.EXTERIOR,
            Location.INTERIOR);

    for (int i = 0; i < p.getNumInteriorRing(); i++) {
    	LinearRing hole = p.getInteriorRingN(i);
    	
      // Holes are topologically labelled opposite to the shell, since
      // the interior of the polygon lies on their opposite side
      // (on the left, if the hole is oriented CW)
      addPolygonRing(
      		hole,
          Location.INTERIOR,
          Location.EXTERIOR);
    }
  }

 /**private */void addLineString(LineString line)
  {
    List<Coordinate> coord = CoordinateArrays.removeRepeatedPoints(line.getCoordinates());

    if (coord.length < 2) {
      hasTooFewPoints = true;
      invalidPoint = coord[0];
      return;
    }

    // add the edge for the LineString
    // line edges do not have locations for their left and right sides
    Edge e = new Edge(coord, new Label(argIndex, Location.INTERIOR));
    lineEdgeMap.put(line, e);
    insertEdge(e);
    /*
     * Add the boundary points of the LineString, if any.
     * Even if the LineString is closed, add both points as if they were endpoints.
     * This allows for the case that the node already exists and is a boundary point.
     */
    Assert.isTrue(coord.length >= 2, "found LineString with single point");
    insertBoundaryPoint(argIndex, coord[0]);
    insertBoundaryPoint(argIndex, coord[coord.length - 1]);
  }

  /**
   * Add an Edge computed externally.  The label on the Edge is assumed
   * to be correct.
   *
   * @param e Edge
   */
  void addEdge(Edge e)
  {
    insertEdge(e);
    List<Coordinate> coord = e.getCoordinates();
    // insert the endpoint as a node, to mark that it is on the boundary
    insertPoint(argIndex, coord[0], Location.BOUNDARY);
    insertPoint(argIndex, coord[coord.length - 1], Location.BOUNDARY);
  }

  /**
   * Add a point computed externally.  The point is assumed to be a
   * Point Geometry part, which has a location of INTERIOR.
   *
   * @param pt Coordinate
   */
  void addPoint(Coordinate pt)
  {
    insertPoint(argIndex, pt, Location.INTERIOR);
  }
  
  /**
   * Compute self-nodes, taking advantage of the Geometry type to
   * minimize the number of intersection tests.  (E.g. rings are
   * not tested for self-intersection, since they are assumed to be valid).
   * 
   * @param li the LineIntersector to use
   * @param computeRingSelfNodes if <code>false</code>, intersection checks are optimized to not test rings for self-intersection
   * @return the computed SegmentIntersector containing information about the intersections found
   */
  SegmentIntersector computeSelfNodes(LineIntersector li, bool computeRingSelfNodes)
  {
    SegmentIntersector si = new SegmentIntersector(li, true, false);
    EdgeSetIntersector esi = createEdgeSetIntersector();
    // optimize intersection search for valid Polygons and LinearRings
    bool isRings = parentGeom is LinearRing
			|| parentGeom is Polygon
			|| parentGeom is MultiPolygon;
    bool computeAllSegments = computeRingSelfNodes || ! isRings;
    esi.computeIntersections(edges, si, computeAllSegments);
    
    //System.out.println("SegmentIntersector # tests = " + si.numTests);
    addSelfIntersectionNodes(argIndex);
    return si;
  }

  SegmentIntersector computeEdgeIntersections(
    GeometryGraph g,
    LineIntersector li,
    bool includeProper)
  {
    SegmentIntersector si = new SegmentIntersector(li, includeProper, true);
    si.setBoundaryNodes(this.getBoundaryNodes(), g.getBoundaryNodes());

    EdgeSetIntersector esi = createEdgeSetIntersector();
    esi.computeIntersections(edges, g.edges, si);
/*
for (Iterator i = g.edges.iterator(); i.moveNext();) {
Edge e = (Edge) i.current;
Debug.print(e.getEdgeIntersectionList());
}
*/
    return si;
  }

 /**private */void insertPoint(int argIndex, Coordinate coord, int onLocation)
  {
    Node n = nodes.addNode(coord);
    Label lbl = n.getLabel();
    if (lbl == null) {
      n.label = new Label(argIndex, onLocation);
    }
    else
      lbl.setLocation(argIndex, onLocation);
  }

  /**
   * Adds candidate boundary points using the current {@link BoundaryNodeRule}.
   * This is used to add the boundary
   * points of dim-1 geometries (Curves/MultiCurves).
   */
 /**private */void insertBoundaryPoint(int argIndex, Coordinate coord)
  {
    Node n = nodes.addNode(coord);
    // nodes always have labels
    Label lbl = n.getLabel();
    // the new point to insert is on a boundary
    int boundaryCount = 1;
    // determine the current location for the point (if any)
    int loc = Location.NONE;
    loc = lbl.getLocation(argIndex, Position.ON);
    if (loc == Location.BOUNDARY) boundaryCount++;

    // determine the boundary status of the point according to the Boundary Determination Rule
    int newLoc = determineBoundary(boundaryNodeRule, boundaryCount);
    lbl.setLocation(argIndex, newLoc);
  }

 /**private */void addSelfIntersectionNodes(int argIndex)
  {
    for (Iterator i = edges.iterator(); i.moveNext(); ) {
      Edge e = (Edge) i.current;
      int eLoc = e.getLabel().getLocation(argIndex);
      for (Iterator eiIt = e.eiList.iterator(); eiIt.moveNext(); ) {
        EdgeIntersection ei = (EdgeIntersection) eiIt.current;
        addSelfIntersectionNode(argIndex, ei.coord, eLoc);
      }
    }
  }
  /**
   * Add a node for a self-intersection.
   * If the node is a potential boundary node (e.g. came from an edge which
   * is a boundary) then insert it as a potential boundary node.
   * Otherwise, just add it as a regular node.
   */
 /**private */void addSelfIntersectionNode(int argIndex, Coordinate coord, int loc)
  {
    // if this node is already a boundary node, don't change it
    if (isBoundaryNode(argIndex, coord)) return;
    if (loc == Location.BOUNDARY && useBoundaryDeterminationRule)
        insertBoundaryPoint(argIndex, coord);
    else
      insertPoint(argIndex, coord, loc);
  }

  // MD - experimental for now
  /**
   * Determines the {@link Location} of the given {@link Coordinate}
   * in this geometry.
   * 
   * @param pt the point to test
   * @return the location of the point in the geometry
   */
  int locate(Coordinate pt)
  {
  	if (parentGeom is Polygonal && parentGeom.getNumGeometries() > 50) {
  		// lazily init point locator
  		if (areaPtLocator == null) {
  			areaPtLocator = new IndexedPointInAreaLocator(parentGeom);
  		}
  		return areaPtLocator.locate(pt);
  	}
  	return ptLocator.locate(pt, parentGeom);
  }
}
