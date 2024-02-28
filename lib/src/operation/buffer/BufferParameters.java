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


import org.locationtech.jts.algorithm.Angle;

/**
 * A value class containing the parameters which 
 * specify how a buffer should be constructed.
 * <p>
 * The parameters allow control over:
 * <ul>
 * <li>Quadrant segments (accuracy of approximation for circular arcs)
 * <li>End Cap style
 * <li>Join style
 * <li>Mitre limit
 * <li>whether the buffer is single-sided
 * </ul>
 * 
 * @author Martin Davis
 *
 */
class BufferParameters 
{
  /**
   * Specifies a round line buffer end cap style.
   */
  static final int CAP_ROUND = 1;
  /**
   * Specifies a flat line buffer end cap style.
   */
  static final int CAP_FLAT = 2;
  /**
   * Specifies a square line buffer end cap style.
   */
  static final int CAP_SQUARE = 3;
  
  /**
   * Specifies a round join style.
   */
  static final int JOIN_ROUND = 1;
  /**
   * Specifies a mitre join style.
   */
  static final int JOIN_MITRE = 2;
  /**
   * Specifies a bevel join style.
   */
  static final int JOIN_BEVEL = 3;

  /**
   * The default number of facets into which to divide a fillet of 90 degrees.
   * A value of 8 gives less than 2% max error in the buffer distance.
   * For a max error of &lt; 1%, use QS = 12.
   * For a max error of &lt; 0.1%, use QS = 18.
   */
  static final int DEFAULT_QUADRANT_SEGMENTS = 8;

  /**
   * The default mitre limit
   * Allows fairly pointy mitres.
   */
  static final double DEFAULT_MITRE_LIMIT = 5.0;
  
  /**
   * The default simplify factor
   * Provides an accuracy of about 1%, which matches the accuracy of the default Quadrant Segments parameter.
   */
  static final double DEFAULT_SIMPLIFY_FACTOR = 0.01;
  

  private int quadrantSegments = DEFAULT_QUADRANT_SEGMENTS;
  private int endCapStyle = CAP_ROUND;
  private int joinStyle = JOIN_ROUND;
  private double mitreLimit = DEFAULT_MITRE_LIMIT;
  private bool isSingleSided = false;
  private double simplifyFactor = DEFAULT_SIMPLIFY_FACTOR;
  
  /**
   * Creates a default set of parameters
   *
   */
  BufferParameters() {
  }

  /**
   * Creates a set of parameters with the
   * given quadrantSegments value.
   * 
   * @param quadrantSegments the number of quadrant segments to use
   */
  BufferParameters(int quadrantSegments) 
  {
    setQuadrantSegments(quadrantSegments);
  }

  /**
   * Creates a set of parameters with the
   * given quadrantSegments and endCapStyle values.
   * 
   * @param quadrantSegments the number of quadrant segments to use
   * @param endCapStyle the end cap style to use
   */
  BufferParameters(int quadrantSegments,
      int endCapStyle) 
  {
    setQuadrantSegments(quadrantSegments);
    setEndCapStyle(endCapStyle);
  }

  /**
   * Creates a set of parameters with the
   * given parameter values.
   * 
   * @param quadrantSegments the number of quadrant segments to use
   * @param endCapStyle the end cap style to use
   * @param joinStyle the join style to use
   * @param mitreLimit the mitre limit to use
   */
  BufferParameters(int quadrantSegments,
      int endCapStyle,
      int joinStyle,
      double mitreLimit) 
  {
    setQuadrantSegments(quadrantSegments);
    setEndCapStyle(endCapStyle);
    setJoinStyle(joinStyle);
    setMitreLimit(mitreLimit);
  }

  /**
   * Gets the number of quadrant segments which will be used
   * to approximate angle fillets in round endcaps and joins.
   * 
   * @return the number of quadrant segments
   */
  int getQuadrantSegments()
  {
    return quadrantSegments;
  }
  
  /**
   * Sets the number of line segments in a quarter-circle
   * used to approximate angle fillets in round endcaps and joins.
   * The value should be at least 1.
   * <p>
   * This determines the
   * error in the approximation to the true buffer curve.
   * The default value of 8 gives less than 2% error in the buffer distance.
   * For a error of &lt; 1%, use QS = 12.
   * For a error of &lt; 0.1%, use QS = 18.
   * The error is always less than the buffer distance 
   * (in other words, the computed buffer curve is always inside the true
   * curve).
   * 
   * @param quadSegs the number of segments in a fillet for a circle quadrant
   */
  void setQuadrantSegments(int quadSegs)
  {
    quadrantSegments = quadSegs;
  }

  /**
   * Computes the maximum distance error due to a given level
   * of approximation to a true arc.
   * 
   * @param quadSegs the number of segments used to approximate a quarter-circle
   * @return the error of approximation
   */
  static double bufferDistanceError(int quadSegs)
  {
    double alpha = Angle.PI_OVER_2 / quadSegs;
    return 1 - Math.cos(alpha / 2.0);
  }
  
  /**
   * Gets the end cap style.
   * 
   * @return the end cap style code
   */
  int getEndCapStyle()
  {
    return endCapStyle;
  }
  
  /**
   * Specifies the end cap style of the generated buffer.
   * The styles supported are {@link #CAP_ROUND}, {@link #CAP_FLAT}, and {@link #CAP_SQUARE}.
   * The default is {@link #CAP_ROUND}.
   *
   * @param endCapStyle the code for the end cap style
   */
  void setEndCapStyle(int endCapStyle)
  {
    this.endCapStyle = endCapStyle;
  }
  
  /**
   * Gets the join style.
   * 
   * @return the join style code
   */
  int getJoinStyle()
  {
    return joinStyle;
  }
  
  /**
   * Sets the join style for outside (reflex) corners between line segments.
   * The styles supported are {@link #JOIN_ROUND},
   * {@link #JOIN_MITRE} and {link JOIN_BEVEL}.
   * The default is {@link #JOIN_ROUND}.
   * 
   * @param joinStyle the code for the join style
   */
  void setJoinStyle(int joinStyle)
  {
    this.joinStyle = joinStyle;
  }
  
  /**
   * Gets the mitre ratio limit.
   * 
   * @return the limit value
   */
  double getMitreLimit()
  {
    return mitreLimit;
  }
  
  /**
   * Sets the limit on the mitre ratio used for very sharp corners.
   * The mitre ratio is the ratio of the distance from the corner
   * to the end of the mitred offset corner.
   * When two line segments meet at a sharp angle, 
   * a miter join will extend far beyond the original geometry.
   * (and in the extreme case will be infinitely far.)
   * To prevent unreasonable geometry, the mitre limit 
   * allows controlling the maximum length of the join corner.
   * Corners with a ratio which exceed the limit will be beveled.
   *
   * @param mitreLimit the mitre ratio limit
   */
  void setMitreLimit(double mitreLimit)
  {
    this.mitreLimit = mitreLimit;
  }

  /**
   * Sets whether the computed buffer should be single-sided.
   * A single-sided buffer is constructed on only one side of each input line.
   * <p>
   * The side used is determined by the sign of the buffer distance:
   * <ul>
   * <li>a positive distance indicates the left-hand side
   * <li>a negative distance indicates the right-hand side
   * </ul>
   * The single-sided buffer of point geometries is 
   * the same as the regular buffer.
   * <p>
   * The End Cap Style for single-sided buffers is 
   * always ignored, 
   * and forced to the equivalent of <tt>CAP_FLAT</tt>. 
   * 
   * @param isSingleSided true if a single-sided buffer should be constructed
   */
  void setSingleSided(bool isSingleSided)
  {
    this.isSingleSided = isSingleSided;
  }

  /**
   * Tests whether the buffer is to be generated on a single side only.
   * 
   * @return true if the generated buffer is to be single-sided
   */
  bool isSingleSided() {
    return isSingleSided;
  }

  /**
   * Gets the simplify factor.
   * 
   * @return the simplify factor
   */
  double getSimplifyFactor() {
    return simplifyFactor;
  }
  
  /**
   * Sets the factor used to determine the simplify distance tolerance
   * for input simplification.
   * Simplifying can increase the performance of computing buffers.
   * Generally the simplify factor should be greater than 0.
   * Values between 0.01 and .1 produce relatively good accuracy for the generate buffer.
   * Larger values sacrifice accuracy in return for performance.
   * 
   * @param simplifyFactor a value greater than or equal to zero.
   */
  void setSimplifyFactor(double simplifyFactor)
  {
    this.simplifyFactor = simplifyFactor < 0 ? 0 : simplifyFactor;
  }
  
  BufferParameters copy() {
    BufferParameters bp = new BufferParameters();
    bp.quadrantSegments = quadrantSegments;
    bp.endCapStyle = endCapStyle;
    bp.joinStyle = joinStyle;
    bp.mitreLimit = mitreLimit;
    return bp;
  }
}
