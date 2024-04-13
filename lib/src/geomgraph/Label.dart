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


// import org.locationtech.jts.geom.Location;
// import org.locationtech.jts.geom.Position;

import 'package:jtscore4dart/src/geom/Location.dart';
import 'package:jtscore4dart/src/geom/Position.dart';

import 'TopologyLocation.dart';

/**
 * 收集拓扑关系
 * 支持存储二元拓扑操作信息
 * 
 * A <code>Label</code> indicates the topological relationship of a component
 * of a topology graph to a given <code>Geometry</code>.
 * 
 * This class supports labels for relationships to two <code>Geometry</code>s,
 * which is sufficient for algorithms for binary operations.
 * <P>
 * Topology graphs support the concept of labeling nodes and edges in the graph.
 * The label of a node or edge specifies its topological relationship to one or
 * more geometries.  (In fact, since JTS operations have only two arguments labels
 * are required for only two geometries).  A label for a node or edge has one or
 * two elements, depending on whether the node or edge occurs in one or both of the
 * input <code>Geometry</code>s.  
 * 
 * 拓扑图形支持label 的node 和 edge 
 * label 的node 或者 edge 指明和另一个或两个geometry 的拓扑关系
 * 
 * Elements contain attributes which categorize the
 * topological location of the node or edge relative to the parent
 * <code>Geometry</code>; that is, whether the node or edge is in the interior,
 * boundary or exterior of the <code>Geometry</code>.  
 * 
 * Attributes have a value
 * from the set <code>{Interior, Boundary, Exterior}</code>.  In a node each
 * element has  a single attribute <code>&lt;On&gt;</code>.  For an edge each element has a
 * triplet of attributes <code>&lt;Left, On, Right&gt;</code>.
 * 
 * <P>
 * It is up to the client code to associate the 0 and 1 <code>TopologyLocation</code>s
 * with specific geometries.
 * 
 * @version 1.7
 */
class Label {

  // converts a Label to a Line label (that is, one with no side Locations)
  static Label toLineLabel(Label label)
  {
    Label lineLabel = new Label(Location.NONE);
    for (int i = 0; i < 2; i++) {
      lineLabel.setLocationOn(i, label.getLocation(i));
    }
    return lineLabel;
  }

  // List<TopologyLocation> elt = TopologyLocation[2];
  List<TopologyLocation> elt;

  /**
   * Construct a Label with a single location for both Geometries.
   * Initialize the locations to Null
   *
   * @param onLoc On location
   */
  Label(int onLoc)
    :this.elt = List.filled(2, TopologyLocation.On(onLoc), growable: false);
  // Label(int onLoc)
  // {
  //   elt[0] = new TopologyLocation.On(onLoc);
  //   elt[1] = new TopologyLocation.On(onLoc);
  // }
  /**
   * Construct a Label with a single location for both Geometries.
   * Initialize the location for the Geometry index.
   *
   * @param geomIndex Geometry index
   * @param onLoc On location
   */
  Label.GeomIndex(int geomIndex, int onLoc)
  :this.elt = List.filled(2, TopologyLocation.On(Location.NONE),growable: false)
  {
    elt[geomIndex].setLocation(onLoc);
  }
  // Label.GeomIndex(int geomIndex, int onLoc)
  // {
  //   elt[0] = new TopologyLocation.On(Location.NONE);
  //   elt[1] = new TopologyLocation.On(Location.NONE);
  //   elt[geomIndex].setLocation(onLoc);
  // }
  /**
   * Construct a Label with On, Left and Right locations for both Geometries.
   * Initialize the locations for both Geometries to the given values.
   *
   * @param onLoc On location
   * @param rightLoc Right location
   * @param leftLoc Left location
   */
  Label.From3(int onLoc, int leftLoc, int rightLoc)
  :this.elt = List.filled(2, TopologyLocation.From3(onLoc, leftLoc, rightLoc),growable: false);
  // Label.From3(int onLoc, int leftLoc, int rightLoc)
  // {
  //   elt[0] = new TopologyLocation.From3(onLoc, leftLoc, rightLoc);
  //   elt[1] = new TopologyLocation.From3(onLoc, leftLoc, rightLoc);
  // }
  /**
   * Construct a Label with On, Left and Right locations for both Geometries.
   * Initialize the locations for the given Geometry index.
   *
   * @param [geomIndex] Geometry index
   * @param [onLoc] On location
   * @param [rightLoc] Right location
   * @param [leftLoc] Left location
   */
  Label.GeomFrom3(int geomIndex, int onLoc, int leftLoc, int rightLoc)
    :this.elt = List.filled(2, TopologyLocation.From3(Location.NONE, Location.NONE, Location.NONE),growable: false)
  {
    elt[geomIndex].setLocations(onLoc, leftLoc, rightLoc);
  }
  /**
   * Construct a Label with the same values as the argument Label.
   *
   * @param lbl Label
   */
  Label.FromAnother(Label lbl)
  :this.elt = List.generate(2, (i) => TopologyLocation.FromAnother(lbl.elt[i]),growable: false);


  void flip()
  {
    elt[0].flip();
    elt[1].flip();
  }

  int getLocation(int geomIndex, [int posIndex=Position.ON]) { 
    return elt[geomIndex].get(posIndex); 
  }
  // TODO: ruier replace.
  // int getLocation(int geomIndex) { 
  //   return elt[geomIndex].get(Position.ON); 
  // }
  void setLocation(int geomIndex, int posIndex, int location){
    elt[geomIndex].setLocationKV(posIndex, location);
  }

  void setLocationOn(int geomIndex, int location){
    elt[geomIndex].setLocationKV(Position.ON, location);
  }

  void setAllLocations(int geomIndex, int location)
  {
    elt[geomIndex].setAllLocations(location);
  }
  void setAllLocationsIfNullGeom(int geomIndex, int location)
  {
    elt[geomIndex].setAllLocationsIfNull(location);
  }

  void setAllLocationsIfNull(int location){
    setAllLocationsIfNullGeom(0, location);
    setAllLocationsIfNullGeom(1, location);
  }
  /**
   * Merge this label with another one.
   * Merging updates any null attributes of this label with the attributes from lbl.
   *
   * @param lbl Label to merge
s   */
  void merge(Label lbl)
  {
    for (int i = 0; i < 2; i++) {
      if (elt[i] == null && lbl.elt[i] != null) {
        /// TODO: @ruier edit.never to here.. 
        print('>>>>>>>>> never to here.. if you haven see this, please tell me.... <<<<<<<<<<<<<<<<<<<<');
        elt[i] = new TopologyLocation.FromAnother(lbl.elt[i]);
      }
      else {
        elt[i].merge(lbl.elt[i]);
      }
    }
  }
  int getGeometryCount()
  {
    int count = 0;
    if (! elt[0].isNull()) count++;
    if (! elt[1].isNull()) count++;
    return count;
  }
  bool isNull(int geomIndex) { return elt[geomIndex].isNull(); }
  bool isAnyNull(int geomIndex) { return elt[geomIndex].isAnyNull(); }

  // TODO: ruier edit.
  // bool isArea()               { return elt[0].isArea() || elt[1].isArea();   }

  // bool isArea(int geomIndex)  
  // {
  // 	/*  Testing
  // 	if (elt[0].getLocations().length != elt[1].getLocations().length) {
  // 		System.out.println(this);
  // 	}
  // 		*/
  // 	return elt[geomIndex].isArea();   
  // }
  bool isArea([int? geomIndex])  
  {
  	if (geomIndex == null ) {
  	  return elt[0].isArea() || elt[1].isArea();
  	}
  	return elt[geomIndex].isArea();   
  }
  bool isLine(int geomIndex)  { return elt[geomIndex].isLine();   }

  bool isEqualOnSide(Label lbl, int side)
  {
    return this.elt[0].isEqualOnSide(lbl.elt[0], side)
      &&  this.elt[1].isEqualOnSide(lbl.elt[1], side);
  }
  bool allPositionsEqual(int geomIndex, int loc)
  {
    return elt[geomIndex].allPositionsEqual(loc);
  }
  /**
   * Converts one GeometryLocation to a Line location
   * @param geomIndex geometry location
   */
  void toLine(int geomIndex)
  {
    if (elt[geomIndex].isArea()) {
      elt[geomIndex] = new TopologyLocation.On(elt[geomIndex].location[0]);
    }
  }
  @override
  String toString()
  {
    StringBuffer buf = new StringBuffer();
    if (elt[0] != null) {
      buf.write("A:");
      buf.write(elt[0].toString());
    }
    if (elt[1] != null) {
      buf.write(" B:");
      buf.write(elt[1].toString());
    }
    return buf.toString();
  }
}
