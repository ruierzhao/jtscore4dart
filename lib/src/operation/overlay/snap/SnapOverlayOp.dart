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



// import org.locationtech.jts.geom.Geometry;
// import org.locationtech.jts.operation.overlay.OverlayOp;
// import org.locationtech.jts.precision.CommonBitsRemover;

import 'package:jtscore4dart/src/geom/Geometry.dart';
import 'package:jtscore4dart/src/precision/CommonBitsRemover.dart';

import '../OverlayOp.dart';
import 'GeometrySnapper.dart';

/**
 * Performs an overlay operation using snapping and enhanced precision
 * to improve the robustness of the result.
 * This class <i>always</i> uses snapping.  
 * This is less performant than the standard JTS overlay code, 
 * and may even introduce errors which were not present in the original data.
 * For this reason, this class should only be used 
 * if the standard overlay code fails to produce a correct result. 
 *  
 * @author Martin Davis
 * @version 1.7
 */
class SnapOverlayOp
{
  static Geometry overlayOp(Geometry g0, Geometry g1, int opCode)
  {
  	SnapOverlayOp op = new SnapOverlayOp(g0, g1);
  	return op.getResultGeometry(opCode);
  }

  static Geometry intersection(Geometry g0, Geometry g1)
  {
     return overlayOp(g0, g1, OverlayOp.INTERSECTION);
  }

  static Geometry union(Geometry g0, Geometry g1)
  {
     return overlayOp(g0, g1, OverlayOp.UNION);
  }

  static Geometry difference(Geometry g0, Geometry g1)
  {
     return overlayOp(g0, g1, OverlayOp.DIFFERENCE);
  }

  static Geometry symDifference(Geometry g0, Geometry g1)
  {
     return overlayOp(g0, g1, OverlayOp.SYMDIFFERENCE);
  }
  

//  /**private */List<Geometry> geom = new Geometry[2];
 /**private */List<Geometry> geom;
 /**private */late double snapTolerance;

  SnapOverlayOp(Geometry g1, Geometry g2)
  :geom = List.from([g1,g2],growable: false)
  {
    computeSnapTolerance();
  }

 /**private */
 void computeSnapTolerance() 
  {
		snapTolerance = GeometrySnapper.computeOverlaySnapTolerance(geom[0], geom[1]);

		// System.out.println("Snap tol = " + snapTolerance);
	}

  Geometry getResultGeometry(int opCode)
  {
//  	List<Geometry> selfSnapGeom = new List<Geometry> { selfSnap(geom[0]), selfSnap(geom[1])};
    List<Geometry> prepGeom = snap(geom);
    Geometry result = OverlayOp.overlayOp(prepGeom[0], prepGeom[1], opCode);
    return prepareResult(result);	
  }
  
 /**private */Geometry selfSnap(Geometry geom)
  {
    GeometrySnapper snapper0 = new GeometrySnapper(geom);
    Geometry snapGeom = snapper0.snapTo(geom, snapTolerance);
    //System.out.println("Self-snapped: " + snapGeom);
    //System.out.println();
    return snapGeom;
  }
  
 /**private */
 List<Geometry> snap(List<Geometry> geom)
  {
    List<Geometry> remGeom = removeCommonBits(geom);
  	
  	// MD - testing only
//  	List<Geometry> remGeom = geom;
    
    List<Geometry> snapGeom = GeometrySnapper.snap(remGeom[0], remGeom[1], snapTolerance);
    // MD - may want to do this at some point, but it adds cycles
//    checkValid(snapGeom[0]);
//    checkValid(snapGeom[1]);

    /*
    System.out.println("Snapped geoms: ");
    System.out.println(snapGeom[0]);
    System.out.println(snapGeom[1]);
    */
    return snapGeom;
  }

 /**private */Geometry prepareResult(Geometry geom)
  {
    cbr.addCommonBits(geom);
    return geom;
  }

 /**private */CommonBitsRemover cbr = new CommonBitsRemover();

 /**private */List<Geometry> removeCommonBits(List<Geometry> geom)
  {
    // cbr = new CommonBitsRemover();
    cbr.add(geom[0]);
    cbr.add(geom[1]);
    // List<Geometry> remGeom = new Geometry[2];
    // remGeom[0] = cbr.removeCommonBits(geom[0].copy());
    // remGeom[1] = cbr.removeCommonBits(geom[1].copy());
    List<Geometry> remGeom = List.from([
      cbr.removeCommonBits(geom[0].copy()),
      cbr.removeCommonBits(geom[1].copy()),
    ],growable: false);
    return remGeom;
  }
  /*
 /**private */void checkValid(Geometry g)
  {
  	if (! g.isValid()) {
  		System.out.println("Snapped geometry is invalid");
  	}
  }
  */
}
