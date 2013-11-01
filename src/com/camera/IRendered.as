package com.camera 
{
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public interface IRendered 
	{
		function get wordX():Number
		function get wordY():Number
		function get gameCameraSkin():Sprite
		function get worldAngle():Number
		function get screenAngle():Number
		function set screenAngle(vaue:Number):void
	}
	
}