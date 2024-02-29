/*
 * Copyright (c) 2018 Contributors to the Eclipse Foundation
 *
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License 2.0
 * and Eclipse Distribution License v. 1.0 which accompanies this distribution.
 * The Eclipse Public License is available at http://www.eclipse.org/legal/epl-v20.html
 * and the Eclipse Distribution License is available at
 *
 * http://www.eclipse.org/org/documents/edl-v10.php.
 */


import 'package:jtscore4dart/src/geom/Coordinate.dart';

/// Useful utility functions for handling Coordinate objects.
class Coordinates {
  /// Factory method providing access to common Coordinate implementations.
  /// 
  /// @param dimension
  /// @return created coordinate
  static Coordinate create(int dimension)
  {
    return createWithMeasure(dimension, 0);
  }

  /// Factory method providing access to common Coordinate implementations.
  /// 
  /// @param dimension
  /// @param measures
  /// @return created coordinate
  static Coordinate createWithMeasure(int dimension, int measures)
  {
    if (dimension == 2) {
      return CoordinateXY();
    } else if (dimension == 3 && measures == 0) {
      return Coordinate();
    } else if (dimension == 3 && measures == 1) {
      return CoordinateXYM();
    } else if (dimension == 4 && measures == 1) {
      return CoordinateXYZM();
    }
    return Coordinate();
  }
  
  /// Determine dimension based on subclass of {@link Coordinate}.
  /// 
  /// @param coordinate supplied coordinate
  /// @return number of ordinates recorded
  static int dimension(Coordinate coordinate)
  {
    if (coordinate is CoordinateXY) {
      return 2;
    } else if (coordinate is CoordinateXYM) {
      return 3;
    } else if (coordinate is CoordinateXYZM) {
      return 4;      
    } else if (coordinate is Coordinate) {
      return 3;
    } 
    return 3;
  }

  /// Determine number of measures based on subclass of {@link Coordinate}.
  /// 
  /// @param coordinate supplied coordinate
  /// @return number of measures recorded
  static int measures(Coordinate coordinate)
  {
    if (coordinate is CoordinateXY) {
      return 0;
    } else if (coordinate is CoordinateXYM) {
      return 1;
    } else if (coordinate is CoordinateXYZM) {
      return 1;
    } else if (coordinate is Coordinate) {
      return 0;
    } 
    return 0;
  }
    
}