/*
 * Copyright (c) 2016 Vivid Solutions.
 *
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License 2.0
 * and Eclipse Distribution License v. 1.0 which accompanies this distribution.
 * The Eclipse Public License is available at http://www.eclipse.org/legal/epl-v20.html
 * and the Eclipse Distribution License is available at
 *
 * http://www.eclipse.org/org/documents/edl-v10.php.
 */


/**
 *@version 1.7
 */
// import java.io.PrintStream;
// import java.lang.reflect.Method;
// import java.util.Collection;
// import java.util.Iterator;

// import org.locationtech.jts.geom.Coordinate;
// import org.locationtech.jts.geom.CoordinateSequence;
// import org.locationtech.jts.geom.CoordinateSequenceFilter;
// import org.locationtech.jts.geom.Geometry;
// import org.locationtech.jts.geom.GeometryFactory;
// import org.locationtech.jts.geom.LineString;


import 'package:jtscore4dart/geometry.dart';

/// Provides routines to simplify and localize debugging output.
/// Debugging is controlled via a Java system property value.
/// If the system property with the name given in
/// DEBUG_PROPERTY_NAME (currently "jts.debug") has the value
/// "on" or "true" debugging is enabled.
/// Otherwise, debugging is disabled.
/// The system property can be set by specifying the following JVM option:
/// <pre>
/// -Djts.debug=on
/// </pre>
/// 
///
/// @version 1.7
class Debug {

  static String DEBUG_PROPERTY_NAME = "jts.debug";
  static String DEBUG_PROPERTY_VALUE_ON = "on";
  static String DEBUG_PROPERTY_VALUE_TRUE = "true";

  /**private */ 
  static bool debugOn = false;
  /// TODO: @ruier edit.
  // static {
  //   String debugValue = System.getProperty(DEBUG_PROPERTY_NAME);
  //   if (debugValue != null) {
  //     if (debugValue.equalsIgnoreCase(DEBUG_PROPERTY_VALUE_ON)
  //         || debugValue.equalsIgnoreCase(DEBUG_PROPERTY_VALUE_TRUE) )
  //       debugOn = true;
  //   }
  // }

 /**private */static Stopwatch stopwatch = new Stopwatch();
 /**private */static int lastTimePrinted;

  /// Prints the status of debugging to <tt>System.out</tt>
  ///
  /// @param args the cmd-line arguments (no arguments are required)
  static void main(String[] args)
  {
    System.out.println("JTS Debugging is " +
                       (debugOn ? "ON" : "OFF") );
  }

 /**private */static final Debug debug = new Debug();
 /**private */static final GeometryFactory fact = new GeometryFactory();
 /**private */static final String DEBUG_LINE_TAG = "D! ";

 /**private */PrintStream out;
 /**private */Class[] printArgs;
 /**private */Object watchObj = null;
 /**private */Object[] args = new Object[1];

  static bool isDebugging() { return debugOn; }

  static LineString toLine(Coordinate p0, Coordinate p1) {
    return fact.createLineString(new List<Coordinate> { p0, p1 });
  }

  static LineString toLine(Coordinate p0, Coordinate p1, Coordinate p2) {
    return fact.createLineString(new List<Coordinate> { p0, p1, p2});
  }

  static LineString toLine(Coordinate p0, Coordinate p1, Coordinate p2, Coordinate p3) {
    return fact.createLineString(new List<Coordinate> { p0, p1, p2, p3});
  }

  static void print(String str) {
    if (!debugOn) {
      return;
    }
    debug.instancePrint(str);
  }
/*
  static void println(String str) {
    if (! debugOn) return;
    debug.instancePrint(str);
    debug.println();
  }
*/
  static void print(Object obj) {
    if (! debugOn) return;
    debug.instancePrint(obj);
  }

  static void print(bool isTrue, Object obj) {
    if (! debugOn) return;
    if (! isTrue) return;
    debug.instancePrint(obj);
  }

  static void println(Object obj) {
    if (!debugOn) {
      return;
    }
    debug.instancePrint(obj);
    debug.println();
  }
  
  static void resetTime()
  {
    stopwatch.reset();
    lastTimePrinted = stopwatch.getTime();
  }
  
  static void printTime(String tag)
  {
    if (!debugOn) {
      return;
    }
    int time = stopwatch.getTime();
    int elapsedTime = time - lastTimePrinted;
    debug.instancePrint(
        formatField(Stopwatch.getTimeString(time), 10)
        + " (" + formatField(Stopwatch.getTimeString(elapsedTime), 10) + " ) "
        + tag);
    debug.println();    
    lastTimePrinted = time;
  }
  
 /**private */static String formatField(String s, int fieldLen)
  {
    int nPad = fieldLen - s.length();
    if (nPad <= 0) return s;
    String padStr = spaces(nPad) + s;
    return padStr.substring(padStr.length() - fieldLen);
  }
  
 /**private */static String spaces(int n)
  {
    char[] ch = new char[n];
    for (int i = 0; i < n; i++) {
      ch[i] = ' ';
    }
    return new String(ch);
  }
  
  static bool equals(Coordinate c1, Coordinate c2, double tolerance)
  {
  	return c1.distance(c2) <= tolerance;
  }
  /// Adds an object to be watched.
  /// A watched object can be printed out at any time.
  /// 
  /// Currently only supports one watched object at a time.
  /// @param obj
  static void addWatch(Object obj) {
    debug.instanceAddWatch(obj);
  }

  static void printWatch() {
    debug.instancePrintWatch();
  }

  static void printIfWatch(Object obj) {
    debug.instancePrintIfWatch(obj);
  }

  static void breakIf(bool cond)
  {
    if (cond) doBreak();
  }
  
  static void breakIfEqual(Object o1, Object o2)
  {
    if (o1.equals(o2)) doBreak();
  }
  
  static void breakIfEqual(Coordinate p0, Coordinate p1, double tolerance)
  {
    if (p0.distance(p1) <= tolerance) doBreak();
  }
  
 /**private */static void doBreak()
  {
    // Put breakpoint on following statement to break here
    return; 
  }
  
  static bool hasSegment(Geometry geom, Coordinate p0, Coordinate p1)
  {
    SegmentFindingFilter filter = new SegmentFindingFilter(p0, p1);
    geom.apply(filter);
    return filter.hasSegment();
  }
  
 /**private */static class SegmentFindingFilter
  implements CoordinateSequenceFilter
  {
   /**private */Coordinate p0, p1;
   /**private */bool hasSegment = false;
    
    SegmentFindingFilter(Coordinate p0, Coordinate p1)
    {
      this.p0 = p0;
      this.p1 = p1;
    }

    bool hasSegment() { return hasSegment; }

    void filter(CoordinateSequence seq, int i)
    {
      if (i == 0) return;
      hasSegment = p0.equals2D(seq.getCoordinate(i-1)) 
          && p1.equals2D(seq.getCoordinate(i));
    }
    
    bool isDone()
    {
      return hasSegment; 
    }
    
    bool isGeometryChanged()
    {
      return false;
    }
  }
  
 /**private */Debug() {
    out = System.out;
    printArgs = new Class[1];
    try {
      printArgs[0] = Class.forName("java.io.PrintStream");
    }
    catch (Exception ex) {
      // ignore this exception - it will fail later anyway
    }
  }

  void instancePrintWatch() {
    if (watchObj == null) return;
    instancePrint(watchObj);
  }

  void instancePrintIfWatch(Object obj) {
    if (obj != watchObj) return;
    if (watchObj == null) return;
    instancePrint(watchObj);
  }

  void instancePrint(Object obj)
  {
    if (obj is Collection) {
      instancePrint(((Collection) obj).iterator());
    }
    else if (obj is Iterator) {
      instancePrint((Iterator) obj);
    }
    else {
      instancePrintObject(obj);
    }
  }

  void instancePrint(Iterator it)
  {
    while (it.hasNext()) {
      Object obj = it.current;
      instancePrintObject(obj);
    }
  }
  void instancePrintObject(Object obj) {
    //if (true) throw new RuntimeException("DEBUG TRAP!");
    Method printMethod = null;
    try {
      Class cls = obj.getClass();
      try {
        printMethod = cls.getMethod("print", printArgs);
        args[0] = out;
        out.print(DEBUG_LINE_TAG);
        printMethod.invoke(obj, args);
      }
      catch (NoSuchMethodException ex) {
        instancePrint(obj.toString());
      }
    }
    on Exception catch ( ex) {
      // ex.printStackTrace(out);
      PrintHandler;
    }
  }

  void println() {
    out.println();
  }

 /**private */
 void instanceAddWatch(var obj) {
    watchObj = obj;
  }

  /**private */
  void instancePrint(String str) {
    out.print(DEBUG_LINE_TAG);
    out.print(str);
  }

}
