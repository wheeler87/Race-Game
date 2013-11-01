package com.game.plugins.task 
{
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class PriorityUpdate 
	{
		public static var FIRST:int = 100;
		public static var LAST:int = -100;
		
		public static var LOG_READ:int = 0;
		
		
		
		public static var APPLY_PLAYER_INPUT:int = 6;
		public static var AI_UPDATE:int = 6;
		public static var APPLY_FRICTION_MAP:int=7
		
		
		public static var PHYSICS_SIMULATE_MOVEMENT:int = 6;
		public static var PHYSICS_RESLOVE_COLLISIONS:int = 5;
		public static var LOG_ALIGN:int = 1;
		
		
		public static var CAMERA_FOLLOW:int = 2;
		
		public static var NAVIGATION_UPDATE_RACE_PROGRESS:int = 7
		public static var NAVIGATION_CALCULATE_RACE_POSITION:int = 6;
		
		public static var GAME_INTERFACE_UPDATE:int = 0;
		public static var GAME_START_PLUGIN_UPDATE:int=LAST
		public static var DIALOG_PLUGIN_UPDATE:int = -10;
		
		
		public static var LOG_WRITE:int = LAST;
		
		
		
		public function PriorityUpdate() 
		{
			
		}
		
	}

}