package com.model.connection 
{
	import adobe.utils.CustomActions;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.events.TimerEvent;
	import flash.net.GroupSpecifier;
	import flash.net.NetConnection;
	import flash.net.NetGroup;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	[Event(name="connect", type="com.model.connection.ConnectionEvent")]
	[Event(name="reconnect", type="com.model.connection.ConnectionEvent")]
	[Event(name="player_added", type="com.model.connection.ConnectionEvent")]
	[Event(name="player_removed", type="com.model.connection.ConnectionEvent")]
	[Event(name="message", type="com.model.connection.ConnectionEvent")]
	public class P2PConnection extends EventDispatcher 
	{
		static public const DEV_KEY:String = "0c31c37d4438532d8b694f3d-0ffa55a30e9f";
		static public const SERVER_PATH:String = "rtmfp://p2p.rtmfp.net/";
		
		public var peerID:String
		public var enableReconnect:Boolean = true;
		
		private var _groupName:String
		
		private var _connection:NetConnection;
		private var _group:NetGroup;
		
		private var _connectedToServer:Boolean;
		private var _connectedToGroup:Boolean;
		
		private var _reconnectTimer:Timer
		
		private var _cnt:int = 1;
		
		private var _commandsStack:Array;
		private var _shape:Shape
		
		public function P2PConnection() 
		{
			super(null);
			_commandsStack = new Array();
			_shape = new Shape();
		}
		
		public function connectToGroup(groupName:String):void
		{
			removeGroupConnection();
			_groupName = groupName;
			onConnectionStatusChanged();
		}
		
		
		private function onConnectionStatusChanged():void
		{
			if (!_connectedToServer) {
				createNetConnection();
			}else if (!_connectedToGroup) {
				createGroupConnection();
			}
		}
		
		private function createNetConnection():void
		{
			if (_connection) return
			_connectedToServer = false;
			_connection = new NetConnection();
			_connection.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			_connection.connect(SERVER_PATH + DEV_KEY);
		}
		
		
		private function removeNetConnection():void
		{
			_connectedToServer = false;
			if (!_connection) return;
			_connection.removeEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			//_connection.close();
			
			_connection = null;
			
		}
		private function createGroupConnection():void
		{
			if (_group) return;
			if ((!_groupName) || (!_groupName.length)) return;
			_connectedToGroup = false;
			
			var specifier:GroupSpecifier = new GroupSpecifier(_groupName);
			specifier.postingEnabled = true;
			specifier.serverChannelEnabled = true;
			
			_group = new NetGroup(_connection, specifier.groupspecWithoutAuthorizations());
			_group.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
		}
		
		private function removeGroupConnection():void
		{
			_connectedToGroup = false;
			if (!_group) return;
			_group.removeEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			
			//_group.close();
			_group = null;
		}
		
		
		private function startReconnect():void
		{
			if (!enableReconnect) {
				return;
			}
			if (!_reconnectTimer) {
				_reconnectTimer = new Timer(3000, 1);
				_reconnectTimer.addEventListener(TimerEvent.TIMER, onReconnectTime);
			}
			_reconnectTimer.reset();
			_reconnectTimer.start();
		}
		
		private function onReconnectTime(e:TimerEvent):void 
		{
			onConnectionStatusChanged();
		}
		
		
		private function netStatusHandler(e:NetStatusEvent):void 
		{
			var messageData:MessageData;
			var connectionData:ConnectionData
			
			switch (e.info.code) 
			{
				case "NetConnection.Connect.Success":
					_connectedToServer = true;
					onConnectionStatusChanged();
					
				break;
				case "NetGroup.Connect.Success":
					_connectedToGroup = true;
					onConnectionStatusChanged();
					peerID = _connection.nearID;
					connectionData = new ConnectionData();
					connectionData.peerID = _connection.nearID;
					
					dispatchEvent(new ConnectionEvent(ConnectionEvent.CONNECT,connectionData));
					
				break;
				case "NetGroup.Connect.Closed":
					removeGroupConnection();
					startReconnect();
					dispatchEvent(new ConnectionEvent(ConnectionEvent.RECONNECT));
				break;
				case "NetConnection.Connect.Failed":
					removeGroupConnection();
					removeNetConnection();
					startReconnect();
					dispatchEvent(new ConnectionEvent(ConnectionEvent.RECONNECT));
				break;
				case "NetGroup.Neighbor.Connect":
					connectionData = new ConnectionData();
					connectionData.peerID = e.info.peerID;
					
					dispatchEvent(new ConnectionEvent(ConnectionEvent.PLAYER_ADDED, connectionData));
					
				break;
				case "NetGroup.Neighbor.Disconnect":
					connectionData = new ConnectionData();
					connectionData.peerID = e.info.peerID;
					
					dispatchEvent(new ConnectionEvent(ConnectionEvent.PLAYER_REMOVED, connectionData));
				break;
				case "NetGroup.Posting.Notify":
					messageData = new MessageData();
					messageData.name = e.info.message.name;
					messageData.data = e.info.message.data;
					messageData.peerID=e.info.message.peerID
				
					dispatchEvent(new ConnectionEvent(ConnectionEvent.MESSAGE, messageData));
				break;
				
			}
		}
		public function sendCommand(commandName:String, commandData:Object,delay:int=0):void
		{
			var command:Object = { };
			command.cnt = _cnt++;
			command.cnt = Math.random()*int.MAX_VALUE;
			command.name = commandName;
			command.data = commandData;
			command.peerID = peerID;
			command.sendTime = getTimer() + delay;
			
			_commandsStack.push(command)
			_commandsStack.sortOn("sendTime");
			
			advancePosting();
			
			
		}
		
		private function advancePosting(e:Event = null):void
		{
			var currentTime:int = getTimer();
			while ((_commandsStack.length) && (_commandsStack[0].sendTime <= currentTime)) {
				var command:Object = _commandsStack.shift();
				_group.post(command);
			}
			if (_commandsStack.length) {
				if (!_shape) {
					_shape = new Shape();
				}
				_shape.addEventListener(Event.ENTER_FRAME, advancePosting);
			}else if (_shape) {
				_shape.removeEventListener(Event.ENTER_FRAME, advancePosting);
			}
			
		}
		
		
		public function closeConnection():void
		{
			removeGroupConnection();
			removeNetConnection();
		}
		public function isConnected():Boolean
		{
			return _connectedToGroup && _connectedToServer && _connection.connected;
		}
		public function get playersAmount():int
		{
			var result:int = (_group)?_group.neighborCount:0;
			return result;
		}
		
	}

}