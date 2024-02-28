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


import org.locationtech.jts.geom.Coordinate;

/**
 * Contains a pair of points and the distance between them.
 * Provides methods to update with a new point pair with
 * either maximum or minimum distance.
 */
class PointPairDistance {

  private List<Coordinate> pt = { new Coordinate(), new Coordinate() };
  private double distance = Double.NaN;
  private bool isNull = true;

  PointPairDistance()
  {
  }

  void initialize() { isNull = true; }

  void initialize(Coordinate p0, Coordinate p1)
  {
    pt[0].setCoordinate(p0);
    pt[1].setCoordinate(p1);
    distance = p0.distance(p1);
    isNull = false;
  }

  /**
   * Initializes the points, avoiding recomputing the distance.
   * @param p0
   * @param p1
   * @param distance the distance between p0 and p1
   */
  private void initialize(Coordinate p0, Coordinate p1, double distance)
  {
    pt[0].setCoordinate(p0);
    pt[1].setCoordinate(p1);
    this.distance = distance;
    isNull = false;
  }

  double getDistance() { return distance; }

  List<Coordinate> getCoordinates() { return pt; }

  Coordinate getCoordinate(int i) { return pt[i]; }

  void setMaximum(PointPairDistance ptDist)
  {
    setMaximum(ptDist.pt[0], ptDist.pt[1]);
  }

  void setMaximum(Coordinate p0, Coordinate p1)
  {
    if (isNull) {
      initialize(p0, p1);
      return;
    }
    double dist = p0.distance(p1);
    if (dist > distance)
      initialize(p0, p1, dist);
  }

  void setMinimum(PointPairDistance ptDist)
  {
    setMinimum(ptDist.pt[0], ptDist.pt[1]);
  }

  void setMinimum(Coordinate p0, Coordinate p1)
  {
    if (isNull) {
      initialize(p0, p1);
      return;
    }
    double dist = p0.distance(p1);
    if (dist < distance)
      initialize(p0, p1, dist);
  }
}
