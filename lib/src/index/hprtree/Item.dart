/*
 * Copyright (c) 2019 Martin Davis.
 *
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License 2.0
 * and Eclipse Distribution License v. 1.0 which accompanies this distribution.
 * The Eclipse Public License is available at http://www.eclipse.org/legal/epl-v20.html
 * and the Eclipse Distribution License is available at
 *
 * http://www.eclipse.org/org/documents/edl-v10.php.
 */


import org.locationtech.jts.geom.Envelope;

class Item {

  private Envelope env;
  private Object item;

  Item(Envelope env, Object item) {
    this.env = env;
    this.item = item;
  }

  Envelope getEnvelope() {
    return env;
  }
  
  Object getItem() {
    return item;
  }
  
  String toString() {
    return "Item: " + env.toString();
  }
}
