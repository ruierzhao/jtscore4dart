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
 * @version 1.7
 */
class SweepLineEvent
  implements Comparable
{
  static final int INSERT = 1;
  static final int DELETE = 2;

  private double xValue;
  private int eventType;
  private SweepLineEvent insertEvent; // null if this is an INSERT event
  private int deleteEventIndex;

  SweepLineInterval sweepInt;
  SweepLineEvent(double x, SweepLineEvent insertEvent, SweepLineInterval sweepInt)
  {
    xValue = x;
    this.insertEvent = insertEvent;
    this.eventType = INSERT;
    if (insertEvent != null)
      eventType = DELETE;
    this.sweepInt = sweepInt;
  }

  bool isInsert() { return insertEvent == null; }
  bool isDelete() { return insertEvent != null; }
  SweepLineEvent getInsertEvent() { return insertEvent; }
  int getDeleteEventIndex() { return deleteEventIndex; }
  void setDeleteEventIndex(int deleteEventIndex) { this.deleteEventIndex = deleteEventIndex; }

  SweepLineInterval getInterval() { return sweepInt; }

  /**
   * ProjectionEvents are ordered first by their x-value, and then by their eventType.
   * It is important that Insert events are sorted before Delete events, so that
   * items whose Insert and Delete events occur at the same x-value will be
   * correctly handled.
   */
  int compareTo(Object o) {
    SweepLineEvent pe = (SweepLineEvent) o;
    if (xValue < pe.xValue) return  -1;
    if (xValue > pe.xValue) return   1;
    if (eventType < pe.eventType) return  -1;
    if (eventType > pe.eventType) return   1;
    return 0;
  }


}
