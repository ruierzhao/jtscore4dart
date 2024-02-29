/*
 * Copyright (c) 2016 Martin Davis.
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
// import org.locationtech.jts.geom.CoordinateSequence;
// import org.locationtech.jts.geom.Envelope;

/**
 * A CoordinateSequence wrapper which 
 * projects 3D coordinates into one of the
 * three Cartesian axis planes,
 * using the standard orthonormal projection
 * (i.e. simply selecting the appropriate ordinates into the XY ordinates).
 * The projected data is represented as 2D coordinates.
 * 
 * @author mdavis
 *
 */
class AxisPlaneCoordinateSequence implements CoordinateSequence {

	/**
	 * Creates a wrapper projecting to the XY plane.
	 * 
	 * @param seq the sequence to be projected
	 * @return a sequence which projects coordinates
	 */
	static CoordinateSequence projectToXY(CoordinateSequence seq)
	{
		/**
		 * This is just a no-op, but return a wrapper
		 * to allow better testing
		 */
		return new AxisPlaneCoordinateSequence(seq, XY_INDEX);
	}
	
	/**
	 * Creates a wrapper projecting to the XZ plane.
	 * 
	 * @param seq the sequence to be projected
	 * @return a sequence which projects coordinates
	 */
	static CoordinateSequence projectToXZ(CoordinateSequence seq)
	{
		return new AxisPlaneCoordinateSequence(seq, XZ_INDEX);
	}
	
	/**
	 * Creates a wrapper projecting to the YZ plane.
	 * 
	 * @param seq the sequence to be projected
	 * @return a sequence which projects coordinates
	 */
	static CoordinateSequence projectToYZ(CoordinateSequence seq)
	{
		return new AxisPlaneCoordinateSequence(seq, YZ_INDEX);
	}
	
	private static final int[] XY_INDEX = new int[] { 0,1 };
	private static final int[] XZ_INDEX = new int[] { 0,2 };
	private static final int[] YZ_INDEX = new int[] { 1,2 };
	
	private CoordinateSequence seq;
	private int[] indexMap;
	
	private AxisPlaneCoordinateSequence(CoordinateSequence seq, int[] indexMap) {
		this.seq = seq;
		this.indexMap = indexMap;
	}

	int getDimension() {
		return 2;
	}

	Coordinate getCoordinate(int i) {
		return getCoordinateCopy(i);
	}

	Coordinate getCoordinateCopy(int i) {
		return new Coordinate(getX(i), getY(i), getZ(i));
	}

	void getCoordinate(int index, Coordinate coord) {
		coord.x = getOrdinate(index, X);
		coord.y = getOrdinate(index, Y);
		coord.setZ(getOrdinate(index, Z));
	}

	double getX(int index) {
		return getOrdinate(index, X);
	}

	double getY(int index) {
		return getOrdinate(index, Y);
	}

	double getZ(int index) {
		return getOrdinate(index, Z);
	}

	double getOrdinate(int index, int ordinateIndex) {
		// Z ord is always 0
		if (ordinateIndex > 1) return 0;
		return seq.getOrdinate(index, indexMap[ordinateIndex]);
	}

	int size() {
		return seq.size();
	}

	void setOrdinate(int index, int ordinateIndex, double value) {
		throw new UnsupportedOperationException();
	}

	List<Coordinate> toCoordinateArray() {
		throw new UnsupportedOperationException();
	}

	Envelope expandEnvelope(Envelope env) {
		throw new UnsupportedOperationException();
	}

	Object clone()
	{
		throw new UnsupportedOperationException();		
	}
	
	AxisPlaneCoordinateSequence copy()
	{
		throw new UnsupportedOperationException();		
	}
}
