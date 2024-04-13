/*
 * Copyright (c) 2020 Martin Davis, and others
 *
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License 2.0
 * and Eclipse Distribution License v. 1.0 which accompanies this distribution.
 * The Eclipse Public License is available at http://www.eclipse.org/legal/epl-v20.html
 * and the Eclipse Distribution License is available at
 *
 * http://www.eclipse.org/org/documents/edl-v10.php.
 */


// import java.util.Collection;


import 'FastNodingValidator.dart';
import 'Noder.dart';
import 'SegmentString.dart';

/**
 * A wrapper for {@link Noder}s which validates
 * the output arrangement is correctly noded.
 * An arrangement of line segments is fully noded if 
 * there is no line segment 
 * which has another segment intersecting its interior.
 * If the noding is not correct, a {@link org.locationtech.jts.geom.TopologyException} is thrown
 * with details of the first invalid location found.
 * 
 * @author mdavis
 * 
 * @see FastNodingValidator
 *
 */
class ValidatingNoder implements Noder {

 /**private */final Noder noder;
 /**private */Iterable<SegmentString>? nodedSS;
  
  /**
   * Creates a noding validator wrapping the given Noder
   * 
   * @param noder the Noder to validate
   */
  ValidatingNoder( this.noder);
  
  /**
   * Checks whether the output of the wrapped noder is fully noded.
   * Throws an exception if it is not.
   * 
   * @throws org.locationtech.jts.geom.TopologyException
   */
  /// TODO: @ruier edit. 取消编译器警告。。
  // @SuppressWarnings("unchecked")
  @override
  // void computeNodes(@SuppressWarnings("rawtypes") Collection segStrings) {
  void computeNodes(Iterable<SegmentString> segStrings) {
    noder.computeNodes(segStrings);
    nodedSS = noder.getNodedSubstrings(); 
    validate();
  }

 /**private */void validate() {
    FastNodingValidator nv = new FastNodingValidator( nodedSS! );
    nv.checkValid();
  }

  @override
  Iterable<SegmentString> getNodedSubstrings() {
    return nodedSS!;
  }

}
