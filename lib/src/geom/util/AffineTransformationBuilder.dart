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



// import org.locationtech.jts.geom.Coordinate;
// import org.locationtech.jts.math.Matrix;

import 'package:jtscore4dart/src/geom/Coordinate.dart';
import 'package:jtscore4dart/src/math/Matrix.dart';

import 'AffineTransformation.dart';

/**
 * Builds an {@link AffineTransformation} defined by a set of control vectors. 
 * A control vector consists of a source point and a destination point, 
 * which is the image of the source point under the desired transformation.
 * <p>
 * A transformation is well-defined 
 * by a set of three control vectors 
 * if and only if the source points are not collinear. 
 * (In particular, the degenerate situation
 * where two or more source points are identical will not produce a well-defined transformation).
 * A well-defined transformation exists and is unique.
 * If the control vectors are not well-defined, the system of equations
 * defining the transformation matrix entries is not solvable,
 * and no transformation can be determined.
 * <p>
 * No such restriction applies to the destination points.
 * However, if the destination points are collinear or non-unique,
 * a non-invertible transformations will be generated.
 * <p>
 * This technique of recovering a transformation
 * from its effect on known points is used in the Bilinear Interpolated Triangulation
 * algorithm for warping planar surfaces.
 *
 * @author Martin Davis
 */
class AffineTransformationBuilder
{
 /**private */Coordinate src0;
 /**private */Coordinate src1;
 /**private */Coordinate src2;
 /**private */Coordinate dest0;
 /**private */Coordinate dest1;
 /**private */Coordinate dest2;
  
  // the matrix entries for the transformation
 /**private */late double m00, m01, m02, m10, m11, m12;
  
 
  /**
   * Constructs a new builder for
   * the transformation defined by the given 
   * set of control point mappings.
   * 
   * @param src0 a control point
   * @param src1 a control point
   * @param src2 a control point
   * @param dest0 the image of control point 0 under the required transformation
   * @param dest1 the image of control point 1 under the required transformation
   * @param dest2 the image of control point 2 under the required transformation
   */
  AffineTransformationBuilder(
    this.src0,
    this.src1,
    this.src2,
    this.dest0,
    this.dest1,
    this.dest2);
    
  /**
   * Computes the {@link AffineTransformation}
   * determined by the control point mappings,
   * or <code>null</code> if the control vectors do not determine a well-defined transformation.
   * 
   * @return an affine transformation, or null if the control vectors do not determine a well-defined transformation
   */
  AffineTransformation getTransformation()
  {
  	// compute full 3-point transformation
    bool isSolvable = compute();
    if (isSolvable) {
      return new AffineTransformation(m00, m01, m02, m10, m11, m12);
    }
    return null;
  }
    
  /**
   * Computes the transformation matrix by 
   * solving the two systems of linear equations
   * defined by the control point mappings,
   * if this is possible.
   * 
   * @return true if the transformation matrix is solvable
   */
 /**private */bool compute()
  {
    // double[] bx = new double[] { dest0.x, dest1.x, dest2.x };
    List<double> bx = List.from([dest0.x, dest1.x, dest2.x],growable: false);
    List<double> row0 = solve(bx);
    if (row0 == null) return false;
    m00 = row0[0];
    m01 = row0[1];
    m02 = row0[2];
    
    // List<double> by = List.from([dest0.y, dest1.y, dest2.y],growable: false);
    List<double> by = List.from([dest0.y, dest1.y, dest2.y],growable: false);
    List<double> row1 = solve(by);
    if (row1 == null) return false;
    m10 = row1[0];
    m11 = row1[1];
    m12 = row1[2];
    return true;
  }

  /**
   * Solves the transformation matrix system of linear equations
   * for the given right-hand side vector.
   * 
   * @param b the vector for the right-hand side of the system
   * @return the solution vector, or <code>null</code> if no solution could be determined
   */
 /**private */List<double> solve(List<double> b)
  {
    List<List<double>> a =  [
        [ src0.x, src0.y, 1],
        [ src1.x, src1.y, 1],
        [ src2.x, src2.y, 1]
    ];
    // double[][] a = new double[][] {
    //     { src0.x, src0.y, 1 },
    //     { src1.x, src1.y, 1},
    //     { src2.x, src2.y, 1}
    // };
    return Matrix.solve(a, b);
  }
}
