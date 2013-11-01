package com.model.connection 
{
	import com.model.Model;
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class ConnectionManager 
	{
		private const GROUP_NAME_PREFIX:String="RaceGame."
		
		private var _model:Model;
		
		private var _gameGroupConnection:P2PConnection;
		private var _gameConnection:P2PConnection
		
		public function ConnectionManager(model:Model):void
		{
			_model = model;
			
			_gameGroupConnection = new P2PConnection();
			_gameConnection = new P2PConnection();
		}
		public function connectToGamesGroupRoom():void
		{
			var groupname:String = GROUP_NAME_PREFIX + "GamesRoom";
			_gameGroupConnection.connectToGroup(groupname);
		}
		public function connectToGameRoom(gameName:String):void
		{
			var groupname:String = GROUP_NAME_PREFIX + gameName;
			_gameConnection.connectToGroup(groupname);
		}
		
		public function get gameGroupConnection():P2PConnection 
		{
			return _gameGroupConnection;
		}
		
		public function get gameConnection():P2PConnection 
		{
			return _gameConnection;
		}
		
	}

}