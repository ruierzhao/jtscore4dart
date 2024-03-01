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


///  A utility for making programming assertions.
///
///@version 1.7
class Assert {

  ///  Throws an <code>AssertionFailedException</code> if the given assertion is
  ///  not true.
  ///
  ///@param  assertion                  a condition that is supposed to be true
  ///@throws  AssertionFailedException  if the condition is false
  static void isTrue(bool assertion) {
    isTrue(assertion, null);
  }

  ///  Throws an <code>AssertionFailedException</code> with the given message if
  ///  the given assertion is not true.
  ///
  ///@param  assertion                  a condition that is supposed to be true
  ///@param  message                    a description of the assertion
  ///@throws  AssertionFailedException  if the condition is false
  static void isTrue(bool assertion, String message) {
    if (!assertion) {
      if (message == null) {
        throw new AssertionFailedException();
      }
      else {
        throw new AssertionFailedException(message);
      }
    }
  }

  ///  Throws an <code>AssertionFailedException</code> if the given objects are
  ///  not equal, according to the <code>equals</code> method.
  ///
  ///@param  expectedValue              the correct value
  ///@param  actualValue                the value being checked
  ///@throws  AssertionFailedException  if the two objects are not equal
  static void equals(Object expectedValue, Object actualValue) {
    equals(expectedValue, actualValue, null);
  }

  ///  Throws an <code>AssertionFailedException</code> with the given message if
  ///  the given objects are not equal, according to the <code>equals</code>
  ///  method.
  ///
  ///@param  expectedValue              the correct value
  ///@param  actualValue                the value being checked
  ///@param  message                    a description of the assertion
  ///@throws  AssertionFailedException  if the two objects are not equal
  static void equals(Object expectedValue, Object actualValue, String message) {
    if (!actualValue.equals(expectedValue)) {
      throw new AssertionFailedException("Expected $expectedValue but encountered "
           + actualValue + (message != null ? ": " + message : ""));
    }
  }

  ///  Always throws an <code>AssertionFailedException</code>.
  ///
  ///@throws  AssertionFailedException  thrown always
  // TODO: ruier edit.
  // static void shouldNeverReachHere() {
  //   shouldNeverReachHere();
  // }

  ///  Always throws an <code>AssertionFailedException</code> with the given
  ///  message.
  ///
  ///@param  message                    a description of the assertion
  ///@throws  AssertionFailedException  thrown always
  static void shouldNeverReachHere([String? message]) {
    // throw AssertionFailedException("Should never reach here"+ (message != null ? ": " + message : ""));
    var _massage = message != null ? ": $message": "";
    throw AssertionFailedException("Should never reach here $_massage");
  }
}

