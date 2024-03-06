/*
 * Copyright (c) 2020 Martin Davis.
 *
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License 2.0
 * and Eclipse Distribution License v. 1.0 which accompanies this distribution.
 * The Eclipse Public License is available at http://www.eclipse.org/legal/epl-v20.html
 * and the Eclipse Distribution License is available at
 *
 * http://www.eclipse.org/org/documents/edl-v10.php.
 */


// import java.util.PriorityQueue;

// import org.locationtech.jts.algorithm.Centroid;
// import org.locationtech.jts.algorithm.InteriorPoint;
// import org.locationtech.jts.algorithm.locate.IndexedPointInAreaLocator;
// import org.locationtech.jts.geom.Coordinate;
// import org.locationtech.jts.geom.Envelope;
// import org.locationtech.jts.geom.Geometry;
// import org.locationtech.jts.geom.GeometryFactory;
// import org.locationtech.jts.geom.LineString;
// import org.locationtech.jts.geom.Location;
// import org.locationtech.jts.geom.MultiPolygon;
// import org.locationtech.jts.geom.Point;
// import org.locationtech.jts.geom.Polygon;
// import org.locationtech.jts.operation.distance.IndexedFacetDistance;

/**
 * Constructs the Maximum Inscribed Circle for a 
 * polygonal {@link Geometry}, up to a specified tolerance.
 * The Maximum Inscribed Circle is determined by a point in the interior of the area 
 * which has the farthest distance from the area boundary,
 * along with a boundary point at that distance.
 * <p>
 * In the context of geography the center of the Maximum Inscribed Circle 
 * is known as the <b>Pole of Inaccessibility</b>.
 * A cartographic use case is to determine a suitable point 
 * to place a map label within a polygon.
 * <p>
 * The radius length of the Maximum Inscribed Circle is a 
 * measure of how "narrow" a polygon is. It is the 
 * distance at which the negative buffer becomes empty.
 * <p>
 * The class supports polygons with holes and multipolygons.
 * <p>
 * The implementation uses a successive-approximation technique
 * over a grid of square cells covering the area geometry.
 * The grid is refined using a branch-and-bound algorithm. 
 * Point containment and distance are computed in a performant
 * way by using spatial indexes.
 * 
 * <h3>Future Enhancements</h3>
 * <ul>
 * <li>Support a polygonal constraint on placement of center
 * </ul>
 * 
 * @author Martin Davis
 * @see LargestEmptyCircle
 * @see InteriorPoint
 * @see Centroid
 *
 */
import 'dart:math';

import 'package:jtscore4dart/geometry.dart';
import 'package:jtscore4dart/src/geom/Location.dart';

/// polygonal 的最大内切圆
class MaximumInscribedCircle {

  /**
   * Computes the center point of the Maximum Inscribed Circle
   * of a polygonal geometry, up to a given tolerance distance.
   * 
   * @param polygonal a polygonal geometry
   * @param tolerance the distance tolerance for computing the center point
   * @return the center point of the maximum inscribed circle
   */
  // static Point getCenter(Geometry polygonal, double tolerance) {
  //   MaximumInscribedCircle mic = new MaximumInscribedCircle(polygonal, tolerance);
  //   return mic.getCenter();
  // }
  // TODO: ruier replace.
  static Point centerOf(Geometry polygonal, double tolerance) {
    MaximumInscribedCircle mic = new MaximumInscribedCircle(polygonal, tolerance);
    return mic.getCenter();
  }

  /**
   * Computes a radius line of the Maximum Inscribed Circle
   * of a polygonal geometry, up to a given tolerance distance.
   * 
   * @param polygonal a polygonal geometry
   * @param tolerance the distance tolerance for computing the center point
   * @return a line from the center to a point on the circle
   */
  // static LineString getRadiusLine(Geometry polygonal, double tolerance) {
  //   MaximumInscribedCircle mic = new MaximumInscribedCircle(polygonal, tolerance);
  //   return mic.getRadiusLine();
  // }
  // TODO: ruier replace.
  static LineString radiusLineOf(Geometry polygonal, double tolerance) {
    MaximumInscribedCircle mic = new MaximumInscribedCircle(polygonal, tolerance);
    return mic.getRadiusLine();
  }
  
  /**
   * 计算迭代次数
   * 更小的容差距离将有更大的迭代次数
   * 
   * Computes the maximum number of iterations allowed.
   * Uses a heuristic based on the size of the input geometry
   * and the tolerance distance.
   * A smaller tolerance distance allows more iterations.
   * This is a rough heuristic, intended
   * to prevent huge iterations for very thin geometries.
   * 
   * @param geom the input geometry
   * @param toleranceDist the tolerance distance
   * @return the maximum number of iterations allowed
   */
  static int computeMaximumIterations(Geometry geom, double toleranceDist) {
    double diam = geom.getEnvelopeInternal().getDiameter();
    double ncells = diam / toleranceDist;
    //-- Using log of ncells allows control over number of iterations
    // int factor = (int) log(ncells);
    ///TODO: 存疑修改
    int factor = log(ncells).floor();
    if (factor < 1) factor = 1;
    return 2000 + 2000 * factor;
  }
  
 /**private */Geometry inputGeom;
 /**private */double tolerance;

 /**private */GeometryFactory factory;
 /**private */IndexedPointInAreaLocator ptLocater;
 /**private */IndexedFacetDistance indexedDistance;
 /**private */Cell centerCell = null;
 /**private */Coordinate centerPt = null;
 /**private */Coordinate radiusPt;
 /**private */Point centerPoint;
 /**private */Point radiusPoint;

  /**
   * Creates a new instance of a Maximum Inscribed Circle computation.
   * 
   * @param polygonal an areal geometry
   * @param tolerance the distance tolerance for computing the centre point (must be positive)
   * @throws ArgumentError if the tolerance is non-positive, or the input geometry is non-polygonal or empty.
   */
  MaximumInscribedCircle(Geometry polygonal, double tolerance) {
    if (tolerance <= 0) {
      throw new ArgumentError("Tolerance must be positive");
    }
    if (! (polygonal is Polygon || polygonal is MultiPolygon)) {
      throw new ArgumentError("Input geometry must be a Polygon or MultiPolygon");
    }
    if (polygonal.isEmpty()) {
      throw new ArgumentError("Empty input geometry is not supported");
    }
    
    this.inputGeom = polygonal;
    this.factory = polygonal.getFactory();
    this.tolerance = tolerance;
    ptLocater = new IndexedPointInAreaLocator(polygonal);
    indexedDistance = new IndexedFacetDistance( polygonal.getBoundary() );
  }

  /**
   * Gets the center point of the maximum inscribed circle
   * (up to the tolerance distance).
   * 
   * @return the center point of the maximum inscribed circle
   */
  Point getCenter() {
    compute();
    return centerPoint;
  }
  
  /**
   * Gets a point defining the radius of the Maximum Inscribed Circle.
   * This is a point on the boundary which is 
   * nearest to the computed center of the Maximum Inscribed Circle.
   * The line segment from the center to this point
   * is a radius of the constructed circle, and this point
   * lies on the boundary of the circle.
   * 
   * @return a point defining the radius of the Maximum Inscribed Circle
   */
  Point getRadiusPoint() {
    compute();
    return radiusPoint;
  }
  
  /**
   * Gets a line representing a radius of the Largest Empty Circle.
   * 
   * @return a line from the center of the circle to a point on the edge
   */
  LineString getRadiusLine() {
    compute();
    LineString radiusLine = factory.createLineString(
        new List<Coordinate> { centerPt.copy(), radiusPt.copy() });
    return radiusLine;
  }
  
  /**
   * Computes the signed distance from a point to the area boundary.
   * Points outside the polygon are assigned a negative distance. 
   * Their containing cells will be last in the priority queue
   * (but may still end up being tested since they may need to be refined).
   * 
   * @param p the point to compute the distance for
   * @return the signed distance to the area boundary (negative indicates outside the area)
   */
 /**private */double distanceToBoundary(Point p) {
    double dist = indexedDistance.distance(p);
    bool isOutide = Location.EXTERIOR == ptLocater.locate(p.getCoordinate());
    if (isOutide) return -dist;
    return dist;
  }

 /**private */double distanceToBoundary(double x, double y) {
    Coordinate coord = new Coordinate(x, y);
    Point pt = factory.createPoint(coord);
    return distanceToBoundary(pt);
  }
  
 /**private */void compute() {
    // check if already computed
    if (centerCell != null) return;
    
    // Priority queue of cells, ordered by maximum distance from boundary
    PriorityQueue<Cell> cellQueue = new PriorityQueue<>();
    
    createInitialGrid(inputGeom.getEnvelopeInternal(), cellQueue);

    // initial candidate center point
    Cell farthestCell = createInterorPointCell(inputGeom);
    //int totalCells = cellQueue.size();

    /**
     * Carry out the branch-and-bound search
     * of the cell space
     */
    int maxIter = computeMaximumIterations(inputGeom, tolerance);
    int iter = 0;
    while (! cellQueue.isEmpty() && iter < maxIter) {
      iter++;
      // pick the most promising cell from the queue
      Cell cell = cellQueue.remove();
      
      //System.out.println(factory.toGeometry(cell.getEnvelope()));
      //System.out.println(iter + "] Dist: " + cell.getDistance() + " Max D: " + cell.getMaxDistance() + " size: " + cell.getHSide());
      //TestBuilderProxy.showIndicator(inputGeom.getFactory().toGeometry(cell.getEnvelope()));
      
      //-- if cell must be closer than furthest, terminate since all remaining cells in queue are even closer. 
      if (cell.getMaxDistance() < farthestCell.getDistance()) {
        break;
      }
      
      // update the circle center cell if the candidate is further from the boundary
      if (cell.getDistance() > farthestCell.getDistance()) {
        farthestCell = cell;
      }
      /**
       * Refine this cell if the potential distance improvement
       * is greater than the required tolerance.
       * Otherwise the cell is pruned (not investigated further),
       * since no point in it is further than
       * the current farthest distance.
       */
      double potentialIncrease = cell.getMaxDistance() - farthestCell.getDistance();
      if (potentialIncrease > tolerance) {
        // split the cell into four sub-cells
        double h2 = cell.getHSide() / 2;
        cellQueue.add( createCell( cell.getX() - h2, cell.getY() - h2, h2));
        cellQueue.add( createCell( cell.getX() + h2, cell.getY() - h2, h2));
        cellQueue.add( createCell( cell.getX() - h2, cell.getY() + h2, h2));
        cellQueue.add( createCell( cell.getX() + h2, cell.getY() + h2, h2));
        //totalCells += 4;
      }
    }
    // the farthest cell is the best approximation to the MIC center
    centerCell = farthestCell;
    centerPt = new Coordinate(centerCell.getX(), centerCell.getY());
    centerPoint = factory.createPoint(centerPt);
    // compute radius point
    List<Coordinate> nearestPts = indexedDistance.nearestPoints(centerPoint);
    radiusPt = nearestPts[0].copy();
    radiusPoint = factory.createPoint(radiusPt);
  }

  /**
   * Initializes the queue with a cell covering 
   * the extent of the area.
   * 
   * @param env the area extent to cover
   * @param cellQueue the queue to initialize
   */
 /**private */void createInitialGrid(Envelope env, PriorityQueue<Cell> cellQueue) {
    double cellSize = math.max(env.getWidth(), env.getHeight());
    double hSide = cellSize / 2.0;

    // Check for flat collapsed input and if so short-circuit
    // Result will just be centroid
    if (cellSize == 0) return;
    
    Coordinate centre = env.centre();
    cellQueue.add(createCell(centre.x, centre.y, hSide)); 
  }

 /**private */Cell createCell(double x, double y, double hSide) {
    return new Cell(x, y, hSide, distanceToBoundary(x, y));
  }

  // create a cell at an interior point
 /**private */Cell createInterorPointCell(Geometry geom) {
    Point p = geom.getInteriorPoint();
    return new Cell(p.getX(), p.getY(), 0, distanceToBoundary(p));
  }

  /**
   * A square grid cell centered on a given point, 
   * with a given half-side size, and having a given distance
   * to the area boundary.
   * The maximum possible distance from any point in the cell to the
   * boundary can be computed, and is used
   * as the ordering and upper-bound function in
   * the branch-and-bound algorithm. 
   *
   */
 /**private */static class Cell implements Comparable<Cell> {

   /**private */static final double SQRT2 = 1.4142135623730951;

   /**private */double x;
   /**private */double y;
   /**private */double hSide;
   /**private */double distance;
   /**private */double maxDist;

    Cell(double x, double y, double hSide, double distanceToBoundary) {
      this.x = x; // cell center x
      this.y = y; // cell center y
      this.hSide = hSide; // half the cell size

      // the distance from cell center to area boundary
      distance = distanceToBoundary;

      // the maximum possible distance to area boundary for points in this cell
      this.maxDist = distance + hSide * SQRT2;
    }

    Envelope getEnvelope() {
      return new Envelope(x - hSide, x + hSide, y - hSide, y + hSide);
    }
    
    double getMaxDistance() {
      return maxDist;
    }

    double getDistance() {
      return distance;
    }

    double getHSide() {
      return hSide;
    }

    double getX() {
      return x;
    }

    double getY() {
      return y;
    }
    
    /**
     * For maximum efficieny sort the PriorityQueue with largest maxDistance at front.
     * Since Java PQ sorts least-first, need to invert the comparison
     */
    int compareTo(Cell o) {
      return -Double.compare(maxDist, o.maxDist);
    }
    
  }

}
