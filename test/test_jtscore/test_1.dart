class SuperClass{
  int a;
  String s;
  SuperClass.from(this.a,this.s);
}

class subClass extends SuperClass{
  
  subClass(int aa, String s):super.from(aa,s);
  rueir(){
    print(a);
  }
}

void main() {
  List<int> arr  = [1,2,3];
  print('>>>>>>>>> ${ arr is List } <<<<<<<<<<<<<<<<<<<<');
}