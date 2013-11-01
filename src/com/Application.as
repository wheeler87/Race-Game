package com 
{
	import com.camera.GameCamera;
	import com.game.entity.Racer;
	import com.game.Game;
	import com.game.settings.GameSettings;
	import com.game.settings.Player;
	import com.managers.assets.AssetNamesConst;
	import com.managers.info.components.LocationContentInfo;
	import com.managers.info.components.LocationInfo;
	import com.view.ApplicationSprite;
	
	import com.view.text.ApplicationTF;
	import com.view.text.TextStyle;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class Application extends ApplicationSprite 
	{
		private var _game:Game
		
		
		
		public function Application() 
		{
			super();
			
			
			
			Facade.instance.init(this);
			
		}
		public function createUIComponents():void
		{
			
		}
		
		
		
	}

}