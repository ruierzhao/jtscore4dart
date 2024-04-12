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


/// Provides constants representing the dimensions of a point, a curve and a surface.
/// Also provides constants representing the dimensions of the empty geometry and
/// non-empty geometries, and the wildcard constant {@link #DONTCARE} meaning "any dimension".
/// These constants are used as the entries in {@link IntersectionMatrix}s.
/// 
/// @version 1.7
class Dimension {

  ///  Dimension value of a point (0).
  static const int P = 0;

  ///  Dimension value of a curve (1).
  static const int L = 1;

  ///  Dimension value of a surface (2).
  static const int A = 2;

  ///  Dimension value of the empty geometry (-1).
  static const int FALSE = -1;

  ///  Dimension value of non-empty geometries (= {P, L, A}).
  static const int TRUE = -2;

  ///  Dimension value for any dimension (= {FALSE, TRUE}).
  static const int DONTCARE = -3;

  /// Symbol for the FALSE pattern matrix entry
  static const String SYM_FALSE = 'F';
  
  /// Symbol for the TRUE pattern matrix entry
  static const String SYM_TRUE = 'T';
  
  /// Symbol for the DONTCARE pattern matrix entry
  static const String SYM_DONTCARE = '*';
  
  /// Symbol for the P (dimension 0) pattern matrix entry
  static const String SYM_P = '0';
  
  /// Symbol for the L (dimension 1) pattern matrix entry
  static const String SYM_L = '1';
  
  /// Symbol for the A (dimension 2) pattern matrix entry
  static const String SYM_A = '2';
  
  ///  Converts the dimension value to a dimension symbol, for example, <code>TRUE =&gt; 'T'</code>
  ///  .
  ///
  ///@param  [dimensionValue]  a number that can be stored in the <code>IntersectionMatrix</code>
  ///      . Possible values are <code>{TRUE, FALSE, DONTCARE, 0, 1, 2}</code>.
  ///@return                 a character for use in the string representation of
  ///      an <code>IntersectionMatrix</code>. Possible values are <code>{T, F, * , 0, 1, 2}</code>
  ///      .
  static String toDimensionSymbol(int dimensionValue) {
    switch (dimensionValue) {
      case FALSE:
        return SYM_FALSE;
      case TRUE:
        return SYM_TRUE;
      case DONTCARE:
        return SYM_DONTCARE;
      case P:
        return SYM_P;
      case L:
        return SYM_L;
      case A:
        return SYM_A;
    }
    throw ArgumentError("Unknown dimension value: $dimensionValue" );
  }

  ///  Converts the dimension symbol to a dimension value, for example, <code>'*' =&gt; DONTCARE</code>
  ///  .
  ///
  ///@param  [dimensionSymbol]  a character for use in the string representation of
  ///      an <code>[IntersectionMatrix]</code>. Possible values are <code>{T, F, * , 0, 1, 2}</code>
  ///      .
  ///@return a number that can be stored in the <code>IntersectionMatrix</code>
  ///      . Possible values are <code>{TRUE, FALSE, DONTCARE, 0, 1, 2}</code>.
  static int toDimensionValue(String dimensionSymbol) {
    // switch (Character.toUpperCase(dimensionSymbol)) {
    switch ((dimensionSymbol).toUpperCase()) {
      case SYM_FALSE:
        return FALSE;
      case SYM_TRUE:
        return TRUE;
      case SYM_DONTCARE:
        return DONTCARE;
      case SYM_P:
        return P;
      case SYM_L:
        return L;
      case SYM_A:
        return A;
    }
    throw ArgumentError("Unknown dimension symbol: $dimensionSymbol");
  }
}


