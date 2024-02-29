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
// import java.awt.geom.Ellipse2D;
// import java.awt.geom.GeneralPath;
// import java.awt.geom.Line2D;
// import java.awt.geom.Point2D;
// import java.awt.geom.Rectangle2D;

/**
 * An abstract class for classes which create {@link Shape}s to represent 
 * {@link Point}
 * geometries. Java2D does not provide an actual point shape, so some other
 * shape must be used to render points (e.g. such as a Rectangle or Ellipse).
 * 
 * @author Martin Davis
 * 
 */
abstract class PointShapeFactory {
  /**
   * Creates a shape representing a {@link Point}.
   * 
   * @param point
   *          the location of the point
   * @return a shape
   */
  Shape createPoint(Point2D point);

  static abstract class BasePointShapeFactory implements
      PointShapeFactory {
    /**
     * The default size of the shape
     */
    static final double DEFAULT_SIZE = 3.0;

    protected double size = DEFAULT_SIZE;

    /**
     * Creates a new factory for points with default size.
     * 
     */
    BasePointShapeFactory() {
    }

    /**
     * Creates a factory for points of given size.
     * 
     * @param size
     *          the size of the points
     */
    BasePointShapeFactory(double size) {
      this.size = size;
    }

    /**
     * Creates a shape representing a point.
     * 
     * @param point
     *          the location of the point
     * @return a shape
     */
    abstract Shape createPoint(Point2D point);
  }

  static class Point extends BasePointShapeFactory {
    /**
     * Creates a new factory for points with default size.
     * 
     */
    Point() {
      super();
    }

    /**
     * Creates a factory for points of given size.
     * 
     * @param size
     *          the size of the points
     */
    Point(double size) {
      super(size);
    }

    /**
     * Creates a shape representing a point.
     * 
     * @param point
     *          the location of the point
     * @return a shape
     */
    Shape createPoint(Point2D point) {
      Line2D.Double pointMarker =
        new Line2D.Double(
        	point.getX(),
        	point.getY(),
          point.getX(),
          point.getY());
      return pointMarker;
    }
  }
  
  static class Square extends BasePointShapeFactory {
    /**
     * Creates a new factory for squares with default size.
     * 
     */
    Square() {
      super();
    }

    /**
     * Creates a factory for squares of given size.
     * 
     * @param size
     *          the size of the points
     */
    Square(double size) {
      super(size);
    }

    /**
     * Creates a shape representing a point.
     * 
     * @param point
     *          the location of the point
     * @return a shape
     */
    Shape createPoint(Point2D point) {
      Rectangle2D.Double pointMarker =
        new Rectangle2D.Double(
          0.0,
          0.0,
          size,
          size);
      pointMarker.x = (point.getX() - (size / 2));
      pointMarker.y = (point.getY() - (size / 2));

      return pointMarker;
    }
  }
  
  static class Star extends BasePointShapeFactory {
    /**
     * Creates a new factory for points with default size.
     * 
     */
    Star() {
      super();
    }

    /**
     * Creates a factory for points of given size.
     * 
     * @param size
     *          the size of the points
     */
    Star(double size) {
      super(size);
    }

    /**
     * Creates a shape representing a point.
     * 
     * @param point
     *          the location of the point
     * @return a shape
     */
    Shape createPoint(Point2D point) {
      GeneralPath path = new GeneralPath();
      path.moveTo((float) point.getX(), (float) (point.getY() - size/2));
      path.lineTo((float) (point.getX() + size * 1/8), (float) (point.getY() - size * 1/8));
      path.lineTo((float) (point.getX() + size/2), (float) (point.getY() - size * 1/8));
      path.lineTo((float) (point.getX() + size * 2/8), (float) (point.getY() + size * 1/8));
      path.lineTo((float) (point.getX() + size * 3/8), (float) (point.getY() + size/2));
      path.lineTo((float) (point.getX()), (float) (point.getY() + size * 2/8));
      path.lineTo((float) (point.getX() - size * 3/8), (float) (point.getY() + size/2));
      path.lineTo((float) (point.getX() - size * 2/8), (float) (point.getY() + size * 1/8));
      path.lineTo((float) (point.getX() - size/2), (float) (point.getY() - size * 1/8));
      path.lineTo((float) (point.getX() - size * 1/8), (float) (point.getY() - size * 1/8));
      path.closePath();
      return path;
    }
  }
  
  static class Triangle extends BasePointShapeFactory {
    /**
     * Creates a new factory for points with default size.
     * 
     */
    Triangle() {
      super();
    }

    /**
     * Creates a factory for points of given size.
     * 
     * @param size
     *          the size of the points
     */
    Triangle(double size) {
      super(size);
    }

    /**
     * Creates a shape representing a point.
     * 
     * @param point
     *          the location of the point
     * @return a shape
     */
    Shape createPoint(Point2D point) {

      GeneralPath path = new GeneralPath();
      path.moveTo((float) (point.getX()), (float) (point.getY() - size / 2));
      path.lineTo((float) (point.getX() + size / 2), (float) (point.getY() + size / 2));
      path.lineTo((float) (point.getX() - size / 2), (float) (point.getY() + size / 2));
      path.lineTo((float) (point.getX()), (float) (point.getY() - size / 2));

      return path;
    }

  }
  static class Circle extends BasePointShapeFactory {
    /**
     * Creates a new factory for points with default size.
     * 
     */
    Circle() {
      super();
    }

    /**
     * Creates a factory for points of given size.
     * 
     * @param size
     *          the size of the points
     */
    Circle(double size) {
      super(size);
    }

    /**
     * Creates a shape representing a point.
     * 
     * @param point
     *          the location of the point
     * @return a shape
     */
    Shape createPoint(Point2D point) {
      Ellipse2D.Double pointMarker =
        new Ellipse2D.Double(
          0.0,
          0.0,
          size,
          size);
      pointMarker.x = (point.getX() - (size / 2));
      pointMarker.y = (point.getY() - (size / 2));

      return pointMarker;
    }

  }
  static class Cross extends BasePointShapeFactory {
    /**
     * Creates a new factory for points with default size.
     * 
     */
    Cross() {
      super();
    }

    /**
     * Creates a factory for points of given size.
     * 
     * @param size
     *          the size of the points
     */
    Cross(double size) {
      super(size);
    }

    /**
     * Creates a shape representing a point.
     * 
     * @param point
     *          the location of the point
     * @return a shape
     */
    Shape createPoint(Point2D point) {

      float x1 = (float) (point.getX() - size/2f);
      float x2 = (float) (point.getX() - size/4f);
      float x3 = (float) (point.getX() + size/4f);
      float x4 = (float) (point.getX() + size/2f);

      float y1 = (float) (point.getY() - size/2f);
      float y2 = (float) (point.getY() - size/4f);
      float y3 = (float) (point.getY() + size/4f);
      float y4 = (float) (point.getY() + size/2f);

  GeneralPath path = new GeneralPath();
      path.moveTo(x2, y1);
      path.lineTo(x3, y1);
      path.lineTo(x3, y2);
      path.lineTo(x4, y2);
      path.lineTo(x4, y3);
      path.lineTo(x3, y3);
      path.lineTo(x3, y4);
      path.lineTo(x2, y4);
      path.lineTo(x2, y3);
      path.lineTo(x1, y3);
      path.lineTo(x1, y2);
      path.lineTo(x2, y2);
      path.lineTo(x2, y1);

      return path;
    }

  }
  static class X extends BasePointShapeFactory {
    /**
     * Creates a new factory for points with default size.
     * 
     */
    X() {
      super();
    }

    /**
     * Creates a factory for points of given size.
     * 
     * @param size
     *          the size of the points
     */
    X(double size) {
      super(size);
    }

    /**
     * Creates a shape representing a point.
     * 
     * @param point
     *          the location of the point
     * @return a shape
     */
    Shape createPoint(Point2D point) {
      GeneralPath path = new GeneralPath();
      path.moveTo((float) (point.getX()), (float) (point.getY() - size * 1/8));
      path.lineTo((float) (point.getX() + size * 2/8), (float) (point.getY() - size/2));
      path.lineTo((float) (point.getX() + size/2), (float) (point.getY() - size/2));
      path.lineTo((float) (point.getX() + size * 1/8), (float) (point.getY()));
      path.lineTo((float) (point.getX() + size/2), (float) (point.getY() + size/2));
      path.lineTo((float) (point.getX() + size * 2/8), (float) (point.getY() + size/2));
      path.lineTo((float) (point.getX()), (float) (point.getY() + size * 1/8));
      path.lineTo((float) (point.getX() - size * 2/8), (float) (point.getY() + size/2));
      path.lineTo((float) (point.getX() - size/2), (float) (point.getY() + size/2));
      path.lineTo((float) (point.getX() - size * 1/8), (float) (point.getY()));
      path.lineTo((float) (point.getX() - size/2), (float) (point.getY() - size/2));
      path.lineTo((float) (point.getX() - size * 2/8), (float) (point.getY() - size/2));
      path.closePath();
      return path;
    }

  }
}
