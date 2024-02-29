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
// import java.util.Arrays;
// import java.util.List;

// import org.locationtech.jts.algorithm.PointLocation;
// import org.locationtech.jts.geom.Coordinate;
// import org.locationtech.jts.geom.Geometry;
// import org.locationtech.jts.geom.GeometryFactory;
// import org.locationtech.jts.geom.LineSegment;
// import org.locationtech.jts.geom.LinearRing;
// import org.locationtech.jts.geom.Polygon;


/**
 * Models a triangle formed from {@link QuadEdge}s in a {@link QuadEdgeSubdivision}
 * which forms a triangulation. The class provides methods to access the
 * topological and geometric properties of the triangle and its neighbours in
 * the triangulation. Triangle vertices are ordered in CCW orientation in the
 * structure.
 * <p>
 * QuadEdgeTriangles support having an external data attribute attached to them.
 * Alternatively, this class can be subclassed and attributes can 
 * be defined in the subclass.  Subclasses will need to define 
 * their own <tt>BuilderVisitor</tt> class
 * and <tt>createOn</tt> method.
 * 
 * @author Martin Davis
 * @version 1.0
 */
class QuadEdgeTriangle 
{
	/**
	 * Creates {@link QuadEdgeTriangle}s for all facets of a 
	 * {@link QuadEdgeSubdivision} representing a triangulation.
	 * The <tt>data</tt> attributes of the {@link QuadEdge}s in the subdivision
	 * will be set to point to the triangle which contains that edge.
	 * This allows tracing the neighbour triangles of any given triangle.
	 * 
	 * @param subdiv
	 * 				the QuadEdgeSubdivision to create the triangles on.
	 * @return a List of the created QuadEdgeTriangles
	 */
	static List createOn(QuadEdgeSubdivision subdiv)
	{
		QuadEdgeTriangleBuilderVisitor visitor = new QuadEdgeTriangleBuilderVisitor();
		subdiv.visitTriangles(visitor, false);
		return visitor.getTriangles();
	}

	/**
	 * Tests whether the point pt is contained in the triangle defined by 3
	 * {@link Vertex}es.
	 * 
	 * @param tri
	 *          an array containing at least 3 Vertexes
	 * @param pt
	 *          the point to test
	 * @return true if the point is contained in the triangle
	 */
	static bool contains(Vertex[] tri, Coordinate pt) {
		List<Coordinate> ring = new List<Coordinate> { tri[0].getCoordinate(),
				tri[1].getCoordinate(), tri[2].getCoordinate(), tri[0].getCoordinate() };
		return PointLocation.isInRing(pt, ring);
	}

	/**
	 * Tests whether the point pt is contained in the triangle defined by 3
	 * {@link QuadEdge}es.
	 * 
	 * @param tri
	 *          an array containing at least 3 QuadEdges
	 * @param pt
	 *          the point to test
	 * @return true if the point is contained in the triangle
	 */
	static bool contains(QuadEdge[] tri, Coordinate pt) {
		List<Coordinate> ring = new List<Coordinate> { tri[0].orig().getCoordinate(),
				tri[1].orig().getCoordinate(), tri[2].orig().getCoordinate(),
				tri[0].orig().getCoordinate() };
		return PointLocation.isInRing(pt, ring);
	}

	static Geometry toPolygon(Vertex[] v) {
		List<Coordinate> ringPts = new List<Coordinate> { v[0].getCoordinate(),
				v[1].getCoordinate(), v[2].getCoordinate(), v[0].getCoordinate() };
		GeometryFactory fact = new GeometryFactory();
		LinearRing ring = fact.createLinearRing(ringPts);
		Polygon tri = fact.createPolygon(ring);
		return tri;
	}

	static Geometry toPolygon(QuadEdge[] e) {
		List<Coordinate> ringPts = new List<Coordinate> { e[0].orig().getCoordinate(),
				e[1].orig().getCoordinate(), e[2].orig().getCoordinate(),
				e[0].orig().getCoordinate() };
		GeometryFactory fact = new GeometryFactory();
		LinearRing ring = fact.createLinearRing(ringPts);
		Polygon tri = fact.createPolygon(ring);
		return tri;
	}

	/**
	 * Finds the next index around the triangle. Index may be an edge or vertex
	 * index.
	 * 
	 * @param index
	 * @return the next index
	 */
	static int nextIndex(int index) {
		return index = (index + 1) % 3;
	}

	private QuadEdge[] edge;
	private Object data;

	/**
	 * Creates a new triangle from the given edges.
	 * 
	 * @param edge an array of the edges of the triangle in CCW order
	 */
	QuadEdgeTriangle(QuadEdge[] edge) {
		this.edge = (QuadEdge[]) Arrays.copyOf(edge, edge.length);
		// link the quadedges back to this triangle
		for (int i = 0; i < 3; i++) {
			edge[i].setData(this);
		}
	}

  /**
   * Sets the external data value for this triangle.
   * 
   * @param data an object containing external data
   */
  void setData(Object data) {
      this.data = data;
  }
  
  /**
   * Gets the external data value for this triangle.
   * 
   * @return the data object
   */
  Object getData() {
      return data;
  }

	void kill() {
		edge = null;
	}

	bool isLive() {
		return edge != null;
	}

	QuadEdge[] getEdges() {
		return edge;
	}

	QuadEdge getEdge(int i) {
		return edge[i];
	}

	Vertex getVertex(int i) {
		return edge[i].orig();
	}

	/**
	 * Gets the vertices for this triangle.
	 * 
	 * @return a new array containing the triangle vertices
	 */
	Vertex[] getVertices() {
		Vertex[] vert = new Vertex[3];
		for (int i = 0; i < 3; i++) {
			vert[i] = getVertex(i);
		}
		return vert;
	}

	Coordinate getCoordinate(int i) {
		return edge[i].orig().getCoordinate();
	}

	/**
	 * Gets the index for the given edge of this triangle
	 * 
	 * @param e
	 *          a QuadEdge
	 * @return the index of the edge in this triangle
	 * or -1 if the edge is not an edge of this triangle
	 */
	int getEdgeIndex(QuadEdge e) {
		for (int i = 0; i < 3; i++) {
			if (edge[i] == e)
				return i;
		}
		return -1;
	}

	/**
	 * Gets the index for the edge that starts at vertex v.
	 * 
	 * @param v
	 *          the vertex to find the edge for
	 * @return the index of the edge starting at the vertex
	 * or -1 if the vertex is not in the triangle
	 */
	int getEdgeIndex(Vertex v) {
		for (int i = 0; i < 3; i++) {
			if (edge[i].orig() == v)
				return i;
		}
		return -1;
	}

	void getEdgeSegment(int i, LineSegment seg) {
		seg.p0 = edge[i].orig().getCoordinate();
		int nexti = (i + 1) % 3;
		seg.p1 = edge[nexti].orig().getCoordinate();
	}

	List<Coordinate> getCoordinates() {
		List<Coordinate> pts = new Coordinate[4];
		for (int i = 0; i < 3; i++) {
			pts[i] = edge[i].orig().getCoordinate();
		}
		pts[3] = new Coordinate(pts[0]);
		return pts;
	}

	bool contains(Coordinate pt) {
		List<Coordinate> ring = getCoordinates();
		return PointLocation.isInRing(pt, ring);
	}

	Polygon getGeometry(GeometryFactory fact) {
		LinearRing ring = fact.createLinearRing(getCoordinates());
		Polygon tri = fact.createPolygon(ring);
		return tri;
	}

	String toString() {
		return getGeometry(new GeometryFactory()).toString();
	}

	/**
	 * Tests whether this triangle is adjacent to the outside of the subdivision.
	 * 
	 * @return true if the triangle is adjacent to the subdivision exterior
	 */
	bool isBorder() {
		for (int i = 0; i < 3; i++) {
			if (getAdjacentTriangleAcrossEdge(i) == null)
				return true;
		}
		return false;
	}

	bool isBorder(int i) {
		return getAdjacentTriangleAcrossEdge(i) == null;
	}

	QuadEdgeTriangle getAdjacentTriangleAcrossEdge(int edgeIndex) {
		return (QuadEdgeTriangle) getEdge(edgeIndex).sym().getData();
	}

	int getAdjacentTriangleEdgeIndex(int i) {
		return getAdjacentTriangleAcrossEdge(i).getEdgeIndex(getEdge(i).sym());
	}

	/**
	 * Gets the triangles which are adjacent (include) to a 
	 * given vertex of this triangle.
	 * 
	 * @param vertexIndex the vertex to query
	 * @return a list of the vertex-adjacent triangles
	 */
	List getTrianglesAdjacentToVertex(int vertexIndex) {
		// Assert: isVertex
		List adjTris = new ArrayList();

		QuadEdge start = getEdge(vertexIndex);
		QuadEdge qe = start;
		do {
			QuadEdgeTriangle adjTri = (QuadEdgeTriangle) qe.getData();
			if (adjTri != null) {
				adjTris.add(adjTri);
			}
			qe = qe.oNext();
		} while (qe != start);

		return adjTris;

	}

	/**
	 * Gets the neighbours of this triangle. If there is no neighbour triangle,
	 * the array element is <code>null</code>
	 * 
	 * @return an array containing the 3 neighbours of this triangle
	 */
	QuadEdgeTriangle[] getNeighbours() {
		QuadEdgeTriangle[] neigh = new QuadEdgeTriangle[3];
		for (int i = 0; i < 3; i++) {
			neigh[i] = (QuadEdgeTriangle) getEdge(i).sym().getData();
		}
		return neigh;
	}

	private static class QuadEdgeTriangleBuilderVisitor implements TriangleVisitor {
		private List triangles = new ArrayList();

		QuadEdgeTriangleBuilderVisitor() {
		}

		void visit(QuadEdge[] edges) {
			triangles.add(new QuadEdgeTriangle(edges));
		}

		List getTriangles() {
			return triangles;
		}
	}
}


