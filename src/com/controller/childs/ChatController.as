package com.controller.childs 
{
	import com.Facade;
	import com.managers.messenger.Message;
	import com.managers.messenger.Messenger;
	import com.model.ApplicationState;
	import com.model.connection.ConnectionEvent;
	import com.model.connection.MessageData;
	import com.model.connection.P2PConnection;
	import com.view.components.chat.ChatPanel;
	import flash.events.DataEvent;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class ChatController extends BaseChildController 
	{
		static private var _instance:ChatController = new ChatController();
		private var _panel:ChatPanel;
		private var _connection:P2PConnection
		
		private var _localUsernameColor:uint = 0xcccc00;
		private var _remoteUsernameColor:uint = 0x00cccc;
		private var _speechColor:uint;
		
		public function ChatController() 
		{
			super();
			if (instance) {
				throw new Error("asas");
				return;
			}
		}
		
		override public function onEnter():void 
		{
			super.onEnter();
			
			if (!_panel) {
				var panelWidth:Number = model.screenWidth-20;
				var panelHeight:Number = 200;
				
				_panel = new ChatPanel(panelWidth, panelHeight);
				_panel.x = (model.screenWidth - panelWidth) * 0.5;
				_panel.y = model.screenHeight- panelHeight-5;
			}
			view.addChild(_panel);
			view.stage.tabChildren = false
			
			
			var messanger:Messenger = Facade.instance.messanger;
			messanger.addEventListener(Message.STATE_ENTER, stateEnterHandler,false,-100);
			
			
		}
		
		
		override public function onExit():void 
		{
			super.onExit();
			var messanger:Messenger = Facade.instance.messanger;
			messanger.removeEventListener(Message.STATE_ENTER, stateEnterHandler);
			
		}
		
		private function stateEnterHandler(e:Message):void 
		{
			switch (model.applicationState) 
			{
				case ApplicationState.MAIN_MENU:
					unsubscribeOffUserInput();
					setConnection(null);
					_panel.clearCorrespondence();
					_panel.mode = _panel.MODE_PASSIVE;
					
				break;
				case ApplicationState.CREATE_GAME:
					unsubscribeOffUserInput();
					setConnection(null);
					_panel.mode = _panel.MODE_PASSIVE;
					
				break;
				case ApplicationState.JOIN_GAME:
					subscribeOnUserInput();
					setConnection(model.connectionManager.gameGroupConnection);
					_panel.mode = _panel.MODE_PASSIVE;
					
				break;
				case ApplicationState.LOBBY:
					subscribeOnUserInput();
					setConnection(model.connectionManager.gameConnection);
					_panel.mode = _panel.MODE_ACTIVE;
					
				break;
				case ApplicationState.GAME:
					subscribeOnUserInput();
					setConnection(model.connectionManager.gameConnection);
					_panel.mode = _panel.MODE_PASSIVE;
					_panel.clearCorrespondence();
					
				break;
				
			}
		}
		private function subscribeOnUserInput():void
		{
			view.stage.focus = null;
			_panel.addEventListener(ChatPanel.TEXT_TYPED, onTextTyped);
			view.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			_panel.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
		}
		
		private function keyDownHandler(e:KeyboardEvent):void 
		{
			if ((e.keyCode != Keyboard.ENTER) && (e.keyCode != Keyboard.ESCAPE)) {
				return;
			}
			
			
			
			if ((e.currentTarget == _panel)&&(e.keyCode==Keyboard.ENTER)) {
				e.stopImmediatePropagation();
				return;
			}
			
			if (_panel.mode == _panel.MODE_ACTIVE) {
				_panel.mode=_panel.MODE_PASSIVE;
			}else if(e.keyCode==Keyboard.ENTER){
				_panel.mode=_panel.MODE_ACTIVE;
			}
			
		}
		
		private function onTextTyped(e:DataEvent):void 
		{
			var text:String = e.data;
			if (text.length) {
				sendSpeechMessage(text);
			}else {
				_panel.mode=_panel.MODE_PASSIVE
			}
		}
		private function unsubscribeOffUserInput():void
		{
			
		}
		private function setConnection(value:P2PConnection):void
		{
			if (_connection == value) return;
			if (_connection) {
				_connection.removeEventListener(ConnectionEvent.MESSAGE, onConnectionMessageEvent);
			}
			_connection = value;
			if (_connection) {
				_connection.addEventListener(ConnectionEvent.MESSAGE, onConnectionMessageEvent);
			}
			
		}
		
		private function onConnectionMessageEvent(e:ConnectionEvent):void 
		{
			var messageData:MessageData = e.data as MessageData;
			if (messageData.name != MessageData.SPEECH) return;
			handleSpeechMessage(messageData);
			
		}
		
		
		private function sendSpeechMessage(speech:String):void
		{
			var data:Object = new Object();
			data.speech = speech;
			data.username = model.playerManager.ownerPlayer.name;
			
			
			
			_panel.addMessage(model.playerManager.ownerPlayer.name, _localUsernameColor, speech, _speechColor);
			_connection.sendCommand(MessageData.SPEECH, data);
		}
		private function handleSpeechMessage(value:MessageData):void
		{
			var username:String = value.data.username;
			var speech:String = value.data.speech
			
			_panel.addMessage(username, _remoteUsernameColor, speech, _speechColor);
		}
		
		static public function get instance():ChatController 
		{
			return _instance;
		}
		
		public function get panel():ChatPanel {	return _panel;	}
		
	}

}