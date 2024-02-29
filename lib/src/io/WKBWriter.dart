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


// import java.io.ByteArrayOutputStream;
// import java.io.IOException;

// import org.locationtech.jts.geom.Coordinate;
// import org.locationtech.jts.geom.CoordinateSequence;
// import org.locationtech.jts.geom.Geometry;
// import org.locationtech.jts.geom.GeometryCollection;
// import org.locationtech.jts.geom.LineString;
// import org.locationtech.jts.geom.LinearRing;
// import org.locationtech.jts.geom.MultiLineString;
// import org.locationtech.jts.geom.MultiPoint;
// import org.locationtech.jts.geom.MultiPolygon;
// import org.locationtech.jts.geom.Point;
// import org.locationtech.jts.geom.Polygon;
// import org.locationtech.jts.util.Assert;

/**
 * Writes a {@link Geometry} into Well-Known Binary format.
 * Supports use of an {@link OutStream}, which allows easy use
 * with arbitrary byte stream sinks.
 * <p>
 * The WKB format is specified in the 
 * OGC <A HREF="http://portal.opengeospatial.org/files/?artifact_id=829"><i>Simple Features for SQL
 * specification</i></a> (section 3.3.2.6).
 * <p>
 * There are a few cases which are not specified in the standard.
 * The implementation uses a representation which is compatible with
 * other common spatial systems (notably, PostGIS).
 * <ul>
 * <li>{@link LinearRing}s are written as {@link LineString}s</li>
 * <li>Empty geometries are output as follows:
 * <ul>
 * <li><b>Point</b>: a <code>WKBPoint</code> with <code>NaN</code> ordinate values</li> 
 * <li><b>LineString</b>: a <code>WKBLineString</code> with zero points</li>
 * <li><b>Polygon</b>: a <code>WKBPolygon</code> with zero rings</li>
 * <li><b>Multigeometries</b>: a <code>WKBMulti</code> geometry of appropriate type with zero elements</li>
 * <li><b>GeometryCollections</b>: a <code>WKBGeometryCollection</code> with zero elements</li>
 * </ul></li>
 * </ul>
 * <p>
 * This implementation supports the <b>Extended WKB</b> standard. 
 * Extended WKB allows writing 3-dimensional coordinates
 * and the geometry SRID value.  
 * The presence of 3D coordinates is indicated
 * by setting the high bit of the <tt>wkbType</tt> word.
 * The presence of a SRID is indicated
 * by setting the third bit of the <tt>wkbType</tt> word.
 * EWKB format is upward-compatible with the original SFS WKB format.
 * <p>
 * SRID output is optimized, if specified. 
 * Only the top-level geometry has the SRID included.
 * This assumes that all geometries in a collection have the same SRID as 
 * the collection (which is the JTS convention).
 * <p>
 * This class supports reuse of a single instance to read multiple
 * geometries. This class is not thread-safe; each thread should create its own
 * instance.
 * 
 * <h3>Syntax</h3>
 * The following syntax specification describes the version of Well-Known Binary
 * supported by JTS.
 * <p>
 * <i>The specification uses a syntax language similar to that used in
 * the C language.  Bitfields are specified from high-order to low-order bits.</i>
 * <p>
 * <blockquote><pre>
 * 
 * <b>byte</b> = 1 byte
 * <b>uint32</b> = 32 bit unsigned integer (4 bytes)
 * <b>double</b> = double precision number (8 bytes)
 * 
 * abstract Point { }
 * 
 * Point2D extends Point {
 * 	<b>double</b> x;
 * 	<b>double</b> y;
 * }
 * 
 * Point3D extends Point {
 * 	<b>double</b> x;
 * 	<b>double</b> y;
 * 	<b>double</b> z;
 * }
 * 
 * LinearRing {
 * 	<b>uint32</b> numPoints;
 * 	Point points[numPoints];
 * }
 * 
 * enum wkbGeometryType {
 * 	wkbPoint = 1,
 * 	wkbLineString = 2,
 * 	wkbPolygon = 3,
 * 	wkbMultiPoint = 4,
 * 	wkbMultiLineString = 5,
 * 	wkbMultiPolygon = 6,
 * 	wkbGeometryCollection = 7
 * }
 * 
 * enum byteOrder {
 * 	wkbXDR = 0,	// Big Endian
 * 	wkbNDR = 1 	// Little Endian
 * }
 * 
 * WKBType {
 * 	<b>uint32</b> wkbGeometryType : 8; // values from enum wkbGeometryType
 * }
 * 
 * EWKBType {
 * 	<b>uint32</b> is3D : 1; 	// 0 = 2D, 1 = 3D
 * 	<b>uint32</b> noData1 : 1; 
 * 	<b>uint32</b> hasSRID : 1;  	// 0, no, 1 = yes
 * 	<b>uint32</b> noData2 : 21; 
 * 	<b>uint32</b> wkbGeometryType : 8; // values from enum wkbGeometryType
 * }
 * 
 * abstract WKBGeometry {
 * 	<b>byte</b> byteOrder;		// values from enum byteOrder
 * 	EWKBType wkbType
 * 	[ <b>uint32</b> srid; ] 	// only if hasSRID = yes
 * }
 * 
 * WKBPoint extends WKBGeometry {
 * 	Point point;
 * }
 * 
 * WKBLineString extends WKBGeometry {
 * 	<b>uint32</b> numCoords;
 * 	Point points[numCoords];
 * }
 * 
 * WKBPolygon extends WKBGeometry {
 * 	<b>uint32</b> numRings;
 * 	LinearRing rings[numRings];
 * }
 * 
 * WKBMultiPoint extends WKBGeometry {
 * 	<b>uint32</b> numElems;
 * 	WKBPoint elems[numElems];
 * }
 * 
 * WKBMultiLineString extends WKBGeometry {
 * 	<b>uint32</b> numElems;
 * 	WKBLineString elems[numElems];
 * }
 * 
 * wkbMultiPolygon extends WKBGeometry {
 * 	<b>uint32</b> numElems;
 * 	WKBPolygon elems[numElems];
 * }
 * 
 * WKBGeometryCollection extends WKBGeometry {
 * 	<b>uint32</b> numElems;
 * 	WKBGeometry elems[numElems];
 * }
 * 
 * </pre></blockquote> 
 * @see WKBReader
 */
class WKBWriter
{
  /**
   * Converts a byte array to a hexadecimal string.
   * 
   * @param bytes
   * @return a string of hexadecimal digits
   * 
   * @deprecated
   */
  static String bytesToHex(byte[] bytes)
  {
    return toHex(bytes);
  }

  /**
   * Converts a byte array to a hexadecimal string.
   * 
   * @param bytes a byte array
   * @return a string of hexadecimal digits
   */
  static String toHex(byte[] bytes)
  {
    StringBuffer buf = new StringBuffer();
    for (int i = 0; i < bytes.length; i++) {
      byte b = bytes[i];
      buf.append(toHexDigit((b >> 4) & 0x0F));
      buf.append(toHexDigit(b & 0x0F));
    }
    return buf.toString();
  }

  private static char toHexDigit(int n)
  {
    if (n < 0 || n > 15)
      throw new ArgumentError("Nibble value out of range: " + n);
    if (n <= 9)
      return (char) ('0' + n);
    return (char) ('A' + (n - 10));
  }

  private int outputDimension = 2;
  private int byteOrder;
  private bool includeSRID = false;
  private ByteArrayOutputStream byteArrayOS = new ByteArrayOutputStream();
  private OutStream byteArrayOutStream = new OutputStreamOutStream(byteArrayOS);
  // holds output data values
  private byte[] buf = new byte[8];

  /**
   * Creates a writer that writes {@link Geometry}s with
   * output dimension = 2 and BIG_ENDIAN byte order
   */
  WKBWriter() {
    this(2, ByteOrderValues.BIG_ENDIAN);
  }

  /**
   * Creates a writer that writes {@link Geometry}s with
   * the given dimension (2 or 3) for output coordinates
   * and {@link ByteOrderValues#BIG_ENDIAN} byte order.
   * If the input geometry has a small coordinate dimension,
   * coordinates will be padded with {@link Coordinate#NULL_ORDINATE}.
   *
   * @param outputDimension the coordinate dimension to output (2 or 3)
   */
  WKBWriter(int outputDimension) {
    this(outputDimension, ByteOrderValues.BIG_ENDIAN);
  }

  /**
   * Creates a writer that writes {@link Geometry}s with
   * the given dimension (2 or 3) for output coordinates
   * and {@link ByteOrderValues#BIG_ENDIAN} byte order. This constructor also
   * takes a flag to control whether srid information will be
   * written.
   * If the input geometry has a smaller coordinate dimension,
   * coordinates will be padded with {@link Coordinate#NULL_ORDINATE}.
   *
   * @param outputDimension the coordinate dimension to output (2 or 3)
   * @param includeSRID indicates whether SRID should be written
   */
  WKBWriter(int outputDimension, bool includeSRID) {
    this(outputDimension, ByteOrderValues.BIG_ENDIAN, includeSRID);
  }
  
  /**
   * Creates a writer that writes {@link Geometry}s with
   * the given dimension (2 or 3) for output coordinates
   * and byte order
   * If the input geometry has a small coordinate dimension,
   * coordinates will be padded with {@link Coordinate#NULL_ORDINATE}.
   *
   * @param outputDimension the coordinate dimension to output (2 or 3)
   * @param byteOrder the byte ordering to use
   */
  WKBWriter(int outputDimension, int byteOrder) {
      this(outputDimension, byteOrder, false);
  }
  
  /**
   * Creates a writer that writes {@link Geometry}s with
   * the given dimension (2 or 3) for output coordinates
   * and byte order. This constructor also takes a flag to 
   * control whether srid information will be written.
   * If the input geometry has a small coordinate dimension,
   * coordinates will be padded with {@link Coordinate#NULL_ORDINATE}.
   *
   * @param outputDimension the coordinate dimension to output (2 or 3)
   * @param byteOrder the byte ordering to use
   * @param includeSRID indicates whether SRID should be written
   */
  WKBWriter(int outputDimension, int byteOrder, bool includeSRID) {
      this.outputDimension = outputDimension;
      this.byteOrder = byteOrder;
      this.includeSRID = includeSRID;
      
      if (outputDimension < 2 || outputDimension > 3)
        throw new ArgumentError("Output dimension must be 2 or 3");
  }
  
  /**
   * Writes a {@link Geometry} into a byte array.
   *
   * @param geom the geometry to write
   * @return the byte array containing the WKB
   */
  byte[] write(Geometry geom)
  {
    try {
      byteArrayOS.reset();
      write(geom, byteArrayOutStream);
    }
    catch (IOException ex) {
      throw new RuntimeException("Unexpected IO exception: " + ex.getMessage());
    }
    return byteArrayOS.toByteArray();
  }

  /**
   * Writes a {@link Geometry} to an {@link OutStream}.
   *
   * @param geom the geometry to write
   * @param os the out stream to write to
   * @throws IOException if an I/O error occurs
   */
  void write(Geometry geom, OutStream os) throws IOException
  {
    if (geom is Point)
      writePoint((Point) geom, os);
    // LinearRings will be written as LineStrings
    else if (geom is LineString)
      writeLineString((LineString) geom, os);
    else if (geom is Polygon)
      writePolygon((Polygon) geom, os);
    else if (geom is MultiPoint)
      writeGeometryCollection(WKBConstants.wkbMultiPoint, 
          (MultiPoint) geom, os);
    else if (geom is MultiLineString)
      writeGeometryCollection(WKBConstants.wkbMultiLineString,
          (MultiLineString) geom, os);
    else if (geom is MultiPolygon)
      writeGeometryCollection(WKBConstants.wkbMultiPolygon,
          (MultiPolygon) geom, os);
    else if (geom is GeometryCollection)
      writeGeometryCollection(WKBConstants.wkbGeometryCollection,
          (GeometryCollection) geom, os);
    else {
      Assert.shouldNeverReachHere("Unknown Geometry type");
    }
  }

  private void writePoint(Point pt, OutStream os) throws IOException
  {
    writeByteOrder(os);
    writeGeometryType(WKBConstants.wkbPoint, pt, os);
    if (pt.getCoordinateSequence().size() == 0) {
      // write empty point as NaNs (extension to OGC standard)
      writeNaNs(outputDimension, os);
    } else {
      writeCoordinateSequence(pt.getCoordinateSequence(), false, os);
    }
  }

  private void writeLineString(LineString line, OutStream os)
      throws IOException
  {
    writeByteOrder(os);
    writeGeometryType(WKBConstants.wkbLineString, line, os);
    writeCoordinateSequence(line.getCoordinateSequence(), true, os);
  }

  private void writePolygon(Polygon poly, OutStream os) throws IOException
  {
    writeByteOrder(os);
    writeGeometryType(WKBConstants.wkbPolygon, poly, os);
    //--- write empty polygons with no rings (OCG extension)
    if (poly.isEmpty()) {
      writeInt(0, os);
      return;
    }
    writeInt(poly.getNumInteriorRing() + 1, os);
    writeCoordinateSequence(poly.getExteriorRing().getCoordinateSequence(), true, os);
    for (int i = 0; i < poly.getNumInteriorRing(); i++) {
      writeCoordinateSequence(poly.getInteriorRingN(i).getCoordinateSequence(), true,
          os);
    }
  }

  private void writeGeometryCollection(int geometryType, GeometryCollection gc,
      OutStream os) throws IOException
  {
    writeByteOrder(os);
    writeGeometryType(geometryType, gc, os);
    writeInt(gc.getNumGeometries(), os);
    bool originalIncludeSRID = this.includeSRID;
    this.includeSRID = false;
    for (int i = 0; i < gc.getNumGeometries(); i++) {
      write(gc.getGeometryN(i), os);
    }
    this.includeSRID = originalIncludeSRID;
  }

  private void writeByteOrder(OutStream os) throws IOException
  {
    if (byteOrder == ByteOrderValues.LITTLE_ENDIAN)
      buf[0] = WKBConstants.wkbNDR;
    else
      buf[0] = WKBConstants.wkbXDR;
    os.write(buf, 1);
  }

  private void writeGeometryType(int geometryType, Geometry g, OutStream os)
      throws IOException
  {
    int flag3D = (outputDimension == 3) ? 0x80000000 : 0;
    int typeInt = geometryType | flag3D;
    typeInt |= includeSRID ? 0x20000000 : 0;
    writeInt(typeInt, os);
    if (includeSRID) {
        writeInt(g.getSRID(), os);
    }
  }

  private void writeInt(int intValue, OutStream os) throws IOException
  {
    ByteOrderValues.putInt(intValue, buf, byteOrder);
    os.write(buf, 4);
  }

  private void writeCoordinateSequence(CoordinateSequence seq, bool writeSize, OutStream os)
      throws IOException
  {
    if (writeSize)
      writeInt(seq.size(), os);

    for (int i = 0; i < seq.size(); i++) {
      writeCoordinate(seq, i, os);
    }
  }

  private void writeCoordinate(CoordinateSequence seq, int index, OutStream os)
  throws IOException
  {
    ByteOrderValues.putDouble(seq.getX(index), buf, byteOrder);
    os.write(buf, 8);
    ByteOrderValues.putDouble(seq.getY(index), buf, byteOrder);
    os.write(buf, 8);
    
    // only write 3rd dim if caller has requested it for this writer
    if (outputDimension >= 3) {
      // if 3rd dim is requested, only write it if the CoordinateSequence provides it
    	double ordVal = Coordinate.NULL_ORDINATE;
    	if (seq.getDimension() >= 3) {
    		ordVal = seq.getOrdinate(index, 2);
    	}
      ByteOrderValues.putDouble(ordVal, buf, byteOrder);
      os.write(buf, 8);
    }
  }
  
  private void writeNaNs(int numNaNs, OutStream os)
      throws IOException
  {
    for (int i = 0; i < numNaNs; i++) {
      ByteOrderValues.putDouble(double.nan, buf, byteOrder);
      os.write(buf, 8);
    }
  }
}
