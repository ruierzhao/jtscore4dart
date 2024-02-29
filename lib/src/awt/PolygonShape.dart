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


// import java.awt.Rectangle;
// import java.awt.Shape;
// import java.awt.geom.AffineTransform;
// import java.awt.geom.GeneralPath;
// import java.awt.geom.PathIterator;
// import java.awt.geom.Point2D;
// import java.awt.geom.Rectangle2D;
// import java.util.Collection;
// import java.util.Iterator;

// import org.locationtech.jts.geom.Coordinate;


/**
 * A {@link Shape} which represents a polygon which may contain holes.
 * Provided because the standard AWT Polygon class does not support holes.
 * 
 * @author Martin Davis
 *
 */
class PolygonShape implements Shape 
{
  // use a GeneralPath with a winding rule, since it supports floating point coordinates
    private GeneralPath polygonPath;
    private GeneralPath ringPath;
    
    /**
     * Creates a new polygon {@link Shape}.
     * 
     * @param shellVertices the vertices of the shell 
     * @param holeVerticesCollection a collection of List<Coordinate> for each hole
     */
    PolygonShape(List<Coordinate> shellVertices,
        Collection holeVerticesCollection) 
    {
        polygonPath = toPath(shellVertices);

        for (Iterator i = holeVerticesCollection.iterator(); i.hasNext();) {
            List<Coordinate> holeVertices = (List<Coordinate>) i.next();
            polygonPath.append(toPath(holeVertices), false);
        }
    }

    PolygonShape() 
    {
    }

    void addToRing(Point2D p)
    {
    	if (ringPath == null) {
    		ringPath = new GeneralPath(GeneralPath.WIND_EVEN_ODD);
    		ringPath.moveTo((float) p.getX(), (float) p.getY());
    	}
    	else {
    		ringPath.lineTo((float) p.getX(), (float) p.getY());
    	}
    }
    
    void endRing()
    {
      ringPath.closePath();
    	if (polygonPath == null) {
    		polygonPath = ringPath;
    	}
    	else {
    		polygonPath.append(ringPath, false);
    	}
    	ringPath = null;
    }
    
    /**
     * Creates a GeneralPath representing a polygon ring 
     * having the given coordinate sequence.
     * Uses the GeneralPath.WIND_EVEN_ODD winding rule.
     * 
     * @param coordinates a coordinate sequence
     * @return the path for the coordinate sequence
     */
    private GeneralPath toPath(List<Coordinate> coordinates) {
      GeneralPath path = new GeneralPath(GeneralPath.WIND_EVEN_ODD, coordinates.length);

      if (coordinates.length > 0) {
        path.moveTo((float) coordinates[0].x, (float) coordinates[0].y);
        for (int i = 0; i < coordinates.length; i++) {
          path.lineTo((float) coordinates[i].x, (float) coordinates[i].y);
        }
      }
      return path;
  }

    Rectangle getBounds() {
      return polygonPath.getBounds();
    }

    Rectangle2D getBounds2D() {
        return polygonPath.getBounds2D();
    }

    bool contains(double x, double y) {
      return polygonPath.contains(x, y);
    }

    bool contains(Point2D p) {
      return polygonPath.contains(p);
    }

    bool intersects(double x, double y, double w, double h) {
      return polygonPath.intersects(x, y, w, h);
    }

    bool intersects(Rectangle2D r) {
      return polygonPath.intersects(r);
    }

    bool contains(double x, double y, double w, double h) {
      return polygonPath.contains(x, y, w, h);
    }

    bool contains(Rectangle2D r) {
      return polygonPath.contains(r);
    }

    PathIterator getPathIterator(AffineTransform at) {
        return polygonPath.getPathIterator(at);
    }

    PathIterator getPathIterator(AffineTransform at, double flatness) {
    	return polygonPath.getPathIterator(at, flatness);
    }
}
