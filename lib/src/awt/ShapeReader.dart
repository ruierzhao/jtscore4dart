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



// import java.awt.Shape;
// import java.awt.geom.AffineTransform;
// import java.awt.geom.PathIterator;
// import java.util.ArrayList;
// import java.util.List;

// import org.locationtech.jts.algorithm.Orientation;
// import org.locationtech.jts.geom.Coordinate;
// import org.locationtech.jts.geom.CoordinateList;
// import org.locationtech.jts.geom.Geometry;
// import org.locationtech.jts.geom.GeometryFactory;
// import org.locationtech.jts.geom.LinearRing;


/**
 * Converts a Java2D {@link Shape} 
 * or the more general {@link PathIterator} into a {@link Geometry}.
 * <p>
 * The coordinate system for Java2D is typically screen coordinates, 
 * which has the Y axis inverted
 * relative to the usual JTS coordinate system.
 * This is rectified during conversion. 
 * <p>
 * PathIterators to be converted are expected to be linear or flat.
 * That is, they should contain only <tt>SEG_MOVETO</tt>, <tt>SEG_LINETO</tt>, and <tt>SEG_CLOSE</tt> segment types.
 * Any other segment types will cause an exception.
 * 
 * @author Martin Davis
 *
 */
class ShapeReader 
{
 /**private */static final AffineTransform INVERT_Y = AffineTransform.getScaleInstance(1, -1);

  /**
   * Converts a flat path to a {@link Geometry}.
   * 
   * @param pathIt the path to convert
   * @param geomFact the GeometryFactory to use
   * @return a Geometry representing the path
   */
  static Geometry read(PathIterator pathIt, GeometryFactory geomFact)
  {
    ShapeReader pc = new ShapeReader(geomFact);
    return pc.read(pathIt);
  }
  
  /**
   * Converts a Shape to a Geometry, flattening it first.
   * 
   * @param shp the Java2D shape
   * @param flatness the flatness parameter to use
   * @param geomFact the GeometryFactory to use
   * @return a Geometry representing the shape
   */
  static Geometry read(Shape shp, double flatness, GeometryFactory geomFact)
  {
    PathIterator pathIt = shp.getPathIterator(INVERT_Y, flatness);
    return ShapeReader.read(pathIt, geomFact);
  }

 /**private */GeometryFactory geometryFactory;
  
  ShapeReader(GeometryFactory geometryFactory) {
    this.geometryFactory = geometryFactory;
  }

  /**
   * Converts a flat path to a {@link Geometry}.
   * 
   * @param pathIt the path to convert
   * @return a Geometry representing the path
   */
  Geometry read(PathIterator pathIt)
  {
    List pathPtSeq = toCoordinates(pathIt);
    
    List polys = [];
    int seqIndex = 0;
    while (seqIndex < pathPtSeq.size()) {
      // assume next seq is shell 
      // TODO: test this
      List<Coordinate> pts = (List<Coordinate>) pathPtSeq.get(seqIndex);
      LinearRing shell = geometryFactory.createLinearRing(pts);
      seqIndex++;
      
      List holes = [];
      // add holes as int as rings are CCW
      while (seqIndex < pathPtSeq.size() && isHole((List<Coordinate>) pathPtSeq.get(seqIndex))) {
        List<Coordinate> holePts = (List<Coordinate>) pathPtSeq.get(seqIndex);
        LinearRing hole = geometryFactory.createLinearRing(holePts);
        holes.add(hole);
        seqIndex++;
      }
      List<LinearRing> holeArray = GeometryFactory.toLinearRingArray(holes);
      polys.add(geometryFactory.createPolygon(shell, holeArray));
    }
    return geometryFactory.buildGeometry(polys);
  }
  
 /**private */bool isHole(List<Coordinate> pts)
  {
    return Orientation.isCCW(pts);
  }
  
  /**
   * Extracts the points of the paths in a flat {@link PathIterator} into
   * a list of Coordinate arrays.
   * 
   * @param pathIt a path iterator
   * @return a List of Coordinate arrays
   * @throws ArgumentError if a non-linear segment type is encountered
   */
  static List toCoordinates(PathIterator pathIt)
  {
    List coordArrays = [];
    while (! pathIt.isDone()) {
      List<Coordinate> pts = nextCoordinateArray(pathIt);
      if (pts == null)
        break;
      coordArrays.add(pts);
    }
    return coordArrays;
  }
  
 /**private */static List<Coordinate> nextCoordinateArray(PathIterator pathIt)
  {
    double[] pathPt = new double[6];
    CoordinateList coordList = null;
    bool isDone = false;
    while (! pathIt.isDone()) {
      int segType = pathIt.currentSegment(pathPt);
      switch (segType) {
      case PathIterator.SEG_MOVETO:
        if (coordList != null) {
          // don't advance pathIt, to retain start of next path if any
          isDone = true;
        }
        else {
          coordList = new CoordinateList();
          coordList.add(new Coordinate(pathPt[0], pathPt[1]));
          pathIt.current;
        }
        break;
      case PathIterator.SEG_LINETO:
        coordList.add(new Coordinate(pathPt[0], pathPt[1]));
        pathIt.current;
        break;
      case PathIterator.SEG_CLOSE:  
        coordList.closeRing();
        pathIt.current;
        isDone = true;   
        break;
      default:
      	throw new ArgumentError("unhandled (non-linear) segment type encountered");
      }
      if (isDone) 
        break;
    }
    return coordList.toCoordinateArray();
  }

}
