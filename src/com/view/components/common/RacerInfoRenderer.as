package com.view.components.common 
{
	import com.managers.assets.AssetNamesConst;
	import com.managers.info.components.RacerInfo;
	import com.view.ApplicationSprite;
	import com.view.Sheet;
	import com.view.text.ApplicationTF;
	import com.view.text.TextStyle;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class RacerInfoRenderer extends ApplicationSprite 
	{
		private var _avarageMass:Number;
		private var _avarageEngineForce:Number;
		private var _avarageTurnForce:Number;
		private var _avarageBreakForce:Number;
		
		private var _racerInfo:RacerInfo
		
		private var _massPercent:int;
		private var _engineForcePercent:int;
		private var _turnForcePercent:int;
		private var _breakForcePercent:int
		
		
		private var _faceCanvas:Bitmap
		private var _carCanvas:Bitmap
		
		private var _faceSheet:Sheet
		private var _carSheet:Sheet;
		
		private var _paramsTF:ApplicationTF;
		private var _paramsBG:Shape;
		
		private var _paramsContainer:Sprite
		private var _paramLabelList:Vector.<ApplicationTF>
		private var _paramTarceList:Vector.<Shape>
		
		private var _advanceCarFrameTimer:Timer;
		private var _advanceFaceFrameTimer:Timer;
		
		public function RacerInfoRenderer() 
		{
			super();
			
			calculateAvarageValues();
			createComponents()
			alignComponents();
		}
		
		private function calculateAvarageValues():void
		{
			_avarageMass = 0;
			_avarageEngineForce = 0;
			_avarageTurnForce = 0;
			_avarageBreakForce = 0;
			
			var racersList:Vector.<RacerInfo> = info.racersInfoList;
			for (var i:uint = 0; i < racersList.length; i++ ) {
				var racer:RacerInfo = racersList[i];
				_avarageMass += racer.mass;
				_avarageEngineForce += racer.engineForce;
				_avarageTurnForce += racer.turnForce;
				_avarageBreakForce += racer.breakForce;
			}
			_avarageMass /= racersList.length;
			_avarageEngineForce /= racersList.length;
			_avarageTurnForce /= racersList.length;
			_avarageBreakForce /= racersList.length;
		}
		private function createComponents():void
		{
			_faceCanvas = new Bitmap();
			_faceCanvas.scaleX = _faceCanvas.scaleY = 1.8;
			addChild(_faceCanvas);
			
			_carCanvas = new Bitmap();
			_carCanvas.scaleX = _carCanvas.scaleY = 2;
			addChild(_carCanvas);
			
			
			_paramsBG = new Shape();
			addChild(_paramsBG);
			
			_paramsTF = new ApplicationTF();
			addChild(_paramsTF);
			var style:TextStyle = _paramsTF.style;
			style.size = 12;
			style.color = AssetNamesConst.COLOR_WHITE_DARK;
			_paramsTF.update();
			
			
			_paramsContainer = new Sprite();
			addChild(_paramsContainer);
			_paramLabelList = new Vector.<ApplicationTF>();
			_paramTarceList=new Vector.<Shape>()
			
			
			
			_faceSheet = new Sheet();
			_carSheet = new Sheet();
			
			_advanceCarFrameTimer = new Timer(200);
			_advanceFaceFrameTimer = new Timer(500);
		}
		
		
		public function get racerInfo():RacerInfo{return _racerInfo;}
		
		public function set racerInfo(value:RacerInfo):void 
		{
			deactivate();
			clear();
			_racerInfo = value;
			
			calculateerParams();
			reRender();
			alignComponents();
			activate();
		}
		
		private function calculateerParams():void
		{
			_massPercent = (100 * _racerInfo.mass / _avarageMass);
			_engineForcePercent = (100 * _racerInfo.engineForce / _avarageEngineForce);
			_turnForcePercent = (100 * _racerInfo.turnForce / _avarageTurnForce);
			_breakForcePercent = (100 * _racerInfo.breakForce / _avarageBreakForce);
		}
		private function clear():void
		{
			_faceCanvas.bitmapData = null;
			_carCanvas.bitmapData = null;
			_paramsTF.text = "";
			clearParamRenderers();
		}
		
		private function reRender():void
		{
			_faceSheet.init(_racerInfo.faceSheetID);
			_faceCanvas.bitmapData = _faceSheet.framePixels;
			
			_carSheet.init(_racerInfo.generalRaceSheetID);
			_carCanvas.bitmapData = _carSheet.framePixels;
			
			
			_paramsTF.text = _racerInfo.name + "'s characteristics:";
			renderParamAt("Weight:", _massPercent, 0);
			renderParamAt("Power:", _engineForcePercent, 1);
			renderParamAt("Mobility:", _turnForcePercent, 2);
			renderParamAt("Breaks:", _breakForcePercent, 3);
			alignParamRenderers();
			redrawparamsBG();
		}
		private function redrawparamsBG():void
		{
			var g:Graphics = _paramsBG.graphics;
			g.clear();
			var bgWidth:Number = 330;
			var bgHeight:Number = 100;
			
			var type:String = GradientType.LINEAR
			var color:uint=AssetNamesConst.COLOR_BLUE
			var colors:Array = [ color,color, color, color];
			var alphas:Array = [0.6, 0.2,0.2, 0.6];
			var ratios:Array = [0, 100,150, 255];
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(bgWidth, bgHeight);
			
			g.beginGradientFill(type, colors, alphas, ratios, matrix);
			g.drawRect(0, 0, bgWidth, bgHeight);
		}
		
		public function deactivate():void
		{
			_advanceCarFrameTimer.removeEventListener(TimerEvent.TIMER, onAdvanceCarFrameTimerEvent);
			_advanceFaceFrameTimer.removeEventListener(TimerEvent.TIMER, onAdvanceFaceFrameTimerEvent);
			_advanceCarFrameTimer.reset();
			_advanceFaceFrameTimer.reset();
			
		}
		public function activate():void
		{
			_faceSheet.selectedTileIndex = 1;
			_carSheet.selectedTileIndex = _carSheet.tilesAmount * 0.5;
			
			_advanceCarFrameTimer.addEventListener(TimerEvent.TIMER, onAdvanceCarFrameTimerEvent);
			_advanceFaceFrameTimer.addEventListener(TimerEvent.TIMER, onAdvanceFaceFrameTimerEvent);
			_advanceCarFrameTimer.start();
			_advanceFaceFrameTimer.start();
		}
		
		private function onAdvanceFaceFrameTimerEvent(e:TimerEvent):void 
		{
			_faceSheet.selectedTileIndex = 0;
			_advanceFaceFrameTimer.reset();
		}
		
		private function onAdvanceCarFrameTimerEvent(e:TimerEvent):void 
		{
			var index:int = _carSheet.selectedTileIndex - 1;
			if (index < 0) {
				index = _carSheet.tilesAmount - 1;
			}else if (index >= _carSheet.tilesAmount) {
				index = 0;
			}
			_carSheet.selectedTileIndex = index;
		}
		private function alignComponents():void
		{
			var hGap:int = 20;
			
			_faceCanvas.x = 0;
			_faceCanvas.y = 10;
			
			_carCanvas.x = _faceCanvas.width+hGap;
			_carCanvas.y = 10;
			
			_paramsTF.x = _carCanvas.x + _carCanvas.width + hGap;
			_paramsTF.y = 0;
			
			_paramsBG.x = _paramsTF.x;
			_paramsBG.y = _paramsTF.y+_paramsTF.height+5;
			
			_paramsContainer.x = _paramsBG.x + 10;
			_paramsContainer.y = _paramsBG.y + 10;
		}
		public function renderParamAt(name:String, percent:int, positionIndex:int):void
		{
			
			var labelTF:ApplicationTF;
			var traceShape:Shape
			while (positionIndex >= _paramLabelList.length) {
				labelTF = new ApplicationTF();
				labelTF.filters=[AssetNamesConst.WHITE_LINE_THIN]
				var style:TextStyle = labelTF.style;
				style.color = AssetNamesConst.COLOR_LIGHT_BLACK;
				style.size = 10;
				labelTF.update();
				
				_paramsContainer.addChild(labelTF);
				_paramLabelList.push(labelTF);
			}
			while (positionIndex >= _paramTarceList.length) {
				traceShape = new Shape();
				traceShape.filters=[AssetNamesConst.WHITE_LINE_THIN]
				_paramsContainer.addChild(traceShape);
				_paramTarceList.push(traceShape);
			}
			labelTF = _paramLabelList[positionIndex];
			traceShape = _paramTarceList[positionIndex];
			var g:Graphics = traceShape.graphics;
			
			labelTF.text = name;
			
			var traceWidth:uint = 120 * percent / 100.0;
			var traceHeight:uint = labelTF.height * 0.8;
			var traceColor:uint = AssetNamesConst.COLOR_GREEN;
			g.clear();
			g.beginFill(traceColor,1.0);
			g.drawRoundRect(0, 0, traceWidth, traceHeight,10);
			
		}
		public function alignParamRenderers():void
		{
			var vGap:int = 5;
			var hGap:int = 60;
			var currY:int = 0;
			var currTF:ApplicationTF;
			var currTrace:Shape
			for (var i:uint = 0; i < _paramLabelList.length; i++ ) {
				currTF = _paramLabelList[i];
				currTrace = _paramTarceList[i];
				
				currTF.x = 0;
				currTF.y = currY;
				
				currTrace.x = hGap;
				currTrace.y = currY + (currTF.height - currTrace.height) * 0.5;
				
				currY += currTF.height + vGap;
			}
		}
		public function clearParamRenderers():void
		{
			for each(var labelRenderer:ApplicationTF in _paramLabelList) {
				labelRenderer.text = "";
				labelRenderer.y = 0;
				labelRenderer.x = 0;
			}
			for each(var traceRenderer:Shape in _paramTarceList) {
				traceRenderer.graphics.clear();
				traceRenderer.x = 0;
				traceRenderer.y = 0;
			}
		}
		
	}

}