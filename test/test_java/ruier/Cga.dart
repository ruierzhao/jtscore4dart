main() {
  // print(5~/0);
  void test(bool errr){
    if(errr){
      throw AssertionError("rueir assert");
    }
    throw Exception("cuowu ");
  }
  test(false);
  print(5/3);
}
