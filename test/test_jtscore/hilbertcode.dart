


import 'package:jtscore4dart/src/geom/Coordinate.dart';
import 'package:jtscore4dart/src/shape/fractal/HilbertCode.dart';

import 'test.dart';




void testSize() {
    assertEquals( HilbertCode.size( 0 ), 1);
    assertEquals( HilbertCode.size( 1 ), 4);
    assertEquals( HilbertCode.size( 2 ), 16);
    assertEquals( HilbertCode.size( 3 ), 64);
    assertEquals( HilbertCode.size( 4 ), 256);
    assertEquals( HilbertCode.size( 5 ), 1024);
    assertEquals( HilbertCode.size( 6 ), 4096);
  }

void testLevel() {
    assertEquals( HilbertCode.level( 1 ), 0);
    assertEquals( HilbertCode.level( 2 ), 1);
    assertEquals( HilbertCode.level( 3 ), 1);
    assertEquals( HilbertCode.level( 4 ), 1);
    assertEquals( HilbertCode.level( 5 ), 2);
    assertEquals( HilbertCode.level( 13 ), 2);
    assertEquals( HilbertCode.level( 15 ), 2);
    assertEquals( HilbertCode.level( 16 ), 2);
    assertEquals( HilbertCode.level( 17 ), 3);
    assertEquals( HilbertCode.level( 63 ), 3);
    assertEquals( HilbertCode.level( 64 ), 3);
    assertEquals( HilbertCode.level( 65 ), 4);
    assertEquals( HilbertCode.level( 255 ), 4);
    assertEquals( HilbertCode.level( 255 ), 4);
    assertEquals( HilbertCode.level( 256 ), 4);
  }
  
  void testDecode() {
    checkDecode(1, 0, 0, 0);

    checkDecode(1, 0, 0, 0);
    checkDecode(1, 1, 0, 1);
  
    checkDecode(3, 0, 0, 0);
    checkDecode(3, 1, 0, 1);
    
    checkDecode(4,0, 0, 0);
    checkDecode(4, 1, 1, 0);
    checkDecode(4, 24, 6, 2);
    checkDecode(4, 255, 15, 0);
    
    checkDecode(5, 124, 8, 6);
  }

  void testDecodeEncode() {
    checkDecodeEncodeForLevel(4);
    checkDecodeEncodeForLevel(5);
  }
  
 /**private */void checkDecode(int order, int index, int x, int y) {
    Coordinate p = HilbertCode.decode(order, index);
    //System.out.println(p);
    print(p);
    assertEquals( p.getX().toInt(), x);
    assertEquals( p.getY().toInt(), y);
  }
  
 /**private */void checkDecodeEncodeForLevel(int level) {
    int n = HilbertCode.size(level);
    for (int i = 0; i < n; i++) {
      checkDecodeEncode(level, i);
    }
  }

 /**private */void checkDecodeEncode(int level, int index) {
    Coordinate p = HilbertCode.decode(level, index);
    int _encode = HilbertCode.encode(level, p.getX().toInt(), p.getY().toInt() );
    assertEquals( index, _encode);
  }

/// TODO: @ruier edit.
/// all java test pass
void main() {
  // testSize();
  // print(">>>>>>>>>>>");
  // testLevel();
  // print(">>>>>>>>>>>");
  // testDecode();
  // print(">>>>>>>>>>>");
  // testDecodeEncode();
}
