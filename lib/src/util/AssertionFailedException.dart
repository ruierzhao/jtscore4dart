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


///  Thrown when the application is in an inconsistent state. Indicates a problem
///  with the code.
///
///@version 1.7
class AssertionFailedException extends AssertionError {

  ///  Creates an <code>AssertionFailedException</code>.
  // AssertionFailedException() {
  //   super();
  // }

  ///  Creates a <code>AssertionFailedException</code> with the given detail
  ///  message.
  ///
  ///@param  message  a description of the assertion
  AssertionFailedException([String? message]) 
    :super(message);
}


