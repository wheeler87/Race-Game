package com.globals 
{
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.filters.DisplacementMapFilter;
	import flash.filters.DisplacementMapFilterMode;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class Util 
	{
		
		public function Util() 
		{
			
		}
		static public function createTrapezeDisplacementFilter(width:Number,height:Number,angle:Number):DisplacementMapFilter
		{
			var map:BitmapData = createTrapezeDisplacementMap(width, height, angle);
			var startP:Point = new Point();
			var componentX:int = BitmapDataChannel.RED;
			var componentY:int = BitmapDataChannel.GREEN;
			var scaleX:Number = 2* height * Math.tan(angle);
			var scaleY:Number = 1;
			var mode:String = DisplacementMapFilterMode.COLOR;
			
			var result:DisplacementMapFilter = new DisplacementMapFilter(map, startP, componentX, componentY, scaleX, scaleY, mode);
			
			return result;
		}
		
		static private function createTrapezeDisplacementMap(width:Number,height:Number,angle:Number):BitmapData
		{
			var result:BitmapData = new BitmapData(width, height);
			result.lock();
			
			var resultX:int;
			var resultY:int;
			var displacementMax:Number = Math.abs(height * Math.tan(angle));
			var currentDisplacement:int;
			var currentRedChannel:uint;
			var color:uint
			var minRedChannel:int = int.MAX_VALUE;
			var maxRedChannel:int = int.MIN_VALUE;
			
			for (var currentY:int = 0; currentY < height; currentY++ ) {
				for (var currentX:int = 0; currentX < width; currentX++ ) {
					
					//resultX = (currentX / width - 2 * (height - currentY) * Math.tan(angle)) + (height - currentY) * Math.tan(angle);
					resultX = (currentX / width) * (width - 2 * (height - currentY) * Math.tan(angle)) + (height - currentY) * Math.tan(angle);
					resultY = currentY;
					currentDisplacement = currentX-resultX;
					//trace(currentDisplacement);
					currentRedChannel = 128.0 + 128.0*currentDisplacement / displacementMax;
					//trace(currentRedChannel);
					if (currentRedChannel < minRedChannel) {
						minRedChannel = currentRedChannel;
					}else if (currentRedChannel > maxRedChannel) {
						maxRedChannel = currentRedChannel;
					}
					
					color = currentRedChannel << 16 | 128 << 8;
					result.setPixel(currentX, currentY, color);
				}
			}
			//trace(minRedChannel, maxRedChannel);
			
			result.unlock();
			return result;
		}
		
		
		
	}

}