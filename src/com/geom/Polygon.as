package com.geom 
{
	import flash.geom.Point;
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class Polygon 
	{
		private var _helper1:Vector3D = new Vector3D();
		private var _helper2:Vector3D = new Vector3D();
		private var _helper3:Vector3D = new Vector3D();
		private var _helper4:Vector3D = new Vector3D();
		private var _helper5:Vector3D = new Vector3D();
		
		private var _sides:Vector.<LineSegment>
		private var _origin:Point
		
		public function Polygon() 
		{
			_sides = new Vector.<LineSegment>();
			_origin = new Point();
		}
		public function update():void
		{
			recalculateOrigin();
		}
		
		public function addSide(startX:Number, startY:Number, endX:Number, endY:Number):void
		{
			var side:LineSegment = new LineSegment();
			side.startP.x = startX;
			side.startP.y = startY;
			
			side.endP.x = endX;
			side.endP.y = endY;
			
			_sides.push(side);
			
			recalculateOrigin();
		}
		public function getAppropriateSideToPoint(x:Number, y:Number):LineSegment
		{
			var directionAngle:Number = Math.atan2(y - _origin.y, x - _origin.x);
			var heading:Vector3D = _helper1;
			heading.x = Math.cos(directionAngle);
			heading.y = Math.sin(directionAngle);
			
			var lNormal:Vector3D = _helper2;
			lNormal.x = Math.cos(directionAngle-Math.PI * 0.5);
			lNormal.y = Math.sin(directionAngle-Math.PI * 0.5);
			
			
			var currentSegment:LineSegment;
			var length:int = _sides?_sides.length:0;
			for (var i:uint = 0; i < length; i++ ) {
				currentSegment = _sides[i];
				var toStartP:Vector3D = _helper3;
				toStartP.x = currentSegment.startP.x - _origin.x;
				toStartP.y = currentSegment.startP.y - _origin.y;
				
				var toEntP:Vector3D = _helper4;
				toEntP.x = currentSegment.endP.x - _origin.x;
				toEntP.y = currentSegment.endP.y - _origin.y;
				
				var startAngle:Number = Math.atan2(toStartP.y, toStartP.x);
				var startRNormal:Vector3D = _helper5;
				startRNormal.x = Math.cos(startAngle + Math.PI * 0.5);
				startRNormal.y = Math.sin(startAngle + Math.PI * 0.5);
				
				
				
				var dot1:Number = lNormal.dotProduct(toStartP);
				var dot2:Number = lNormal.dotProduct(toEntP);
				var dot3:Number = startRNormal.dotProduct(toEntP);
				
				if((dot1<0)&&(dot2<0)) continue
				if((dot1>0)&&(dot2>0)) continue
				
				
				var clocwiseOriented:Boolean = (dot3 >= 0);
				var leftToRinghtIntersection:Boolean = (dot1 >= 0) && (dot2 < 0);
				var rightToLeftIntersection:Boolean = (dot1<0)&&(dot2>=0);
				if (((clocwiseOriented) && (leftToRinghtIntersection)) ||
					((!clocwiseOriented)&&(rightToLeftIntersection)))
				{
					return currentSegment
				}
				
				
				
			}
			return null;
		}
		private function recalculateOrigin():void
		{
			_origin.x = 0;
			_origin.y = 0;
			var length:int = (_sides)?_sides.length:0;
			
			if (length < 1) return;
			for (var i:uint = 0; i < length; i++ ) {
				_origin.x += _sides[i].endP.x;
				_origin.x += _sides[i].startP.x;
				
				_origin.y += _sides[i].endP.y;
				_origin.y += _sides[i].startP.y;
			}
			_origin.x /= length * 2;
			_origin.y /= length * 2;
		}
	}

}