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


import org.locationtech.jts.geom.LineSegment;

class LocateFailureException 
	extends RuntimeException 
{
	private static String msgWithSpatial(String msg, LineSegment seg) {
		if (seg != null)
			return msg + " [ " + seg + " ]";
		return msg;
	}

	private LineSegment seg = null;

	LocateFailureException(String msg) {
		super(msg);
	}

	LocateFailureException(String msg, LineSegment seg) {
		super(msgWithSpatial(msg, seg));
		this.seg = new LineSegment(seg);
	}

	LocateFailureException(LineSegment seg) {
		super(
				"Locate failed to converge (at edge: "
						+ seg
						+ ").  Possible causes include invalid Subdivision topology or very close sites");
		this.seg = new LineSegment(seg);
	}

	LineSegment getSegment() {
		return seg;
	}

}
