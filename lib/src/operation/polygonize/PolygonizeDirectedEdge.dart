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
// import org.locationtech.jts.planargraph.DirectedEdge;
// import org.locationtech.jts.planargraph.Node;

/**
 * A {@link DirectedEdge} of a {@link PolygonizeGraph}, which represents
 * an edge of a polygon formed by the graph.
 * May be logically deleted from the graph by setting the <code>marked</code> flag.
 *
 * @version 1.7
 */
class PolygonizeDirectedEdge
    extends DirectedEdge
{

  private EdgeRing edgeRing = null;
  private PolygonizeDirectedEdge next = null;
  private long label = -1;

  /**
   * Constructs a directed edge connecting the <code>from</code> node to the
   * <code>to</code> node.
   *
   * @param directionPt
   *                  specifies this DirectedEdge's direction (given by an imaginary
   *                  line from the <code>from</code> node to <code>directionPt</code>)
   * @param edgeDirection
   *                  whether this DirectedEdge's direction is the same as or
   *                  opposite to that of the parent Edge (if any)
   */
  PolygonizeDirectedEdge(Node from, Node to, Coordinate directionPt,
      bool edgeDirection)
  {
    super(from, to, directionPt, edgeDirection);
  }

  /**
   * Returns the identifier attached to this directed edge.
   */
  long getLabel() { return label; }
  /**
   * Attaches an identifier to this directed edge.
   */
  void setLabel(long label) { this.label = label; }
  /**
   * Returns the next directed edge in the EdgeRing that this directed edge is a member
   * of.
   */
  PolygonizeDirectedEdge getNext()  {    return next;  }
  /**
   * Sets the next directed edge in the EdgeRing that this directed edge is a member
   * of.
   */
  void setNext(PolygonizeDirectedEdge next)  {   this.next = next;  }
  /**
   * Returns the ring of directed edges that this directed edge is
   * a member of, or null if the ring has not been set.
   * @see #setRing(EdgeRing)
   */
  bool isInRing() { return edgeRing != null; }
  /**
   * Sets the ring of directed edges that this directed edge is
   * a member of.
   */
  void setRing(EdgeRing edgeRing)
  {
      this.edgeRing = edgeRing;
  }
  /**
   * Gets the {@link EdgeRing} this edge is a member of.
   * 
   * @return an edge ring
   */
  EdgeRing getRing() 
  {
    return this.edgeRing;
  }

}
