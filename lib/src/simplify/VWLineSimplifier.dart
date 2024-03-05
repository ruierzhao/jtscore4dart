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



// import org.locationtech.jts.geom.Coordinate;
// import org.locationtech.jts.geom.CoordinateList;
// import org.locationtech.jts.geom.Triangle;

/**
 * Simplifies a linestring (sequence of points) using the 
 * Visvalingam-Whyatt algorithm.
 * The Visvalingam-Whyatt algorithm simplifies geometry 
 * by removing vertices while trying to minimize the area changed.
 * 
 * @version 1.7
 */
class VWLineSimplifier
{
  static List<Coordinate> simplify(List<Coordinate> pts, double distanceTolerance)
  {
    VWLineSimplifier simp = new VWLineSimplifier(pts, distanceTolerance);
    return simp.simplify();
  }

 /**private */List<Coordinate> pts;
 /**private */double tolerance;

  VWLineSimplifier(List<Coordinate> pts, double distanceTolerance)
  {
    this.pts = pts;
    this.tolerance = distanceTolerance * distanceTolerance;
  }

  List<Coordinate> simplify()
  {
    VWLineSimplifier.VWVertex vwLine = VWVertex.buildLine(pts);
    double minArea = tolerance;
    do {
      minArea = simplifyVertex(vwLine);
    } while (minArea < tolerance);
    List<Coordinate> simp = vwLine.getCoordinates();
    // ensure computed value is a valid line
    if (simp.length < 2) {
      return new List<Coordinate> { simp[0], new Coordinate(simp[0]) };
    }
    return simp;
  }

 /**private */double simplifyVertex(VWLineSimplifier.VWVertex vwLine)
  {
    /**
     * Scan vertices in line and remove the one with smallest effective area.
     */
    // TODO: use an appropriate data structure to optimize finding the smallest area vertex
    VWLineSimplifier.VWVertex curr = vwLine;
    double minArea = curr.getArea();
    VWLineSimplifier.VWVertex minVertex = null;
    while (curr != null) {
      double area = curr.getArea();
      if (area < minArea) {
        minArea = area;
        minVertex = curr;
      }
      curr = curr.next;
    }
    if (minVertex != null && minArea < tolerance) {
      minVertex.remove();
    }
    if (! vwLine.isLive()) return -1;
    return minArea;
  }


  static class VWVertex
  {
    static VWLineSimplifier.VWVertex buildLine(List<Coordinate> pts)
    {
      VWLineSimplifier.VWVertex first = null;
      VWLineSimplifier.VWVertex prev = null;
      for (int i = 0; i < pts.length; i++) {
        VWLineSimplifier.VWVertex v = new VWVertex(pts[i]);
        if (first == null)
          first = v;
        v.setPrev(prev);
        if (prev != null) {
          prev.setNext(v);
          prev.updateArea();
        }
        prev = v;
      }
      return first;
    }
    
    static double MAX_AREA = Double.MAX_VALUE;
    
   /**private */Coordinate pt;
   /**private */VWLineSimplifier.VWVertex prev;
   /**private */VWLineSimplifier.VWVertex next;
   /**private */double area = MAX_AREA;
   /**private */bool isLive = true;

    VWVertex(Coordinate pt)
    {
      this.pt = pt;
    }

    void setPrev(VWLineSimplifier.VWVertex prev)
    {
      this.prev = prev;
    }

    void setNext(VWLineSimplifier.VWVertex next)
    {
      this.next = next;
    }

    void updateArea()
    {
      if (prev == null || next == null) {
        area = MAX_AREA;
        return;
      }
      area = (Triangle.area(prev.pt, pt, next.pt).abs());
    }

    double getArea()
    {
      return area;
    }
    bool isLive()
    {
      return isLive;
    }
    VWLineSimplifier.VWVertex remove()
    {
      VWLineSimplifier.VWVertex tmpPrev = prev;
      VWLineSimplifier.VWVertex tmpNext = next;
      VWLineSimplifier.VWVertex result = null;
      if (prev != null) {
        prev.setNext(tmpNext);
        prev.updateArea();
        result = prev;
      }
      if (next != null) {
        next.setPrev(tmpPrev);
        next.updateArea();
        if (result == null)
          result = next;
      }
      isLive = false;
      return result;
    }
    List<Coordinate> getCoordinates()
    {
      CoordinateList coords = new CoordinateList();
      VWLineSimplifier.VWVertex curr = this;
      do {
        coords.add(curr.pt, false);
        curr = curr.next;
      } while (curr != null);
      return coords.toCoordinateArray();
    }
  }
}
