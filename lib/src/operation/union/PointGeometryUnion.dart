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



// import java.util.Set;
// import java.util.TreeSet;

// import org.locationtech.jts.algorithm.PointLocator;
// import org.locationtech.jts.geom.Coordinate;
// import org.locationtech.jts.geom.CoordinateArrays;
// import org.locationtech.jts.geom.Geometry;
// import org.locationtech.jts.geom.GeometryFactory;
// import org.locationtech.jts.geom.Location;
// import org.locationtech.jts.geom.Point;
// import org.locationtech.jts.geom.Puntal;
// import org.locationtech.jts.geom.util.GeometryCombiner;

import 'package:jtscore4dart/geometry.dart';
import 'package:jtscore4dart/src/algorithm/PointLocator.dart';
import 'package:jtscore4dart/src/geom/Location.dart';
import 'package:jtscore4dart/src/geom/Puntal.dart';
import 'package:jtscore4dart/src/geom/util/GeometryCombiner.dart';

/**
 * Computes the union of a {@link Puntal} geometry with 
 * another arbitrary {@link Geometry}.
 * Does not copy any component geometries.
 * 
 * @author mbdavis
 *
 */
class PointGeometryUnion 
{
  /// TODO: @ruier edit.
	// static Geometry union(Puntal pointGeom, Geometry otherGeom)
	static Geometry of(Puntal pointGeom, Geometry otherGeom)
	{
		PointGeometryUnion unioner = new PointGeometryUnion(pointGeom, otherGeom);
		return unioner.union();
	}
	
	// /**private */ Geometry pointGeom;
	/**private */ Puntal pointGeom;
	/**private */ Geometry otherGeom;
	/**private */ GeometryFactory geomFact;
	
	PointGeometryUnion(this.pointGeom, this.otherGeom)
	:
		geomFact = otherGeom.getFactory();
	
	Geometry union()
	{
		PointLocator locater = new PointLocator();
		// use a set to eliminate duplicates, as required for union
		Set<Coordinate> exteriorCoords = new TreeSet();
		
		for (int i =0 ; i < pointGeom.getNumGeometries(); i++) {
			Point point = (Point) pointGeom.getGeometryN(i);
			Coordinate coord = point.getCoordinate();
			int loc = locater.locate(coord, otherGeom);
			if (loc == Location.EXTERIOR) {
			  exteriorCoords.add(coord);
			}
		}
		
		// if no points are in exterior, return the other geom
		if (exteriorCoords.isEmpty) {
		  return otherGeom;
		}
		
		// make a puntal geometry of appropriate size
		Geometry ptComp;
		List<Coordinate> coords = CoordinateArrays.toCoordinateArray(exteriorCoords);
		if (coords.length == 1) {
			ptComp = geomFact.createPoint(coords[0]);
		}
		else {
			ptComp = geomFact.createMultiPointFromCoords(coords);
		}
		
		// add point component to the other geometry
		return GeometryCombiner.combine(ptComp, otherGeom);
	}
}
