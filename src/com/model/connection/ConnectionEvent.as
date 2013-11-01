package com.model.connection 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	[Event(name="connect", type="com.model.connection.ConnectionEvent")]
	[Event(name="reconnect", type="com.model.connection.ConnectionEvent")]
	[Event(name="player_added", type="com.model.connection.ConnectionEvent")]
	[Event(name="player_removed", type="com.model.connection.ConnectionEvent")]
	[Event(name="message", type="com.model.connection.ConnectionEvent")]
	public class ConnectionEvent extends Event 
	{
		static public const CONNECT:String = "connect";
		static public const RECONNECT:String = "reconnect";
		static public const PLAYER_ADDED:String = "player_added";
		static public const PLAYER_REMOVED:String = "player_removed";
		
		static public const MESSAGE:String = "message";
		
		private var _data:Object
		
		
		public function ConnectionEvent(type:String, data:Object=null):void
		{
			_data = data;
			super(type, false, false);
			
		}
		override public function clone():Event 
		{
			return new ConnectionEvent(type, data);
		}
		
		
		
		public function get data():Object {	return _data;}
		
	}

}