package com.geom 
{
	import flash.geom.Point;
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class LineSegment 
	{
		public var startP:Point = new Point();
		public var endP:Point = new Point();
		
		public function LineSegment() 
		{
			
		}
		public function get length():Number
		{
			return Point.distance(startP, endP);
		}
		public function getLongitudialVector(target:Vector3D=null):Vector3D
		{
			if (!target) {
				target = new Vector3D();
			}
			target.x = endP.x - startP.x;
			target.y = endP.y - startP.y;
			
			return target
		}
		public function toString():String
		{
			var result:String = "LineSegment: start " + startP + " end " + endP;
			return result;
		}
		
	}

}