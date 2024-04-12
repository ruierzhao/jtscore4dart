import 'package:jtscore4dart/src/operation/overlay/OverlayOp.dart';
import 'package:jtscore4dart/io.dart';
import 'package:jtscore4dart/src/geom/Geometry.dart';

void main() {
  String wktstr = "POLYGON ((585 289, 654 446, 970 430, 1006 244, 846 96, 585 289))";
  String wktstr2 = "POLYGON ((850 580, 862 375, 1160 330, 1140 600, 1010 650, 850 580))";
  WKTReader reader = WKTReader();
  // WKTWriter writer = WKTWriter();
  Geometry g = reader.read(wktstr)!;
  Geometry g2 = reader.read(wktstr2)!;
  print('>>>>>>>>> ${ OverlayOp.overlayOp(g,g2,OverlayOp.INTERSECTION) } <<<<<<<<<<<<<<<<<<<<');
}
