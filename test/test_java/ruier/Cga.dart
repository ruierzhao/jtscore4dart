import 'dart:collection';
import 'dart:math';

import 'package:jtscore4dart/src/algorithm/Orientation.dart';
import 'package:jtscore4dart/src/geom/Coordinate.dart';

class Envelope implements Comparable {
  static final double _DP_SAFE_EPSILON = 1e-15;
  static void ruier() {
    print("cga ruier");
  }

  ///  the minimum x-coordinate
  final double _minx;

  ///  the maximum x-coordinate
  final double _maxx;

  ///  the minimum y-coordinate
  final double _miny;

  ///  the maximum y-coordinate
  final double _maxy;

  ///  Creates a null <code>Envelope</code>.
  // TODO: ruier edit. 改写成 const
  const Envelope.init()
      : _minx = 0,
        _maxx = -1,
        _miny = 0,
        _maxy = -1;

  ///  Creates an <code>Envelope</code> for a region defined by maximum and minimum values.
  ///
  ///@param  x1  the first x-value
  ///@param  x2  the second x-value
  ///@param  y1  the first y-value
  ///@param  y2  the second y-value
  Envelope(double x1, double x2, double y1, double y2)
      : _minx = min<double>(x1, x2),
        _maxx = max(x1, x2),
        _miny = min(y1, y2),
        _maxy = max(y1, y2);
  Envelope.fromCoord1(Coordinate p):this(p.x, p.x, p.y, p.y);
  // {
  //   adjustXY(_minx,_maxx,_maxx,_maxy);
  // }
// static double adjustXY(double x1, double x2, double y1, double y2)
  
  Envelope.fromAnother(Envelope env)
      : _maxx = env._maxx,
        _miny = env._miny,
        _maxy = env._maxy,
        _minx = env._minx;

  ///  Initialize to a null <code>Envelope</code>.
  // TODO: ruier edit.
  // void init()
  // {
  //   setToNull();
  // }

  ///  Initialize an <code>Envelope</code> for a region defined by maximum and minimum values.
  ///
  ///@param  x1  the first x-value
  ///@param  x2  the second x-value
  ///@param  y1  the first y-value
  ///@param  y2  the second y-value
  // void init(double x1, double x2, double y1, double y2) {
  //   if (x1 < x2) {
  //     _minx = x1;
  //     _maxx = x2;
  //   } else {
  //     _minx = x2;
  //     _maxx = x1;
  //   }
  //   if (y1 < y2) {
  //     _miny = y1;
  //     _maxy = y2;
  //   } else {
  //     _miny = y2;
  //     _maxy = y1;
  //   }
  // }
  @override
  String toString() {
    // TODO: implement toString
    return "($_minx, $_maxx, $_miny, $_maxy)";
  }
  
  @override
  int compareTo(other) {
    // TODO: implement compareTo
    throw UnimplementedError();
  }
}

class Ruier extends ListBase<Coordinate>{
  void ruier(){
    print("ruier");
  }

  Ruier(List<Coordinate> coord, [bool allowRepeated=true]){
    length = coord.length;
    for (var i = 0; i < coord.length; i++) {
      // add(coord[i]);
      this[i] = coord[i];
    }
  }

  @override
  void add(Coordinate element) {
    // TODO: implement add
    super.add(element);
  }
  
  @override
  late int length;

  @override
  operator [](int index) {
    // TODO: implement []
    throw UnimplementedError();
  }
  
  @override
  void operator []=(int index, value) {
    // TODO: implement []=
  }
  

}

abstract class Ruier2{
  int cc;
  Ruier2([this.cc = 5]);
  void ruier(String vv);
  void vvv(){
    print("rueir");
  }
}

test(int a,[int b=0,int? c]){
  c??= 4;
  return a + b +c;
}

enum SomeFilter{
  CFilter([]),
  GeometryFilter([]);
  final List<int> list;
  const SomeFilter(this.list);
}

extension _ on SomeFilter{
  filter(int g){
    print(g);
  }
}

apply(SomeFilter filter){
  filter.filter(5);
}


class _Type{
  final String name;

  _Type({required this.name});
}

class Ruier23{
  _Type ruier = _Type(name: "ruier");
  Ruier23();
  gettypenamr(){ 
    return ruier;
  }
}


class RuierList{
  final List<int> _cc = [];
  RuierList([ List<int>? coord ]){
    if (coord != null) {
      _cc.addAll(coord);
    }
  }
  add(int v){
    _cc.add(v);
  }
  printcc(){
    for (int v in _cc) {
      print("$v");
    }
  }
}

test_reverse(){
  List<int> arr = [1,2,3,4,5,6,7];
  var arrlen = arr.length;
  var cc = List<int>.generate(arrlen, (index) => arr[arrlen-index-1],growable: false);
  print(cc);
  var dd = List.filled(5, 5);
  print(dd.length);
  cc.add(0);
}

test_sublist(){
  List<int> arr = [1,2,3,4,5,6,7];
  var narr = arr.sublist(3,5);
  print(narr);
  print(arr);

}

  void scroll(List<int> coordinates, int indexOfFirstCoordinate, [bool ensureRing=false]) {

    int i = indexOfFirstCoordinate;
    if (i <= 0) return;

    // List<Coordinate> newCoordinates = new Coordinate[coordinates.length];
    List<int> newCoordinates = List.filled(coordinates.length, 0);
    // newCoordinates.sublist()
    if (!ensureRing) { // not ring
      /// 第一个参数是要被复制的数组
      /// 第二个参数是被复制的数字开始复制的下标
      /// 第三个参数是目标数组，也就是要把数据放进来的数组
      /// 第四个参数是从目标数据第几个下标开始放入数据
      /// 第五个参数表示从被复制的数组中拿几个数值放到目标数组中
      // System.arraycopy(coordinates, i, newCoordinates, 0, coordinates.length - i);
      // System.arraycopy(coordinates, 0, newCoordinates, coordinates.length - i, i);
      var _li1 = coordinates.sublist(i,coordinates.length);
      var _li2 = coordinates.sublist(0,i);
      _li1.addAll(_li2);
      for (var i = 0; i < coordinates.length; i++) {
        coordinates[i] = _li1[i];
      }
      print(coordinates);
    } else {
      int last = coordinates.length - 1;

      // fill in values
      int j;
      for (j = 0; j < last; j++) {
        newCoordinates[j] = coordinates[(i + j) % last];
      }

      // Fix the ring (first == last)
      newCoordinates[j] = newCoordinates[0];

      for (var i = 0; i < coordinates.length; i++) {
        coordinates[i] = newCoordinates[i];
      }
    }
    // System.arraycopy(newCoordinates, 0, coordinates, 0, coordinates.length);
  }

void scroll2(List<int> coordinates, int indexOfFirstCoordinate, [bool ensureRing=false]) {

    int i = indexOfFirstCoordinate;
    if (i <= 0) return;

    // List<Coordinate> newCoordinates = new Coordinate[coordinates.length];
    List<int> newCoordinates = List.filled(coordinates.length, 0);
    // newCoordinates.sublist()
    if (!ensureRing) { // not ring
      /// 第一个参数是要被复制的数组
      /// 第二个参数是被复制的数字开始复制的下标
      /// 第三个参数是目标数组，也就是要把数据放进来的数组
      /// 第四个参数是从目标数据第几个下标开始放入数据
      /// 第五个参数表示从被复制的数组中拿几个数值放到目标数组中
      // System.arraycopy(coordinates, i, newCoordinates, 0, coordinates.length - i);
      // System.arraycopy(coordinates, 0, newCoordinates, coordinates.length - i, i);
      // var _li1 = coordinates.sublist(i,coordinates.length);
      // var _li2 = coordinates.sublist(0,i);
      // _li1.addAll(_li2);
      // for (var i = 0; i < coordinates.length; i++) {
      //   coordinates[i] = _li1[i];
      // }
      newCoordinates = coordinates.sublist(i,coordinates.length);
      newCoordinates.addAll(coordinates.sublist(0,i));
      
    } else {
      int last = coordinates.length - 1;

      // fill in values
      int j;
      for (j = 0; j < last; j++) {
        newCoordinates[j] = coordinates[(i + j) % last];
      }

      // Fix the ring (first == last)
      newCoordinates[j] = newCoordinates[0];

      // for (var i = 0; i < coordinates.length; i++) {
      //   coordinates[i] = newCoordinates[i];
      // }
    }
    for (var i = 0; i < coordinates.length; i++) {
      coordinates[i] = newCoordinates[i];
    }
    // System.arraycopy(newCoordinates, 0, coordinates, 0, coordinates.length);
  }

test_scrool(){
  List<int> arr = [1,2,3,4,5,6,7];
  List<int> arrring = [7,2,3,4,5,6,7];
  scroll2(arr, 4);
  print(arr);
  scroll2(arrring, 4, true);
  print(arrring);
}


sort(List<Coordinate> pts,int from, int to){
  int polarCompare(Coordinate o, Coordinate p, Coordinate q)
    {
      int orient = Orientation.index(o, p, q);
      if (orient == Orientation.COUNTERCLOCKWISE) return 1;
      if (orient == Orientation.CLOCKWISE) return -1;

      /** 
       * The points are collinear,
       * so compare based on distance from the origin.  
       * The points p and q are >= to the origin,
       * so they lie in the closed half-plane above the origin.
       * If they are not in a horizontal line, 
       * the Y ordinate can be tested to determine distance.
       * This is more robust than computing the distance explicitly.
       */
      if (p.y > q.y) return 1;
      if (p.y < q.y) return -1;

      /**
       * The points lie in a horizontal line, which should also contain the origin
       * (since they are collinear).
       * Also, they must be above the origin.
       * Use the X ordinate to determine distance. 
       */ 
      if (p.x > q.x) return 1;
      if (p.x < q.x) return -1;
      // Assert: p = q
      return 0;
    }
    Coordinate t;
    for (int i = 1; i < pts.length; i++) {
      if ((pts[i].y < pts[0].y) || ((pts[i].y == pts[0].y) && (pts[i].x < pts[0].x))) {
        t = pts[0];
        pts[0] = pts[i];
        pts[i] = t;
      }
    }

  var origin = pts[0];
  int compare(Coordinate p1, Coordinate p2)
  {
    int comp = polarCompare(origin, p1, p2);      
    return comp;
  }

  var sortPts = pts.sublist(from,to);
  sortPts.sort(compare);
  
  for (var i = 0; i < sortPts.length; i++) {
    pts[i+from] = sortPts[i];
  }
  // return pts;
 }

// MULTIPOINT ((480 490), (930 560), (1020 380), (800 130), (480 220), (720 400), (560 430), (760 290), (940 430), (645 245), (1204 494), (755 651), (594 576), (777 495), (900 290), (860 140), (831 165), (920 170), (936 206), (958 285), (1066 315), (1060 230), (660 440), (550 540))
test_sort(){
  var cc = [(480, 490), (930, 560), (1020, 380), (800, 130), (480, 220), (720, 400), (560, 430), (760, 290), (940, 430), (645, 245), (1204, 494), (755, 651), (594, 576), (777, 495), (900, 290), (860, 140), (831, 165), (920, 170), (936, 206), (958, 285), (1066, 315), (1060, 230), (660, 440), (550, 540)];
  var vv = List.generate(cc.length, (index) => Coordinate(cc[index].$1.toDouble(), cc[index].$2.toDouble()));
  print(vv);
  print('===================================');
  sort(vv, 0, vv.length);
  print(vv);
  
  // List<Coordinate> coords = List.generate(, (index) => null)
}

class Ruier5 {
  int age;
  int name;

  Ruier5(this.name):age=name-8
  {
    print(age);
  }
  ruier(){}
}



void main() {
  List vv = [];
  vv[0] = 10;
  vv[1] = 5;
print(vv);
}
