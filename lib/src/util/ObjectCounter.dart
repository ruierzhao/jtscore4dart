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


// import java.util.Map;
// import java.util.Map;

import 'package:jtscore4dart/src/patch/Map.dart';

/**
 * Counts occurrences of objects.
 * 
 * @author Martin Davis
 *
 */
class ObjectCounter 
{

 /**private */Map counts = new Map();
  
  ObjectCounter();

  void add(Object o)
  {
    Counter counter = counts.get(o);
    if (counter == null) {
      counts.put(o, new Counter(1));
    } else {
      counter.increment();
    }
  }
  
  // TODO: add remove(Object o)
  
  int count(Object o)
  {
    Counter counter = counts.get(o);
    if (counter == null) {
      return 0;
    } else {
      return counter.count;
    }
   
  }
  
}


 /**private static*/ class Counter
  {
    // int count = 0;
    int count;
    
    Counter([this.count=0])
    {
      this.count = count;
    }
    /// TODO: @ruier edit.
    // int count()
    // {
    //   return count;
    // }
    
    void increment()
    {
      count++;
    }
  }
