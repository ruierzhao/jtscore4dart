  import 'dart:math';

import 'test_java/ruier/Cga.dart';

List<int> shuffle(int n) {
    final Random rnd = Random(13);
    List<int> ints = List<int>.filled(n, 0);
    
    for (int i = 0; i < n; i++) {
      ints[i] = i;
    }
    for (int i = n - 1; i >= 1; i--) {
      int j = rnd.nextInt(i + 1);
      int last = ints[i];
      ints[i] = ints[j];
      ints[j] = last;
    }
    return ints;
  }

void main() {
  var cc = shuffle(20);
  print(cc);
  Cga.ruier();
  }