package com.game.entity 
{
	
	import com.Facade;
	import com.managers.info.components.ObjectInfo;
	import com.managers.info.components.RacerInfo;
	import com.managers.info.IInfoComponent;
	import com.managers.info.Info;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class EntityFactory 
	{
		static private var _instance:EntityFactory = new EntityFactory();
		
		private var _entitiesDefinitionsDict:Dictionary
		
		public function EntityFactory() 
		{
			if (instance) {
				throw new  Error("singletone");
			}
			init();
		}
		
		private function init():void
		{
			_entitiesDefinitionsDict = new Dictionary();
			var currentInfo:IInfoComponent
			
			for each(currentInfo in Facade.instance.info.objectsInfoList) {
				_entitiesDefinitionsDict[currentInfo.infoID]=LocationObject
			}
			for each(currentInfo in Facade.instance.info.racersInfoList) {
				_entitiesDefinitionsDict[currentInfo.infoID]=Racer
			}
		}
		
		public function createByTemplateID(templateID:int):BaseEntity
		{
			var result:BaseEntity
			
			var info:IInfoComponent = Facade.instance.info.getInfoComponentByID(templateID);
			var entityDeffinition:Class = _entitiesDefinitionsDict[templateID];
			
			if ((info) && (entityDeffinition)) {
				result = new entityDeffinition() as BaseEntity
				result.init(templateID);
			}
			
			return result;
		}
		
		static public function get instance():EntityFactory 
		{
			return _instance;
		}
		
	}

}