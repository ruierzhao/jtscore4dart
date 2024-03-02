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


/// Utility functions to report JVM memory usage.
/// 
/// @author mbdavis
///
class Memory 
{
	static long used()
	{
		Runtime runtime = Runtime.getRuntime ();
		return runtime.totalMemory() - runtime.freeMemory();
	}
	
	static String usedString()
	{
		return format(used());
	}
	
	static long free()
	{
		Runtime runtime = Runtime.getRuntime ();
		return runtime.freeMemory();
	}
	
	static String freeString()
	{
		return format(free());
	}
	
	static long total()
	{
		Runtime runtime = Runtime.getRuntime ();
		return runtime.totalMemory();
	}
	
	static String totalString()
	{
		return format(total());
	}
	
	static String usedTotalString()
	{
		return "Used: " + usedString() 
		+ "   Total: " + totalString();
	}
	
	static String allString()
	{
		return "Used: " + usedString() 
		+ "   Free: " + freeString()
		+ "   Total: " + totalString();
	}
	
	static final double KB = 1024;
	static final double MB = 1048576;
	static final double GB = 1073741824;

	static String format(long mem)
	{
		if (mem < 2 * KB)
			return mem + " bytes";
		if (mem < 2 * MB)
			return round(mem / KB) + " KB";
		if (mem < 2 * GB)
			return round(mem / MB) + " MB";
		return round(mem / GB) + " GB";
	}
	
	static double round(double d)
	{
		return math.ceil(d * 100) / 100;
	}
}
