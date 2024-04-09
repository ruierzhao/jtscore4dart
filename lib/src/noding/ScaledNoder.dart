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
// import org.locationtech.jts.geom.CoordinateArrays;

import 'package:jtscore4dart/src/geom/Coordinate.dart';
import 'package:jtscore4dart/src/geom/CoordinateArrays.dart';

import 'NodedSegmentString.dart';
import 'Noder.dart';
import 'SegmentString.dart';

/**
 * Wraps a {@link Noder} and transforms its input
 * into the integer domain.
 * This is intended for use with Snap-Rounding noders,
 * which typically are only intended to work in the integer domain.
 * Offsets can be provided to increase the number of digits of available precision.
 * <p>
 * Clients should be aware that rescaling can involve loss of precision,
 * which can cause zero-length line segments to be created.
 * These in turn can cause problems when used to build a planar graph.
 * This situation should be checked for and collapsed segments removed if necessary.
 *
 * @version 1.7
 */
class ScaledNoder
    implements Noder
{
 /**private */Noder noder;
 /**private */double scaleFactor;
 /**private */double offsetX;
 /**private */double offsetY;
 /**private */bool isScaled = false;

  // ScaledNoder(Noder noder, double scaleFactor) {
  //   this(noder, scaleFactor, 0, 0);
  // }

  ScaledNoder(this.noder, this.scaleFactor, [this.offsetX=0, this.offsetY=0]) {
    this.isScaled = ! isIntegerPrecision();
  }

  bool isIntegerPrecision() { return this.scaleFactor == 1.0; }

  @override
  Iterable<SegmentString> getNodedSubstrings()
  {
    Iterable<SegmentString> splitSS = noder.getNodedSubstrings();
    if (isScaled) _rescale(splitSS);
    return splitSS;
  }

  @override
  void computeNodes(Iterable inputSegStrings)
  {
    Iterable intSegStrings = inputSegStrings;
    if (isScaled) {
      intSegStrings = _scale(inputSegStrings);
    }
    noder.computeNodes(intSegStrings as Iterable<NodedSegmentString>);
  }

 /**private */Iterable _scale(Iterable segStrings)
  {
    // List nodedSegmentStrings = new ArrayList(segStrings.size());
    List nodedSegmentStrings = [];
    for (Iterator i = segStrings.iterator; i.moveNext(); ) {
      SegmentString ss =  i.current as SegmentString;
      nodedSegmentStrings.add(new NodedSegmentString(scale(ss.getCoordinates()), ss.getData()));
    }
    return nodedSegmentStrings;
  }

 /**private */List<Coordinate> scale(List<Coordinate> pts)
  {
    // List<Coordinate> roundPts = new Coordinate[pts.length];
    List<Coordinate> roundPts = List.filled(pts.length, Coordinate.fromAnother(pts[0]));
    for (int i = 0; i < pts.length; i++) {
      roundPts[i] = new Coordinate(
          ((pts[i].x - offsetX) * scaleFactor).roundToDouble(),
          ((pts[i].y - offsetY) * scaleFactor).roundToDouble(),
          pts[i].getZ()
        );
    }
    List<Coordinate> roundPtsNoDup = CoordinateArrays.removeRepeatedPoints(roundPts);
    return roundPtsNoDup;
  }

  //private double scale(double val) { return (double) math.round(val * scaleFactor); }

 /**private */void _rescale(Iterable<SegmentString> segStrings)
  {
    for (Iterator i = segStrings.iterator; i.moveNext(); ) {
      SegmentString ss = i.current as SegmentString;
      rescale(ss.getCoordinates());
    }
  }

 /**private */void rescale(List<Coordinate> pts)
  {
    for (int i = 0; i < pts.length; i++) {
      pts[i].x = pts[i].x / scaleFactor + offsetX;
      pts[i].y = pts[i].y / scaleFactor + offsetY;
    }
    /*
    if (pts.length == 2 && pts[0].equals2D(pts[1])) {
      System.out.println(pts);
    }
    */
  }

  //private double rescale(double val) { return val / scaleFactor; }
}
