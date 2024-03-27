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
 * Implements a timer function which can compute
 * elapsed time as well as split times.
 *
 * @version 1.7
 */
class Stopwatch {

 /**private */int startTimestamp;
 /**private */int totalTime = 0;
 /**private */bool isRunning = false;

  Stopwatch()
  {
    start();
  }

  void start()
  {
    if (isRunning) return;
    startTimestamp = System.currentTimeMillis();
    isRunning = true;
  }

  int stop()
  {
    if (isRunning) {
      updateTotalTime();
      isRunning = false;
    }
    return totalTime;
  }

  void reset()
  {
    totalTime = 0;
    startTimestamp = System.currentTimeMillis();
  }

  int split()
  {
    if (isRunning)
      updateTotalTime();
    return totalTime;
  }

 /**private */void updateTotalTime()
  {
    int endTimestamp = System.currentTimeMillis();
    int elapsedTime = endTimestamp - startTimestamp;
    startTimestamp = endTimestamp;
    totalTime += elapsedTime;
  }

  int getTime()
  {
    updateTotalTime();
    return totalTime;
  }

  String getTimeString()
  {
    int totalTime = getTime();
    return getTimeString(totalTime);
  }

  static String getTimeString(long timeMillis) {
    String totalTimeStr = timeMillis < 10000 
        ? timeMillis + " ms" 
        : (double) timeMillis / 1000.0 + " s";
    return totalTimeStr;
  }
}
