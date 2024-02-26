/// 将java重命名为dart

import 'dart:io';
// 读取当前文件夹下的文件及目录
void readDir(String currDir,{srcExt="java",targetExt="dart"}){
  Directory dir = Directory(currDir);
  List<FileSystemEntity> dirlist = dir.listSync(recursive: true);
  print('==============${dirlist.length}====================='); // 649
  for (var path in dirlist) {
    var filestat = path.statSync();
    
    if (FileSystemEntityType.file == filestat.type){
      var srcName = path.path;
      if (!srcName.contains(srcExt)){
        continue;
      }else{
        String newname = srcName.replaceAll(srcExt, targetExt);
        File(srcName).renameSync(newname);
      }
    }else{
      print('======dir:${path.path}');
    }
  }
}

void renameJava2Dart(String dir){
  readDir(dir);
}
void main(List<String> args) {
  String srcDir = r"D:\carbon\jtsd\lib\src";
  renameJava2Dart(srcDir);
}
