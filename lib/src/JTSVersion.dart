// ignore_for_file: slash_for_doc_comments

/*
 * Copyright (c) 2016 Vivid Solutions.
 *
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse  License 2.0
 * and Eclipse Distribution License v. 1.0 which accompanies this distribution.
 * The Eclipse  License is available at http://www.eclipse.org/legal/epl-v20.html
 * and the Eclipse Distribution License is available at
 *
 * http://www.eclipse.org/org/documents/edl-v10.php.
 */

library jtsd.version;

/**
 * JTS API version information.
 * <p>
 * Versions consist of a 3-part version number: <code>major.minor.patch</code>
 * An optional release status string may be present in the string version of
 * the version.
 *
 * @version 1.7
 */
class JTSVersion {

  /**
   * The current version number of the JTS API.
   */
  static final JTSVersion CURRENT_VERSION = new JTSVersion();

  /**
   * The major version number.
   */
   static const int MAJOR = 1;

  /**
   * The minor version number.
   */
   static const int MINOR = 20;

  /**
   * The patch version number.
   */
   static const int PATCH = 0;

  /**
   * An optional string providing further release info (such as "alpha 1");
   */
   static const String RELEASE_INFO = "SNAPSHOT";


  /**
   * Gets the major number of the release version.
   *
   * @return the major number of the release version.
   */
   int getMajor() { return MAJOR; }

  /**
   * Gets the minor number of the release version.
   *
   * @return the minor number of the release version.
   */
   int getMinor() { return MINOR; }

  /**
   * Gets the patch number of the release version.
   *
   * @return the patch number of the release version.
   */
   int getPatch() { return PATCH; }

  /**
   * Gets the full version number, suitable for display.
   *
   * @return the full version number, suitable for display.
   */
   String toString()
  {
    String ver = "$MAJOR.$MINOR.$PATCH";
    if (RELEASE_INFO.isNotEmpty)
      return ver + " " + RELEASE_INFO;
    return ver;
  }

}

