/*
 * Copyright (c) 2016 Vivid Solutions, and others.
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

// import org.locationtech.jts.geom.Geometry;
// import org.locationtech.jts.geom.GeometryFactory;
// import org.locationtech.jts.geom.LineString;
// import org.locationtech.jts.geom.PrecisionModel;
// import org.locationtech.jts.geom.util.LinearComponentExtracter;
// import org.locationtech.jts.noding.NodedSegmentString;
// import org.locationtech.jts.noding.Noder;
// import org.locationtech.jts.noding.NodingValidator;
// import org.locationtech.jts.noding.SegmentString;

import 'package:jtscore4dart/src/geom/Geometry.dart';
import 'package:jtscore4dart/src/geom/GeometryFactory.dart';
import 'package:jtscore4dart/src/geom/LineString.dart';
import 'package:jtscore4dart/src/geom/PrecisionModel.dart';
import 'package:jtscore4dart/src/geom/util/LinearComponentExtracter.dart';
import 'package:jtscore4dart/src/noding/NodedSegmentString.dart';
import 'package:jtscore4dart/src/noding/Noder.dart';
import 'package:jtscore4dart/src/noding/NodingValidator.dart';
import 'package:jtscore4dart/src/noding/SegmentString.dart';

import 'SnapRoundingNoder.dart';

/**
 * Nodes the linework in a list of {@link Geometry}s using Snap-Rounding
 * to a given {@link PrecisionModel}.
 * <p>
 * Input coordinates do not need to be rounded to the 
 * precision model.  
 * All output coordinates are rounded to the precision model.
 * <p>
 * This class does <b>not</b> dissolve the output linework,
 * so there may be duplicate linestrings in the output.  
 * Subsequent processing (e.g. polygonization) may require
 * the linework to be unique.  Using <code>UnaryUnion</code> is one way
 * to do this (although this is an inefficient approach).
 * 
 */
class GeometryNoder {
  /**private */ GeometryFactory? geomFact;
  /**private */ PrecisionModel pm;
  /**private */ bool isValidityChecked = false;

  /**
   * Creates a new noder which snap-rounds to a grid specified
   * by the given {@link PrecisionModel}.
   * 
   * @param pm the precision model for the grid to snap-round to
   */
  GeometryNoder(this.pm);

  /**
   * Sets whether noding validity is checked after noding is performed.
   * 
   * @param isValidityChecked
   */
  void setValidate(bool isValidityChecked) {
    this.isValidityChecked = isValidityChecked;
  }

  /**
   * Nodes the linework of a set of Geometrys using SnapRounding. 
   * 
   * @param geoms a Collection of Geometrys of any type
   * @return a List of LineStrings representing the noded linework of the input
   */
  List node(Iterable geoms) {
    // get geometry factory
    Iterator geom0It = geoms.iterator;
    geom0It.moveNext();
    Geometry geom0 = geom0It.current;
    geomFact = geom0.getFactory();

    List<SegmentString> segStrings = _toSegmentStrings(_extractLines(geoms));
    Noder sr = new SnapRoundingNoder(pm);
    sr.computeNodes(segStrings);
    Iterable nodedLines = sr.getNodedSubstrings();

    //TODO: improve this to check for full snap-rounded correctness
    if (isValidityChecked) {
      NodingValidator nv = new NodingValidator(nodedLines);
      nv.checkValid();
    }

    return _toLineStrings(nodedLines);
  }

  List _toLineStrings(Iterable segStrings) {
    List lines = [];
    for (Iterator it = segStrings.iterator; it.moveNext();) {
      SegmentString ss = it.current;
      // skip collapsed lines
      if (ss.size() < 2) {
        continue;
      }
      lines.add(geomFact!.createLineString(ss.getCoordinates()));
    }
    return lines;
  }

  List<LineString> _extractLines(Iterable geoms) {
    List<LineString> lines = [];
    LinearComponentExtracter lce = new LinearComponentExtracter(lines);
    for (Iterator it = geoms.iterator; it.moveNext();) {
      Geometry geom = it.current;
      geom.applyGeometryComonent(lce);
    }
    return lines;
  }

  List<NodedSegmentString> _toSegmentStrings(Iterable lines) {
    List<NodedSegmentString> segStrings = [];
    for (Iterator it = lines.iterator; it.moveNext();) {
      LineString line = it.current;
      segStrings.add(new NodedSegmentString(line.getCoordinates(), null));
    }
    return segStrings;
  }
}
