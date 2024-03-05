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



// import java.util.ArrayList;
// import java.util.List;

// import org.locationtech.jts.geom.Geometry;
// import org.locationtech.jts.geom.GeometryFactory;
// import org.locationtech.jts.geom.util.GeometryCombiner;


/**
 * Experimental code to union MultiPolygons
 * with processing limited to the elements which actually interact.
 * 
 * Not currently used, since it doesn't seem to offer much of a performance advantage.
 * 
 * @author mbdavis
 *
 */
class UnionInteracting 
{
	static Geometry union(Geometry g0, Geometry g1)
	{
		UnionInteracting uue = new UnionInteracting(g0, g1);
		return uue.union();
	}

	
	private GeometryFactory geomFactory;
	
	private Geometry g0;
	private Geometry g1;
	
	private bool[] interacts0;
	private bool[] interacts1;
	
	UnionInteracting(Geometry g0, Geometry g1)
	{
		this.g0 = g0;
		this.g1 = g1;
		geomFactory = g0.getFactory();
		interacts0 = new bool[g0.getNumGeometries()];
		interacts1 = new bool[g1.getNumGeometries()];
	}
	
	Geometry union()
	{
		computeInteracting();
		
		// check for all interacting or none interacting!
		
		Geometry int0 = extractElements(g0, interacts0, true);
		Geometry int1 = extractElements(g1, interacts1, true);
		
//		System.out.println(int0);
//		System.out.println(int1);
/*
		if (int0.isEmpty() || int1.isEmpty()) {
			System.out.println("found empty!");
//			computeInteracting();
		}
		*/
//		if (! int0.isValid()) {
			//System.out.println(int0);
			//throw new RuntimeException("invalid geom!");
//		}
		
		Geometry union = int0.union(int1);
		
		Geometry disjoint0 = extractElements(g0, interacts0, false);
		Geometry disjoint1 = extractElements(g1, interacts1, false);
		
  	Geometry overallUnion = GeometryCombiner.combine(union, disjoint0, disjoint1);
  	
  	return overallUnion;

	}

	private void computeInteracting()
	{
		for (int i = 0; i < g0.getNumGeometries(); i++) {
			Geometry elem = g0.getGeometryN(i);
			interacts0[i] = computeInteracting(elem);
		}
	}
	
	private bool computeInteracting(Geometry elem0)
	{
		bool interactsWithAny = false;
		for (int i = 0; i < g1.getNumGeometries(); i++) {
			Geometry elem1 = g1.getGeometryN(i);
			bool interacts = elem1.getEnvelopeInternal().intersects(elem0.getEnvelopeInternal());
			if (interacts) interacts1[i] = true;
			if (interacts) 
				interactsWithAny = true;
		}
		return interactsWithAny;
	}
	
 /**private */Geometry extractElements(Geometry geom, 
  		bool[] interacts, bool isInteracting)
  {
  	List extractedGeoms = new ArrayList();
  	for (int i = 0; i < geom.getNumGeometries(); i++) { 
  		Geometry elem = geom.getGeometryN(i);
  		if (interacts[i] == isInteracting)
  			extractedGeoms.add(elem);
  	}
  	return geomFactory.buildGeometry(extractedGeoms);
  }

	
}
