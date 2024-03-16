
extension JavaList<T> on List<T>{
  T get(int i) => this[i];

  // 用于替换动态数组中指定索引的元素。
  T set(int i,T value){
    var temp = this[i]; // TODO: maybe copy
    this[i] = value;
    return temp;
  } 
}

