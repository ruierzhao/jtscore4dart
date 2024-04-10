import 'package:jtscore4dart/io.dart';
import 'package:jtscore4dart/src/algorithm/ConvexHull.dart';
import 'package:jtscore4dart/src/geom/Geometry.dart';

test1(){
  String wktstr = "POLYGON ((239.6 173.4, 239.625 173.575, 242.6 176.9, 249.2 175.4, 251.4 170.5, 241.7 169.4, 239.6 173.4))";
  WKTReader reader = WKTReader();
  WKTWriter writer = WKTWriter();
  Geometry g = reader.read(wktstr)!;
  Geometry newg = ConvexHull(g).getConvexHull();
  print('>>>>>>>>> ${ writer.write(newg) } <<<<<<<<<<<<<<<<<<<<');
  
}
test2(){
  String wktstr = "POLYGON ((255.3 174.1, 257.7 178.2, 260.5 178.1, 258 177.2, 255.3 174.1))";
  WKTReader reader = WKTReader();
  WKTWriter writer = WKTWriter();
  Geometry g = reader.read(wktstr)!;
  print("===============================");
  print('>>>>>>>>> ${ g.convexHull() } <<<<<<<<<<<<<<<<<<<<');
  Geometry newg = ConvexHull(g).getConvexHull();
  print('>>>>>>>>> ${ writer.write(newg) } <<<<<<<<<<<<<<<<<<<<');
  
}
void main() {
  test1();
  test2();
}