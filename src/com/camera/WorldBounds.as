package com.camera 
{
	import com.geom.GeoUtil;
	import com.geom.LineSegment;
	import com.geom.SegmentsIntersectionResult;
	import com.managers.info.components.LocationInfo;
	import com.view.ApplicationSprite;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class WorldBounds extends ApplicationSprite 
	{
		private var INDEX_TOP:int = 0;
		private var INDEX_BOTTOM:int = 1;
		private var INDEX_LEFT:int = 2;
		private var INDEX_RIGHT:int = 3;
		private var indexes:Array = [INDEX_TOP, INDEX_LEFT, INDEX_RIGHT, INDEX_BOTTOM];
		
		private var _boundWidth:Number;
		private var _boundHeight:Number;
		
		private var _closerBG:BitmapData;
		private var _fartherBG:BitmapData;
		
		private var _boundCanvas:Vector.<BoundPlane>
		private var _wordBoundSegments:Vector.<LineSegment>;
		private var _cameraBoundSegments:Vector.<LineSegment>;
		private var _helperPoints:Vector.<Point>;
		private var _helperItersectionResults:Vector.<SegmentsIntersectionResult>
		
		private var _helperV1:Vector3D = new Vector3D();
		private var _helperV2:Vector3D = new Vector3D();
		
		private var _currentWorldPosOfScreenCenter:Point=new Point()
		private var _currentScreenAngle:Number;
		private var _toScreenMatrix:Matrix = new Matrix();
		
		public function WorldBounds() 
		{
			super();
			createBounds();
			
		}
		
		private function createBounds():void
		{
			_boundCanvas = new Vector.<BoundPlane>;
			_wordBoundSegments = new Vector.<LineSegment>();
			_cameraBoundSegments = new Vector.<LineSegment>();
			_helperPoints = new Vector.<Point>();
			
			
			var currentCanvas:BoundPlane
			var currentSegment:LineSegment
			var currentPoint:Point
			while (_boundCanvas.length < 4) {
				currentCanvas = new BoundPlane();
				currentCanvas.rotationX = 90;
				
				addChild(currentCanvas);
				_boundCanvas.push(currentCanvas);
				
				currentSegment = new LineSegment()
				_cameraBoundSegments.push(currentSegment);
				
				currentSegment = new LineSegment();
				_wordBoundSegments.push(currentSegment);
				
				currentPoint = new Point()
				_helperPoints.push(currentPoint);
			}
			
			_helperItersectionResults = new Vector.<SegmentsIntersectionResult>()
			while (_helperItersectionResults.length < 2) {
				_helperItersectionResults.push(new SegmentsIntersectionResult());
			}
		}
		
		public function init(locationInfo:LocationInfo):void
		{
			_boundWidth = locationInfo.width;
			_boundHeight = locationInfo.height;
			
			
			//graphics.clear();
			//graphics.beginFill(0xff0000,0.3);
			//graphics.drawRect( -_boundWidth * 0.5, -_boundHeight * 0.5, _boundWidth, _boundHeight);
			//
			_fartherBG = assetManager.getBitmapData(locationInfo.fartherBG);
			_closerBG = assetManager.getBitmapData(locationInfo.closerBG);
			
			_boundCanvas[INDEX_TOP].init(_closerBG, _fartherBG, _boundWidth);
			_boundCanvas[INDEX_TOP].y = -_boundHeight*0.5;
			
			
			
			_boundCanvas[INDEX_BOTTOM].init(_closerBG, _fartherBG, _boundWidth);
			_boundCanvas[INDEX_BOTTOM].y = _boundHeight * 0.5;
			_boundCanvas[INDEX_BOTTOM].rotationZ = 180;
			
			
			
			
			_boundCanvas[INDEX_LEFT].init(_closerBG, _fartherBG, _boundHeight);
			_boundCanvas[INDEX_LEFT].x = -_boundWidth * 0.5;
			_boundCanvas[INDEX_LEFT].rotationZ = -90;
			
			
			
			_boundCanvas[INDEX_RIGHT].init(_closerBG, _fartherBG, _boundHeight);
			_boundCanvas[INDEX_RIGHT].x = _boundWidth * 0.5;
			_boundCanvas[INDEX_RIGHT].rotationZ = 90;
			
			
			updateWordBoundsLineSegments(_boundWidth, _boundHeight);
		}
		private function updateWordBoundsLineSegments(boundWidth:Number, boundHeight:Number):void
		{
			var currentSegment:LineSegment;
			
			currentSegment = _wordBoundSegments[INDEX_TOP];
			currentSegment.startP.x = 0;
			currentSegment.startP.y = 0;
			currentSegment.endP.x = boundWidth;
			currentSegment.endP.y = 0;
			
			currentSegment = _wordBoundSegments[INDEX_BOTTOM];
			currentSegment.startP.x = boundWidth;
			currentSegment.startP.y = boundHeight;
			currentSegment.endP.x = 0;
			currentSegment.endP.y = boundHeight;
			
			currentSegment = _wordBoundSegments[INDEX_LEFT];
			currentSegment.startP.x = 0;
			currentSegment.startP.y = _boundHeight;
			currentSegment.endP.x = 0;
			currentSegment.endP.y = 0;
			
			
			currentSegment = _wordBoundSegments[INDEX_RIGHT];
			currentSegment.startP.x = boundWidth;
			currentSegment.startP.y = 0;
			currentSegment.endP.x = boundWidth;
			currentSegment.endP.y = boundHeight;
			
		}
		
		
		public function render(wordX:Number, wordY:Number, angle:Number, scrennWidth:Number, screenHeigh:Number):void
		{
			
			
			updateScreenBoundsLineSegments(wordX, wordY, angle, scrennWidth, screenHeigh);
			updatePosition(wordX, wordY, angle);
			updateBoundCanvas();
		}
		
		private function updateScreenBoundsLineSegments(wordX:Number, wordY:Number, angle:Number, scrennWidth:Number, screenHeigh:Number):void
		{
			var heading:Vector3D = _helperV1;
			var normal:Vector3D = _helperV2;
			
			heading.x = Math.cos(angle);
			heading.y = Math.sin(angle);
			
			
			
			normal.x = Math.cos(angle + Math.PI * 0.5);
			normal.y = Math.sin(angle + Math.PI * 0.5);
			
			var blc:Point = _helperPoints[0];
			var brc:Point = _helperPoints[1];
			var tlc:Point = _helperPoints[2];
			var trc:Point = _helperPoints[3];
			
			normal.scaleBy(0.5 * scrennWidth);
			heading.scaleBy(screenHeigh);
			
			blc.x = wordX - normal.x;
			blc.y = wordY - normal.y;
			
			brc.x = wordX + normal.x;
			brc.y = wordY + normal.y;
			
			tlc.x = wordX - normal.x + heading.x;
			tlc.y = wordY - normal.y + heading.y;
			
			trc.x = wordX + normal.x + heading.x;
			trc.y = wordY + normal.y + heading.y;
			
			var currentSegment:LineSegment
			
			currentSegment = _cameraBoundSegments[INDEX_TOP];
			currentSegment.startP.x = tlc.x;
			currentSegment.startP.y = tlc.y;
			currentSegment.endP.x = trc.x;
			currentSegment.endP.y = trc.y;
			
			currentSegment = _cameraBoundSegments[INDEX_BOTTOM];
			currentSegment.startP.x = brc.x;
			currentSegment.startP.y = brc.y;
			currentSegment.endP.x = blc.x;
			currentSegment.endP.y = blc.y;
			
			currentSegment = _cameraBoundSegments[INDEX_LEFT];
			currentSegment.startP.x = blc.x;
			currentSegment.startP.y = blc.y;
			currentSegment.endP.x = tlc.x;
			currentSegment.endP.y = tlc.y;
			
			currentSegment = _cameraBoundSegments[INDEX_RIGHT];
			currentSegment.startP.x = trc.x;
			currentSegment.startP.y = trc.y;
			currentSegment.endP.x = brc.x;
			currentSegment.endP.y = brc.y;
			
			_currentScreenAngle = angle;
			_currentWorldPosOfScreenCenter.x = (tlc.x + brc.x) * 0.5;
			_currentWorldPosOfScreenCenter.y = (tlc.y + brc.y) * 0.5;
			
			
		}
		
		private function updatePosition(wordX:Number, wordY:Number, angle:Number):void
		{
			var dx:Number = _boundWidth * 0.5 - wordX;
			var dy:Number = _boundHeight * 0.5 - wordY;
			
			_toScreenMatrix.identity();
			_toScreenMatrix.translate(dx, dy);
			_toScreenMatrix.rotate( -Math.PI / 2 - angle);
			transform.matrix = _toScreenMatrix;
			
		}
		private function updateBoundCanvas():void
		{
			var currentWordBoundLS:LineSegment
			var currentCameraBoundLS:LineSegment;
			var currentSIR:SegmentsIntersectionResult;
			
			var intersectionsFound:int
			for (var i:uint = 0; i < _wordBoundSegments.length; i++ ) {
				currentWordBoundLS = _wordBoundSegments[i];
				intersectionsFound = 0;
				
				for (var j:uint = 0; j < _cameraBoundSegments.length; j++ ) {
					currentCameraBoundLS = _cameraBoundSegments[j];
					currentSIR = _helperItersectionResults[intersectionsFound];
					GeoUtil.testInersection(currentWordBoundLS, currentCameraBoundLS, currentSIR);
					if (currentSIR.intersects) {
						if (!currentSIR.isIternalIntersectionForSecondSegment()) {
							continue;
						}
						intersectionsFound++;
						if (intersectionsFound == _helperItersectionResults.length) {
							
							break;
						}
					}
				}
				updateCurrentCavas(i);
			}
		}
		public function updateCurrentCavas(canvasIndex:int):void
		{
			var intersect1:SegmentsIntersectionResult = _helperItersectionResults[0];
			var intersect2:SegmentsIntersectionResult = _helperItersectionResults[1];
			
			var canvas:BoundPlane = _boundCanvas[canvasIndex];
			canvas.visible = false;
			var actualWordBoundLS:LineSegment = _wordBoundSegments[canvasIndex];
			
			if ((intersect1.firsLineSegment != actualWordBoundLS) || (intersect2.firsLineSegment != actualWordBoundLS)) {
				return;
			}
			canvas.visible = true;
			
			
			var minRatio:Number = Math.min(intersect1.firstSegmentIntersectionRatio, intersect2.firstSegmentIntersectionRatio);
			var maxRatio:Number = Math.max(intersect1.firstSegmentIntersectionRatio, intersect2.firstSegmentIntersectionRatio);
			
			minRatio = Math.max(0, minRatio);
			maxRatio = Math.min(1, maxRatio);
			
			var boundX:Number = minRatio * actualWordBoundLS.length;
			var boundWidth:Number = (maxRatio - minRatio) * actualWordBoundLS.length;
			
			canvas.draw(boundX, boundWidth);
			
			
			
			
		}
		
		
		
	}

}