import 'package:jtscore4dart/algorithm.dart';
import 'package:jtscore4dart/src/geom/Coordinate.dart';
import 'package:jtscore4dart/src/geom/CoordinateSequence.dart';
import 'package:jtscore4dart/src/geom/CoordinateSequenceFactory.dart';
import 'package:jtscore4dart/src/geom/GeometryFactory.dart';
import 'package:jtscore4dart/src/geom/LineString.dart';
import 'package:jtscore4dart/src/geom/PrecisionModel.dart';
import 'package:jtscore4dart/src/geom/impl/CoordinateArraySequenceFactory.dart';

void main() {
  var p = LineString(CoordinateArraySequenceFactory().create([Coordinate(20, 50),Coordinate(40, 60)]), GeometryFactory());
  var cc = Centroid.of(p);
  print(cc);
}
