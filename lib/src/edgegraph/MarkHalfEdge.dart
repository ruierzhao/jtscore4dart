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

import 'package:jtscore4dart/src/geom/Coordinate.dart';

import 'HalfEdge.dart';

/**
 * A {@link HalfEdge} which supports
 * marking edges with a bool flag.
 * Useful for algorithms which perform graph traversals.
 * 
 * @author Martin Davis
 *
 */
class MarkHalfEdge extends HalfEdge
{
  /**
   * Tests whether the given edge is marked.
   * 
   * @param e the edge to test
   * @return true if the edge is marked
   */
  static bool isMarkedS(HalfEdge e) 
  {
    return ( e as MarkHalfEdge).isMarked();
  }
  
  /**
   * Marks the given edge.
   * 
   * @param e the edge to mark
   */
  static void markS(HalfEdge e)
  {
    ( e as MarkHalfEdge).mark();
  }

  /**
   * Sets the mark for the given edge to a bool value.
   * 
   * @param e the edge to set
   * @param isMarked the mark value
   */
  static void setMarkS(HalfEdge e, bool isMarked)
  {
    ( e as MarkHalfEdge).setMark(isMarked);
  }

  /**
   * Sets the mark for the given edge pair to a bool value.
   * 
   * @param e an edge of the pair to update
   * @param isMarked the mark value to set
   */
  static void setMarkBoth(HalfEdge e, bool isMarked)
  {
    (e as MarkHalfEdge).setMark(isMarked);
    ( e.sym() as MarkHalfEdge).setMark(isMarked);
  }

  /**
   * Marks the edges in a pair.
   * 
   * @param e an edge of the pair to mark
   */
  static void markBoth(HalfEdge e) {
    ( e as MarkHalfEdge).mark();
    (e.sym() as MarkHalfEdge).mark();
  }
  
 /**private */bool _isMarked = false;

  /**
   * Creates a new marked edge.
   * 
   * @param orig the coordinate of the edge origin
   */
  MarkHalfEdge(Coordinate orig) :
    super(orig);

  /**
   * Tests whether this edge is marked.
   * 
   * @return true if this edge is marked
   */
  bool isMarked()
  {
    return _isMarked ;
  }
  
  /**
   * Marks this edge.
   * 
   */
  void mark()
  {
    _isMarked = true;
  }

  /**
   * Sets the value of the mark on this edge.
   * 
   * @param isMarked the mark value to set
   */
  void setMark(bool isMarked)
  {
    this._isMarked = isMarked;
  }


}
