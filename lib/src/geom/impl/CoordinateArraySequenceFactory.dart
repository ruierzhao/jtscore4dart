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

// import java.io.Serializable;

// import org.locationtech.jts.geom.Coordinate;
// import org.locationtech.jts.geom.CoordinateSequence;
// import org.locationtech.jts.geom.CoordinateSequenceFactory;

import 'CoordinateArraySequence.dart';
import '../Coordinate.dart';
import '../CoordinateSequence.dart';
import '../CoordinateSequenceFactory.dart';

/// Creates {@link CoordinateSequence}s represented as an array of {@link Coordinate}s.
///
/// @version 1.7
final class CoordinateArraySequenceFactory
    implements CoordinateSequenceFactory {
  ///**private */static final int serialVersionUID = -4099577099607551657L;
  static final CoordinateArraySequenceFactory _instanceObject = CoordinateArraySequenceFactory();

  /**private */ CoordinateArraySequenceFactory();

  /**private */ Object readResolve() {
    // http://www.javaworld.com/javaworld/javatips/jw-javatip122.html
    return CoordinateArraySequenceFactory.instance();
  }

  /// Returns the singleton instance of {@link CoordinateArraySequenceFactory}
  static CoordinateArraySequenceFactory instance() {
    return _instanceObject;
  }

  /// Returns a {@link CoordinateArraySequence} based on the given array (the array is
  /// not copied).
  ///
  /// @param coordinates
  ///            the coordinates, which may not be null nor contain null
  ///            elements
  @override
  CoordinateSequence create(List<Coordinate> coordinates) {
    return CoordinateArraySequence(coordinates);
  }

  /// @see org.locationtech.jts.geom.CoordinateSequenceFactory#create(org.locationtech.jts.geom.CoordinateSequence)
  @override
  CoordinateSequence createFromCoordSeq(CoordinateSequence coordSeq) {
    return CoordinateArraySequence.fromAnother(coordSeq);
  }

  /// The created sequence dimension is clamped to be &lt;= 3.
  ///
  /// @see org.locationtech.jts.geom.CoordinateSequenceFactory#create(int, int)
  ///
  @override
  CoordinateSequence createBySize(int size, int dimension) {
    if (dimension > 3) {
      dimension = 3;
    }
    //throw new ArgumentError("dimension must be <= 3");

    // handle bogus dimension
    if (dimension < 2) {
      dimension = 2;
    }

    return CoordinateArraySequence.init(size, dimension);
  }

  @override
  CoordinateSequence createWithSize(int size, int dimension, [int? measures]) {
    if (measures == null) {
      return createBySize(size, dimension);
    }

    int spatial = dimension - measures;

    if (measures > 1) {
      measures = 1; // clip measures
      //throw new ArgumentError("measures must be <= 1");
    }
    if ((spatial) > 3) {
      spatial = 3; // clip spatial dimension
      //throw new ArgumentError("spatial dimension must be <= 3");
    }

    if (spatial < 2) {
      spatial = 2; // handle bogus spatial dimension
    }

    return CoordinateArraySequence.init2(size, spatial + measures, measures);
  }
  
}
