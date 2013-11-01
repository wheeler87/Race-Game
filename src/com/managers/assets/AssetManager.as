package com.managers.assets 
{
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.system.ApplicationDomain;
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class AssetManager 
	{
		
		
		public function AssetManager() 
		{
			
		}
		
		public function getSource(assetName:String):Class
		{
			var domain:ApplicationDomain = ApplicationDomain.currentDomain;
			var result:Class = (domain.hasDefinition(assetName))?domain.getDefinition(assetName) as Class:null;
			return result;
		}
		public function getBitmapData(assetName:String):BitmapData
		{
			var source:Class = getSource(assetName);
			var result:BitmapData = (source)?new source():null;
			
			return result;
		}
		public function getMovieClip(assetName:String):MovieClip
		{
			var source:Class = getSource(assetName);
			var result:MovieClip = (source)?new source():null;
			
			return result;
		}
		public function getSprite(assetName:String):Sprite
		{
			var source:Class = getSource(assetName);
			var result:Sprite = (source)?new source():null;
			
			return result;
		}
	}

}