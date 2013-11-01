package com.geom 
{
	import flash.geom.Point;
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class GeoUtil 
	{
		static private var _helperV:Vector3D = new Vector3D();
		static private var _helperV2:Vector3D = new Vector3D();
		static private var _helperV3:Vector3D = new Vector3D();
		static private var _helperV4:Vector3D = new Vector3D();
		
		
		
		public function GeoUtil() 
		{
			
		}
		static public function rotate(angle:Number, startP:Point, resultP:Point=null):Point
		{
			if (!resultP) {
				resultP = new Point();
			}
			_helperV.x = startP.x;
			_helperV.y = startP.y;
			var distance:Number = _helperV.length;
			
			_helperV.normalize();
			var startAngle:Number = Math.acos(_helperV.x);
			
			var finalAngle:Number = startAngle + angle;
			
			_helperV.x = Math.cos(finalAngle);
			_helperV.y = Math.sin(finalAngle);
			
			_helperV.scaleBy(distance);
			resultP.x = _helperV.x;
			resultP.y = _helperV.y;
			
			return resultP;
		}
		static public function testInersection(seg1:LineSegment, seg2:LineSegment, res:SegmentsIntersectionResult = null):SegmentsIntersectionResult
		{
			if (!res) {
				res = new SegmentsIntersectionResult();
			}
			res.reset();
			res.firsLineSegment = seg1;
			res.secondLineSegment = seg2;
			var ab:Vector3D = seg1.getLongitudialVector(_helperV);
			var cd:Vector3D = seg2.getLongitudialVector(_helperV2);
			
			var oa:Vector3D = _helperV3;
			oa.x=seg1.startP.x
			oa.y=seg1.startP.y
			
			var oc:Vector3D = _helperV4;
			oc.x=seg2.startP.x
			oc.y=seg2.startP.y
			
			
			var n1:Number;
			var n2:Number;
			
			if ((ab.lengthSquared <= 0.0001) || (cd.lengthSquared < 0.001)) {
				return res;
			}
			
			if (((ab.x == 0) || (cd.y == 0)) && ((cd.x == 0) || (ab.y == 0))) {
				return res;
			}
			if ((ab.x != 0) && (cd.y != 0)) {
				n1 = (oc.x - oa.x + cd.x * oa.y / cd.y - oc.y * cd.x / cd.y) / (ab.x - cd.x * ab.y / cd.y);
				n2 = (oa.y + n1 * ab.y - oc.y) / cd.y;
			}else {
				n1 = (oc.y - oa.y + cd.y * oa.x / cd.x - oc.x * cd.y / cd.x) / (ab.y - cd.y * ab.x / cd.x);
				n2 = (oa.x + n1 * ab.x - oc.x) / cd.x;
			}
			res.intersects = true;
			res.firstSegmentIntersectionRatio = n1;
			res.secondSegmentIntersectionRatio = n2;
			
			return res;
			
		}
		
		static public function getPureRadians(value:Number):Number
		{
			var result:Number = value;
			while (result < 0) {
				result += Math.PI * 2;
			}
			while (result >= Math.PI * 2) {
				result-= Math.PI * 2;
			}
			return result
		}
		
	}

}