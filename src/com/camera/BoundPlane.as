package com.camera 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class BoundPlane extends Sprite 
	{
		private var _planeRenderer:Bitmap;
		private var _planePixels:BitmapData
		
		
		
		
		public function BoundPlane() 
		{
			super();
			
			_planeRenderer = new Bitmap();
			addChild(_planeRenderer);
			
			_planeRenderer.scrollRect = new Rectangle();
			
			
		}
		public function init(closerBGTexture:BitmapData, fartherBGTexture:BitmapData,width:Number):void
		{
			var actualHeight:Number = Math.max(closerBGTexture.height, fartherBGTexture.height);
			_planePixels = new BitmapData(width, actualHeight, true, 0);
			
			
			
			var helper:Shape = new Shape();
			helper.graphics.beginBitmapFill(fartherBGTexture);
			helper.graphics.drawRect(0,actualHeight - fartherBGTexture.height, width, fartherBGTexture.height);
			helper.graphics.endFill();
			
			helper.graphics.beginBitmapFill(closerBGTexture);
			helper.graphics.drawRect(0,actualHeight - closerBGTexture.height, width, closerBGTexture.height);
			helper.graphics.endFill();
			
			_planePixels.draw(helper);
			_planeRenderer.bitmapData = _planePixels;
			_planeRenderer.y = -actualHeight;
			_planeRenderer.x = -_planePixels.width* 0.5;
			
			
		}
		public function draw(startX:Number, width:Number):void
		{
			
			var rect:Rectangle = _planeRenderer.scrollRect;
			rect.x = startX;
			rect.height = _planePixels.height;
			rect.width = width;
			
			_planeRenderer.scrollRect = rect;
			_planeRenderer.x = -_planePixels.width* 0.5 + startX;
			
			
			//graphics.clear();
			//graphics.beginFill(0, 0.5);
			//graphics.drawRect(startX - _planePixels.width * 0.5, -_planePixels.height, width, _planePixels.height);
			
			
		}
		
	}

}