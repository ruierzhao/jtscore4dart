/// dart 语法测试
// ================================================test================================================
import 'dart:io';

import 'j2d.dart';

test_registry(){
  ListEditorFunc listediter = ListEditorFunc.defalutHandler();
  listediter.registry();
  listediter.add((codeSegment) {
    print(codeSegment);
    return "";
  },);
  print(listediter.length);
}
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
  // testreplace();
  // testreplace2();
  // test_registry();
}

