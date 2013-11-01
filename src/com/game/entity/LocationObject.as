package com.game.entity 
{
	import com.camera.IRendered;
	import com.managers.info.components.LocationInfo;
	import com.managers.info.components.ObjectInfo;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class LocationObject extends BaseEntity
	{
		private var _objectInfo:ObjectInfo
		
		public function LocationObject() 
		{
			super();
			
		}
		override public function init(templateID:int):void 
		{
			super.init(templateID);
			_objectInfo = baseInfo as ObjectInfo
			while (gameCameraSkin.numChildren) {
				gameCameraSkin.removeChildAt(0);
			}
			var skin:Sprite = assetManager.getSprite(_objectInfo.skin);
			gameCameraSkin.addChild(skin);
			//skin.x = -(0.5 * skin.width);
			//skin.y = -0.5 * skin.height;
			
			mass = _objectInfo.mass;
			boundRadius = _objectInfo.boundRadius;
		}
		
		
		
		
		public function get objectInfo():ObjectInfo {return _objectInfo;}
		
		
		
		
		
	}

}