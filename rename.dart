/// 将java重命名为dart

import 'dart:collection';
import 'dart:io';

// ignore: slash_for_doc_comments
/**
class EffectList extends ListBase<Effect> with AnimateManager<EffectList> {
  final List<Effect> _effects = [];

  @override
  EffectList addEffect(Effect effect) {
    _effects.add(effect);
    return this;
  }

  // concrete implementations required when extending ListBase:
  @override
  set length(int length) {
    _effects.length = length;
  }

  @override
  int get length => _effects.length;

  @override
  Effect operator [](int index) => _effects[index];

  @override
  void operator []=(int index, Effect value) {
    _effects[index] = value;
  }
}
 * 
 */

// 单行处理函数
typedef EditerFileFunc = void Function(String codeSegment);

class ListEditorFunc extends ListBase<EditerFileFunc>{
  @override
  int length;

  @override
  operator [](int index) {
    // TODO: implement []
    throw UnimplementedError();
  }

  @override
  void operator []=(int index, value) {
    // TODO: implement []=
  }
  
}

class Editor {
  late File f;
  Editor(this.f);

  Editor.fromFileName(String filename) {
    f = File(filename);
  }

  String srcExt = "java";
  String targetExt = "dart";

  Future<dynamic> init({
    List<EditerFileFunc>? listHandler,
    bool needRename = true,
  }){
      if (needRename){ // 需要重命名
        // 读取文件内容
        // 编辑完成之后写入新文件（边编辑边写入）
        // 删除源文件
        return f.readAsLines();
      }else{ // 不需要重命名
        // 直接修改源文件
        return f.readAsString();
      }
  }

  Future<void> edit() {
    return f.readAsLines().then((fileLines){
      for (var line in fileLines) {
        print(">> $line");
      }
  // return "";
  });
  }
  

  void _deletePublic(String codeSegment) {}
}

// 修改代码源文件
void editFile(String filename) {
  Editor editor = Editor.fromFileName(filename);
  editor.edit();
}

// 读取当前文件夹下的文件及目录
void readDir(String currDir, {srcExt = "java", targetExt = "dart"}) {
  Directory dir = Directory(currDir);
  List<FileSystemEntity> dirlist = dir.listSync(recursive: true);
  print('==============${dirlist.length}====================='); // 649
  for (var path in dirlist) {
    var filestat = path.statSync();

    var srcName = path.path;
    if (FileSystemEntityType.file == filestat.type) {
      if (!srcName.contains(srcExt)) {
        continue;
      } else {
        String newname = srcName.replaceAll(srcExt, targetExt);
        File(srcName).renameSync(newname);
      }
    } else {
      print('======dir:${path.path}');
    }
  }
}

// 只修改文件名
void renameJava2Dart(String dir) {
  readDir(dir);
}

// 修改文件名并修改文件内容
void renameAndEdit(String dir) {
  throw UnimplementedError("renameAndEdit not implements");
}

void main(List<String> args) {
  // String srcDir = r"D:\carbon\jtsd\lib\src";
  // renameJava2Dart(srcDir);
  editFile(r"C:\Users\ruier\projections\jtsd\jtscore4dart\lib\src2\test1.dart");
}
