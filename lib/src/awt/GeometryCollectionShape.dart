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
// import java.awt.geom.PathIterator;
// import java.awt.geom.Point2D;
// import java.awt.geom.Rectangle2D;
// import java.util.ArrayList;
// import java.util.Iterator;

// import org.locationtech.jts.geom.Geometry;

/**
 * A {@link Shape} which contains a heterogeneous collection of other shapes
 * representing JTS {@link Geometry}s.
 * 
 * @author Martin Davis
 *
 */
class GeometryCollectionShape implements Shape {
   /**private */ArrayList shapes = [];

    GeometryCollectionShape() {
    }

    void add(Shape shape) {
        shapes.add(shape);
    }

    Rectangle getBounds() {
        /**@todo Implement this java.awt.Shape method*/
        throw new java.lang.UnsupportedOperationException(
            "Method getBounds() not yet implemented.");
    }

    Rectangle2D getBounds2D() {
        Rectangle2D rectangle = null;

        for (Iterator i = shapes.iterator(); i.moveNext();) {
            Shape shape = (Shape) i.current;

            if (rectangle == null) {
                rectangle = shape.getBounds2D();
            } else {
                rectangle.add(shape.getBounds2D());
            }
        }

        return rectangle;
    }

    bool contains(double x, double y) {
        /**@todo Implement this java.awt.Shape method*/
        throw new java.lang.UnsupportedOperationException(
            "Method contains() not yet implemented.");
    }

    bool contains(Point2D p) {
        /**@todo Implement this java.awt.Shape method*/
        throw new java.lang.UnsupportedOperationException(
            "Method contains() not yet implemented.");
    }

    bool intersects(double x, double y, double w, double h) {
        /**@todo Implement this java.awt.Shape method*/
        throw new java.lang.UnsupportedOperationException(
            "Method intersects() not yet implemented.");
    }

    bool intersects(Rectangle2D r) {
        /**@todo Implement this java.awt.Shape method*/
        throw new java.lang.UnsupportedOperationException(
            "Method intersects() not yet implemented.");
    }

    bool contains(double x, double y, double w, double h) {
        /**@todo Implement this java.awt.Shape method*/
        throw new java.lang.UnsupportedOperationException(
            "Method contains() not yet implemented.");
    }

    bool contains(Rectangle2D r) {
        /**@todo Implement this java.awt.Shape method*/
        throw new java.lang.UnsupportedOperationException(
            "Method contains() not yet implemented.");
    }

    PathIterator getPathIterator(AffineTransform at) {
        return new ShapeCollectionPathIterator(shapes, at);
    }

    PathIterator getPathIterator(AffineTransform at, double flatness) {
        // since Geometry is linear, can simply delegate to the simple method
        return getPathIterator(at);
    }
}
