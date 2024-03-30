import 'package:jtscore4dart/src/geom/Coordinate.dart';

class CoordinateTest{
  assertEquals(var v1,var v2){
    if (v1 == v2) {
      print("$v1 == $v2");
    }else{
      print("$v1 != $v2");
    }
  }
  assertTrue(var v1){
    print(v1);
  }
  
  void testConstructor3D() 
  {
    Coordinate c = new Coordinate(350.2, 4566.8, 5266.3);
    assertEquals(c.x, 350.2);
    assertEquals(c.y, 4566.8);
    assertEquals(c.getZ(), 5266.3);
  }
  
  void testConstructor2D() 
  {
    Coordinate c = new Coordinate(350.2, 4566.8);
    assertEquals(c.x, 350.2);
    assertEquals(c.y, 4566.8);
    assertEquals(c.getZ(), Coordinate.NULL_ORDINATE);
  }
  void testDefaultConstructor() 
  {
    Coordinate c = Coordinate.empty2D();
    assertEquals(c.x, 0.0);
    assertEquals(c.y, 0.0);
    assertEquals(c.getZ(), Coordinate.NULL_ORDINATE);
  }
  void testCopyConstructor3D() 
  {
    Coordinate orig = new Coordinate(350.2, 4566.8, 5266.3);
    Coordinate c = new Coordinate.fromAnother(orig);
    assertEquals(c.x, 350.2);
    assertEquals(c.y, 4566.8);
    assertEquals(c.getZ(), 5266.3);
  }
  void testSetCoordinate() 
  {
    Coordinate orig = new Coordinate(350.2, 4566.8, 5266.3);
    Coordinate c = Coordinate.empty2D();
    c.setCoordinate(orig);
    assertEquals(c.x, 350.2);
    assertEquals(c.y, 4566.8);
    assertEquals(c.getZ(), 5266.3);
  }
  void testGetOrdinate() 
  {
    Coordinate c = new Coordinate(350.2, 4566.8, 5266.3);
    assertEquals(c.getOrdinate(Coordinate.X), 350.2);
    assertEquals(c.getOrdinate(Coordinate.Y), 4566.8);
    assertEquals(c.getOrdinate(Coordinate.Z), 5266.3);
  }
  void testSetOrdinate() 
  {
    Coordinate c = Coordinate.empty2D();
    c.setOrdinate(Coordinate.X, 111);
    c.setOrdinate(Coordinate.Y, 222);
    c.setOrdinate(Coordinate.Z, 333);
    assertEquals(c.getOrdinate(Coordinate.X), 111.0);
    assertEquals(c.getOrdinate(Coordinate.Y), 222.0);
    assertEquals(c.getOrdinate(Coordinate.Z), 333.0);
  }
  void testEquals()
  {
    Coordinate c1 = new Coordinate(1,2,3);
    String s = "Not a coordinate";
    assertTrue(! c1.equals(s));
    
    Coordinate c2 = new Coordinate(1,2,3);
    assertTrue(c1.equals2D(c2));

    Coordinate c3 = new Coordinate(1,22,3);
    assertTrue(! c1.equals2D(c3));
  }
  void testEquals2D()
  {
    Coordinate c1 = new Coordinate(1,2,3);
    Coordinate c2 = new Coordinate(1,2,3);
    assertTrue(c1.equals2D(c2));
    
    Coordinate c3 = new Coordinate(1,22,3);
    assertTrue(! c1.equals2D(c3));
  }
  void testEquals3D()
  {
    Coordinate c1 = new Coordinate(1,2,3);
    Coordinate c2 = new Coordinate(1,2,3);
    assertTrue(c1.equals3D(c2));
    
    Coordinate c3 = new Coordinate(1,22,3);
    assertTrue(! c1.equals3D(c3));
  }
  void testEquals2DWithinTolerance() 
  {
    Coordinate c = new Coordinate(100.0, 200.0, 50.0);
    Coordinate aBitOff = new Coordinate(100.1, 200.1, 50.0);
    assertTrue(c.equals2DWithTolerance(aBitOff, 0.2));
  }

  void testEqualsInZ() {
    
    Coordinate c = new Coordinate(100.0, 200.0, 50.0);
    Coordinate withSameZ = new Coordinate(100.1, 200.1, 50.1);
    assertTrue(c.equalInZ(withSameZ, 0.2));
  }

  void testCompareTo() 
  {
    Coordinate lowest = new Coordinate(10.0, 100.0, 50.0);
    Coordinate highest = new Coordinate(20.0, 100.0, 50.0);
    Coordinate equalToHighest = new Coordinate(20.0, 100.0, 50.0);
    Coordinate higherStill = new Coordinate(20.0, 200.0, 50.0);
    
    assertEquals(-1, lowest.compareTo(highest));
    assertEquals(1, highest.compareTo(lowest));
    assertEquals(-1, highest.compareTo(higherStill));
    assertEquals(0, highest.compareTo(equalToHighest));
  }
  

}

void main() {
  var t = CoordinateTest();
  t.testCopyConstructor3D();
  t.testCompareTo();
}
