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


// import java.util.ArrayList;

// import org.locationtech.jts.geom.Coordinate;
// import org.locationtech.jts.geom.GeometryFactory;
// import org.locationtech.jts.geom.LineString;
// import org.locationtech.jts.geom.PrecisionModel;

import 'package:jtscore4dart/src/geom/Coordinate.dart';
import 'package:jtscore4dart/src/geom/GeometryFactory.dart';
import 'package:jtscore4dart/src/geom/LineString.dart';
import 'package:jtscore4dart/src/geom/PrecisionModel.dart';

import 'package:jtscore4dart/src/patch/ArrayList.dart';
/**
 * A dynamic list of the vertices in a constructed offset curve.
 * Automatically removes adjacent vertices
 * which are closer than a given tolerance.
 * 
 * @author Martin Davis
 *
 */
class OffsetSegmentString 
{
//  /**private */static final List<Coordinate> COORDINATE_ARRAY_TYPE = new Coordinate[0];

//  /**private */List ptList;
 /**private */List<Coordinate> ptList;
 /**private */PrecisionModel? precisionModel = null;
  
  /**
   * The distance below which two adjacent points on the curve 
   * are considered to be coincident.
   * This is chosen to be a small fraction of the offset distance.
   */
 /**private */double minimimVertexDistance = 0.0;

  OffsetSegmentString():ptList = [];


  void setPrecisionModel(PrecisionModel precisionModel)
  {
  	this.precisionModel = precisionModel;
  }
  
  void setMinimumVertexDistance(double minimimVertexDistance)
  {
  	this.minimimVertexDistance = minimimVertexDistance;
  }
  
  void addPt(Coordinate pt)
  {
    Coordinate bufPt = new Coordinate.fromAnother(pt);
    precisionModel!.makePreciseFromCoord(bufPt);
    // don't add duplicate (or near-duplicate) points
    if (isRedundant(bufPt)) {
      return;
    }
    ptList.add(bufPt);
//System.out.println(bufPt);
  }
  
  void addPts(List<Coordinate> pt, bool isForward)
  {
    if (isForward) {
      for (int i = 0; i < pt.length; i++) {
        addPt(pt[i]);
      }
    }
    else {
      for (int i = pt.length - 1; i >= 0; i--) {
        addPt(pt[i]);
      }     
    }
  }
  
  /**
   * Tests whether the given point is redundant
   * relative to the previous
   * point in the list (up to tolerance).
   * 
   * @param pt
   * @return true if the point is redundant
   */
 /**private */bool isRedundant(Coordinate pt)
  {
    if (ptList.size() < 1) {
      return false;
    }
    Coordinate lastPt =  ptList.get(ptList.size() - 1);
    double ptDist = pt.distance(lastPt);
    if (ptDist < minimimVertexDistance) {
      return true;
    }
    return false;
  }
  
  void closeRing()
  {
    if (ptList.size() < 1) return;
    Coordinate startPt = new Coordinate.fromAnother( ptList.get(0));
    Coordinate lastPt = ptList.get(ptList.size() - 1);
    if (startPt.equals(lastPt)) return;
    ptList.add(startPt);
  }

  void reverse()
  {
    
  }
  
  List<Coordinate> getCoordinates()
  {
    /*
     // check that points are a ring - add the startpoint again if they are not
   if (ptList.size() > 1) {
      Coordinate start  = (Coordinate) ptList.get(0);
      Coordinate end    = (Coordinate) ptList.get(ptList.size() - 1);
      if (! start.equals(end) ) addPt(start);
    }
    */
    List<Coordinate> coord =  ptList.toArray();
    return coord;
  }

  @override
  String toString()
  {
  	GeometryFactory fact = new GeometryFactory();
  	LineString line = fact.createLineString(getCoordinates());
  	return line.toString();
  }
}
