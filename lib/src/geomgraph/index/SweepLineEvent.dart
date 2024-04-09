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
 /**private */static const int INSERT = 1;
 /**private */static const int DELETE = 2;

 /**private */Object? label;    // used for red-blue intersection detection
 /**private */double xValue;
 /**private */late int eventType;
 /**private */SweepLineEvent? insertEvent = null; // null if this is an INSERT event
 /**private */int? deleteEventIndex;
 /**private */Object? obj;

  /**
   * Creates an INSERT event.
   * 
   * @param label the edge set label for this object
   * @param xValue the event location
   * @param obj the object being inserted
   */
  SweepLineEvent.insert(this.label, this.xValue, this.obj)
  {
    this.eventType = INSERT;
  }

  /**
   * Creates a DELETE event.
   * 
   * @param x the event location
   * @param insertEvent the corresponding INSERT event
   */
  SweepLineEvent.delete(this.xValue, SweepLineEvent this.insertEvent)
  {
    this.eventType = DELETE;
  }

  bool isInsert() { return eventType == INSERT; }
  bool isDelete() { return eventType == DELETE; }
  SweepLineEvent? getInsertEvent() { return insertEvent; }
  int? getDeleteEventIndex() { return deleteEventIndex; }
  void setDeleteEventIndex(int deleteEventIndex) { this.deleteEventIndex = deleteEventIndex; }

  Object? getObject() { return obj; }

  bool isSameLabel(SweepLineEvent ev)
  {
    // no label set indicates single group
    if (label == null) return false;
    return label == ev.label;
  }
  /**
   * Events are ordered first by their x-value, and then by their eventType.
   * Insert events are sorted before Delete events, so that
   * items whose Insert and Delete events occur at the same x-value will be
   * correctly handled.
   */
  @override
  int compareTo(dynamic o) {
    SweepLineEvent pe = o as SweepLineEvent;
    if (xValue < pe.xValue) return  -1;
    if (xValue > pe.xValue) return   1;
    if (eventType < pe.eventType) return  -1;
    if (eventType > pe.eventType) return   1;
    return 0;
  }


}
