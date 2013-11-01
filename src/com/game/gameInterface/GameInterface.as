package com.game.gameInterface 
{
	import com.game.entity.Racer;
	import com.game.Game;
	import com.game.GameEvent;
	import com.game.GameProgress;
	import com.game.plugins.task.PriorityInitialization;
	import com.game.plugins.task.PriorityUpdate;
	import com.game.settings.Player;
	import com.managers.assets.AssetNamesConst;
	import com.managers.info.components.LocationInfo;
	import com.view.ApplicationSprite;
	import com.view.Sheet;
	import com.view.text.ApplicationTF;
	import com.view.text.TextStyle;
	import fl.controls.Label;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class GameInterface extends ApplicationSprite 
	{
		static public const EXPRESSION_NORMAL:int = 0;
		static public const EXPRESSION_GALD_1:int = 2;
		static public const EXPRESSION_GALD_2:int = 1;
		static public const EXPRESSION_ANGRY_1:int = 4;
		static public const EXPRESSION_ANGRY_2:int = 3;
		static public const EXPRESSION_ANGRY_3:int = 5;
		
		
		
		private var _owner:Game
		private var _width:Number;
		private var _height:Number;
		
		private var _localRacer:Racer;
		
		private var _racerFaceCanvas:Sprite
		private var _racerFaceRenderer:Bitmap
		private var _racerFaceSheet:Sheet;
		
		private var _racerDilogCanvas:Sprite
		private var _racerDilogTF:ApplicationTF;
		private var _racerDilogBG:Shape;
		
		private var _timeToDilogFadeOut:int
		private var _timeToDilogfadeIn:int;
		private var _fadeTransitionDuration:int
		
		
		private var _racePositionRenderer:Label;
		
		
		private var _miniMap:MiniMap
		private var _stepsToNextMinimapRender:int;
		private var _minimapRenderPeriodInSteps:int
		
		
		private var _lastUpdateTime:int
		private var _dilogExistTime:int = 0;
		
		
		public function GameInterface(owner:Game) 
		{
			super();
			_owner = owner;
			_owner.synchronizer.addInitializationTask(initialize, PriorityInitialization.GAME_INTERFACE_INITIALIZATION);
			
		}
		public function destroy():void
		{
			_owner.synchronizer.removeInitializationTask(initialize);
			_owner.synchronizer.removeUpdateTask(update);
			
		}
		public function setSize(width:Number, height:Number):void
		{
			_width = width;
			_height = height;
			
		}
		public function displayDilog(text:String, expression:int = 0, duration:Number = 3000):void
		{
			_racerFaceSheet.selectedTileIndex = expression;
			
			
			_racerDilogTF.text = text;
			
			var g:Graphics = _racerDilogBG.graphics;
			g.clear();
			g.beginFill(0xffffff,0.8);
			
			
			var textIndentH:int = 15;
			var textIndentV:int = 5;
			var pTop:int = 57;
			
			var rectTop:int = Math.max(0, pTop - 0.5 * _racerDilogTF.height - textIndentV);
			var rectW:Number = _racerDilogTF.width + 2 * textIndentH;
			var rectH:Number = _racerDilogTF.height + 2 * textIndentV;
			
			var circlesAmount:int = 3;
			var circleSizeProgression:Number = 1.4;
			var circlesIndent:int = 5;
			
			var currentRadius:int = 5;
			var currentX:Number = currentRadius;
			
			for (var i:uint = 0; i < circlesAmount; i++ ) {
				g.drawCircle(currentX, pTop, currentRadius);
				
				currentX += currentRadius + circlesIndent;
				currentRadius *= circleSizeProgression;
				currentX += currentRadius;
			}
			g.drawRoundRect(currentX, rectTop, rectW, rectH, textIndentH);
			
			_racerDilogTF.x = currentX + (rectW - _racerDilogTF.width) * 0.5;
			_racerDilogTF.y = rectTop + (rectH - _racerDilogTF.height) * 0.5;
			
			
			_racerDilogCanvas.x = _racerFaceCanvas.x + _racerFaceCanvas.width;
			_racerDilogCanvas.y = _racerFaceCanvas.y;
			
			_dilogExistTime = duration;
			
			_fadeTransitionDuration = 500;
			_timeToDilogFadeOut = _fadeTransitionDuration;
			_timeToDilogfadeIn = _fadeTransitionDuration + _fadeTransitionDuration + duration;
			
		}
		private function initialize():void
		{
			grabLocalRacer();
			configurateFaceRenderer();
			configurateDilogRenderer();
			configurateMiniMap();
			renderMiniMap();
			configurateRaceRenderers();
			
			_owner.synchronizer.addUpdateTask(update, PriorityUpdate.GAME_INTERFACE_UPDATE);
			_lastUpdateTime = getTimer();
			
		}
		private function grabLocalRacer():void
		{
			_localRacer = null;
			for each(var racer:Racer in _owner.racers) {
				if (racer.player.type == Player.TYPE_OWNER) {
					_localRacer = racer;
					break;
				}
			}
		}
		private function configurateFaceRenderer():void
		{
			_racerFaceCanvas = new Sprite()
			
			_racerFaceSheet = new Sheet();
			_racerFaceSheet.init(_localRacer.racerIfo.faceSheetID);
			
			
			_racerFaceRenderer = new Bitmap();
			_racerFaceRenderer.bitmapData = _racerFaceSheet.framePixels;
			_racerFaceRenderer.scaleX = _racerFaceRenderer.scaleY = 2;
			
			addChild(_racerFaceCanvas)
			_racerFaceCanvas.addChild(_racerFaceRenderer)
			
			var canvasW:Number = _racerFaceRenderer.scaleX * _racerFaceSheet.info.tileWidth;
			var canvasH:Number = _racerFaceRenderer.scaleY * _racerFaceSheet.info.tileHeight;
			var g:Graphics = _racerFaceCanvas.graphics;
			var type:String = GradientType.LINEAR;
			var color:uint=0x000ff00
			var colors:Array = [color, color];
			var alphas:Array = [0.2, 0.7];
			var ratios:Array = [0, 255];
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(canvasW, canvasH, Math.PI * 0.5);
			
			g.beginGradientFill(type, colors, alphas, ratios, matrix);
			g.drawRect(0, 0, canvasW, canvasH);
			
			_racerFaceCanvas.alpha = 0;
			
		}
		private function configurateDilogRenderer():void
		{
			_racerDilogCanvas = new Sprite();
			
			_racerDilogBG = new Shape();
			_racerDilogTF = new ApplicationTF();
			var style:TextStyle = _racerDilogTF.style;
			style.size = 12;
			style.wordWrap = true;
			style.multiline = true;
			_racerDilogTF.update();
			_racerDilogTF.width = 300;
			
			addChild(_racerDilogCanvas);
			_racerDilogCanvas.addChild(_racerDilogBG);
			_racerDilogCanvas.addChild(_racerDilogTF);
			
			_racerDilogCanvas.alpha = 0;
			
		}
		
		private function configurateMiniMap():void
		{
			var paddingH:int = 0;
			var paddingV:int = 0;
			
			_miniMap = new MiniMap(200, 150);
			addChild(_miniMap);
			_miniMap.x = (_width - _miniMap.width)-paddingH;
			//_miniMap.y = _height-_miniMap.height-paddingV;
			_miniMap.y = paddingV;
			
			_stepsToNextMinimapRender = 0;
			_minimapRenderPeriodInSteps = _owner.settings.stepsPerMiniMapRender;
		}
		private function configurateRaceRenderers():void
		{
			var format:TextFormat 
			format = new TextFormat();
			format.font = TextStyle.APPLICATION_FONT_NAME;
			format.size = 72;
			format.color = 0x00FF00;
			
			
			_racePositionRenderer = new Label()
			addChild(_racePositionRenderer);
			_racePositionRenderer.setStyle("embedFonts", true);
			_racePositionRenderer.setStyle("textFormat", format);
			_racePositionRenderer.autoSize = TextFieldAutoSize.LEFT;
			
			_racePositionRenderer.text = "";
			_racePositionRenderer.x = _width - 260;
			_racePositionRenderer.y = 5;
			_racePositionRenderer.filters = [AssetNamesConst.WHITE_LINE_THIN_4];
			
		}
		
		private function update():void
		{
			var timeElapsed:int = getTimer()-_lastUpdateTime;
			_lastUpdateTime += timeElapsed;
			advanceMinimapRendering();
			advanceDilogRendering(timeElapsed);
			advanceRaceInfoRendering();
			
		}
		private function advanceDilogRendering(dt:int):void
		{
			var percent:Number
			if (_timeToDilogFadeOut >0) {
				_timeToDilogFadeOut -= dt;
				if (_timeToDilogFadeOut < _fadeTransitionDuration) {
					_timeToDilogFadeOut = Math.max(0, _timeToDilogFadeOut);
					percent = ((_fadeTransitionDuration-_timeToDilogFadeOut)/ Number(_fadeTransitionDuration));
					_racerFaceCanvas.alpha = percent;
					_racerDilogCanvas.alpha = percent;
				}
				
			}
			if (_timeToDilogfadeIn > 0) {
				_timeToDilogfadeIn -= dt;
				if (_timeToDilogfadeIn < _fadeTransitionDuration) {
					_timeToDilogfadeIn = Math.max(0, _timeToDilogfadeIn);
					percent = (_timeToDilogfadeIn / Number(_fadeTransitionDuration));
					_racerFaceCanvas.alpha = percent;
					_racerDilogCanvas.alpha = percent;
				}
			}
		}
		
		
		
		private function advanceMinimapRendering():void
		{
			_stepsToNextMinimapRender--
			if (_stepsToNextMinimapRender <= 0) {
				_stepsToNextMinimapRender = _minimapRenderPeriodInSteps;
				renderMiniMap();
			}
		}
		
		
		private function renderMiniMap():void
		{
			var worldPixel:BitmapData = _owner.camera.environmentPixels;
			var racers:Vector.<Racer> = _owner.racers;
			
			_miniMap.render(worldPixel, _localRacer, racers);
		}
		
		private function advanceRaceInfoRendering():void
		{
			var progress:GameProgress = _owner.progress;
			if (progress.raceCompleted) return;
			_racePositionRenderer.text = progress.currentRacePosition.toString()//+"/"+_owner.racers.length;
			
		}
		
		
		override public function get width():Number {	return _width;	}
		override public function get height():Number{	return _height;	}
		
	}

}