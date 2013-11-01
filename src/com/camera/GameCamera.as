package com.camera 
{
	import com.Facade;
	import com.game.plugins.log.ILogItem;
	import com.geom.Point2D;
	import com.geom.Point3D;
	import com.globals.CameraUtil;
	import com.managers.info.components.LocationInfo;
	import com.view.ApplicationSprite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.filters.DisplacementMapFilter;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.PerspectiveProjection;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Utils3D;
	import flash.geom.Vector3D;
	
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class GameCamera extends ApplicationSprite implements ILogItem
	{
		private var _id:String = "GameCamera";
		private var _screenWidth:Number = 200;
		private var _screenHeight:Number = 150;
		private var _zoom:Number = 3;
		
		private var _fieldOfView:Number = 120;
		
		private var _projection:PerspectiveProjection;
		private var _projectionCenter:Point
		private var _envRotationXDef:Number = -80;
		private var _envScreenRelatedH:Number = 4;
		
		
		private var _wordX:Number = 0;
		private var _wordY:Number = 0;
		private var _wordRotation:Number = -90.0;
		private var _wordAngle:Number = _wordRotation / 180.0 * Math.PI;
		private var _heading:Vector3D = new Vector3D(Math.cos(_wordAngle), Math.sin(_wordAngle));
		
		private var _screenContainer:Sprite;
		private var _environmentScreenNest:Sprite
		private var _environmentScreen:Bitmap;
		private var _environmentScreenPixels:BitmapData;
		private var _worldBounds:WorldBounds
		private var _objectsLayer:ObjectsLayer
		
		private var _environmentPixels:BitmapData;
		private var _grabWordPixelsMatrix:Matrix = new Matrix();
		
		private var _lastEntyStepIndex:int=-1
		private var _lastEntryWorldX:Number;
		private var _lastEntryWorldY:Number;
		private var _lastEtryRotation:Number;
		
		private var _lastAlignmentStepIndex:int = -1;
		
		private var _alignmentXSpeed:Number;
		private var _alignmentYSpeed:Number;
		private var _aligmentRSpeed:Number;
		
		
		public function GameCamera() 
		{
			super();
			
			
			
			_screenContainer = new Sprite();
			addChild(_screenContainer);
			
			_environmentScreenNest = new Sprite();
			_screenContainer.addChild(_environmentScreenNest)
			
			_environmentScreen = new Bitmap();
			
			_environmentScreenNest.addChild(_environmentScreen);
			
			_worldBounds = new WorldBounds();
			_environmentScreenNest.addChild(_worldBounds);
			
			
			
			_environmentScreenNest.rotationX = _envRotationXDef;
			
			_objectsLayer = new ObjectsLayer();
			_screenContainer.addChild(_objectsLayer);
			_objectsLayer.rotationX = _envRotationXDef;
			
			
			setCameraSize(_screenWidth, _screenHeight,_zoom);
			setCameraPosition(_screenWidth, _screenHeight, -90);
			
		}
		public function setCameraSize(width:Number, height:Number,zoom:Number):void
		{
			_screenWidth = width;
			_screenHeight = height;
			_zoom = zoom;
			_screenContainer.scaleX = _zoom;
			_screenContainer.scaleY = _zoom;
			
			_screenContainer.graphics.clear();
			_screenContainer.graphics.beginFill(0xd0e8d0,1);
			_screenContainer.graphics.drawRect(0, 0, width , height)
			
			if (!_screenContainer.mask) {
				_screenContainer.mask = new Shape();
				_screenContainer.addChild(_screenContainer.mask);
			}
			var mask:Shape = _screenContainer.mask as Shape;
			mask.graphics.clear();
			mask.graphics.beginFill(0);
			mask.graphics.drawRect(0, 0, _screenWidth, _screenHeight);
			
			recalculateProjectionParams();
			regenEnvironmentScreen();
			alignComponents();
		}
		
		public function alignComponents():void
		{
			var currentWidth:Number = _screenWidth
			var currentHeight:Number = _screenHeight
			
			_environmentScreenNest.x = currentWidth * 0.5;
			_environmentScreenNest.y = currentHeight;
			
			_objectsLayer.x = (currentWidth) * 0.5;
			_objectsLayer.y = currentHeight;
			
		}
		
		private function recalculateProjectionParams():void
		{
			if (!_projectionCenter) {
				_projectionCenter = new Point();
			}
			_projectionCenter.x = _screenWidth * 0.5;
			_projectionCenter.y = _screenHeight * 0.2;
			
			var projection:PerspectiveProjection = new PerspectiveProjection();
			projection.fieldOfView = _fieldOfView;
			projection.projectionCenter = _projectionCenter;
			
			_screenContainer.transform.perspectiveProjection = projection;
			
			
			
			_projection = projection;
			
			
		}
		
		private function regenEnvironmentScreen():void
		{
			var ltcX:Number= - _screenWidth * 0.5;
			var ltcY:Number = _screenHeight - screenHeight * _envScreenRelatedH * Math.cos(_envRotationXDef * Math.PI / 180.0);
			var ltcZ:Number =  - screenHeight * _envScreenRelatedH * Math.sin(_envRotationXDef * Math.PI / 180.0);
			
			var worldPos:Vector.<Number> = new Vector.<Number>(3, true);
			worldPos[0]=ltcX
			worldPos[1]=ltcY
			worldPos[2]=ltcZ
			
			var screenPos:Vector.<Number> = new Vector.<Number>(2, true);
			var uvs:Vector.<Number>=new Vector.<Number>(3,true)
			
			var projMatrix:Matrix3D = _projection.toMatrix3D();
			Utils3D.projectVectors(projMatrix, worldPos, screenPos, uvs);
			
			var cornerOffsetX:Number = _projectionCenter.x + screenPos[0];
			var cornerOffsetY:Number = _projectionCenter.y + screenPos[1];
			var skewH:Number = cornerOffsetX  * _zoom * 1.15 * 2;
			var skewV:Number = cornerOffsetY  * 0.85;
			
			
			var environmentPixelsHeight:Number = _screenHeight*_envScreenRelatedH;
			var extraWidth:Number = 1.3 * (_screenHeight * _envScreenRelatedH) - _screenWidth * 0.5;
			//extraWidth = skewH;
			
			var environmentPixelsWidth:Number = _screenWidth + extraWidth;
			
			if ((!_environmentScreenPixels) || 
				(!_environmentScreenPixels.width != environmentPixelsWidth) || 
				(_environmentPixels.height != environmentPixelsHeight)) {
				_environmentScreenPixels = new BitmapData(environmentPixelsWidth, environmentPixelsHeight, true, 0xffcccccc);
				_environmentScreen.bitmapData = _environmentScreenPixels;
				
				_environmentScreen.x = -_environmentScreen.width*0.5;
				_environmentScreen.y = -_environmentScreen.height * 1.0;
				
			}
			
			_objectsLayer.onCameraResize(environmentPixelsWidth, environmentPixelsHeight);
		}
		
		
		
		
		public function setLocation(locationID:int):void
		{
			var locationInfo:LocationInfo = Facade.instance.info.getInfoComponentByID(locationID) as LocationInfo;
			_environmentPixels = assetManager.getBitmapData(locationInfo.environment);
			
			
			_worldBounds.init(locationInfo);
			
			
		}
		
		
		public function setCameraPosition(wordX:Number, wordY:Number, wordRotation:Number):void
		{
			_wordX = wordX;
			_wordY = wordY;
			_wordRotation = wordRotation;
			_wordAngle = _wordRotation / 180.0 * Math.PI;
			_heading.x = Math.cos(_wordAngle);
			_heading.y = Math.sin(_wordAngle);
			
			
		}
		
		
		public function render():void
		{
			grabPixelsOnScreen();
			renderObjects();
			renderLocationBounds();
			
			
		}
		public function addRenderedObject(value:IRendered):void
		{
			_objectsLayer.addRenderedObject(value);
		}
		public function removeRenderedObject(value:IRendered):void
		{
			_objectsLayer.removeRenderedObject(value);
		}
		
		/* INTERFACE com.game.plugins.log.ILogItem */
		
		public function write():String 
		{
			var result:String=_wordX + "," + _wordY + "," + _wordRotation;
			return result;
		}
		public function read(entryStepIndex:int,stepInterval:int, value:String,currentStepIndex:int):void 
		{
			var params:Array = value.split(",");
			var entryWorldX:Number = params[0];
			var entryWorldY:Number = params[1];
			var entryWorldRotation:Number = params[2];
			
			if (_lastEntyStepIndex < 0) {
				_lastEntryWorldX = entryWorldX;
				_lastEntryWorldY = entryWorldY;
				_lastEtryRotation = entryWorldRotation;
			}
			
			var kX:Number= Math.atan2(entryWorldX - _lastEntryWorldX, stepInterval);
			var kY:Number= Math.atan2(entryWorldY - _lastEntryWorldY, stepInterval);
			var kRot:Number = Math.atan2(entryWorldRotation - _lastEtryRotation, stepInterval);
			
			
			var dt:Number = stepInterval + (currentStepIndex - entryStepIndex);
			
			_lastAlignmentStepIndex = currentStepIndex + stepInterval - 1;
			//_startAlignmentStepIndex = currentStepIndex;
			var alingmentWorldX:Number = entryWorldX + dt * Math.tan(kX);
			var alignmentWorldY:Number = entryWorldY + dt * Math.tan(kY);
			var alignmentRotation:Number = entryWorldRotation + dt * Math.tan(kRot);
			
			_alignmentXSpeed = (alingmentWorldX - _wordX) / Number(stepInterval);
			_alignmentYSpeed= (alignmentWorldY - _wordY) / Number(stepInterval);
			_aligmentRSpeed= (alignmentRotation - _wordRotation) / Number(stepInterval);
			
			
			
			_lastEntyStepIndex = entryStepIndex;
			_lastEntryWorldX = entryWorldX;
			_lastEntryWorldY = entryWorldY;
			_lastEtryRotation = entryWorldRotation;
			
			
			
			//trace("read", _alingmentWorldX,_wordX);
		}
		
		/* INTERFACE com.game.plugins.log.ILogItem */
		
		public function align(currentGameStep:int):void 
		{
			var dx:Number= _alignmentXSpeed;
			var dy:Number= _alignmentYSpeed;
			var dr:Number= _aligmentRSpeed;
			
			setCameraPosition(_wordX + dx, _wordY + dy, _wordRotation + dr);
			
		}
		
		public function get lastAlignmentStepIndex():int{return _lastAlignmentStepIndex}
		
		private function grabPixelsOnScreen():void
		{
			var currentWidth:Number = _environmentScreenPixels.width;
			var currentHeiht:Number = _environmentScreenPixels.height;
			
			
			_environmentScreenPixels.fillRect(_environmentScreenPixels.rect, 0x00cccccc);
			
			_grabWordPixelsMatrix.identity();
			_grabWordPixelsMatrix.translate( -_wordX, -_wordY);
			_grabWordPixelsMatrix.rotate( -Math.PI / 2 - _wordAngle);
			_grabWordPixelsMatrix.translate( currentWidth * 0.5, currentHeiht);
			
			_environmentScreenPixels.draw(_environmentPixels, _grabWordPixelsMatrix);
			
			
		}
		private function renderLocationBounds():void
		{
			var currentWidth:Number = _environmentScreenPixels.width;
			var currentHeiht:Number = _environmentScreenPixels.height;
			
			_worldBounds.render(_wordX, _wordY, _wordAngle, currentWidth, currentHeiht);
		}
		
		private function renderObjects():void
		{
			_objectsLayer.render(_wordX, _wordY, _wordAngle);
		}
		
		
		public function get screenWidth():Number{return _screenWidth;}
		public function get screenHeight():Number {return _screenHeight;}
		
		
		
		public function get wordX():Number {return _wordX;}
		public function get wordY():Number {return _wordY;}
		public function get wordRotation():Number{return _wordRotation;}
		
		public function get wordAngle():/*radians*/Number {return _wordAngle;}		
		
		public function get id():String 
		{
			return _id;
		}
		
		public function set id(value:String):void 
		{
			_id = value;
		}
		
		public function get environmentPixels():BitmapData 
		{
			return _environmentPixels;
		}
	}

}