
extension JavaList<T> on List<T>{
  T get(int i) => this[i];

  // 用于替换动态数组中指定索引的元素。
  T set(int i,T value){
    var temp = this[i]; // TODO: maybe copy
    this[i] = value;
    return temp;
  } 
  // int indexOf(T value){
  //   for (var i = 0; i < this.size(); i++) {
  //     if (value == this[i]) {
  //       return i;
  //     }
  //   }
  //   return -1;
  // } 
  int size() => this.length;

  // java 中数组和list 不一样
  List<T> toArray(){
    return List<T>.from(this, growable: false);
  }
  // 实现2
  List<T> toArray2(){
    return this.toList(growable: false);
  }

// 原文链接：https://blog.csdn.net/yaomingyang/article/details/80711193
    // static <E> T min(Iterable<E extends T> coll, [Comptor? comp]) {
    //     if (comp==null)
    //         return min((Iterable<SelfComparable>) (Iterable) coll);

    //     Iterator<? extends T> i = coll.iterator();
    //     T candidate = i.next();

    //     while (i.hasNext()) {
    //         T next = i.next();
    //         if (comp.compare(next, candidate) < 0)
    //             candidate = next;
    //     }
    //     return candidate;
    // }
  
}

