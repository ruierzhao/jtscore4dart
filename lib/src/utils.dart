import "dart:math";

import "package:collection/collection.dart";


// 补充的 java 方法
double hypot(double dx, double dy){
  return sqrt(dx * dx + dy * dy);
}

bool equalsWithTolerance(double x1, double x2, double tolerance)
{
  return (x1 - x2).abs() <= tolerance;
}


/// Utilities for collections
class CollectionsUtils {
  /// Shift a list of items from a given [index] to the first position.
  static List<T>? shiftToFirst<T>(List<T>? list, int index) {
    if (list == null || list.isEmpty) return list;
    if (index > list.length - 1) {
      throw ArgumentError(
          "The shift index can't be bigger than the list size.");
    }
    return list.sublist(index)..addAll(list.sublist(0, index));
  }

  /// Removes subsequent equal items from a [list].
  static List<T> removeRepeated<T>(List<T> list) {
    List<T> newList = [];
    for (int i = 1; i < list.length; i++) {
      if (list[i - 1] != list[i]) {
        newList.add(list[i - 1]);
      }
    }
    if (newList.last != list.last) {
      newList.add(list.last);
    }
    return newList;
  }

  /// CHecks if there are subsequent repeating items.
  static bool hasRepeated<T>(List<T> list) {
    for (var i = 1; i < list.length; i++) {
      if (list[i - 1] == list[i]) {
        return true;
      }
    }
    return false;
  }

  static bool addIfNotEqualToLast<T>(List<T> list, T item) {
    if (list.isEmpty || list.last == item) {
      list.add(item);
      return true;
    }
    return false;
  }

  static bool areEqual<T>(List<T> listA, List<T> listB) {
    Function eq = const ListEquality().equals;
    return eq(listA, listB);
  }
}


class StringUtils {
  static bool isDigit(String s, int idx) => (s.codeUnitAt(idx) ^ 0x30) <= 9;

  static bool equalsIgnoreCase(String string1, String string2) {
    return string1.toLowerCase() == string2.toLowerCase();
  }

  static String replaceCharAt(String oldString, int index, String newChar) {
    return oldString.substring(0, index) +
        newChar +
        oldString.substring(index + 1);
  }
}
