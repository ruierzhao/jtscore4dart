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
 * An action taken when a {@link SweepLineIndex} detects that two
 * {@link SweepLineInterval}s overlap
 *
 * @version 1.7
 */
interface SweepLineOverlapAction {

  void overlap(SweepLineInterval s0, SweepLineInterval s1);
}
