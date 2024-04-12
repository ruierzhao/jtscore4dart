import 'package:jtscore4dart/io.dart';
import 'package:jtscore4dart/src/geom/Geometry.dart';

test(){
  String wktstr = "POLYGON ((2050 710, 2340 770, 2500 630, 2280 390, 1690 470, 2050 710))";
  String wktstr2 = "POLYGON ((2150 590, 2380 840, 2820 820, 2910 540, 2410 320, 2150 590))";
  
  WKTReader reader = WKTReader();
  WKTWriter writer = WKTWriter();

  Geometry g1 = reader.read(wktstr)!;
  Geometry g2 = reader.read(wktstr2)!;
  var newg = g1.touches(g2);
  print('>>>>>>>>> ${ newg } <<<<<<<<<<<<<<<<<<<<');
}
void main() {
  test();
}
