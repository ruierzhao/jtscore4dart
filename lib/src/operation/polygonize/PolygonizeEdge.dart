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


// import org.locationtech.jts.geom.LineString;
// import org.locationtech.jts.planargraph.Edge;

/**
 * An edge of a polygonization graph.
 *
 * @version 1.7
 */
class PolygonizeEdge
    extends Edge
{
 /**private */LineString line;

  PolygonizeEdge(LineString line)
  {
    this.line = line;
  }
  LineString getLine() { return line; }
}
