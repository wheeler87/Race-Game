package com.geom 
{
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class SegmentsIntersectionResult 
	{
		
		public var intersects:Boolean;
		public var firstSegmentIntersectionRatio:Number;
		public var secondSegmentIntersectionRatio:Number;
		public var firsLineSegment:LineSegment;
		public var secondLineSegment:LineSegment;
		
		public function SegmentsIntersectionResult() 
		{
			
		}
		
		public function reset():void
		{
			intersects = false;
			firstSegmentIntersectionRatio = Infinity;
			secondSegmentIntersectionRatio = Infinity;
			firsLineSegment = null;
			secondLineSegment = null;
		}
		public function isIternalIntersectionForFirstSegment():Boolean
		{
			return 	intersects &&
					(firstSegmentIntersectionRatio >= 0) &&
					(firstSegmentIntersectionRatio <= 1)
		}
		public function isIternalIntersectionForSecondSegment():Boolean
		{
			return intersects &&
					(secondSegmentIntersectionRatio >= 0) &&
					(secondSegmentIntersectionRatio <= 1)
		}
		
		public function isIternalIntersection():Boolean
		{
			return 				intersects && 
								(firstSegmentIntersectionRatio >= 0) &&
								(firstSegmentIntersectionRatio <= 1) &&
								(secondSegmentIntersectionRatio >= 0) &&
								(secondSegmentIntersectionRatio<=1)
		}
		
		public function toString():String
		{
			var result:String = "SegmentsIntersectionResult: " + " intersects - " + intersects + " n1 - " + firstSegmentIntersectionRatio + " n2 - " + secondSegmentIntersectionRatio;
			return result;
		}
	}

}