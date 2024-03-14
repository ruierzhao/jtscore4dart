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
// import java.util.Iterator;
// import java.util.List;

// import org.locationtech.jts.geom.Coordinate;
// import org.locationtech.jts.geom.Geometry;
// import org.locationtech.jts.geom.LineString;
// import org.locationtech.jts.geom.util.LinearComponentExtracter;

/**
 * Generates points offset by a given distance 
 * from both sides of the midpoint of
 * all segments in a {@link Geometry}.
 * Can be used to generate probe points for
 * determining whether a polygonal overlay result
 * is incorrect.
 * The input geometry may have any orientation for its rings,
 * but {@link #setSidesToGenerate(bool, bool)} is
 * only meaningful if the orientation is known.
 *
 * @author Martin Davis
 * @version 1.7
 */
class OffsetPointGenerator
{
 /**private */Geometry g;
 /**private */bool doLeft = true; 
 /**private */bool doRight = true;
  
  OffsetPointGenerator(Geometry g)
  {
    this.g = g;
  }

  /**
   * Set the sides on which to generate offset points.
   * 
   * @param doLeft
   * @param doRight
   */
  void setSidesToGenerate(bool doLeft, bool doRight)
  {
    this.doLeft = doLeft;
    this.doRight = doRight;
  }
  
  /**
   * Gets the computed offset points.
   *
   * @return List&lt;Coordinate&gt;
   */
  List getPoints(double offsetDistance)
  {
    List offsetPts = [];
    List lines = LinearComponentExtracter.getLines(g);
    for (Iterator i = lines.iterator(); i.moveNext(); ) {
      LineString line = (LineString) i.current;
      extractPoints(line, offsetDistance, offsetPts);
    }
    //System.out.println(toMultiPoint(offsetPts));
    return offsetPts;
  }

 /**private */void extractPoints(LineString line, double offsetDistance, List offsetPts)
  {
    List<Coordinate> pts = line.getCoordinates();
    for (int i = 0; i < pts.length - 1; i++) {
    	computeOffsetPoints(pts[i], pts[i + 1], offsetDistance, offsetPts);
    }
  }

  /**
   * Generates the two points which are offset from the 
   * midpoint of the segment <tt>(p0, p1)</tt> by the
   * <tt>offsetDistance</tt>.
   * 
   * @param p0 the first point of the segment to offset from
   * @param p1 the second point of the segment to offset from
   */
 /**private */void computeOffsetPoints(Coordinate p0, Coordinate p1, double offsetDistance, List offsetPts)
  {
    double dx = p1.x - p0.x;
    double dy = p1.y - p0.y;
    double len = math.hypot(dx, dy);
    // u is the vector that is the length of the offset, in the direction of the segment
    double ux = offsetDistance * dx / len;
    double uy = offsetDistance * dy / len;

    double midX = (p1.x + p0.x) / 2;
    double midY = (p1.y + p0.y) / 2;

    if (doLeft) {
      Coordinate offsetLeft = new Coordinate(midX - uy, midY + ux);
      offsetPts.add(offsetLeft);
    }
    
    if (doRight) {
      Coordinate offsetRight = new Coordinate(midX + uy, midY - ux);
      offsetPts.add(offsetRight);
    }
  }

}
