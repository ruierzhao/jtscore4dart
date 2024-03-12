import 'dart:collection';
import 'dart:math';

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


void main() {
// var cc = <int>[];
// var cc = List.empty(growable: true);
var cc = List.filled(5,Coordinate.empty2D());
for (var i = 0; i < 5; i++) {
  cc[i] = Coordinate(i.toDouble(), i*i.toDouble());
}
print(cc);
}
