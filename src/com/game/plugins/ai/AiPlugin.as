package com.game.plugins.ai 
{
	import com.Facade;
	import com.game.entity.Racer;
	import com.game.Game;
	import com.game.plugins.BasePlugin;
	import com.game.plugins.task.PriorityInitialization;
	import com.game.plugins.task.PriorityUpdate;
	import com.game.settings.Player;
	import com.managers.info.components.LocationInfo;
	
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class AiPlugin extends BasePlugin 
	{
		private var _aiList:Vector.<RacerAi>
		
		
		public function AiPlugin(owner:Game) 
		{
			super(owner);
			
		}
		override public function onEnter():void 
		{
			super.onEnter();
			owner.synchronizer.addInitializationTask(initialize, PriorityInitialization.AI_PLUGIN_INITIALIZATION);
		}
		override public function onExit():void 
		{
			super.onExit();
			owner.synchronizer.removeInitializationTask(initialize);
			owner.synchronizer.removeUpdateTask(updateAi);
		}
		private function initialize():void
		{
			generateAi();
			owner.synchronizer.addUpdateTask(updateAi, PriorityUpdate.AI_UPDATE);
		}
		private function updateAi():void
		{
			for each(var racerAi:RacerAi in _aiList) {
				racerAi.update();
			}
			
		}
		
		
		
		private function generateAi():void
		{
			var locationInfo:LocationInfo = Facade.instance.info.getInfoComponentByID(owner.settings.locationID) as LocationInfo;
			_aiList = new Vector.<RacerAi>();
			if (!owner.settings.hostGame) return;
			var currentAI:RacerAi
			for each(var racer:Racer in owner.racers) {
				if (racer.player.type != Player.TYPE_CPU) continue;
				
				currentAI = new RacerAi();
				currentAI.init(racer, locationInfo);
				_aiList.push(currentAI);
			}
		}
	}

}