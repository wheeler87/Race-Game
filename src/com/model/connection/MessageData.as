package com.model.connection 
{
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class MessageData extends Object 
	{
		static public const GAME_ROOM_UPDATE:String = "game_room_update";
		
		static public const PLAYER_JOIN:String = "player_join";
		static public const PLAYER_KICK:String = "player_kick";
		static public const PLAYER_INFO:String = "player_info";
		static public const START_GAME:String = "start_game";
		
		static public const PLAYER_LOG:String = "player_log";
		static public const SPEECH:String = "speech";
		
		public var name:String
		public var data:Object;
		public var peerID:String;
		
		public function MessageData() 
		{
			super();
			
		}
		public function toString():String
		{
			var result:String = "[" + name + ", " + data + ", " + peerID;
			return result;
		}
	}

}