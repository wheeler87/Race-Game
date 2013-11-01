package com.view.components.joinGame 
{
	import com.managers.assets.AssetNamesConst;
	import com.model.connection.GameRoomData;
	import com.view.ApplicationSprite;
	import com.view.components.common.PlayerProfile;
	import com.view.text.TextStyle;
	import fl.controls.Button;
	import fl.controls.Label;
	import fl.controls.List;
	import fl.data.DataProvider;
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class JoinGameScreen extends ApplicationSprite 
	{
		private var _width:Number;
		private var _height:Number;
		
		private var _playerProfile:PlayerProfile;
		
		private var _gameLabel:Label
		private var _gamesList:List;
		
		private var _backBtn:Button
		private var _joinBtn:Button;
		
		private var _gameName:String
		
		
		public function JoinGameScreen(width:Number,height:Number):void
		{
			super();
			
			_width = width;
			_height = height;
			
			fillBg();
			addPlayerProfile();
			addGamesRelatedContent();
			addButtons();
			align();
		}
		public function activate():void
		{
			_playerProfile.addEventListener(PlayerProfile.USERNAME_CHANGE, onUserNameChange);
			_gamesList.addEventListener(Event.CHANGE, onSelectedRoomChange);
			onGameRoomNameChange()
			validateButtonsStatus();
			_playerProfile.activate();
		}
		
		
		
		
		public function deactivate():void
		{
			_playerProfile.removeEventListener(PlayerProfile.USERNAME_CHANGE, onUserNameChange);
			_gamesList.removeEventListener(Event.CHANGE, onSelectedRoomChange);
			_playerProfile.deactivate()
		}
		
		private function fillBg():void 
		{
			var g:Graphics = graphics;
			g.clear();
			g.beginFill(AssetNamesConst.COLOR_LIGHT_BLACK);
			g.drawRect(0, 0, _width, _height);
		}
		
		private function addPlayerProfile():void 
		{
			_playerProfile = new PlayerProfile();
			addChild(_playerProfile);
			
		}
		
		private function addGamesRelatedContent():void 
		{
			var format:TextFormat = new TextFormat();
			format.font = TextStyle.APPLICATION_FONT_NAME;
			format.size = 18;
			format.color = AssetNamesConst.COLOR_WHITE_DARK;
			
			_gameLabel = new Label();
			_gameLabel.setStyle("embedFonts", true);
			_gameLabel.setStyle("textFormat", format);
			_gameLabel.autoSize = TextFieldAutoSize.LEFT;
			
			_gameLabel.text = "Created Games:";
			addChild(_gameLabel);
			
			_gamesList = new List();
			_gamesList.setStyle("cellRenderer", GameRoomRenderer);
			
			
			_gamesList.rowCount = 5;
			_gamesList.rowHeight = GameRoomRenderer.HEIGHT;
			
			
			_gamesList.setSize(GameRoomRenderer.WIDTH, GameRoomRenderer.HEIGHT*5);
			
			
			addChild(_gamesList);
		}
		
		private function addButtons():void 
		{
			var format:TextFormat = TextStyle.getFormatForButton();
			
			_backBtn = new Button();
			_backBtn.setStyle("embedFonts", true);
			_backBtn.setStyle("textFormat", format);
			_backBtn.setStyle("disabledTextFormat", format);
			
			_backBtn.label = "Back";
			addChild(_backBtn);
			
			_joinBtn = new Button();
			_joinBtn.setStyle("embedFonts", true);
			_joinBtn.setStyle("textFormat", format);
			_joinBtn.setStyle("disabledTextFormat", format);
			
			_joinBtn.label = "Join";
			addChild(_joinBtn);
			
			
			
		}
		
		private function align():void 
		{
			_playerProfile.x = 10;
			
			_gameLabel.x = _playerProfile.x + (_playerProfile.width - _gameLabel.width) * 0.5-40;
			_gameLabel.y = 200;
			
			_gamesList.x = _playerProfile.x + (_playerProfile.width - _gamesList.width) * 0.5;
			_gamesList.y = _gameLabel.y + _gameLabel.height + 10;
			
			_backBtn.x = _playerProfile.x+_playerProfile.width+(_width-_playerProfile.x-_playerProfile.width - _backBtn.width)*0.5;	
			_backBtn.y = 20;
			
			_joinBtn.x = _backBtn.x;
			_joinBtn.y = _backBtn.y + _backBtn.height + 10;
			
			
		}
		
		public function get backBtn():Button { return _backBtn; }
		public function get joinBtn():Button {	return _joinBtn;}
		public function get username():String {	return _playerProfile.username;}
		public function get racerTemplateID():int {return _playerProfile.racerTemplateID;}
		
		public function set username(value:String):void 
		{
			_playerProfile.username = value;
		}
		
		public function set racerTemplateID(value:int):void 
		{
			_playerProfile.racerTemplateID = value;
		}
		
		public function get gameName():String {	return _gameName;}
		public function setCreatedGamesData(gameRoomsList:Vector.<GameRoomData>):void
		{
			var dataProvider:DataProvider = new DataProvider();
			var room:GameRoomData
			for (var i:uint = 0; i < gameRoomsList.length; i++ ) {
				room = gameRoomsList[i];
				var data:Object = { };
				data.label = "";
				data.room = room;
				
				dataProvider.addItem(data);
				
			}
			
			_gamesList.dataProvider = dataProvider;
			_gamesList.selectedIndex = dataProvider.length - 1;
			
			onGameRoomNameChange();
			validateButtonsStatus();
			
		}
		
		
		
		private function validateButtonsStatus():void
		{
			var gameRoom:GameRoomData = (_gamesList.selectedItem)?_gamesList.selectedItem.room:null;
			
			_joinBtn.enabled = ((username) && (username.length) && (gameRoom)&&(gameRoom.opened));
		}
		private function onGameRoomNameChange():void
		{
			_gameName = (_gamesList.selectedItem && _gamesList.selectedItem.room)?(_gamesList.selectedItem.room as GameRoomData).name:"";
		}
		
		
		private function onUserNameChange(e:Event):void 
		{
			validateButtonsStatus();
		}
		private function onSelectedRoomChange(e:Event):void 
		{
			onGameRoomNameChange();
			validateButtonsStatus();
			
		}
	}

}