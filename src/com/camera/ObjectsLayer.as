package com.camera 
{
	import com.geom.Point2D;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class ObjectsLayer extends Sprite 
	{
		private var _portWidth:Number;
		private var _portDepth:Number
		
		
		private var _helperV1:Vector3D;
		private var _helperV2:Vector3D;
		private var _helperV3:Vector3D;
		
		private var _objects:Vector.<IRendered>
		
		
		public function ObjectsLayer() 
		{
			super();
			
			_helperV1 = new Vector3D();
			_helperV2 = new Vector3D();
			_helperV3 = new Vector3D();
			
			_objects = new Vector.<IRendered>();
			
		}
		public function onCameraResize(screenWidth:Number, screenDepth:Number):void
		{
			
			_portWidth = screenWidth;
			_portDepth = screenDepth;
		}
		
		
		
		
		public function addRenderedObject(value:IRendered):void
		{
			if ((!value) || (!value.gameCameraSkin) || (_objects.indexOf(value) >= 0)) return;
			_objects.push(value);
			addChild(value.gameCameraSkin);
			value.gameCameraSkin.visible=false
			
		}
		public function removeRenderedObject(value:IRendered):void
		{
			var index:int = (value)?_objects.indexOf(value): -1;
			if (index < 0) return;
			_objects.splice(index, 1);
			removeChild(value.gameCameraSkin);
		}
		public function render(wordX:Number, wordY:Number, angle:Number):void
		{
			var heading:Vector3D = _helperV1;
			var normal:Vector3D = _helperV2;
			var toObject:Vector3D = _helperV3;
			
			heading.x = Math.cos(angle);
			heading.y = Math.sin(angle);
			
			normal.x = Math.cos(angle + Math.PI * 0.5);
			normal.y = Math.sin(angle + Math.PI * 0.5);
			
			var localX:Number;
			var localY:Number;
			
			var currentX:Number
			var currentY:Number;
			
			for each(var object:IRendered in _objects)
			{
				toObject.x = object.wordX - wordX;
				toObject.y = object.wordY - wordY;
				
				localX = toObject.dotProduct(normal);
				localY = toObject.dotProduct(heading);
				
				
				
				var outByX:Boolean = ((localX<(-0.5*_portWidth))||(localY>(0.5*_portWidth)));
				var outByY:Boolean = ((localY<(0))||(localY>(_portDepth)));
				
				if ((outByX) || (outByY)) {
					object.gameCameraSkin.visible = false;
					continue;
				}
				
				object.gameCameraSkin.visible = true;
				object.gameCameraSkin.x = localX;
				object.gameCameraSkin.y = -localY;
				object.screenAngle = object.worldAngle-angle;
				
			}
		}
		
	}

}