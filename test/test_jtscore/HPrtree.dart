

import 'package:jtscore4dart/src/geom/Envelope.dart';
import 'package:jtscore4dart/src/index/hprtree/HPRtree.dart';
import 'package:jtscore4dart/src/patch/ArrayList.dart';

import 'test.dart';

void testDisallowedInserts() {
    HPRtree t = new HPRtree(3);
    t.insert(new Envelope(0, 0, 0, 0), new Object());
    t.insert(new Envelope(0, 0, 0, 0), new Object());
    t.query(new Envelope.init());
    try {
      t.insert(new Envelope(0, 0, 0, 0), new Object());
      assertTrue(false);
    }
    on Exception catch ( e) {
      print(e);
      assertTrue(true);
    }
  }

//  void testQuery() {
//     ArrayList geometries = new ArrayList();
//     geometries.add(factory.createLineString(new Coordinate[]{
//         new Coordinate(0, 0), new Coordinate(10, 10)}));
//     geometries.add(factory.createLineString(new Coordinate[]{
//         new Coordinate(20, 20), new Coordinate(30, 30)}));
//     geometries.add(factory.createLineString(new Coordinate[]{
//         new Coordinate(20, 20), new Coordinate(30, 30)}));
//     HPRtree t = new HPRtree(3);
//     for (Iterator i = geometries.iterator(); i.hasNext(); ) {
//       Geometry g = (Geometry) i.next();
//       t.insert(g.getEnvelopeInternal(), new Object());
//     }
//     t.query(new Envelope(5, 6, 5, 6));
//     try {
//       assertEquals(1, t.query(new Envelope(5, 6, 5, 6)).size());
//       assertEquals(0, t.query(new Envelope(20, 30, 0, 10)).size());
//       assertEquals(2, t.query(new Envelope(25, 26, 25, 26)).size());
//       assertEquals(3, t.query(new Envelope(0, 100, 0, 100)).size());
//     }
//     catch (Throwable x) {
//       //STRtreeDemo.printSourceData(geometries, System.out);
//       //STRtreeDemo.printLevels(t, System.out);
//       throw x;
//     }
//   }

   void testQuery3() {
    HPRtree t = new HPRtree();
    for (int i = 0; i < 3; i++ ) {
      double _i = i.toDouble();
      t.insert(new Envelope(_i, _i+1, _i, _i+1), i);
    }
    t.query(new Envelope(0,1,0,1));
    assertEquals(3, t.query(new Envelope(1, 2, 1, 2)).size());
    assertEquals(0, t.query(new Envelope(9, 10, 9, 10)).size());
  }

   void testQuery10() {
    HPRtree t = new HPRtree();
    for (int i = 0; i < 10; i++ ) {
      double _i = i.toDouble();
      t.insert(new Envelope(_i, _i+1, _i, _i+1), _i);
    }
    t.query(new Envelope(0,1,0,1));
    assertEquals(3, t.query(new Envelope(5, 6, 5, 6)).size());
    assertEquals(2, t.query(new Envelope(9, 10, 9, 10)).size());
    assertEquals(0, t.query(new Envelope(25, 26, 25, 26)).size());
    assertEquals(10, t.query(new Envelope(0, 10, 0, 10)).size());
  }

   void testQuery100() {
    queryGrid( 100, new HPRtree() );
  }

   void testQuery100cap8() {
    queryGrid( 100, new HPRtree(8) );
  }

   void testQuery100cap2()  {
    queryGrid( 100, new HPRtree(2) );
  }

 /**private */void queryGrid(int size, HPRtree t) {
    for (int i = 0; i < size; i++ ) {
      double _i = i.toDouble();
      t.insert(new Envelope(_i, _i+1, _i, _i+1), i);
    }
    t.query(new Envelope(0,1,0,1));
    assertEquals(3, t.query(new Envelope(5, 6, 5, 6)).size());
    assertEquals(3, t.query(new Envelope(9, 10, 9, 10)).size());
    assertEquals(3, t.query(new Envelope(25, 26, 25, 26)).size());
    assertEquals(11, t.query(new Envelope(0, 10, 0, 10)).size());
  }


void main() {
  // testDisallowedInserts();
  // testQuery3();
  // testQuery10();
  testQuery100();
}
