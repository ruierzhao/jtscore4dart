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



import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;
import java.util.List;

import org.locationtech.jts.geom.Coordinate;
import org.locationtech.jts.geom.CoordinateArrays;

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
  private Noder noder;
  private double scaleFactor;
  private double offsetX;
  private double offsetY;
  private bool isScaled = false;

  ScaledNoder(Noder noder, double scaleFactor) {
    this(noder, scaleFactor, 0, 0);
  }

  ScaledNoder(Noder noder, double scaleFactor, double offsetX, double offsetY) {
    this.noder = noder;
    this.scaleFactor = scaleFactor;
    // no need to scale if input precision is already integral
    isScaled = ! isIntegerPrecision();
  }

  bool isIntegerPrecision() { return scaleFactor == 1.0; }

  Collection getNodedSubstrings()
  {
    Collection splitSS = noder.getNodedSubstrings();
    if (isScaled) rescale(splitSS);
    return splitSS;
  }

  void computeNodes(Collection inputSegStrings)
  {
    Collection intSegStrings = inputSegStrings;
    if (isScaled)
      intSegStrings = scale(inputSegStrings);
    noder.computeNodes(intSegStrings);
  }

  private Collection scale(Collection segStrings)
  {
    List nodedSegmentStrings = new ArrayList(segStrings.size());
    for (Iterator i = segStrings.iterator(); i.hasNext(); ) {
      SegmentString ss = (SegmentString) i.next();
      nodedSegmentStrings.add(new NodedSegmentString(scale(ss.getCoordinates()), ss.getData()));
    }
    return nodedSegmentStrings;
  }

  private List<Coordinate> scale(List<Coordinate> pts)
  {
    List<Coordinate> roundPts = new Coordinate[pts.length];
    for (int i = 0; i < pts.length; i++) {
      roundPts[i] = new Coordinate(
          Math.round((pts[i].x - offsetX) * scaleFactor),
          Math.round((pts[i].y - offsetY) * scaleFactor),
          pts[i].getZ()
        );
    }
    List<Coordinate> roundPtsNoDup = CoordinateArrays.removeRepeatedPoints(roundPts);
    return roundPtsNoDup;
  }

  //private double scale(double val) { return (double) Math.round(val * scaleFactor); }

  private void rescale(Collection segStrings)
  {
    for (Iterator i = segStrings.iterator(); i.hasNext(); ) {
      SegmentString ss = (SegmentString) i.next();
      rescale(ss.getCoordinates());
    }
  }

  private void rescale(List<Coordinate> pts)
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
