library test;



void assertEquals(int a,int b){
  if (a == b) {
    print("pass");
  }else{
    print("$a != $b");
  }
}

void assertTrue(bool a){
  if (a) {
    // print("pass");
  }else{
    Exception();
  }
}
