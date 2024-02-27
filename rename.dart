/// 将java重命名为dart

import 'dart:collection';
import 'dart:io';

// 单行处理函数
typedef EditerFileFunc = String Function(String codeSegment);

class ListEditorFunc extends ListBase<EditerFileFunc> {
  final List<EditerFileFunc> _handles = [];
  @override
  int get length => _handles.length;

  @override
  operator [](int index) {
    // TODO: implement []
    return _handles[index];
  }

  @override
  void operator []=(int index, value) {
    // TODO: implement []=
    _handles[index] = value;
  }

  @override
  set length(int length) {
    _handles.length = length;
  }

  ListEditorFunc() {
    _handles.add(_deletePublic);
  }

  static String _deletePublic(String codeSegment) {
    print("_deletePublic");
    return "newCodeSegments";
  }
}

class Editor {
  late File f;
  late Directory fileParentPath;
  late String _baseName;
  Editor(this.f);

  Editor.fromFileName(String filename) {
    f = File(filename);
    fileParentPath = f.parent;
    // _baseName = basename(f.path);
  }

  String srcExt = "java";
  String targetExt = "dart";

  Future<dynamic> init({
    bool needRename = true,
  }) {
    if (needRename) {
      // 需要重命名
      // 读取文件内容
      // 编辑完成之后写入新文件（边编辑边写入）
      // 删除源文件
      return f.readAsLines();
    } else {
      // 不需要重命名
      // 直接修改源文件
      return f.readAsString();
    }
  }

  /// 一行一行读取修改
  Future<dynamic> editLineByLine({ListEditorFunc? listEditorFunc ,bool needRename=true}) {
    return f.readAsLines().then((value){
      return Future(() {
        if (needRename){
          createNewFileByExt(targetExt);
        }
        for (var editer in listEditorFunc??[]) {
          String newLine =  editer(value);
        }
        return f;
      });
    });                                     
  }
  
  /// 读取整个文件修改
  // Future<String> editAll() {
  //   return f.readAsString();
  // }
  void createNewFileByExt(String targetExt) {
    
  }
}

// 修改代码源文件
void editFile(String filename) {
  Editor editor = Editor.fromFileName(filename);
  ListEditorFunc listEditorFunc = ListEditorFunc();
  editor.editLineByLine();
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
