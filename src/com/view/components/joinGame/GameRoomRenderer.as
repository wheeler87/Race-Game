package com.view.components.joinGame 
{
	import com.managers.assets.AssetNamesConst;
	import com.model.connection.GameRoomData;
	import com.view.ApplicationSprite;
	import com.view.text.TextStyle;
	import fl.controls.Button;
	import fl.controls.Label;
	import fl.controls.listClasses.CellRenderer;
	import fl.controls.listClasses.ICellRenderer;
	import fl.controls.listClasses.ListData;
	import flash.events.MouseEvent;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class GameRoomRenderer extends ApplicationSprite implements ICellRenderer
	{
		static public const WIDTH:Number=620;
		static public const HEIGHT:Number = 60;
		
		
		private var _gameRoom:GameRoomData
		
		private var _selected:Boolean;
		private var _listData:ListData;
		private var _data:Object
		
		private var _background:Button;
		
		private var _founderLabel:Label;
		private var _founderNameLabel:Label;
		
		private var _gameLabel:Label
		private var _gameNameLabel:Label;
		
		private var _statusLabel:Label;
		private var _openedLabel:Label
		private var _closedLabel:Label;
		
		
		public function GameRoomRenderer() 
		{
			super();
			
			createComponents();
			alignComponents();
		}
		
		
		private function createComponents():void 
		{
			_background = new Button();
			_background.setSize(WIDTH, HEIGHT);
			_background.label = "";
			addChild(_background);
			_background.drawNow();
			_background.mouseEnabled = false;
			
			
			format = TextStyle.getFormatForButton();
			format.size = 10;
			format.color = AssetNamesConst.COLOR_BLUE;
			
			_gameLabel = new Label();
			addChild(_gameLabel);
			_gameLabel.setStyle("embedFonts", true);
			_gameLabel.setStyle("textFormat", format);
			_gameLabel.autoSize = TextFieldAutoSize.LEFT;
			_gameLabel.text = "Game:";
			_gameLabel.drawNow();
			
			format = TextStyle.getFormatForButton();
			format.size = 20;
			format.color=AssetNamesConst.COLOR_GREEN
			
			_gameNameLabel = new Label();
			addChild(_gameNameLabel);
			_gameNameLabel.setStyle("embedFonts", true);
			_gameNameLabel.setStyle("textFormat", format);
			_gameNameLabel.autoSize = TextFieldAutoSize.LEFT;
			_gameNameLabel.text = "";
			_gameNameLabel.drawNow();
			
			
			var format:TextFormat;
			format = TextStyle.getFormatForButton();
			format.size = 10;
			format.color = AssetNamesConst.COLOR_BLUE;
			
			_founderLabel = new Label();
			_founderLabel.setStyle("embedFonts", true);
			_founderLabel.setStyle("textFormat", format);
			_founderLabel.autoSize = TextFieldAutoSize.LEFT;
			_founderLabel.text = "Founder:";
			_founderLabel.drawNow();
			addChild(_founderLabel);
			
			format = TextStyle.getFormatForButton();
			format.color = AssetNamesConst.COLOR_GREEN;
			format.size = 12;
			_founderNameLabel = new Label();
			_founderNameLabel.setStyle("embedFonts", true);
			_founderNameLabel.setStyle("textFormat", format);
			_founderNameLabel.autoSize = TextFieldAutoSize.LEFT;
			_founderNameLabel.text = "";
			_founderNameLabel.drawNow();
			addChild(_founderNameLabel);
			
			
			
			
			format = TextStyle.getFormatForButton();
			format.size = 10;
			format.color = AssetNamesConst.COLOR_BLUE;
			
			_statusLabel = new Label();
			addChild(_statusLabel);
			
			_statusLabel.setStyle("embedFonts", true);
			_statusLabel.setStyle("textFormat", format);
			_statusLabel.autoSize = TextFieldAutoSize.LEFT;
			_statusLabel.text = "Status:";
			_statusLabel.drawNow();
			
			format = TextStyle.getFormatForButton();
			format.size = 12;
			format.color = AssetNamesConst.COLOR_GREEN;
			
			_openedLabel = new Label();
			addChild(_openedLabel);
			
			_openedLabel.setStyle("embedFonts", true);
			_openedLabel.setStyle("textFormat", format);
			_openedLabel.autoSize = TextFieldAutoSize.LEFT;
			_openedLabel.text = "opened";
			_openedLabel.drawNow();
			
			format = TextStyle.getFormatForButton();
			format.size = 12;
			format.color = AssetNamesConst.COLOR_RED;
			
			_closedLabel = new Label();
			addChild(_closedLabel);
			
			_closedLabel.setStyle("embedFonts", true);
			_closedLabel.setStyle("textFormat", format);
			_closedLabel.autoSize = TextFieldAutoSize.LEFT;
			_closedLabel.text = "closed";
			_closedLabel.drawNow();
			
			
			
		}
		private function alignComponents():void
		{
			_gameLabel.x = 10;
			_gameLabel.y = 9;
			
			_gameNameLabel.x = _gameLabel.x + _gameLabel.width+5;
			_gameNameLabel.y = 0;
			
			
			_founderLabel.x = 10;
			_founderLabel.y = HEIGHT - _founderLabel.height + 2;
			
			_founderNameLabel.x = _founderLabel.x + _founderLabel.width + 5;
			_founderNameLabel.y = _founderLabel.y-2;
			
			var statusValuePos:int = (WIDTH - Math.max(_openedLabel.width, _closedLabel.width) - 10);
			
			_statusLabel.x = statusValuePos - _statusLabel.width - 5;
			_statusLabel.y = _founderLabel.y;
			
			_openedLabel.x = statusValuePos;
			_openedLabel.y = _founderNameLabel.y;
			
			_closedLabel.x = statusValuePos;
			_closedLabel.y = _founderNameLabel.y;
			
		}
		
		
		
		
		/* INTERFACE fl.controls.listClasses.ICellRenderer */
		
		public function get data():Object{return _data;}
		public function set data(value:Object):void 
		{
			
			_data = value;
			_gameRoom = value.room as GameRoomData;
			visible = Boolean(_gameRoom);
			stopInputBlocking();
			if (!_gameRoom) return;
			_gameNameLabel.text = _gameRoom.name;
			_founderNameLabel.text = _gameRoom.foundername;
			_closedLabel.visible = (!_gameRoom.opened);
			_openedLabel.visible = (_gameRoom.opened);
			if (!_gameRoom.opened) {
				startInputBlocking();
			}
			
			
		}
		private function startInputBlocking():void
		{
			addEventListener(MouseEvent.MOUSE_DOWN, inputCanceler,false,int.MAX_VALUE);
			addEventListener(MouseEvent.CLICK, inputCanceler,false,int.MAX_VALUE);
			addEventListener(MouseEvent.MOUSE_UP, inputCanceler,false,int.MAX_VALUE);
		}
		private function stopInputBlocking():void
		{
			removeEventListener(MouseEvent.MOUSE_DOWN, inputCanceler);
			removeEventListener(MouseEvent.CLICK, inputCanceler);
			removeEventListener(MouseEvent.MOUSE_UP, inputCanceler);
		}
		
		private function inputCanceler(e:MouseEvent):void 
		{
			
			e.stopImmediatePropagation();
		}
		
		public function get listData():ListData{return _listData;}
		public function set listData(value:ListData):void {_listData = value;}
		public function get selected():Boolean {return _selected;}
		public function set selected(value:Boolean):void {
			
			_selected = value;
			_background.setMouseState((value)?"down":"up");
			_background.drawNow();
			
		}
		
		public function setMouseState(param0:String):void 
		{
			
		}
		
		public function setSize(param0:Number, param1:Number):void 
		{
			
		}
		
		
	}

}