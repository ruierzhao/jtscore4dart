/// 将java源文件转为dart

// ignore_for_file: non_constant_identifier_names, avoid_print

import 'dart:collection';
import 'dart:io';
import 'dart:math';

import 'package:path/path.dart' as p;

/// 单行处理函数
/// 输入一行 返回修改后的 新行
typedef EditerFileFunc = String Function(String codeSegment);

/// 递归读取文件夹的回调函数
typedef ReadDirCallback = void Function(String filename);

class ListEditorFunc extends ListBase<EditerFileFunc> {
  final List<EditerFileFunc> _handles = [];
  @override
  int get length => _handles.length;
  // @override
  // bool get isEmpty => length == 0;

  @override
  operator [](int index) {
    return _handles[index];
  }

  @override
  void operator []=(int index, value) {
    _handles[index] = value;
  }

  @override
  set length(int length) {
    _handles.length = length;
  }

  @override
  void add(EditerFileFunc element) {
    if (!_handles.contains(element)) {
      super.add(element);
    }
  }

  ListEditorFunc(); // 默认无处理构造，按需添加处理函数

  ListEditorFunc.registry() {
    // 初始化构造，注册所有处理函数
    _handles.addAll(<EditerFileFunc>[
      _deletePublic,
      _removeLine,
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
  static const String pattern_listCoordinate = "Coordinate[]";
  static const String pattern_listCoordinate_to = "List<Coordinate>";
  static const String pattern_math_abs = "Math.abs";
  static const String pattern_math_abs_to = "";

  static RegExp absRegexp =
      RegExp(r"(?<abs>(?<=abs\()(.+?)(?=\)))"); // () 小括号 - (?<ruier> 匹配表达式 ) // Math.abs(p.x - p0.x) -> (p.x - p0.x).abs()

  /// dart正则匹配小括号 原文链接：https://blog.csdn.net/qq_52421092/article/details/126106237
  static RegExp regexp2 = RegExp(r"/(?<=\[)(.+?)(?=\])/g"); // [] 中括号
  static RegExp regexp3 = RegExp(r"/(?<=\{)(.+?)(?=\})/g"); // {} 花括号，大括号

  static String _deletePublic(String codeSegment) {
    print("<< _deletePublic");
    return codeSegment.replaceAll(pattern_Delete_Public, "");
    // if (codeSegment.contains(pattern_Delete_Public)) {
    //   return codeSegment.replaceAll("public ", "");
    // }else{
    //   return codeSegment;
    // }
  }

  // delete "package ... " line
  static String _removeLine(String codeSegment) {
    print("<< _removeLine");
    if (codeSegment.startsWith(pattern_package_line)) {
      return "";
    } else {
      return codeSegment;
    }
  }

  /// Math.abs(p.x - p0.x) -> (p.x - p0.x).abs()
  static String _replace(String codeSegment) {
    print("<< _replace");
    String replaceMathAbs(String codeSegment){ // Math.abs(p.x - p0.x) -> (p.x - p0.x).abs()
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
}

class Editor {
  late File f;

  Editor(this.f);

  Editor.fromFileName(String filename) : f = File(filename);

  final ListEditorFunc _editorFuncs = ListEditorFunc.registry();

  String _srcExt = "java";
  String _targetExt = "dart";

  void addEditFun(EditerFileFunc editfunc) {
    _editorFuncs.add(editfunc);
  }

  get tagetFilePath => p.setExtension(f.path, ".$_targetExt");

  void setTargetExt(String ext) {
    if (ext.startsWith(".")) {
      _targetExt = ext.replaceFirst(".", "");
    } else {
      _targetExt = ext;
    }
  }

  void setSrcExt(String ext) {
    _srcExt = ext;
  }

  /// 一行一行读取修改
  Future<(File, String)> editLineByLine() {
    if (_editorFuncs.isEmpty) {
      print("没有处理函数, maybe call `addEditFun` and then try again.");
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
        return (f, sb.toString());
      });
    });
  }

  void save2newFile(String newContents) {
    print("save2newFile");
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

/// 递归读取[currDir]文件夹下的文件及目录
void readDirAndEditFile(String currDir, ReadDirCallback callbackHandler,
    {srcExt = "java", targetExt = "dart"}) {
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
        callbackHandler(srcName);
        // String newname = srcName.replaceAll(srcExt, targetExt);
        // File(srcName).renameSync(newname);
      }
    } else {
      print('======dir:${path.path}');
    }
  }
}

// 只修改文件名
void renameJava2Dart(String dir) {
// 递归读取当前文件夹下的文件及目录
  ((String currDir, {srcExt = "java", targetExt = "dart"}) {
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

// 修改代码源文件
void editFile(String filename, {bool needRename = false}) {
  Editor editor = Editor.fromFileName(filename);

  editor.editLineByLine().then((value) {
    File oldFile = value.$1;
    String editedString = value.$2;

    if (needRename) {
      print(" >>> needRename...");
      editor.save2newFile(editedString);
    } else {
      // 覆盖原来的文件
      editor.saveNewContents(editedString);
    }
  });
}

// 修改文件内容并修改文件名
void renameAndEdit(String dir) {
  throw UnimplementedError("renameAndEdit not implements");
}

void main(List<String> args) {
  // String srcDir = r"D:\carbon\jtsd\lib\src";
  // renameJava2Dart(srcDir);
  // var editor = Editor.fromFileName(r"C:\Users\ruier\projections\jtsd\jtscore4dart\lib\src2\test1.dart");

  // editFile(r"C:\Users\ruier\projections\jtsd\jtscore4dart\lib\src2\test1.dart");

  // var f =
  //     File(r"C:\Users\ruier\projections\jtsd\jtscore4dart\lib\src2\test1.dart");
  // print(f.path);
  // test_P_split();
  // testreplace();
  // test_break();
  testreplace();
  // testreplace2();
}

// ========================test========================
void test_regEpx() {
  var str2 = "123{456}hhh[789]zzz[yyy]bbb(90ba)kkk";
  RegExp regexp1 = RegExp(r"(?<=\()(.+?)(?=\))");
  // [] 中括号
  RegExp regexp2 = RegExp(r"(?<=\[)(.+?)(?=\])");
// {} 花括号，大括号
  RegExp regexp3 = RegExp(r"(?<=\{)(.+?)(?=\})");

  print(regexp1.stringMatch(str2)); //['90ba']
// print(regexp1.firstMatch(str2)); //['90ba']
//['789', 'yyy']
// regexp2.allMatches(str2);
// print(regexp3.allMatches(str2).toList());//['456']

  RegExp exp = RegExp(
      r'^((13[0-9])|(14[0-9])|(15[0-9])|(16[0-9])|(17[0-9])|(18[0-9])|(19[0-9]))\d{8}$');
  bool matched = exp.hasMatch("15288144694");
  print(matched);
// 链接：https://juejin.cn/post/6943101444773904420
}

test_break() {
  var ccs = List<int>.generate(10, (index) => 2 * index);
  for (var i = 0; i < 5; i++) {
    print("<< $i");
    for (var cc in ccs) {
      if (cc > 6) {
        break;
      }
      print(cc);
    }
  }
}

void testreplace() {

  String replaceMathAbs(String codeSegment){ // Math.abs(p.x - p0.x) -> (p.x - p0.x).abs()
    RegExp absRegexp =
        RegExp(r"(?<abs>(?<=abs\()(.+?)(?=\)))"); // (?<ruier> 匹配表达式 )
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
  /// TODO: 测试完成
  String abstr1 =
      "double pdx = Math.abs(p.x - p0.x) -  Math.abs(p1.x - p2.x);"; //Math.abs(p.x - p0.x) -> (p.x - p0.x).abs()
  String abstr2 = "double xAbs = Math.abs(cc);";
  String abstr3 = "double xAbs = Math.log(x);";

  // RegExp regexp1 = RegExp(r"(?<小括号>(?<=\()(.+?)(?=\)))"); // (?<ruier> 匹配表达式 )
  RegExp regexp1 =
      RegExp(r"(?<abs>(?<=abs\()(.+?)(?=\)))"); // (?<ruier> 匹配表达式 )
var cc = replaceMathAbs(abstr3);
print('==============${cc}=====================');

}

void testreplace2() {
  const pattern =
      r'^\[(?<Time>\s*((?<hour>\d+)):((?<minute>\d+))\.((?<ruier>\d+)))\]'
      r'\s(?<Message>\s*(.*)$)';

  final regExp = RegExp(
    pattern,
    multiLine: true,
  );
  const multilineText = '[00:13.37] This is a first message.\n'
      '[01:15.57] This is a second message.\n';

  RegExpMatch regExpMatch = regExp.firstMatch(multilineText)!;
  // var regExpMatch = regExp.allMatches(multilineText);
  // for (var cc in regExpMatch) {
  //   print(cc.groupCount);
  //   // print(cc[0]);
  //   for (var i = 0; i < cc.groupCount; i++) {
  //     print(cc.group(i));

  //   }
  // }
  print(regExpMatch.groupNames.join('-')); // hour-minute-second-Time-Message.
  final time = regExpMatch.namedGroup('Time'); // 00:13.37
  final hour = regExpMatch.namedGroup('hour'); // 00
  final minute = regExpMatch.namedGroup('minute'); // 13
  final second = regExpMatch.namedGroup('ruier'); // 37
  final message =
      regExpMatch.namedGroup('Message'); // This is the first message.
  // final date = regExpMatch.namedGroup('Date'); // Undefined `Date`, throws.

  Iterable<RegExpMatch> matches = regExp.allMatches(multilineText);
  for (final m in matches) {
    print(m.namedGroup('Time'));
    print(m.namedGroup('Message'));
    // 00:13.37
    // This is the first message.
    // 01:15.57
    // This is the second message.
  }
}

void test_P_split() {
  String tagetFilePath =
      r"C:\Users\ruier\projections\jtsd\jtscore4dart\lib\src2\test1.dart";
  File f = File(tagetFilePath);
  if (f.existsSync()) {
    var newfilepath =
        "$tagetFilePath.${DateTime.now().microsecondsSinceEpoch}.edit";
    print(newfilepath);
  }
}

void testReadAndThenWrite() {
  var f =
      File(r"C:\Users\ruier\projections\jtsd\jtscore4dart\lib\src2\test1.dart");
  f.readAsLines().then((value) {
    var newString = StringBuffer();
    for (var line in value) {
      print(line);
      String newline = line.replaceAll(",", "，");
      newString.write(newline);
      newString.write("\n");
    }
    f.writeAsString(newString.toString()); //会覆盖源文件
  });
}

void test_editFile() {
  String line = "   * @param g0 the 1st geometry";
  var cc = line.startsWith("*"); // false
  print(cc);
}

void test_emptyList() {
  var ccs = <int>[];
  for (var i = 0; i < 10; i++) {
    // 不会操作
    for (var cc in ccs) {
      print("ruier");
    }
  }
}

void test_Error() {
  print("normal");
  throw Error();
  // throw Exception("ruier");
}
