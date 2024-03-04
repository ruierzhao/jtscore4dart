import 'dart:collection';

import 'package:jtscore4dart/src/geom/Coordinate.dart';

/// A list of {@link Coordinate}s, which may
/// be set to prevent repeated coordinates from occurring in the list.
///
///
/// @version 1.7
class CoordinateList extends ListBase<Coordinate>{
  @override
  set length(int newLength) {
    this.length = length;
  }

  @override
  operator [](int index) {
    this[index];
  }

  @override
  void operator []=(int index, value) {
    // TODO: implement []=
  }
  
  @override
  // TODO: implement length
  int get length => 5;
  

}