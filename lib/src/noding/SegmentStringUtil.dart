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
// import java.util.Collection;
// import java.util.Iterator;
// import java.util.List;

// import org.locationtech.jts.geom.Coordinate;
// import org.locationtech.jts.geom.Geometry;
// import org.locationtech.jts.geom.GeometryFactory;
// import org.locationtech.jts.geom.LineString;
// import org.locationtech.jts.geom.MultiLineString;
// import org.locationtech.jts.geom.util.LinearComponentExtracter;

import 'package:jtscore4dart/src/geom/Coordinate.dart';
import 'package:jtscore4dart/src/geom/Geometry.dart';
import 'package:jtscore4dart/src/geom/GeometryFactory.dart';
import 'package:jtscore4dart/src/geom/LineString.dart';
import 'package:jtscore4dart/src/geom/util/LinearComponentExtracter.dart';

import 'BasicSegmentString.dart';
import 'NodedSegmentString.dart';
import 'SegmentString.dart';

/**
 * Utility methods for processing {@link SegmentString}s.
 * 
 * @author Martin Davis
 *
 */
class SegmentStringUtil {
  /**
   * Extracts all linear components from a given {@link Geometry}
   * to {@link SegmentString}s.
   * The SegmentString data item is set to be the source Geometry.
   * 
   * @param geom the geometry to extract from
   * @return a List of SegmentStrings
   */
  static List extractSegmentStrings(Geometry geom) {
    return extractNodedSegmentStrings(geom);
  }

  /**
   * Extracts all linear components from a given {@link Geometry}
   * to {@link NodedSegmentString}s.
   * The SegmentString data item is set to be the source Geometry.
   * 
   * @param geom the geometry to extract from
   * @return a List of NodedSegmentStrings
   */
  static List extractNodedSegmentStrings(Geometry geom) {
    List segStr = [];
    List lines = LinearComponentExtracter.getLines(geom);
    for (Iterator i = lines.iterator; i.moveNext();) {
      LineString line = i.current;
      List<Coordinate> pts = line.getCoordinates();
      segStr.add(new NodedSegmentString(pts, geom));
    }
    return segStr;
  }

  /**
   * Extracts all linear components from a given {@link Geometry}
   * to {@link BasicSegmentString}s.
   * The SegmentString data item is set to be the source Geometry.
   * 
   * @param geom the geometry to extract from
   * @return a List of BasicSegmentStrings
   */
  static List extractBasicSegmentStrings(Geometry geom) {
    List segStr = [];
    List lines = LinearComponentExtracter.getLines(geom);
    for (Iterator i = lines.iterator; i.moveNext();) {
      LineString line = i.current;
      List<Coordinate> pts = line.getCoordinates();
      segStr.add(new BasicSegmentString(pts, geom));
    }
    return segStr;
  }

  /**
   * Converts a collection of {@link SegmentString}s into a {@link Geometry}.
   * The geometry will be either a {@link LineString} or a {@link MultiLineString} (possibly empty).
   *
   * @param segStrings a collection of SegmentStrings
   * @return a LineString or MultiLineString
   */
  static Geometry toGeometry(
      Iterable<SegmentString> segStrings, GeometryFactory geomFact) {
    // List<LineString> lines = new LineString[segStrings.size()];
    // int index = 0;
    // for (Iterator i = segStrings.iterator; i.moveNext(); ) {
    //   SegmentString ss = i.current;
    //   LineString line = geomFact.createLineString(ss.getCoordinates());
    //   lines[index++] = line;
    // }
    var _segStrings = segStrings.toList(growable: false);
    List<LineString> lines = List.generate(segStrings.length, (index) {
      return geomFact.createLineString(_segStrings[index].getCoordinates());
    });

    if (lines.length == 1) return lines[0];
    return geomFact.createMultiLineString(lines);
  }

  // static String toString(List segStrings)
  static String getString(List segStrings) {
    StringBuffer buf = new StringBuffer();
    for (Iterator i = segStrings.iterator; i.moveNext();) {
      SegmentString segStr = i.current;
      buf.write(segStr.toString());
      buf.write("\n");
    }
    return buf.toString();
  }
}
