package com.view.components.chat 
{
	import com.view.ApplicationSprite;
	import com.view.text.ApplicationTF;
	import com.view.text.TextStyle;
	import fl.controls.TextInput;
	import fl.events.ComponentEvent;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class ChatPanel extends ApplicationSprite 
	{
		static public const TEXT_TYPED:String="text_typed"
		
		public const MODE_ACTIVE:int = 1;
		public const MODE_PASSIVE:int = 2;
		
		private var _width:Number;
		private var _height:Number;
		private var _indent:int = 5;
		private var _inputLineHeight:Number = 20;
		private var _messageExistDuration:int = 5 * 1000;
		private var _messageFadeDuration:int = 1.5 * 1000;
		private var _messageExistTimeDict:Dictionary
		private var _mode:int;
		
		private var _lastFadeAdvanceTime:int;
		
		private var _inputLine:TextInput;
		private var _correspondenceCanvas:Sprite;
		private var _correspondenceTF:TextField;
		private var _messagesContainer:Sprite;
		
		
		private var _helperFormat:TextFormat
		
		
		
		private var _messagesPool:Vector.<TextField> = new Vector.<TextField>();
		
		public function ChatPanel(width:Number,height:Number):void
		{
			super();
			
			_width = width;
			_height = height;
			
			createInputLine();
			createCorrespondenceComponents();
			createMessagesComponents();
			createHelpers();
			
			
			mode = MODE_PASSIVE;
		}
		
		private function createInputLine():void
		{
			var format:TextFormat = new TextFormat();
			format.font = TextStyle.APPLICATION_FONT_NAME;
			format.color = 0x000099;
			format.size = 12;
			
			_inputLine = new TextInput();
			_inputLine.setStyle("embedFonts", true);
			_inputLine.setStyle("textFormat", format);
			
			addChild(_inputLine);
			_inputLine.width = _width;
			_inputLine.height = _inputLineHeight;
			_inputLine.y = _height - _inputLine.height;
			
			_inputLine.addEventListener(ComponentEvent.ENTER, onEnterInputed);
		}
		
		private function onEnterInputed(e:ComponentEvent):void 
		{
			e.stopImmediatePropagation();
			var inputedText:String = _inputLine.text;
			_inputLine.text = "";
			
			dispatchEvent(new DataEvent(TEXT_TYPED, false, false, inputedText));
		}
		private function createCorrespondenceComponents():void
		{
			_correspondenceCanvas = new Sprite();
			
			
			var g:Graphics = _correspondenceCanvas.graphics;
			g.clear();
			g.beginFill(0xffff77, 0.2);
			g.drawRect(0, 0, _width, _height - _inputLineHeight - _indent);
			
			
			
			_correspondenceTF = new TextField();
			_correspondenceTF.embedFonts = true;
			_correspondenceTF.autoSize = TextFieldAutoSize.NONE;
			_correspondenceTF.width = _width;
			_correspondenceTF.height = (_height - _inputLineHeight - _indent);
			_correspondenceTF.wordWrap = true;
			
			
			addChild(_correspondenceCanvas);
			_correspondenceCanvas.addChild(_correspondenceTF);
		}
		private function createMessagesComponents():void
		{
			_messagesContainer = new Sprite();
			addChild(_messagesContainer);
		}
		
		private function createHelpers():void 
		{
			_helperFormat = new TextFormat();
			_helperFormat.font = TextStyle.APPLICATION_FONT_NAME;
			
			_messageExistTimeDict = new Dictionary();
		}
		
		
		public function addMessage(sender:String, senderColor:uint, message:String, messageColor:uint):void
		{
			
			var startIndex:int;
			var endIndex:int;
			
			sender += ": ";
			message += "\n";
			
			startIndex = _correspondenceTF.text.length;
			endIndex = startIndex + sender.length;
			
			
			
			_helperFormat.size = 14;
			_helperFormat.color = senderColor;
			
			_correspondenceTF.appendText(sender);
			_correspondenceTF.setTextFormat(_helperFormat, startIndex, endIndex);
			
			
			_helperFormat.size = 12;
			_helperFormat.color = messageColor;
			
			startIndex = _correspondenceTF.text.length;
			endIndex = startIndex + message.length;
			
			_correspondenceTF.appendText(message);
			_correspondenceTF.setTextFormat(_helperFormat, startIndex, endIndex);
			_correspondenceTF.scrollV = _correspondenceTF.maxScrollV;
			
			var messageRenderer:TextField = getMessageFromPool();
			_messageExistTimeDict[messageRenderer] = _messageExistDuration;
			messageRenderer.text = "";
			messageRenderer.alpha = 1;
			
			_helperFormat.size = 14;
			_helperFormat.color = senderColor;
			
			
			startIndex = 0;
			endIndex = sender.length;
			messageRenderer.text = sender;
			messageRenderer.setTextFormat(_helperFormat, startIndex, endIndex);
			
			message = message.substr(0, message.length - 1);
			
			startIndex = messageRenderer.text.length;
			endIndex = startIndex + message.length;
			
			_helperFormat.size = 12;
			_helperFormat.color = messageColor;
			
			messageRenderer.appendText(message);
			messageRenderer.setTextFormat(_helperFormat, startIndex, endIndex);
			
			_messagesContainer.addChild(messageRenderer);
			onMessagesAmountUpdate();
			
			while ((_messagesContainer.numChildren > 2) && (_messagesContainer.height > (_height - _inputLineHeight - _indent)))
			{
				var messageRendererToRemove:TextField = _messagesContainer.removeChildAt(0) as TextField;
				addMessageInPool(messageRendererToRemove);
			}
			_lastFadeAdvanceTime = getTimer();
			advanceMessagesFade();
			
			
		}
		private function advanceMessagesFade(e:Event = null):void
		{
			removeEventListener(Event.ENTER_FRAME, advanceMessagesFade);
			var dt:int = getTimer() - _lastFadeAdvanceTime;
			_lastFadeAdvanceTime += dt;
			
			var currentMessageRenderer:TextField;
			var amountChanged:Boolean
			var existTime:int;
			for (var i:int = _messagesContainer.numChildren - 1; i >= 0; i-- ) {
				currentMessageRenderer = _messagesContainer.getChildAt(i) as TextField;
				existTime = _messageExistTimeDict[currentMessageRenderer];
				existTime-= dt;
				_messageExistTimeDict[currentMessageRenderer] = existTime;
				if (existTime >= _messageFadeDuration) continue;
				if (existTime < 0) {
					_messagesContainer.removeChild(currentMessageRenderer);
					addMessageInPool(currentMessageRenderer);
					amountChanged = true;
				}else {
					currentMessageRenderer.alpha=existTime/Number(_messageFadeDuration);
				}
			}
			if (amountChanged) {
				onMessagesAmountUpdate();
			}
			if (_messagesContainer.numChildren) {
				addEventListener(Event.ENTER_FRAME, advanceMessagesFade);
			}
		}
		
		
		private function getMessageFromPool():TextField
		{
			var result:TextField
			if (!_messagesPool.length) {
				result = new TextField();
				result.embedFonts = true;
				result.autoSize = TextFieldAutoSize.LEFT;
				result.wordWrap = true;
				result.width = _width;
				
				var format:TextFormat = new TextFormat();
				format.font = TextStyle.APPLICATION_FONT_NAME;
				
				result.defaultTextFormat = format;
				
				_messagesPool.push(result);
			}
			result = _messagesPool.shift();
			return result;
			
		}
		private function addMessageInPool(value:TextField):void
		{
			_messagesPool.push(value);
		}
		
		
		private function onMessagesAmountUpdate():void
		{
			var messageRenderer:TextField
			var currentY:int = 0;
			var indentV:int = -3;
			for (var i:int = 0; i < _messagesContainer.numChildren; i++ ) {
				messageRenderer = _messagesContainer.getChildAt(i) as TextField;
				messageRenderer.y = currentY;
				currentY += messageRenderer.height + indentV;
			}
		}
		
		public function get mode():int 
		{
			return _mode;
		}
		
		public function set mode(value:int):void 
		{
			_mode = value;
			if (_mode == MODE_ACTIVE) {
				_correspondenceCanvas.visible = true;
				_inputLine.visible = true;
				_inputLine.dispatchEvent(new FocusEvent(FocusEvent.FOCUS_IN));
				_messagesContainer.visible = false;
				
			}else {
				_correspondenceCanvas.visible = false;
				_inputLine.visible = false;
				
				_messagesContainer.visible = true;
			}
		}
		public function clearCorrespondence():void
		{
			_correspondenceTF.text = "";
			_lastFadeAdvanceTime = -_messageExistDuration;
			advanceMessagesFade();
		}
		
	}

}