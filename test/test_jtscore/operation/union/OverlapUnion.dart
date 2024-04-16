import 'package:jtscore4dart/io.dart';
import 'package:jtscore4dart/src/geom/Geometry.dart';
import 'package:jtscore4dart/src/geom/GeometryFactory.dart';
import 'package:jtscore4dart/src/geom/PrecisionModel.dart';
import 'package:jtscore4dart/src/geom/TopologyException.dart';
import 'package:jtscore4dart/src/operation/union/OverlapUnion.dart';

void testFixedPrecCausingBorderChange() {
  String a = "POLYGON ((130 -10, 20 -10, 20 22, 30 20, 130 20, 130 -10))";
  String b =
      "MULTIPOLYGON (((50 0, 100 450, 100 0, 50 0)), ((53 28, 50 28, 50 30, 53 30, 53 28)))";


  _checkUnionWithTopologyFailure(a, b, 1);
}

void testFullPrecision() {
  String a = "POLYGON ((130 -10, 20 -10, 20 22, 30 20, 130 20, 130 -10))";
  String b =
      "MULTIPOLYGON (((50 0, 100 450, 100 0, 50 0)), ((53 28, 50 28, 50 30, 53 30, 53 28)))";

  checkUnion(a, b);
}

void testSimpleOverlap() {
  String a =
      "MULTIPOLYGON (((0 400, 50 400, 50 350, 0 350, 0 400)), ((200 200, 220 200, 220 180, 200 180, 200 200)), ((350 100, 370 100, 370 80, 350 80, 350 100)))";
  String b =
      "MULTIPOLYGON (((430 20, 450 20, 450 0, 430 0, 430 20)), ((100 300, 124 300, 124 276, 100 276, 100 300)), ((230 170, 210 170, 210 190, 230 190, 230 170)))";

  checkUnionOptimized(a, b);
}

/**
   * It is hard to create a situation where border segments change by 
   * enough to cause an invalid geometry to be returned.
   * One way is to use a fixed precision model, 
   * which will cause segments to move enough to 
   * intersect with non-overlapping components.
   * <p>
   * However, the current union algorithm
   * emits topology failures for these situations, since
   * it is not performing snap-rounding. 
   * These exceptions are irrelevant to the correctness
   * of the OverlapUnion algorithm, so are prevented from being reported as a test failure.
   * 
   * @param wktA
   * @param wktB
   * @param scaleFactor
   * @throws ParseException
   */
/**private */
void _checkUnionWithTopologyFailure(
    String wktA, String wktB, double scaleFactor) {
  PrecisionModel pm = new PrecisionModel.Fixed(scaleFactor);
  GeometryFactory geomFact = new GeometryFactory(pm);
  WKTReader rdr = new WKTReader.withFactory(geomFact);

  Geometry a = rdr.read(wktA)!;
  Geometry b = rdr.read(wktB)!;

  OverlapUnion union = new OverlapUnion(a, b);

  Geometry? result = null;
  try {
    result = union.union();
  } on TopologyException catch (ex) {
    bool isOptimized = union.isUnionOptimized();

    // if the optimized algorithm was used then this is a real error
    if (isOptimized) throw ex;

    // otherwise the error is probably due to the fixed precision
    // not being handled by the current union code
    return;
  }
  print(result);
  // assertTrue( "OverlapUnion result is invalid", result.isValid());
}

/**private */ void checkUnion(String wktA, String wktB) {
  checkUnion2(wktA, wktB, false);
}

/**private */ void checkUnionOptimized(String wktA, String wktB) {
  checkUnion2(wktA, wktB, true);
}

/**private */ void checkUnion2(
    String wktA, String wktB, bool isCheckOptimized) {
  PrecisionModel pm = new PrecisionModel();
  GeometryFactory geomFact = new GeometryFactory(pm);
  WKTReader rdr = new WKTReader.withFactory(geomFact);

  Geometry a = rdr.read(wktA)!;
  Geometry b = rdr.read(wktB)!;

  OverlapUnion union = new OverlapUnion(a, b);
  Geometry result = union.union();

  if (isCheckOptimized) {
    bool isOptimized = union.isUnionOptimized();
    print('>>>>>>>>> isOptimized: ${isOptimized} <<<<<<<<<<<<<<<<<<<<');
    // assertTrue("Union was not performed using combine", isOptimized);
  }

  print("OverlapUnion result is invalid${result.isValid()}");
}

void main() {
  testFixedPrecCausingBorderChange();
}
