
extension JavaStringBuilder on StringBuffer{
  /// TODO: @ruier edit.优化实现一下
  setCharAt(int index, String newChar){
    String simpleReplace(){
      String old = this.toString();
      String newString = old.replaceRange(index, index+1, newChar);
      return newString;
    }
    List<String> oldArr = List.from(this.toString().split(""), growable: false);
    String onlyReplace(){
      // List<String> oldArr = this.toString().split("");
      oldArr[index] = newChar;
      return oldArr.join();
    }
    return simpleReplace();
  }
}

class StringBuilder{
  final List<String> _strArr;
  final String str ;

  StringBuilder(this.str):this._strArr = List.from(str.split("")) ;

  setCharAt(int index, String newChar){
    if(!(index>=0 && index < str.length)){
      throw Exception("index error");
    }
    this._strArr[index] = newChar;
  }

  @override
  String toString(){
    StringBuffer newStr = StringBuffer("");
    for (var char in _strArr) {
      newStr.write(char);
    }
    return newStr.toString();
  }
}
