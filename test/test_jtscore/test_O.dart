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
  print('>>>>>>>>> ${ OverlayOp.overlayOp(g,g2,OverlayOp.UNION) } <<<<<<<<<<<<<<<<<<<<');
}

/// error stack.
/// side location conflict [ (858.449866848331, 435.64810800767947, NaN) ]
// #0      EdgeEndStar.propagateSideLabels (package:jtscore4dart/src/geomgraph/EdgeEndStar.dart:309:13)
// #1      EdgeEndStar.computeLabelling (package:jtscore4dart/src/geomgraph/EdgeEndStar.dart:138:5)
// #2      DirectedEdgeStar.computeLabelling (package:jtscore4dart/src/geomgraph/DirectedEdgeStar.dart:128:11)
// #3      OverlayOp.computeLabelling (package:jtscore4dart/src/operation/overlay/OverlayOp.dart:467:23)
// #4      OverlayOp.computeOverlay (package:jtscore4dart/src/operation/overlay/OverlayOp.dart:250:5)
// #5      OverlayOp.getResultGeometry (package:jtscore4dart/src/operation/overlay/OverlayOp.dart:198:5)
// #6      OverlayOp.overlayOp (package:jtscore4dart/src/operation/overlay/OverlayOp.dart:108:27)
// #7      main (file:///C:/Users/ruier/projections/jtsd/jtscore4dart/test/test_jtscore/test_O.dart:12:33)
// #8      _delayEntrypointInvocation.<anonymous closure> (dart:isolate-patch/isolate_patch.dart:297:19)
// #9      _RawReceivePort._handleMessage (dart:isolate-patch/isolate_patch.dart:184:12)
