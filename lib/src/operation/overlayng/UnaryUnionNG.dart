/*
 * Copyright (c) 2019 Martin Davis.
 *
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License 2.0
 * and Eclipse Distribution License v. 1.0 which accompanies this distribution.
 * The Eclipse Public License is available at http://www.eclipse.org/legal/epl-v20.html
 * and the Eclipse Distribution License is available at
 *
 * http://www.eclipse.org/org/documents/edl-v10.php.
 */


// import org.locationtech.jts.operation.overlayng.OverlayNG.UNION;

// import java.util.Collection;

// import org.locationtech.jts.geom.Geometry;
// import org.locationtech.jts.geom.GeometryFactory;
// import org.locationtech.jts.geom.PrecisionModel;
// import org.locationtech.jts.operation.union.UnaryUnionOp;
// import org.locationtech.jts.operation.union.UnionStrategy;

import 'package:jtscore4dart/src/geom/Geometry.dart';
import 'package:jtscore4dart/src/geom/GeometryFactory.dart';
import 'package:jtscore4dart/src/geom/PrecisionModel.dart';
import 'package:jtscore4dart/src/operation/union/UnaryUnionOp.dart';
import 'package:jtscore4dart/src/operation/union/UnionStrategy.dart';

import 'OverlayNG.dart';
import 'OverlayUtil.dart';

/**
 * Unions a geometry or collection of geometries in an
 * efficient way, using {@link OverlayNG}
 * to ensure robust computation.
 * <p>
 * This class is most useful for performing UnaryUnion using 
 * a fixed-precision model. 
 * For unary union using floating precision,  
 * {@link OverlayNGRobust#union(Geometry)} should be used.
 * 
 * @author Martin Davis
 * @see OverlayNGRobust
 *
 */
class UnaryUnionNG {
  
  /**
   * Unions a geometry (which is often a collection)
   * using a given precision model.
   * 
   * @param geom the geometry to union
   * @param pm the precision model to use
   * @return the union of the geometry
   */
  static Geometry union(Geometry geom, PrecisionModel pm) {
    UnaryUnionOp op = new UnaryUnionOp(geom);
    op.setUnionFunction( createUnionStrategy(pm) );
    return op.union_();
  }
  
  /**
   * Unions a collection of geometries
   * using a given precision model.
   * 
   * @param geoms the collection of geometries to union
   * @param pm the precision model to use
   * @return the union of the geometries
   */
  // static Geometry unionAll(Iterable<Geometry> geoms, PrecisionModel pm) {
  //   UnaryUnionOp op = new UnaryUnionOp.all(geoms);
  //   op.setUnionFunction( createUnionStrategy(pm) );
  //   return op.union_();
  // }
  
  /**
   * Unions a collection of geometries
   * using a given precision model.
   * 
   * @param geoms the collection of geometries to union
   * @param geomFact the geometry factory to use
   * @param pm the precision model to use
   * @return the union of the geometries
   */
  static Geometry unionAll(Iterable<Geometry> geoms,  PrecisionModel pm, [GeometryFactory? geomFact]) {
    UnaryUnionOp op = new UnaryUnionOp.all(geoms, geomFact);
    op.setUnionFunction( createUnionStrategy(pm) );
    return op.union_();
  }
  
 /**private */static UnionStrategy createUnionStrategy(PrecisionModel pm) {
    UnionStrategy unionSRFun = _(pm);
    return unionSRFun;
  }
  
 /**private */UnaryUnionNG() {
    // no instantiation for now
  }
}


class _ implements UnionStrategy {
  final PrecisionModel pm;

  _(this.pm);
  @override
    Geometry union(Geometry g0, Geometry g1) {
    return OverlayNG.overlayWithPM(g0, g1, OverlayNG.UNION, pm);
  }

  @override
  bool isFloatingPrecision() {
      return OverlayUtil.isFloating(pm);
  }
  
}