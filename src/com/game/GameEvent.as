package com.game 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	[Event(name="connection_log_generated", type="com.game.GameEvent")]
	[Event(name="log_entries_applied", type="com.game.GameEvent")]
	[Event(name="race_started", type="com.game.GameEvent")]
	[Event(name="race_completed", type="com.game.GameEvent")]
	public class GameEvent extends Event 
	{
		static public const CONNECTION_LOG_GENERATED:String = "connection_log_generated";
		static public const LOG_ENTRIES_APPLIED:String = "log_entries_applied";
		static public const RACE_STARTED:String = "race_started";
		static public const RACE_COMPLETED:String="race_completed"
		
		
		private var _data:Object
		
		public function GameEvent(type:String, data:Object=null):void
		{
			_data = data;
			super(type, false, false);
			
		}
		override public function clone():Event 
		{
			return new GameEvent(type,data);
		}
		
		public function get data():Object 
		{
			return _data;
		}
		
	}

}