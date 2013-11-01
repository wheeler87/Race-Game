package com.game.gameInterface 
{
	import com.game.entity.Racer;
	import flash.display.Bitmap;
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
	public class MiniMap extends Sprite 
	{
		public var zoom:Number = 0.25;
		
		private var _width:Number
		private var _height:Number
		private var _indendH:int = 2;
		private var _indentV:int = 2;
		
		private var _environmentRenderer:Bitmap;
		private var _environmentPixels:BitmapData
		private var _localPlayerIndicator:Shape
		private var _opponentPlayerIndicator:Shape
		
		
		private var _helperM:Matrix;
		private var _helperP:Point;
		private var _helperV1:Vector3D = new Vector3D();
		private var _helperV2:Vector3D = new Vector3D();
		private var _helperV3:Vector3D = new Vector3D();
		
		
		public function MiniMap(width:Number,height:Number):void
		{
			super();
			
			_width = width;
			_height = height;
			var g:Graphics = graphics;
			g.clear();
			g.beginFill(0, 0.2);
			g.drawRect(0, 0, _width, _height);
			
			
			_environmentPixels = new BitmapData(_width-2*_indendH, _height-2*_indentV, true, 0);
			_environmentRenderer = new Bitmap();
			_environmentRenderer.x = _indendH;
			_environmentRenderer.y = _indentV;
			_environmentRenderer.bitmapData = _environmentPixels;
			addChild(_environmentRenderer);
			
			_localPlayerIndicator = cretePlayerIndicator(0x00ffff);
			_opponentPlayerIndicator = cretePlayerIndicator(0x000000);
			
			_helperM = new Matrix();
			_helperP = new Point();
		}
		
		
		private function cretePlayerIndicator(color:uint):Shape
		{
			var racerWidth:Number = 8;
			var racerHeight:Number = 16;
			
			var vx1:Number = 0;
			var vy1:Number = -0.7 * racerHeight;
			
			var vx2:Number = 0.5*racerWidth;
			var vy2:Number = 0.3 * racerHeight;
			
			var vx3:Number = -0.5*racerWidth;
			var vy3:Number = 0.3 * racerHeight;
			
			var result:Shape = new Shape();
			var g:Graphics = result.graphics;
			g.beginFill(color);
			g.moveTo(vx1, vy1);
			g.lineTo(vx2, vy2);
			g.lineTo(vx3, vy3);
			g.lineTo(vx1, vy1);
			
			return result;
			
		}
		
		
		
		
		public function render(worldPixels:BitmapData, localRacer:Racer, allRacers:Vector.<Racer>):void
		{
			_environmentPixels.fillRect(_environmentPixels.rect, 0x55cccccc);
			_helperM.identity();
			_helperM.translate( -localRacer.wordX, -localRacer.lastWorldY);
			_helperM.rotate( -(localRacer.worldAngle+Math.PI*0.5));
			_helperM.scale(zoom, zoom);
			_helperM.translate(0.5 * _width, 0.5 * _height);
			_environmentPixels.draw(worldPixels, _helperM, null);
			
			
			
			var heading:Vector3D = _helperV1;
			heading.x = Math.cos(localRacer.worldAngle);
			heading.y = Math.sin(localRacer.worldAngle);
			
			var lNormal:Vector3D = _helperV2;
			lNormal.x = Math.cos(localRacer.worldAngle-Math.PI*0.5)
			lNormal.y = Math.sin(localRacer.worldAngle-Math.PI*0.5)
			
			var toOpponent:Vector3D = _helperV3;
			
			var currentIndicator:Shape;
			var currentRacer:Racer
			
			var screenX:Number;
			var screenY:Number;
			var screenAngle:Number
			
			for (var i:uint = 0; i < allRacers.length; i++ ) {
				currentRacer = allRacers[i];
				currentIndicator = (currentRacer == localRacer)?_localPlayerIndicator:_opponentPlayerIndicator;
				
				toOpponent.x = currentRacer.wordX - localRacer.wordX;
				toOpponent.y = currentRacer.wordY - localRacer.wordY;
				
				screenX = -1*lNormal.dotProduct(toOpponent) * zoom + (0.5 * _width);
				screenY = -1*heading.dotProduct(toOpponent) * zoom + (0.5 * _height);
				screenAngle = currentRacer.worldAngle-localRacer.worldAngle;
				
				if ((screenX < 0) || (screenX >= _width) || (screenY < 0) || (screenY >= _height)) {
					continue
				}
				_helperM.identity();
				_helperM.rotate(screenAngle);
				_helperM.translate(screenX, screenY);
				
				_environmentPixels.draw(currentIndicator, _helperM);
				
			}
			
		}
		
	}

}