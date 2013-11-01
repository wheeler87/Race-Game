package com.geom 
{
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class Point3D 
	{
		public var x:Number;
		public var y:Number;
		public var z:Number;
		
		public function Point3D(x:Number=0,y:Number=0,z:Number=0):void
		{
			this.x = x;
			this.y = y;
			this.x = z;
		}
		public function project(focalLength:Number,projectionCenter:Point2D=null,resultP:Point2D = null):Point2D {
			if (!projectionCenter) {
				projectionCenter = new Point2D();
			}
			if (!resultP) {
				resultP = new Point2D();
			}
			
			resultP.t = focalLength / (focalLength + this.z);
			resultP.x = (this.x - projectionCenter.x) * resultP.t + projectionCenter.x;
			resultP.y = (this.y - projectionCenter.y) * resultP.t + projectionCenter.y;
			
			return resultP;
		}
		public function toString():String
		{
			var result:String = "{x= " + x + ", y= " + y + ", z=" + z + "}";
			return result;
			
		}
		
	}

}