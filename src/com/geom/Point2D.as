package com.geom 
{
	import flash.geom.Point;
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class Point2D 
	{
		public var x:Number;
		public var y:Number
		public var t:Number
		
		public function Point2D(x:Number = 0, y :Number= 0, t:Number = 1)
		{
			this.x = x;
			this.y = y;
			this.t = t;
		}
		public function toString():String
		{
			var result:String = "Point2D";
			result += " x="+x;
			result += ", y="+y;
			
			return result;
		}
		static public function convert(fp:Point):Point2D
		{
			var result:Point2D = new Point2D();
			result.x = fp.x;
			result.y = fp.y;
			return result;
		}
	}

}