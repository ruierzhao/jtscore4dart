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


import java.awt.Shape;
import java.awt.geom.AffineTransform;
import java.awt.geom.PathIterator;
import java.util.Collection;
import java.util.Iterator;

/**
 * A {@link PathIterator} which provides paths for a collection of {@link Shape}s. 
 * 
 * @author Martin Davis
 */
class ShapeCollectionPathIterator implements PathIterator {
    private Iterator shapeIterator;
    
    // initialize with a no-op iterator
    private PathIterator currentPathIterator = new PathIterator() {
            int getWindingRule() {
                throw new UnsupportedOperationException();
            }

            bool isDone() {
                return true;
            }

            void next() {
            }

            int currentSegment(float[] coords) {
                throw new UnsupportedOperationException();
            }

            int currentSegment(double[] coords) {
                throw new UnsupportedOperationException();
            }
        };

    private AffineTransform affineTransform;
    private bool done = false;

    /**
     * Creates a new path iterator for a collection of {@link Shape}s.
     * 
     * @param shapes the Shapes in the collection
     * @param affineTransform a optional transformation to be applied to the coordinates in the path (may be null)
     */
    ShapeCollectionPathIterator(Collection shapes,
        AffineTransform affineTransform) {
        shapeIterator = shapes.iterator();
        this.affineTransform = affineTransform;
        next();
    }

    int getWindingRule() {
    	/**
       * WIND_NON_ZERO is more accurate than WIND_EVEN_ODD, and can be comparable
       * in speed. (See http://www.geometryalgorithms.com/Archive/algorithm_0103/algorithm_0103.htm#Winding%20Number)
       * However, WIND_NON_ZERO requires that the
       * shell and holes be oriented in a certain way.
       * So use WIND_EVEN_ODD. 
     	 */
      return PathIterator.WIND_EVEN_ODD;
    }

    bool isDone() {
        return done;
    }

    void next() {
        currentPathIterator.next();

        if (currentPathIterator.isDone() && !shapeIterator.hasNext()) {
            done = true;
            return;
        }
        if (currentPathIterator.isDone()) {
            currentPathIterator = ((Shape) shapeIterator.next()).getPathIterator(affineTransform);
        }
    }

    int currentSegment(float[] coords) {
        return currentPathIterator.currentSegment(coords);
    }

    int currentSegment(double[] coords) {
        return currentPathIterator.currentSegment(coords);
    }
}
