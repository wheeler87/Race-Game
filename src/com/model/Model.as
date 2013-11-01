package com.model 
{
	import com.managers.messenger.Message;
	import com.managers.messenger.Messenger;
	import com.model.connection.ConnectionManager;
	import com.model.connection.P2PConnection;
	import com.model.player.PlayerManager;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class Model extends EventDispatcher 
	{
		public static const PLAYERS_MAXIMUM:int = 6;
		static public const HOME_PAGE:String = "http://gamestore.ucoz.com/";
		
		public var screenWidth:Number = 0;
		public var screenHeight:Number = 0;
		
		public var gameName:String;
		public var isGameFounder:Boolean;
		
		private var _applicationState:int = -1;
		
		private var _messanger:Messenger
		
		
		private var _playerManager:PlayerManager;
		private var _connectionManager:ConnectionManager
		
		public function Model(messanger:Messenger) 
		{
			super(null);
			_messanger = messanger;
			
			
			_playerManager = new PlayerManager(this);
			_connectionManager = new ConnectionManager(this);
		}
		
		public function get applicationState():int 
		{
			return _applicationState;
		}
		
		public function set applicationState(value:int):void 
		{
			_messanger.sendMessage(Message.STATE_EXIT);
			_applicationState = value;
			_messanger.sendMessage(Message.STATE_ENTER);
		}
		
		public function get playerManager():PlayerManager 
		{
			return _playerManager;
		}
		
		public function get messanger():Messenger 
		{
			return _messanger;
		}
		
		public function get connectionManager():ConnectionManager 
		{
			return _connectionManager;
		}
		
	}

}