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


/**
 * Various constant strings associated with GML format.
 */
final class GMLConstants{
	
	  // Namespace constants
	  static const String GML_NAMESPACE = "http://www.opengis.net/gml";
	  static const String GML_PREFIX = "gml";

	  // Source Coordinate System
	  static const String GML_ATTR_SRSNAME = "srsName";

	  // GML associative types
	  static const String GML_GEOMETRY_MEMBER = "geometryMember";
	  static const String GML_POINT_MEMBER = "pointMember";
	  static const String GML_POLYGON_MEMBER = "polygonMember";
	  static const String GML_LINESTRING_MEMBER = "lineStringMember";
	  static const String GML_OUTER_BOUNDARY_IS = "outerBoundaryIs";
	  static const String GML_INNER_BOUNDARY_IS = "innerBoundaryIs";

	  // Primitive Geometries
	  static const String GML_POINT = "Point";
	  static const String GML_LINESTRING = "LineString";
	  static const String GML_LINEARRING = "LinearRing";
	  static const String GML_POLYGON = "Polygon";
	  static const String GML_BOX = "Box";

	  // Aggregate Geometries
	  static const String GML_MULTI_GEOMETRY = "MultiGeometry";
	  static const String GML_MULTI_POINT = "MultiPoint";
	  static const String GML_MULTI_LINESTRING = "MultiLineString";
	  static const String GML_MULTI_POLYGON = "MultiPolygon";

	  // Coordinates
	  static const String GML_COORDINATES = "coordinates";
	  static const String GML_COORD = "coord";
	  static const String GML_COORD_X = "X";
	  static const String GML_COORD_Y = "Y";
	  static const String GML_COORD_Z = "Z";
}
