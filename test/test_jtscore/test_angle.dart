
// ignore_for_file: unnecessary_brace_in_string_interps

import 'dart:math';

import 'package:jtscore4dart/src/algorithm/Angle.dart';
import 'package:jtscore4dart/src/geom/Coordinate.dart';

test1(){
  var cc = Angle.getTurn(45,90);
  print('==============${cc}====================='); // 1
  cc = Angle.getTurn(45,-90);
  print('==============${cc}====================='); // -1
}

test_offset(){
  var cc = Angle.offset(Coordinate.empty2D(), pi/4, 5);
  print('==============${cc}=====================');
  var cs = Angle.cosSnap(45);
  print('==============${cs}=====================');
   cc = Angle.offset(Coordinate.empty2D(), pi/2, 5);
  print('==============${cc}=====================');
}

test_of(){
  var s = Angle.of(Coordinate.empty2D(), Coordinate(3.5355339059327378, 3.5355339059327378));
  print('==============${s}=====================');
  print('==============${Angle.toDegrees(s)}=====================');
}
void main() {
  test_of();
}
