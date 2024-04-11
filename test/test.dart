

void main() {
  List<int>  arr = [1,2,3,4];
  List<int>  rarr = [];

  for (var ar in arr) {
    rarr.add(ar);
  }
  int temp;
  for (int i = 0; i<arr.length;i++) {
    print(arr[i]);
    temp = (arr[i]);
    if (temp == 3) {
      print(arr);
      print('>>>>>>>>> <<<<<<<<<<<<<<<<<<<<');
      rarr.remove(temp);
    }
  }
  print(arr);
  print(rarr);
}