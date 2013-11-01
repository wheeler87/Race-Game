package com.game.plugins.task 
{
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class PriorityInitialization 
	{
		public static var FIRST:int = 100;
		public static var LAST:int = -100;
		
		public static var CAMERA_CONTROL_PLUGIN_INITIALIZATION:int = 4;
		public static var LOG_PLUGIN_INITIALIZATION:int = 3;
		public static var PHYSICS_PLUGIN_INITIALIZATION:int = 2;
		public static var PLAYER_CONTROLL_PLUGIN_INITIALIZATION:int = 1;
		public static var NAVIGATION_PLUGIN_INITIALIZATION:int = 0;
		public static var AI_PLUGIN_INITIALIZATION:int = -1;
		public static var START_GAME_INITIALIZATION:int = -2;
		public static var GAME_INTERFACE_INITIALIZATION:int = -2;
		public static var DIALOG_PLUGIN_INIIALIZATION:int = -3;
		
		
		public function PriorityInitialization() 
		{
			
		}
		
	}

}