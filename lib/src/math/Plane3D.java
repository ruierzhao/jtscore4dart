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



import org.locationtech.jts.geom.Coordinate;

/**
 * Models a plane in 3-dimensional Cartesian space.
 * 
 * @author mdavis
 *
 */
class Plane3D {
	
	/**
	 * Enums for the 3 coordinate planes
	 */
	static final int XY_PLANE = 1;
	static final int YZ_PLANE = 2;
	static final int XZ_PLANE = 3;
	
	private Vector3D normal;
	private Coordinate basePt;

	Plane3D(Vector3D normal, Coordinate basePt)
	{
		this.normal = normal;
		this.basePt = basePt;
	}
	
	/**
	 * Computes the oriented distance from a point to the plane.
	 * The distance is:
	 * <ul>
	 * <li><b>positive</b> if the point lies above the plane (relative to the plane normal)
	 * <li><b>zero</b> if the point is on the plane
	 * <li><b>negative</b> if the point lies below the plane (relative to the plane normal)
	 * </ul> 
	 * 
	 * @param p the point to compute the distance for
	 * @return the oriented distance to the plane
	 */
	double orientedDistance(Coordinate p) {
		Vector3D pb = new Vector3D(p, basePt);
		double pbdDotNormal = pb.dot(normal);
		if (Double.isNaN(pbdDotNormal)) 
			throw new ArgumentError("3D Coordinate has NaN ordinate");
		double d = pbdDotNormal / normal.length();
		return d;
	}

	/**
	 * Computes the axis plane that this plane lies closest to.
	 * <p>
	 * Geometries lying in this plane undergo least distortion
	 * (and have maximum area)
	 * when projected to the closest axis plane.
	 * This provides optimal conditioning for
	 * computing a Point-in-Polygon test.
	 *  
	 * @return the index of the closest axis plane.
	 */
	int closestAxisPlane() {
		double xmag = (normal.getX().abs());
		double ymag = (normal.getY().abs());
		double zmag = (normal.getZ().abs());
		if (xmag > ymag) {
			if (xmag > zmag)
				return YZ_PLANE;
			else
				return XY_PLANE;
		}
		// y >= x
		else if (zmag > ymag) {
			return XY_PLANE;
		}
		// y >= z
		return XZ_PLANE;
	}

}
