
import 'package:jtscore4dart/src/patch/OrdinateFormat.dart';

test(){
  var of = OrdinateFormat.create(16);
  var ss = of.format(15248653);
  print('>>>>>>>>> ${ ss } <<<<<<<<<<<<<<<<<<<<');
}
test2(){
  var ss = OrdinateFormat.DEFAULT.format(1400000000);
  print('>>>>>>>>> ${ ss } <<<<<<<<<<<<<<<<<<<<');
}

void main() {
  test();
  test2();
}

