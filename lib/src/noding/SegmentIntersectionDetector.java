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


import org.locationtech.jts.algorithm.LineIntersector;
import org.locationtech.jts.algorithm.RobustLineIntersector;
import org.locationtech.jts.geom.Coordinate;

/**
 * Detects and records an intersection between two {@link SegmentString}s,
 * if one exists.  Only a single intersection is recorded.
 * This strategy can be configured to search for <b>proper intersections</b>.
 * In this case, the presence of <i>any</i> kind of intersection will still be recorded,
 * but searching will continue until either a proper intersection has been found
 * or no intersections are detected.
 *
 * @version 1.7
 */
class SegmentIntersectionDetector
    implements SegmentIntersector
{
  private LineIntersector li;
  private bool findProper = false;
  private bool findAllTypes = false;
  
  private bool hasIntersection = false;
  private bool hasProperIntersection = false;
  private bool hasNonProperIntersection = false;
  
  private Coordinate intPt = null;
  private List<Coordinate> intSegments = null;

  /**
   * Creates an intersection finder using a {@link RobustLineIntersector}.
   */
  SegmentIntersectionDetector()
  {
    this(new RobustLineIntersector());
  }

  /**
   * Creates an intersection finder using a given LineIntersector.
   *
   * @param li the LineIntersector to use
   */
  SegmentIntersectionDetector(LineIntersector li)
  {
    this.li = li;
  }

  /**
   * Sets whether processing must continue until a proper intersection is found.
   * 
   * @param findProper true if processing should continue until a proper intersection is found
   */
  void setFindProper(bool findProper)
  {
    this.findProper = findProper;
  }
  
  /**
   * Sets whether processing can terminate once any intersection is found.
   * 
   * @param findAllTypes true if processing can terminate once any intersection is found.
   */
  void setFindAllIntersectionTypes(bool findAllTypes)
  {
    this.findAllTypes = findAllTypes;
  }
  
  /**
   * Tests whether an intersection was found.
   * 
   * @return true if an intersection was found
   */
  bool hasIntersection() 
  { 
  	return hasIntersection; 
  }
  
  /**
   * Tests whether a proper intersection was found.
   * 
   * @return true if a proper intersection was found
   */
  bool hasProperIntersection() 
  { 
    return hasProperIntersection; 
  }
  
  /**
   * Tests whether a non-proper intersection was found.
   * 
   * @return true if a non-proper intersection was found
   */
  bool hasNonProperIntersection() 
  { 
    return hasNonProperIntersection; 
  }
  
  /**
   * Gets the computed location of the intersection.
   * Due to round-off, the location may not be exact.
   * 
   * @return the coordinate for the intersection location
   */
  Coordinate getIntersection()  
  {    
  	return intPt;  
  }


  /**
   * Gets the endpoints of the intersecting segments.
   * 
   * @return an array of the segment endpoints (p00, p01, p10, p11)
   */
  List<Coordinate> getIntersectionSegments()
  {
  	return intSegments;
  }
  
  /**
   * This method is called by clients
   * of the {@link SegmentIntersector} class to process
   * intersections for two segments of the {@link SegmentString}s being intersected.
   * Note that some clients (such as <code>MonotoneChain</code>s) may optimize away
   * this call for segment pairs which they have determined do not intersect
   * (e.g. by an disjoint envelope test).
   */
  void processIntersections(
      SegmentString e0,  int segIndex0,
      SegmentString e1,  int segIndex1
      )
  {  	
    // don't bother intersecting a segment with itself
    if (e0 == e1 && segIndex0 == segIndex1) return;
    
    Coordinate p00 = e0.getCoordinate(segIndex0);
    Coordinate p01 = e0.getCoordinate(segIndex0 + 1);
    Coordinate p10 = e1.getCoordinate(segIndex1);
    Coordinate p11 = e1.getCoordinate(segIndex1 + 1);
    
    li.computeIntersection(p00, p01, p10, p11);
//  if (li.hasIntersection() && li.isProper()) Debug.println(li);

    if (li.hasIntersection()) {
			// System.out.println(li);
    	
    	// record intersection info
			hasIntersection = true;
			
			bool isProper = li.isProper();
			if (isProper)
				hasProperIntersection = true;
      if (! isProper)
        hasNonProperIntersection = true;
			
			/**
			 * If this is the kind of intersection we are searching for
			 * OR no location has yet been recorded
			 * save the location data
			 */
			bool saveLocation = true;
			if (findProper && ! isProper) saveLocation = false;
			
			if (intPt == null || saveLocation) {

				// record intersection location (approximate)
				intPt = li.getIntersection(0);

				// record intersecting segments
				intSegments = new Coordinate[4];
				intSegments[0] = p00;
				intSegments[1] = p01;
				intSegments[2] = p10;
				intSegments[3] = p11;
			}
		}
  }
  
  /**
   * Tests whether processing can terminate,
   * because all required information has been obtained
   * (e.g. an intersection of the desired type has been detected).
   * 
   * @return true if processing can terminate
   */
  bool isDone()
  { 
    /**
     * If finding all types, we can stop
     * when both possible types have been found.
     */
    if (findAllTypes) {
      return hasProperIntersection && hasNonProperIntersection;
    }
    
  	/**
  	 * If searching for a proper intersection, only stop if one is found
  	 */
  	if (findProper) {
  		return hasProperIntersection;
  	}
  	return hasIntersection;
  }
}
