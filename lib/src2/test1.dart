class DiscreteFrechetDistance {

/**
   * Computes the Discrete Fréchet Distance between two {@link Geometry}s
   * using a {@code Cartesian} distance computation function.
   *
   * @param g0 the 1st geometry
   * @param g1 the 2nd geometry
   * @return the cartesian distance between {#g0} and {#g1}
   */
  static double distance(Geometry g0, Geometry g1) {

    DiscreteFrechetDistance dist = new DiscreteFrechetDistance(g0, g1);
    return dist.distance();
  }
  
  private final Geometry g0;
  private final Geometry g1;
  private double distance() {
    Coordinate[] coords0 = g0.getCoordinates();
    Coordinate[] coords1 = g1.getCoordinates();

    MatrixStorage distances = createMatrixStorage(coords0.length, coords1.length);
    int[] diagonal = bresenhamDiagonal(coords0.length, coords1.length);

    HashMap<Double, int[]> distanceToPair = new HashMap<>();
    computeCoordinateDistances(coords0, coords1, diagonal, distances, distanceToPair);
    ptDist = computeFrechet(coords0, coords1, diagonal, distances, distanceToPair);

    return ptDist.getDistance();
  }
