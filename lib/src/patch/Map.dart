// 扩展to兼容java 方法
extension SplayTreeMapExtension<K, V> on Map<K, V>{
  int size() => this.length;

  V? get(Object? key) => this[key];
  
  put(K key,V value) => this[key]=value; 
}