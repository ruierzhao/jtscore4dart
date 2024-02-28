/// 将java源文件转为dart
///
/// 1.修改文件名
/// 2.修改代码

// ignore_for_file: non_constant_identifier_names, avoid_print

import 'dart:collection';
import 'dart:io';

import 'package:path/path.dart' as p;

/// 单行处理函数
/// 输入一行 返回修改后的 新行
typedef EditerFileFunc = String Function(String codeSegment);

/// 一行一行修改
///
/// 重写List 类保存处理函数
class ListEditorFunc extends ListBase<EditerFileFunc> {
  final List<EditerFileFunc> _handles = [];
  @override
  int get length => _handles.length;

  @override
  set length(int newlength) {
    _handles.length = newlength;
  }

  @override
  operator [](int index) {
    return _handles[index];
  }

  @override
  void operator []=(int index, value) {
    _handles[index] = value;
  }

  @override
  void add(EditerFileFunc element) {
    // 重写父类方法，防止重复添加处理函数
    if (!_handles.contains(element)) {
      _handles.add(element);
    }
  }

  @override
  void addAll(Iterable<EditerFileFunc> iterable) {
    // 重写父类方法，防止重复添加处理函数
    for (var editerFileFunc in iterable) {
      add(editerFileFunc);
    }
  }

  ListEditorFunc(); // 默认无处理构造，按需添加处理函数

  ListEditorFunc.defalutHandler() {
    // 初始化构造，注册所有处理函数
    registry();
  }

  void registry() {
    addAll(<EditerFileFunc>[
      _removeLine,
      _edit,
      _replace,
    ]);
  }

  /// delete word
  static const String pattern_Delete_Public = "public ";

  /// delete line
  static const String pattern_package_line = "package "; // startwith

  /// replace code
  static const String pattern_boolean = "boolean";
  static const String pattern_boolean_to = "bool";
  static const String pattern_hashmap = "HashMap";
  static const String pattern_hashmap_to = "Map";
  static const String pattern_listCoordinate = "Coordinate[]";
  static const String pattern_listCoordinate_to = "List<Coordinate>";
  static const String pattern_err = "IllegalArgumentException";
  static const String pattern_err_to = "ArgumentError";

  /// 正则替换规则
  static const String pattern_math_abs = "Math.abs";
  static const String pattern_math_abs_to = "";

  static RegExp absRegexp = RegExp(
      r"(?<abs>(?<=abs\()(.+?)(?=\)))"); // () 小括号 - (?<ruier> 匹配表达式 ) // Math.abs(p.x - p0.x) -> (p.x - p0.x).abs()
  /// dart正则匹配小括号 原文链接：https://blog.csdn.net/qq_52421092/article/details/126106237
  static RegExp regexp2 = RegExp(r"/(?<=\[)(.+?)(?=\])/g"); // [] 中括号
  static RegExp regexp3 = RegExp(r"/(?<=\{)(.+?)(?=\})/g"); // {} 花括号，大括号

  static String _replace(String codeSegment) {
    // TODO: 从文件读取转换规则 like: ./trans.rule
    return codeSegment
        .replaceAll(pattern_Delete_Public, "") // del public
        .replaceAll(pattern_boolean, pattern_boolean_to) // boolean -> bool
        .replaceAll(pattern_hashmap, pattern_hashmap_to) // HashMap -> Map
        //IllegalArgumentException -> ArgumentError
        .replaceAll(pattern_err, pattern_err_to)
        // Coordinate[] -> List<Coordinate>
        .replaceAll(pattern_listCoordinate, pattern_listCoordinate_to);
  }

  // delete "package ... " line
  static String _removeLine(String codeSegment) {
    if (codeSegment.startsWith(pattern_package_line)) {
      return "";
    } else {
      return codeSegment;
    }
  }

  /// 通过正则匹配修改
  ///
  /// Math.abs(p.x - p0.x) -> (p.x - p0.x).abs()
  static String _edit(String codeSegment) {
    String replaceMathAbs(String codeSegment) {
      // Math.abs(p.x - p0.x) -> (p.x - p0.x).abs()
      bool matched = absRegexp.hasMatch(codeSegment);
      if (matched) {
        var cc = absRegexp.allMatches(codeSegment);
        for (var c in cc) {
          var value = c.namedGroup("abs");
          String oldCode = "Math.abs($value)";
          String replaceCode = "($value).abs()";
          codeSegment = codeSegment.replaceAll(oldCode, replaceCode);
        }
      }
      return codeSegment;
    }

    String newcode = replaceMathAbs(codeSegment);
    return newcode;
  }

  /// 处理转换后的整个文件
  // ignore: unused_element
  static String _handleAllFile(String codeSegment) {
    throw UnimplementedError();
  }
}

class Editor {
  late File f;
  late String filepath;

  Editor();
  Editor.fromFile(this.f) : filepath = f.path;

  Editor.fromFileName(this.filepath) : f = File(filepath);

  final ListEditorFunc _editorFuncs = ListEditorFunc.defalutHandler();

  String _srcExt = "java";
  String _targetExt = "dart";

  void addEditFun(EditerFileFunc editfunc) {
    _editorFuncs.add(editfunc);
  }

  void registryAllHandler() {
    _editorFuncs.registry();
  }

  get tagetFilePath => p.setExtension(f.path, ".$_targetExt");

  // void setTargetExt(String ext) {
  //   if (ext.startsWith(".")) {
  //     _targetExt = ext.replaceFirst(".", "");
  //   } else {
  //     _targetExt = ext;
  //   }
  // }
  void setTargetExt(String ext) => ext.startsWith(".")
      ? _targetExt = ext.replaceFirst(".", "")
      : _targetExt = ext;

  void setFile(String filepath) {
    this.filepath = filepath;
    f = File(filepath);
  }

  String getFile() {
    return filepath;
  }

  void setSrcExt(String ext) {
    _srcExt = ext;
  }

  String getSrcExt() {
    return _srcExt;
  }

  /// 一行一行读取修改
  Future<String> editLineByLine() {
    if (_editorFuncs.isEmpty) {
      print("没有处理函数, maybe call `setFile` and then try again.");
      exit(0); // 没有处理函数，退出。。。
    }
    if (f == null) {
      print("没有设置处理哪个文件, maybe call `addEditFun` and then try again.");
      exit(0); // 没有处理函数，退出。。。
    }
    return f.readAsLines().then((lines) {
      return Future(() {
        StringBuffer sb = StringBuffer();
        for (var line in lines) {
          String newline = line;
          for (var editer in _editorFuncs) {
            if (newline.isEmpty) {
              // 跳过空行 有时候editor 返回空值
              break;
            }
            newline = editer(newline);
          }
          sb.write(newline);
          sb.write("\n");
        }
        // 返回修改完成的整个文件
        return sb.toString();
      });
    });
  }

  /// TODO：如果java -> dart 情况下存在dart 文件，会将原有dart 文件删除并创建 .edit 副本。
  void save2newFile(String newContents) {
    // print("save2newFile");
    // 先创建xin文件
    File f;
    f = File(tagetFilePath);

    if (f.existsSync()) {
      print("文件$tagetFilePath 已存在");
      String newfilepath =
          "$tagetFilePath.${DateTime.now().microsecondsSinceEpoch}.edit";
      f = File(newfilepath);
    }
    try {
      f.createSync();
    } on FileSystemException catch (e) {
      print("创建文件失败：$e");
      throw FileSystemException("文件 ${f.path} 创建失败。");
      // print("修改的文件将会覆盖写入原来的文件：$tagetFilePath");
    }
    // 写入内容
    f.writeAsString(newContents);
    // 删除原来文件
    deleteCurrFile();
  }

  void deleteCurrFile() {
    try {
      f.deleteSync();
    } catch (e) {
      print("删除文件失败：$e");
    }
  }

  void saveNewContents(String newContents) {
    f.writeAsString(newContents); // 覆盖原文件
  }
}

/// 递归读取文件夹的回调函数
typedef ReadDirCallback = void Function(
  String filename,
  bool needRename,
  Editor editor, {
  int? i,
}); //void editFile(String filename, bool needRename, Editor? editor)

// 修改代码源文件
/// [i] 处理第i个文件。debug 参数
void editFile(String filename, bool needRename, Editor editor, {int? i}) {
  if (editor.getFile() != filename) {
    print(">>>> 编辑的文件不一致。。");
    return;
  }

  print("开始处理${i != null ? '第 $i 个' : ''}文件: $filename");
  editor.editLineByLine().then((value) {
    // File oldFile = value.$1;
    String editedString = value;

    if (needRename) {
      editor.save2newFile(editedString);
    } else {
      // 覆盖原来的文件
      editor.saveNewContents(editedString);
    }
    print("${i != null ? '第 $i 个' : ''}文件: $filename 处理完成。。");
  });
}

/// 递归读取[currDir]文件夹下的文件并编辑
void readDirAndEditFile(
  String currDir,
  ReadDirCallback callbackHandler, {
  Editor? editor,
  srcExt = "java", // 判断编辑文件的类型，不是此类型就跳过
  needRename = false,
  onlyRename = false,
}) {
  if (onlyRename) {
    return renameJava2Dart(currDir);
  }
  Directory dir = Directory(currDir);
  List<FileSystemEntity> dirlist = dir.listSync(recursive: true);
  // print('==============${dirlist.length}====================='); // 649

  int i = 0;
  for (var path in dirlist) {
    i++;
    var filestat = path.statSync();

    var srcName = path.path;
    // editor ??= Editor(); // 初始化编辑器 // 异步函数不能起作用
    // editor.setFile(srcName);
    if (FileSystemEntityType.file == filestat.type &&
        (srcName.endsWith(".$srcExt") /** 粗略判断文件类型 || srcName.endsWith(".dart")*/
        )) {
      callbackHandler(srcName, needRename, Editor.fromFileName(srcName), i: i);
    } else {
      print('======dir:${path.path}');
      print('===文件夹：第 $i / ${dirlist.length} 个FileSystemEntity,'
          ' finished: ${(100 * i / dirlist.length).toStringAsFixed(2)}%  ==================');
    }
  }
}

// 只修改文件名
void renameJava2Dart(
  String dir,
) {
// 递归读取当前文件夹下的文件及目录
  ((
    String currDir, {
    srcExt = "java",
    targetExt = "dart",
  }) {
    Directory dir = Directory(currDir);
    List<FileSystemEntity> dirlist = dir.listSync(recursive: true);
    print('==============${dirlist.length}====================='); // 649
    var i = 0, dirlistLen = dirlist.length;
    for (var path in dirlist) {
      i++;
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
        print('Finished:${100 * i / dirlistLen}%');
      }
    }
  })(dir);
}

void main(List<String> args) {
  // String srcDir = r"D:\carbon\jtsd\lib\src2";
  String srcDir = r"C:\Users\ruier\projections\jtsd\jtscore4dart\lib\src";

  readDirAndEditFile(srcDir, editFile, needRename: true);

  // editFile(r"C:\Users\ruier\projections\jtsd\jtscore4dart\lib\src2\test.dart",
  //     editor: editor);
}
