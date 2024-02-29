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
// import org.locationtech.jts.geom.CoordinateFilter;
// import org.locationtech.jts.geom.CoordinateSequence;
// import org.locationtech.jts.geom.CoordinateSequenceFilter;
// import org.locationtech.jts.geom.Geometry;

/**
 * Finds the approximate maximum distance from a buffer curve to
 * the originating geometry.
 * This is similar to the Discrete Oriented Hausdorff distance
 * from the buffer curve to the input.
 * <p>
 * The approximate maximum distance is determined by testing
 * all vertices in the buffer curve, as well
 * as midpoints of the curve segments.
 * Due to the way buffer curves are constructed, this
 * should be a very close approximation.
 * 
 * @author mbdavis
 *
 */
class BufferCurveMaximumDistanceFinder 
{
	private Geometry inputGeom;
  private PointPairDistance maxPtDist = new PointPairDistance();

	BufferCurveMaximumDistanceFinder(Geometry inputGeom)
	{
		this.inputGeom = inputGeom;
	}
	
	double findDistance(Geometry bufferCurve)
	{
    computeMaxVertexDistance(bufferCurve);
    computeMaxMidpointDistance(bufferCurve);
    return maxPtDist.getDistance();
	}
	
	PointPairDistance getDistancePoints()
	{
		return maxPtDist;
	}
	private void computeMaxVertexDistance(Geometry curve)
	{
    MaxPointDistanceFilter distFilter = new MaxPointDistanceFilter(inputGeom);
    curve.apply(distFilter);
    maxPtDist.setMaximum(distFilter.getMaxPointDistance());
	}
	
	private void computeMaxMidpointDistance(Geometry curve)
	{
    MaxMidpointDistanceFilter distFilter = new MaxMidpointDistanceFilter(inputGeom);
    curve.apply(distFilter);
    maxPtDist.setMaximum(distFilter.getMaxPointDistance());
	}
	
  static class MaxPointDistanceFilter implements CoordinateFilter {
		private PointPairDistance maxPtDist = new PointPairDistance();
		private PointPairDistance minPtDist = new PointPairDistance();
		private Geometry geom;

		MaxPointDistanceFilter(Geometry geom) {
			this.geom = geom;
		}

		void filter(Coordinate pt) {
			minPtDist.initialize();
			DistanceToPointFinder.computeDistance(geom, pt, minPtDist);
			maxPtDist.setMaximum(minPtDist);
		}

		PointPairDistance getMaxPointDistance() {
			return maxPtDist;
		}
	}

  static class MaxMidpointDistanceFilter 
  	implements CoordinateSequenceFilter 
  	{
		private PointPairDistance maxPtDist = new PointPairDistance();
		private PointPairDistance minPtDist = new PointPairDistance();
		private Geometry geom;

		MaxMidpointDistanceFilter(Geometry geom) {
			this.geom = geom;
		}

		void filter(CoordinateSequence seq, int index) 
		{
			if (index == 0)
				return;
			
			Coordinate p0 = seq.getCoordinate(index - 1);
			Coordinate p1 = seq.getCoordinate(index);
			Coordinate midPt = new Coordinate(
					(p0.x + p1.x)/2,
					(p0.y + p1.y)/2);
			
			minPtDist.initialize();
			DistanceToPointFinder.computeDistance(geom, midPt, minPtDist);
			maxPtDist.setMaximum(minPtDist);
		}

		bool isGeometryChanged() { return false; }
		
		bool isDone() { return false; }
		
		PointPairDistance getMaxPointDistance() {
			return maxPtDist;
		}
	}

}