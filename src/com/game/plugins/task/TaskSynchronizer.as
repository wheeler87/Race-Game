package com.game.plugins.task 
{
	import com.game.Game;
	import com.game.plugins.BasePlugin;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class TaskSynchronizer extends BasePlugin 
	{
		static private var _instance:TaskSynchronizer;
		
		private var _initializationTaskList:Vector.<Task>;
		private var _updateTaskList:Vector.<Task>;
		private var _enterFrameTaskList:Vector.<Task>;
		
		private var _initializationTaskDict:Dictionary;
		private var _updateTaskDict:Dictionary;
		private var _enterFrameTaskDict:Dictionary;
		
		public function TaskSynchronizer(owner:Game) 
		{
			super(owner);
			
			_instance = this;
			
			_initializationTaskList = new Vector.<Task>();
			_updateTaskList = new Vector.<Task>();
			_enterFrameTaskList = new Vector.<Task>();
			
			_initializationTaskDict = new Dictionary();
			_updateTaskDict = new Dictionary();
			_enterFrameTaskDict = new Dictionary();
		}
		
		override public function onEnter():void 
		{
			super.onEnter();
			
		}
		override public function onExit():void 
		{
			super.onExit();
			
			_initializationTaskList.length = 0;
			_updateTaskList.length = 0;
			_enterFrameTaskList.length = 0;
			
			_initializationTaskDict = new Dictionary();
			_updateTaskDict = new Dictionary();
			_enterFrameTaskDict = new Dictionary();
		}
		
		
		public function executeInitializationTasks():void
		{
			var currentTask:Task
			for (var i:uint = 0; i < _initializationTaskList.length; i++ ) {
				currentTask = _initializationTaskList[i];
				currentTask.execute();
			}
			_initializationTaskList.length = 0;
		}
		public function executeUpdateTasks():void
		{
			var currentTask:Task;
			for (var i:uint = 0; i < _updateTaskList.length; i++ ) {
				currentTask = _updateTaskList[i];
				currentTask.execute();
			}
		}
		public function executeEnterFrameTasks():void
		{
			var currentTask:Task;
			for (var i:uint = 0; i < _enterFrameTaskList.length; i++ ) {
				currentTask = _enterFrameTaskList[i];
				currentTask.execute();
			}
		}
		
		public function addInitializationTask(callBack:Function, priority:int = 0):void
		{
			var result:Task = _initializationTaskDict[callBack] as Task;
			if (!result) {
				result = new Task();
				result.callBack = callBack;
				_initializationTaskDict[callBack] = result;
				_initializationTaskList.push(result);
			}
			result.priority = priority;
			_initializationTaskList.sort(Task.tasksCompareFunc);
			
			//return result;
			
		}
		public function removeInitializationTask(callBack:Function):void
		{
			var result:Task = _initializationTaskDict[callBack] as Task;
			if (result) {
				_initializationTaskList.splice(_initializationTaskList.indexOf(result), 1);
				_initializationTaskDict[callBack] = null;
				delete _initializationTaskDict[callBack];
			}
			//return result
		}
		
		public function addUpdateTask(callBack:Function, priority:int = 0):void
		{
			var result:Task = _updateTaskDict[callBack] as Task;
			if (!result) {
				result = new Task();
				result.callBack = callBack;
				_updateTaskDict[callBack] = result;
				_updateTaskList.push(result);
			}
			result.priority = priority;
			_updateTaskList.sort(Task.tasksCompareFunc);
			
			//return result;
			
		}
		public function removeUpdateTask(callBack:Function):void
		{
			var result:Task = _updateTaskDict[callBack] as Task;
			if (result) {
				_updateTaskList.splice(_updateTaskList.indexOf(result), 1);
				_updateTaskDict[callBack] = null;
				delete _updateTaskDict[callBack];
			}
			//return result
		}
		
		public function addEnterFrameTask(callBack:Function, priority:int = 0):void
		{
			var task:Task = _enterFrameTaskDict[callBack]
			if (!task) {
				task = new Task();
				task.callBack = callBack;
				_enterFrameTaskDict[callBack] = task;
				_enterFrameTaskList.push(task);
			}
			task.priority = priority;
			_enterFrameTaskList.sort(Task.tasksCompareFunc);
		}
		public function removeEnterFrameTask(callBack:Function):void
		{
			var task:Task = _enterFrameTaskDict[callBack];
			if (!task) return
			_enterFrameTaskDict[callBack] = null;
			delete _enterFrameTaskDict[callBack];
			_enterFrameTaskList.splice(_enterFrameTaskList.indexOf(task), 1);
		}
		
		
		
		static public function get instance():TaskSynchronizer {return _instance;}
		
	}

}