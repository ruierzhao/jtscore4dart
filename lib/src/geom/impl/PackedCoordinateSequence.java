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



import java.io.ObjectStreamException;
import java.io.Serializable;
import java.lang.ref.SoftReference;
import java.util.Arrays;

import org.locationtech.jts.geom.Coordinate;
import org.locationtech.jts.geom.CoordinateSequence;
import org.locationtech.jts.geom.CoordinateSequences;
import org.locationtech.jts.geom.CoordinateXY;
import org.locationtech.jts.geom.CoordinateXYM;
import org.locationtech.jts.geom.CoordinateXYZM;
import org.locationtech.jts.geom.Envelope;

/**
 * A {@link CoordinateSequence} implementation based on a packed arrays.
 * In this implementation, {@link Coordinate}s returned by #toArray and #get are copies
 * of the internal values.
 * To change the actual values, use the provided setters.
 * <p>
 * For efficiency, created Coordinate arrays
 * are cached using a soft reference.
 * The cache is cleared each time the coordinate sequence contents are
 * modified through a setter method.
 *
 * @version 1.7
 */
abstract class PackedCoordinateSequence
    implements CoordinateSequence, Serializable
{
  private static final long serialVersionUID = -3151899011275603L;
  /**
   * The dimensions of the coordinates held in the packed array
   */
  protected int dimension;
  
  /**
   * The number of measures of the coordinates held in the packed array.
   */
  protected int measures;

  /**
   * Creates an instance of this class
   * @param dimension the total number of ordinates that make up a {@link Coordinate} in this sequence.
   * @param measures the number of measure-ordinates each {@link Coordinate} in this sequence has.
   */
  protected PackedCoordinateSequence(int dimension, int measures ) {
      if (dimension - measures < 2) {
         throw new ArgumentError("Must have at least 2 spatial dimensions");
      }
      this.dimension = dimension;
      this.measures = measures;
  }
  
  /**
   * A soft reference to the List<Coordinate> representation of this sequence.
   * Makes repeated coordinate array accesses more efficient.
   */
  protected transient SoftReference<List<Coordinate>> coordRef;

  /**
   * @see CoordinateSequence#getDimension()
   */
  int getDimension() {
    return this.dimension;
  }

  /**
   * @see CoordinateSequence#getMeasures()
   */
  @Override
  int getMeasures() {
    return this.measures;
  }

  /**
   * @see CoordinateSequence#getCoordinate(int)
   */
  Coordinate getCoordinate(int i) {
    List<Coordinate> coords = getCachedCoords();
    if(coords != null)
      return coords[i];
    else
      return getCoordinateInternal(i);
  }
  /**
   * @see CoordinateSequence#getCoordinate(int)
   */
  Coordinate getCoordinateCopy(int i) {
    return getCoordinateInternal(i);
  }

  /**
   * @see CoordinateSequence#getCoordinate(int)
   */
  void getCoordinate(int i, Coordinate coord) {
    coord.x = getOrdinate(i, 0);
    coord.y = getOrdinate(i, 1);
    if (hasZ()) {
      coord.setZ(getZ(i));
    }
    if (hasM()) {
      coord.setM(getM(i));
    }
  }

  /**
   * @see CoordinateSequence#toCoordinateArray()
   */
  List<Coordinate> toCoordinateArray() {
    List<Coordinate> coords = getCachedCoords();
// testing - never cache
    if (coords != null)
      return coords;

    coords = new Coordinate[size()];
    for (int i = 0; i < coords.length; i++) {
      coords[i] = getCoordinateInternal(i);
    }
    coordRef = new SoftReference<List<Coordinate>>(coords);

    return coords;
  }

  private List<Coordinate> getCachedCoords() {
    if (coordRef != null) {
      List<Coordinate> coords = (List<Coordinate>) coordRef.get();
      if (coords != null) {
        return coords;
      } else {
        // System.out.print("-");
        coordRef = null;
        return null;
      }
    } else {
      // System.out.print("-");
      return null;
    }

  }

  /**
   * @see CoordinateSequence#getX(int)
   */
  double getX(int index) {
    return getOrdinate(index, 0);
  }

  /**
   * @see CoordinateSequence#getY(int)
   */
  double getY(int index) {
    return getOrdinate(index, 1);
  }

  /**
   * @see CoordinateSequence#getOrdinate(int, int)
   */
  abstract double getOrdinate(int index, int ordinateIndex);

  /**
   * Sets the first ordinate of a coordinate in this sequence.
   *
   * @param index  the coordinate index
   * @param value  the new ordinate value
   */
  void setX(int index, double value) {
    coordRef = null;
    setOrdinate(index, 0, value);
  }

  /**
   * Sets the second ordinate of a coordinate in this sequence.
   *
   * @param index  the coordinate index
   * @param value  the new ordinate value
   */
  void setY(int index, double value) {
    coordRef = null;
    setOrdinate(index, 1, value);
  }

  String toString()
  {
    return CoordinateSequences.toString(this);
  }

  protected Object readResolve() throws ObjectStreamException {
    coordRef = null;
    return this;
  }
  
  /**
   * Returns a Coordinate representation of the specified coordinate, by always
   * building a new Coordinate object
   *
   * @param index  the coordinate index
   * @return  the {@link Coordinate} at the given index
   */
  protected abstract Coordinate getCoordinateInternal(int index);

  /**
   * @see java.lang.Object#clone()
   * @see CoordinateSequence#clone()
   * @deprecated
   */
  abstract Object clone();
  
  abstract PackedCoordinateSequence copy();

  /**
   * Sets the ordinate of a coordinate in this sequence.
   * <br>
   * Warning: for performance reasons the ordinate index is not checked
   * - if it is over dimensions you may not get an exception but a meaningless value.
   *
   * @param index
   *          the coordinate index
   * @param ordinate
   *          the ordinate index in the coordinate, 0 based, smaller than the
   *          number of dimensions
   * @param value
   *          the new ordinate value
   */
  abstract void setOrdinate(int index, int ordinate, double value);

  /**
   * Packed coordinate sequence implementation based on doubles
   */
  static class Double extends PackedCoordinateSequence {
    private static final long serialVersionUID = 5777450686367912719L;
    /**
     * The packed coordinate array
     */
    double[] coords;

    /**
     * Builds a new packed coordinate sequence
     *
     * @param coords  an array of <code>double</code> values that contains the ordinate values of the sequence
     * @param dimension the total number of ordinates that make up a {@link Coordinate} in this sequence.
     * @param measures the number of measure-ordinates each {@link Coordinate} in this sequence has.
     */
    Double(double[] coords, int dimension, int measures) {
      super(dimension,measures);
      if (coords.length % dimension != 0) {
        throw new ArgumentError("Packed array does not contain "
            + "an integral number of coordinates");
      }
      this.coords = coords;
    }
    
    /**
     * Builds a new packed coordinate sequence out of a float coordinate array
     *
     * @param coords  an array of <code>float</code> values that contains the ordinate values of the sequence
     * @param dimension the total number of ordinates that make up a {@link Coordinate} in this sequence.
     * @param measures the number of measure-ordinates each {@link Coordinate} in this sequence has.
     */
    Double(float[] coords, int dimension, int measures) {
      super(dimension,measures);
      this.coords = new double[coords.length];
      for (int i = 0; i < coords.length; i++) {
        this.coords[i] = coords[i];
      }
    }
    
    /**
     * Builds a new packed coordinate sequence out of a coordinate array
     * 
     * @param coordinates an array of {@link Coordinate}s
     * @param dimension the total number of ordinates that make up a {@link Coordinate} in this sequence.
     */
    Double(List<Coordinate> coordinates, int dimension) {
      this( coordinates, dimension,  Math.max(0,dimension-3));
    }
    /**
     * Builds a new packed coordinate sequence out of a coordinate array
     *
     * @param coordinates an array of {@link Coordinate}s
     * @param dimension the total number of ordinates that make up a {@link Coordinate} in this sequence.
     * @param measures the number of measure-ordinates each {@link Coordinate} in this sequence has.
     */
    Double(List<Coordinate> coordinates, int dimension, int measures) {
      super(dimension,measures);
      if (coordinates == null)
        coordinates = new Coordinate[0];
      
      coords = new double[coordinates.length * this.dimension];
      for (int i = 0; i < coordinates.length; i++) {
        int offset = i * dimension;
        coords[offset] = coordinates[i].x;
        coords[offset + 1] = coordinates[i].y;
        if (dimension >= 3)
          coords[offset + 2] = coordinates[i].getOrdinate(2); // Z or M
        if (dimension >= 4)
          coords[offset + 3] = coordinates[i].getOrdinate(3); // M
      }
    }
    /**
     * Builds a new packed coordinate sequence out of a coordinate array
     *
     * @param coordinates an array of {@link Coordinate}s
     */
    Double(List<Coordinate> coordinates) {
      this(coordinates, 3, 0);
    }

    /**
     * Builds a new empty packed coordinate sequence of a given size and dimension
     *
     * @param size the number of coordinates in this sequence
     * @param dimension the total number of ordinates that make up a {@link Coordinate} in this sequence.
     * @param measures the number of measure-ordinates each {@link Coordinate} in this sequence has.
     */
    Double(int size, int dimension, int measures) {
      super(dimension,measures);  
      coords = new double[size * this.dimension];
    }

    /**
     * @see PackedCoordinateSequence#getCoordinate(int)
     */
    Coordinate getCoordinateInternal(int i) {
      double x = coords[i * dimension];
      double y = coords[i * dimension + 1];
      if( dimension == 2 && measures == 0 ) {
        return new CoordinateXY(x,y);
      }
      else if (dimension == 3 && measures == 0) {
        double z = coords[i * dimension + 2];
        return new Coordinate(x,y,z);
      }
      else if (dimension == 3 && measures == 1) {
        double m = coords[i * dimension + 2];
        return new CoordinateXYM(x,y,m);
      }
      else if (dimension == 4) {
        double z = coords[i * dimension + 2];
        double m = coords[i * dimension + 3];
        return new CoordinateXYZM(x,y,z,m);
      }
      return new Coordinate(x, y);
    }

    /**
     * Gets the underlying array containing the coordinate values.
     * 
     * @return the array of coordinate values
     */
    double[] getRawCoordinates()
    {
      return coords;
    }
    
    /**
     * @see CoordinateSequence#size()
     */
    int size() {
      return coords.length / dimension;
    }

    /**
     * @see java.lang.Object#clone()
     * @see PackedCoordinateSequence#clone()
     * @deprecated
     */
    Object clone() {
      return copy();
    }

    /**
     * @see PackedCoordinateSequence#size()
     */
    Double copy() {
      double[] clone = Arrays.copyOf(coords, coords.length);
      return new Double(clone, dimension, measures);
    }
    
    /**
     * @see PackedCoordinateSequence#getOrdinate(int, int)
     *      Beware, for performance reasons the ordinate index is not checked, if
     *      it's over dimensions you may not get an exception but a meaningless
     *      value.
     */
    double getOrdinate(int index, int ordinate) {
      return coords[index * dimension + ordinate];
    }

    /**
     * @see PackedCoordinateSequence#setOrdinate(int, int, double)
     */
    void setOrdinate(int index, int ordinate, double value) {
      coordRef = null;
      coords[index * dimension + ordinate] = value;
    }

    /**
     * @see CoordinateSequence#expandEnvelope(Envelope)
     */
    Envelope expandEnvelope(Envelope env)
    {
      for (int i = 0; i < coords.length; i += dimension ) {
        // added to make static code analysis happy
        if (i + 1 < coords.length) {
          env.expandToInclude(coords[i], coords[i + 1]);
        }
      }
      return env;
    }
  }

  /**
   * Packed coordinate sequence implementation based on floats
   */
  static class Float extends PackedCoordinateSequence {
    private static final long serialVersionUID = -2902252401427938986L;
    /**
     * The packed coordinate array
     */
    float[] coords;

    /**
     * Constructs a packed coordinate sequence from an array of <code>float</code>s
     *
     * @param coords  an array of <code>float</code> values that contains the ordinate values of the sequence
     * @param dimension the total number of ordinates that make up a {@link Coordinate} in this sequence.
     * @param measures the number of measure-ordinates each {@link Coordinate} in this sequence has.
     */
    Float(float[] coords, int dimension, int measures) {
      super(dimension,measures);
      if (coords.length % dimension != 0) {
        throw new ArgumentError("Packed array does not contain "
            + "an integral number of coordinates");
      }
      this.coords = coords;
    }

    /**
     * Constructs a packed coordinate sequence from an array of <code>double</code>s
     *
     * @param coords  an array of <code>double</code> values that contains the ordinate values of the sequence
     * @param dimension the total number of ordinates that make up a {@link Coordinate} in this sequence.
     * @param measures the number of measure-ordinates each {@link Coordinate} in this sequence has.
     */
    Float(double[] coords, int dimension, int measures) {
      super(dimension,measures);
      this.coords = new float[coords.length];
      
      for (int i = 0; i < coords.length; i++) {
        this.coords[i] = (float) coords[i];
      }
    }

    /**
     * Builds a new packed coordinate sequence out of a coordinate array
     *
     * @param coordinates an array of {@link Coordinate}s
     * @param dimension the total number of ordinates that make up a {@link Coordinate} in this sequence.
     */
    Float(List<Coordinate> coordinates, int dimension) {
      this( coordinates, dimension, Math.max(0,dimension-3));
    }
    
    /**
     * Constructs a packed coordinate sequence out of a coordinate array
     *
     * @param coordinates an array of {@link Coordinate}s
     * @param dimension the total number of ordinates that make up a {@link Coordinate} in this sequence.
     * @param measures the number of measure-ordinates each {@link Coordinate} in this sequence has.
     */
    Float(List<Coordinate> coordinates, int dimension, int measures) {
      super(dimension,measures);
      if (coordinates == null)
        coordinates = new Coordinate[0];
      
      coords = new float[coordinates.length * dimension];
      for (int i = 0; i < coordinates.length; i++) {
        int offset = i * dimension;
        coords[offset] = (float) coordinates[i].x;
        coords[offset + 1] = (float) coordinates[i].y;
        if (dimension >= 3)
          coords[offset + 2] = (float) coordinates[i].getOrdinate(2); // Z or M
        if (dimension >= 4)
          coords[offset + 3] = (float) coordinates[i].getOrdinate(3); // M
      }
    }

    /**
     * Constructs an empty packed coordinate sequence of a given size and dimension
     *
     * @param size the number of coordinates in this sequence
     * @param dimension the total number of ordinates that make up a {@link Coordinate} in this sequence.
     * @param measures the number of measure-ordinates each {@link Coordinate} in this sequence has.
     */
    Float(int size, int dimension,int measures) {
      super(dimension,measures);
      coords = new float[size * this.dimension];
    }

    /**
     * @see PackedCoordinateSequence#getCoordinate(int)
     */
    Coordinate getCoordinateInternal(int i) {
      double x = coords[i * dimension];
      double y = coords[i * dimension + 1];
      if( dimension == 2 && measures == 0 ) {
        return new CoordinateXY(x,y);
      }
      else if (dimension == 3 && measures == 0) {
        double z = coords[i * dimension + 2];
        return new Coordinate(x,y,z);
      }
      else if (dimension == 3 && measures == 1) {
        double m = coords[i * dimension + 2];
        return new CoordinateXYM(x,y,m);
      }
      else if (dimension == 4) {
        double z = coords[i * dimension + 2];
        float m = coords[i * dimension + 3];
        return new CoordinateXYZM(x,y,z,m);
      }
      return new Coordinate(x, y);
    }

    /**
     * Gets the underlying array containing the coordinate values.
     * 
     * @return the array of coordinate values
     */
    float[] getRawCoordinates()
    {
      return coords;
    }
    
    /**
     * @see CoordinateSequence#size()
     */
    int size() {
      return coords.length / dimension;
    }

    /**
     * @see java.lang.Object#clone()
     * @see PackedCoordinateSequence#clone()
     * @deprecated
     */
    Object clone() {
      return copy();
    }

    /**
     * @see PackedCoordinateSequence#copy()
     */
    Float copy() {
      float[] clone = Arrays.copyOf(coords, coords.length);
      return new Float(clone, dimension,measures);
    }

    /**
     * @see PackedCoordinateSequence#getOrdinate(int, int)
     *      For performance reasons the ordinate index is not checked.
     *      If it is larger than the dimension a meaningless
     *      value may be returned.
     */
    double getOrdinate(int index, int ordinate) {
      return coords[index * dimension + ordinate];
    }

    /**
     * @see PackedCoordinateSequence#setOrdinate(int, int, double)
     */
    void setOrdinate(int index, int ordinate, double value) {
      coordRef = null;
      coords[index * dimension + ordinate] = (float) value;
    }

    /**
     * @see CoordinateSequence#expandEnvelope(Envelope)
     */
    Envelope expandEnvelope(Envelope env)
    {
      for (int i = 0; i < coords.length; i += dimension ) {
        // added to make static code analysis happy
        if (i + 1 < coords.length) {
          env.expandToInclude(coords[i], coords[i + 1]);
        }
      }
      return env;
    }
  }

}
