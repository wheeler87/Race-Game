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
	public class CameraUtil 
	{
		
		public function CameraUtil() 
		{
			
		}
		static public function createDisplacementMapFilter(map:BitmapData,scaleX:Number,scaleY:Number):DisplacementMapFilter
		{
			var mapBD:BitmapData=map;
			var mapP:Point;
			var componentX:int = BitmapDataChannel.RED;
			var componentY:int = BitmapDataChannel.GREEN;
			
			
			var mode:String = DisplacementMapFilterMode.COLOR;
			
			var result:DisplacementMapFilter = new DisplacementMapFilter(mapBD, mapP, componentX, componentY, scaleX, scaleY, mode,0xff0000,1);
			return result;
		}
		
		static public function createVerticalDistortMap(width:Number, inputHeight:Number,outPutHeight:Number):BitmapData
		{
			var result:BitmapData = new BitmapData(width, inputHeight, false, 0);
			var maxScale:Number = outPutHeight / inputHeight;
			var fadingRatio:Number=1.5
			
			
			
			var currentX:Number;
			var currentY:Number;
			
			var resultX:Number;
			var resultY:Number;
			
			var maxDisplacement:Number = inputHeight * (1 - maxScale);
			var currentDisplacement:Number
			var currentGreenCannel:int;
			var color:uint;
			
			for (currentY = 0; currentY < inputHeight; currentY++ ) {
				for (currentX = 0; currentX < width; currentX++ ) {
					resultX = currentX;
					resultY = maxScale*inputHeight * Math.pow(currentY / inputHeight, fadingRatio) + inputHeight * (1 - maxScale);
					
					currentDisplacement = currentY - resultY;
					currentGreenCannel = 128 + 127 * currentDisplacement / maxDisplacement;
					currentGreenCannel = Math.min(currentGreenCannel, 255);
					currentGreenCannel = Math.max(currentGreenCannel, 0);
					
					color = 128 << 16 | currentGreenCannel << 8;
					result.setPixel(currentX, currentY, color);
				}
			}
			
			
			
			
			
			return result;
		}
		
		static public function createHorizontalDistortMap(width:Number, height:Number, sidePinch:Number):BitmapData
		{
			var result:BitmapData = new BitmapData(width, height, false, 0);
			var currentX:Number;
			var currentY:Number;
			var resultX:int;
			var resultY:int;
			var currentDisplacement:Number
			
			
			var maxDisplacement:Number = Math.abs(Math.tan(sidePinch) * height);
			
			var currentRedChannel:uint
			var color:uint
			var minRedCCH:int = int.MAX_VALUE;
			var maxRedCCH:int = int.MIN_VALUE;
			
			for (currentY = 0; currentY < height; currentY++ ) {
				for (currentX = 0; currentX < width; currentX++ ) {
					resultX = (currentX/width)*(width-(height-currentY)*Math.tan(sidePinch))
					resultY = currentY;
					
					currentDisplacement = -resultX + currentX;
					currentRedChannel = 128 + (currentDisplacement / maxDisplacement) * 128;
					currentRedChannel = Math.max(0, currentRedChannel);
					currentRedChannel = Math.min(255, currentRedChannel);
					
					if (currentRedChannel < minRedCCH) {
						minRedCCH = currentRedChannel;
					}else if (currentRedChannel > maxRedCCH) {
						maxRedCCH = currentRedChannel;
					}
					
					color = currentRedChannel << 16// | 128 << 8;
					result.setPixel(currentX, currentY, color);
				}
			}
			trace(minRedCCH, maxRedCCH);
			
			
			return result;
		}
		static public function createHorizontalSkewMap(width:Number,height:Number,sidePinch:Number):BitmapData
		{
			var result:BitmapData = new BitmapData(width, height, false, 0);
			
			var currentX:int;
			var currentY:int;
			var resultX:Number;
			var resultY:Number;
			var maxDisplacement:Number = height * Math.tan(sidePinch);
			var currentDisplacement:Number;
			
			var currentRedChannel:uint;
			var currentGreenChannel:uint=128
			var currentColor:uint;
			
			for (currentY = 0; currentY < height; currentY++) {
				for (currentX = 0; currentX < width; currentX++ ) {
					resultX = currentX + Math.tan(sidePinch) * (height - currentY);
					resultY = currentY;
					
					currentDisplacement = currentX-resultX;
					currentRedChannel = 128 + (currentDisplacement / maxDisplacement) * 127;
					currentColor = currentRedChannel << 16 //| currentGreenChannel << 8;
					result.setPixel(currentX, currentY, currentColor);
				}
			}
			
			return result;
		}
		static public function createTrapezeDistortionMap(width:Number, height:Number, sidePinch:Number):BitmapData
		{
			var result:BitmapData = new BitmapData(width, height, false, 0);
			
			var currentX:Number;
			var currentY:Number;
			var resultX:Number;
			var resultY:Number;
			var maxDisplacement:Number = height * Math.tan(sidePinch);
			
			var currentDisplacement:Number;
			
			var currentRedChannel:int
			var color:uint
			var minCV:int = int.MAX_VALUE;
			var maxCV:int = int.MIN_VALUE;
			
			for (currentY = 0; currentY < height; currentY++ ) {
				for (currentX = 0; currentX < width; currentX++ ) {
					resultY = currentY;
					resultX = currentX * (width - 2 * (height - currentY) * Math.tan(sidePinch)) / width + (height - currentY) * Math.tan(sidePinch);
					currentDisplacement = currentX - resultX;
					
					currentRedChannel = 128 + (currentDisplacement / maxDisplacement) * 127;
					if (currentRedChannel < minCV) {
						minCV = currentRedChannel;
					}else if (currentRedChannel > maxCV) {
						maxCV = currentRedChannel;
					}
					color = currentRedChannel << 16 | 128 << 8;
					result.setPixel(currentX, currentY, color);
					
				}
			}
			
			
			
			return result;
		}
		static public function createComplexDistortionMap(width:Number, height:Number, sidePinch:Number, verticalScale:Number):BitmapData
		{
			var result:BitmapData = new BitmapData(width, height, false, 0);
			var currentX:Number;
			var currentY:Number;
			var resultX:Number;
			var resultY:Number;
			
			var maxHDisplacement:Number = height * Math.tan(sidePinch);
			var maxVDisplacement:Number = height * (1 - verticalScale);
			
			var fadingRatioV:Number=0.7
			//var fadingRatioV:Number=2.0
			
			var currentHDisplacement:Number;
			var currentVDisplacement:Number;
			
			var currentRedCV:int;
			var currentGreenCV:int;
			
			var color:uint
			var lineHOffset:Number = maxHDisplacement;
			
			for (currentY = 0; currentY < height; currentY++ ) {
				lineHOffset=Math.min(lineHOffset,(height - currentY) * Math.tan(sidePinch))
				
				for (currentX = 0; currentX < width; currentX++ ) {
					resultX = currentX * (width - 2 * (height - currentY) * Math.tan(sidePinch)) / width + lineHOffset;
					resultY = verticalScale * height * Math.pow(currentY / height, fadingRatioV) + height * (1 - verticalScale);
					
					currentHDisplacement = currentX - resultX;
					currentVDisplacement = currentY - resultY;
					
					currentRedCV = 128 + currentHDisplacement / maxHDisplacement * 127;
					currentGreenCV = 128 + currentVDisplacement / maxVDisplacement * 127;
					currentRedCV = 128;
					//currentGreenCV = 128;
					if (currentGreenCV < 0) {
						currentGreenCV = 0;
					}else if (currentGreenCV > 255) {
						trace(currentGreenCV);
					}
					
					color = currentRedCV << 16 | currentGreenCV << 8;
					result.setPixel(currentX, currentY, color);
				}
			}
			
			
			
			return result;
		}
		//static public function 
	}

}