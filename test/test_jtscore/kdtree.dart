
import 'package:jtscore4dart/geometry.dart';
import 'package:jtscore4dart/src/geom/Coordinate.dart';
import 'package:jtscore4dart/src/index/kdtree/KdNode.dart';
import 'package:jtscore4dart/src/index/kdtree/KdTree.dart';

void testSinglePoint() {
    KdTree index = new KdTree(.001);

    KdNode node1 = index.insert(new Coordinate(1, 1));
    KdNode node2 = index.insert(new Coordinate(1, 1));

    print("Inserting 2 identical points should create one node :${node1 == node2}");

    Envelope queryEnv = new Envelope(0, 10, 0, 10);

    List result = index.query(queryEnv);
    print(result.length == 1);

    KdNode node = result[0];
    print(node.getCount() == 2);
    print(node.isRepeated());
  }

void simpleTest() {
  KdTree kdt = KdTree();
  List<Coordinate> pts = [Coordinate(2,3),Coordinate(5,4),Coordinate(9,6),Coordinate(4,7),Coordinate(8,1),Coordinate(7,2)];
  for (var coord in pts) {
    kdt.insert(coord);
  }
  // var cc = kdt.query(Envelope(0, 0, 1, 1));
  var cc  = kdt.depth();
  print(cc);
}
void main() {
  testSinglePoint();
}
