package com.view 
{
	import com.Facade;
	import com.managers.assets.AssetManager;
	import com.managers.info.Info;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class ApplicationSprite extends Sprite 
	{
		
		public function ApplicationSprite() 
		{
			super();
			
		}
		
		protected function get assetManager():AssetManager { return Facade.instance.assetManager }
		protected function get info():Info { return Facade.instance.info }
		
	}

}