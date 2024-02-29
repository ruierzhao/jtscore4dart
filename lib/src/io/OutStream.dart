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


// import java.io.IOException;

/**
 * A abstract class for classes providing an output stream of bytes.
 * This abstract class is similar to the Java <code>OutputStream</code>,
 * but with a narrower abstract class to make it easier to implement.
 */
abstract class OutStream
{
  void write(byte[] buf, int len) throws IOException;
}
