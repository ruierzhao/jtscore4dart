import 'package:jtscore4dart/io.dart';
import 'package:jtscore4dart/src/geom/Geometry.dart';
import 'package:jtscore4dart/src/precision/CommonBitsOp.dart';

void testPackedCoordinateSequence() {
    // GeometryFactory pcsFactory = new GeometryFactory(PackedCoordinateSequenceFactory.DOUBLE_FACTORY);
    var reader = WKTReader();
    var read = reader.read;
    Geometry geom0 = read("POLYGON ((210 210, 210 220, 220 220, 220 210, 210 210))")!;
    Geometry geom1 = read("POLYGON ((225 225, 225 215, 215 215, 215 225, 225 225))")!;
    CommonBitsOp cbo = new CommonBitsOp(true);
    Geometry result = cbo.intersection(geom0, geom1);
    Geometry expected = geom0.intersection(geom1);
    ///Geometry expected = read("POLYGON ((220 215, 215 215, 215 220, 220 220, 220 215))");
    // checkEqual(expected, result);
    print('>>>>>>>>> ${ expected } <<<<<<<<<<<<<<<<<<<<');
    print('>>>>>>>>> ${ result } <<<<<<<<<<<<<<<<<<<<');
  }
void main() {
  testPackedCoordinateSequence();
}
