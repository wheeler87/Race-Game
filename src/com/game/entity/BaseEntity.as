package com.game.entity 
{
	import com.camera.IRendered;
	import com.Facade;
	import com.geom.GeoUtil;
	import com.managers.assets.AssetManager;
	import com.managers.info.IInfoComponent;
	import com.managers.info.Info;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class BaseEntity implements IRendered
	{
		private var _id:String
		
		protected var _debug:Boolean
		protected var _wordX:Number=0;
		protected var _wordY:Number = 0;
		public var lastWorldX:Number=0;
		public var lastWorldY:Number=0;
		
		protected var _gameCameraSkin:Sprite;
		
		protected var _worldAngle:Number = -Math.PI / 2;
		protected var _screenAngle:Number = 0;
		
		public var movable:Boolean=true
		public var velocity:Vector3D= new Vector3D();
		
		public var angularVelocity:Number = 0;
		
		public var solid:Boolean=true;
		
		public var mass:Number = 0.1;
		public var dragForce:Vector3D = new Vector3D();
		public var turnForce:Number=0;
		
		public var frictionRatio:Number = 0.95;
		
		
		private var _boundRadius:Number = 10;
		
		private var _baseInfo:IInfoComponent
		
		public var justCollidedWithBound:Boolean;
		public var justCollidedWithEntity:Boolean;
		
		public function BaseEntity() 
		{
			_gameCameraSkin = new Sprite();
		}
		public function init(templateID:int):void
		{
			_baseInfo = info.getInfoComponentByID(templateID);
			
		}
		
		/* INTERFACE com.camera.IRendered */
		
		public function get wordX():Number{	return _wordX;}
		public function get wordY():Number {return _wordY;}
		public function get gameCameraSkin():Sprite {return _gameCameraSkin;}
		
		public function set wordX(value:Number):void 
		{
			lastWorldX = _wordX;
			_wordX = value;
		}
		
		public function set wordY(value:Number):void 
		{
			lastWorldY = _wordY;
			_wordY = value;
		}
		
		public function get baseInfo():IInfoComponent {	return _baseInfo;}
		
		protected function get info():Info { return Facade.instance.info }
		protected function get assetManager():AssetManager { return Facade.instance.assetManager }
		
		public function get id():String 
		{
			return _id;
		}
		
		public function set id(value:String):void 
		{
			_id = value;
		}
		
		public function get worldAngle():Number {return _worldAngle;}
		
		public function set worldAngle(value:Number):void 
		{
			_worldAngle = GeoUtil.getPureRadians(value);
		}
		
		public function get screenAngle():Number {return _screenAngle;}
		
		public function set screenAngle(value:Number):void 
		{
			_screenAngle =GeoUtil.getPureRadians(value);
		}
		
		public function get boundRadius():Number 
		{
			return _boundRadius;
		}
		
		public function set boundRadius(value:Number):void 
		{
			_boundRadius = value;
			//var g:Graphics = _gameCameraSkin.graphics;
			//g.clear();
			//g.beginFill(0, 0.4);
			//g.drawCircle(0, 0, _boundRadius);
		}
	}

}