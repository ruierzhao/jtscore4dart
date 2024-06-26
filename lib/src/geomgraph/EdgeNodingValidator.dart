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
// import java.util.Iterable;
// import java.util.Iterator;

// import org.locationtech.jts.geom.TopologyException;
// import org.locationtech.jts.noding.BasicSegmentString;
// import org.locationtech.jts.noding.FastNodingValidator;

import 'package:jtscore4dart/src/noding/BasicSegmentString.dart';
import 'package:jtscore4dart/src/noding/FastNodingValidator.dart';

import 'Edge.dart';

/**
 * Validates that a collection of {@link Edge}s is correctly noded.
 * Throws an appropriate exception if an noding error is found.
 * Uses {@link FastNodingValidator} to perform the validation.
 * 
 * @version 1.7
 * 
 * @see FastNodingValidator
 */
class EdgeNodingValidator 
{  
	/**
   * Checks whether the supplied {@link Edge}s
   * are correctly noded.  
   * Throws a  {@link TopologyException} if they are not.
   * 
   * @param edges a collection of Edges.
   * @throws TopologyException if the SegmentStrings are not correctly noded
   *
   */
	static void checkValid(Iterable edges)
	{
		EdgeNodingValidator validator = new EdgeNodingValidator(edges);
		validator.checkValid_();
	}
	
  static Iterable toSegmentStrings(Iterable edges)
  {
    // convert Edges to SegmentStrings
    List segStrings = [];
    for (Iterator i = edges.iterator; i.moveNext(); ) {
      Edge e =  i.current;
      segStrings.add(new BasicSegmentString(e.getCoordinates(), e));
    }
    return segStrings;
  }

 /**private */
 FastNodingValidator nv;

  /**
   * Creates a new validator for the given collection of {@link Edge}s.
   * 
   * @param edges a collection of Edges.
   */
  EdgeNodingValidator(Iterable edges)
    :nv = new FastNodingValidator(toSegmentStrings(edges));

  /**
   * Checks whether the supplied edges
   * are correctly noded.  Throws an exception if they are not.
   * 
   * @throws TopologyException if the SegmentStrings are not correctly noded
   *
   */
  void checkValid_()
  {
    nv.checkValid();
  }

}
