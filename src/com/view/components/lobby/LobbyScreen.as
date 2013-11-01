package com.view.components.lobby 
{
	import com.game.settings.Player;
	import com.managers.assets.AssetNamesConst;
	import com.view.ApplicationSprite;
	import com.view.text.TextStyle;
	import fl.controls.Button;
	import fl.controls.ComboBox;
	import fl.data.DataProvider;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class LobbyScreen extends ApplicationSprite 
	{
		static public const SLOT_TYPE_CHANGE:String="slotTypeChange"
		
		static public const SLOT_TYPE_OPENED:int = 0;
		static public const SLOT_TYPE_CLOSED:int = 1;
		static public const SLOT_TYPE_CPU:int = 2;
		
		
		private var _totalSlots:int = 0;
		private var _width:Number;
		private var _height:Number;
		
		private var _leftColumnHolder:Sprite;
		private var _rightColumnHolder:Sprite
		
		private var _slotTypeList:Vector.<ComboBox>;
		private var _slotContentList:Vector.<SlotContentRenderer>;
		
		private var _backBtn:Button;
		private var _startBtn:Button;
		
		public function LobbyScreen(width:Number,height:Number,totalSlots:int):void
		{
			super();
			
			_totalSlots = totalSlots;
			_width = width;
			_height = height;
			
			fillBG();
			createColumnHolders();
			createSlotContentComponents();
			createSlotTypeComponents();
			createButtons();
			align();
		}
		public function activate():void
		{
			for (var i:uint = 0; i < _totalSlots; i++ ) {
				setSlotType(i, SLOT_TYPE_OPENED);
				setSlotContent(i, null);
			}
		}
		public function deactivate():void
		{
			
		}
		
		private function fillBG():void
		{
			var g:Graphics = graphics;
			g.clear();
			g.beginFill(AssetNamesConst.COLOR_LIGHT_BLACK);
			g.drawRect(0, 0, _width, _height);
		}
		private function createColumnHolders():void
		{
			_leftColumnHolder = new Sprite();
			addChild(_leftColumnHolder);
			
			_rightColumnHolder = new Sprite();
			addChild(_rightColumnHolder);
		}
		
		private function createSlotTypeComponents():void
		{
			_slotTypeList = new Vector.<ComboBox>()
			var currentCombo:ComboBox
			var provider:DataProvider
			var holder:Sprite
			for (var i:uint = 0; i < _totalSlots; i++ ) {
				provider = new DataProvider();
				provider.addItem( { label:"Opened", type:SLOT_TYPE_OPENED } );
				provider.addItem( { label:"Closed", type:SLOT_TYPE_CLOSED } );
				provider.addItem( { label:"Cpu", type:SLOT_TYPE_CPU } );
				
				currentCombo = new ComboBox();
				currentCombo.addEventListener(Event.CHANGE, onSlotTypeChange);
				
				currentCombo.dataProvider = provider;
				currentCombo.width = 70;
				currentCombo.rowCount = 3;
				
				holder = (i % 2)?_rightColumnHolder:_leftColumnHolder;
				
				holder.addChild(currentCombo);
				_slotTypeList.push(currentCombo);
				
			}
		}
		
		
		private function createSlotContentComponents():void
		{
			_slotContentList = new Vector.<SlotContentRenderer>
			var currentSlotContent:SlotContentRenderer;
			var holder:Sprite
			for (var i:uint = 0; i < _totalSlots; i++ ) {
				holder = (i % 2)?_rightColumnHolder:_leftColumnHolder;
				currentSlotContent = new SlotContentRenderer();
				_slotContentList.push(currentSlotContent);
				holder.addChild(currentSlotContent);
			}
		}
		private function createButtons():void
		{
			var format:TextFormat 
			format = TextStyle.getFormatForButton();
			
			_backBtn = new Button();
			_backBtn.setStyle("embedFonts", true);
			_backBtn.setStyle("textFormat", format);
			_backBtn.setStyle("disabledTextFormat", format);
			_backBtn.label = "Back";
			
			
			addChild(_backBtn)
			
			format = TextStyle.getFormatForButton();
			
			_startBtn = new Button();
			_startBtn.setStyle("embedFonts", true);
			_startBtn.setStyle("textFormat", format);
			_startBtn.setStyle("disabledTextFormat", format);
			_startBtn.label = "Start";
			
			
			addChild(_backBtn);
			addChild(_startBtn);
			
			
		}
		private function align():void
		{
			alignColumn(_leftColumnHolder);
			alignColumn(_rightColumnHolder);
			
			_leftColumnHolder.x = (_width * 0.5 - _leftColumnHolder.width) * 0.5;
			_leftColumnHolder.y = 30;
			
			_rightColumnHolder.x = _width * 0.5 + (_width * 0.5 - _leftColumnHolder.width) * 0.5;
			_rightColumnHolder.y = 30;
			
			_backBtn.x = _width - _backBtn.width - 10;
			_backBtn.y = Math.max(_leftColumnHolder.y + _leftColumnHolder.height, _rightColumnHolder.y + _rightColumnHolder.height);
			
			_startBtn.x = _backBtn.x - _backBtn.width - 10;
			_startBtn.y = _backBtn.y;
			
		}
		private function alignColumn(column:Sprite):void
		{
			var contentR:SlotContentRenderer;
			var typeR:ComboBox;
			
			var rowHeight:Number = Math.max(_slotContentList[0].height, _slotTypeList[0].height);
			var vGap:Number = 5;
			var hGap:Number=2
			
			for (var i:uint = 0; i < column.numChildren * 0.5; i++ ) {
				contentR = column.getChildAt(i) as SlotContentRenderer;
				typeR = column.getChildAt(column.numChildren*0.5 +i ) as ComboBox;
				
				contentR.x = 0;
				contentR.y = i * (rowHeight + vGap)+(rowHeight-contentR.height)
				
				typeR.x = contentR.width + hGap;
				typeR.y = i * (rowHeight + vGap) + (rowHeight - typeR.height)*0;
				
			}
		}
		
		private function onSlotTypeChange(e:Event):void 
		{
			var comboIndex:int = _slotTypeList.indexOf(e.currentTarget as ComboBox);
			dispatchEvent(new DataEvent(SLOT_TYPE_CHANGE, false, false, comboIndex.toString()));
		}
		
		public function getSlotType(slotIndex:int):int
		{
			var combo:ComboBox = (_slotTypeList.length > slotIndex)?_slotTypeList[slotIndex]:null;
			var result:int = (combo && combo.selectedItem)?combo.selectedItem.type:SLOT_TYPE_CLOSED
			
			return result;
		}
		public function setSlotType(slotIndex:int, slotType:int):void
		{
			var combo:ComboBox = _slotTypeList[slotIndex];
			combo.selectedIndex = slotType;
		}
		public function getSlotContent(slotIndex:int):Player
		{
			var player:Player = _slotContentList[slotIndex].player;
			return player;
		}
		public function setSlotContent(slotIndex:int, player:Player):void
		{
			var slot:SlotContentRenderer = _slotContentList[slotIndex];
			slot.player = player;
		}
		
		
		public function get totalSlots():int 
		{
			return _totalSlots;
		}
		
		public function get backBtn():Button 
		{
			return _backBtn;
		}
		
		public function get startBtn():Button 
		{
			return _startBtn;
		}
		public function getSlotTypeSelectorAt(slotIndex:int):ComboBox
		{
			var result:ComboBox = _slotTypeList[slotIndex];
			return result;
		}
		public function getSlotsAmountWithType(slotType:int):int
		{
			var result:int = 0;
			for (var i:uint = 0; i < totalSlots; i++ ) {
				if (getSlotType(i)==slotType) {
					result++;
				}
			}
			return result;
		}
		public function getContentAmountWithType(playerType:int):void
		{
			
		}
		
	}

}