package com.game.plugins.cameraControl 
{
	import com.camera.GameCamera;
	import com.game.entity.Racer;
	import com.game.Game;
	import com.game.plugins.BasePlugin;
	import com.game.plugins.task.PriorityEnterFrame;
	import com.game.plugins.task.PriorityInitialization;
	import com.game.settings.Player;
	import com.geom.GeoUtil;
	import flash.geom.Vector3D;
	
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class CameraControlPlugin extends BasePlugin 
	{
		private var _helperV1:Vector3D = new Vector3D();
		private var _helperV2:Vector3D = new Vector3D();
		private var _helperV3:Vector3D = new Vector3D();
		
		private var _camera:GameCamera;
		private var _follower:Racer;
		
		public var distanceToFollower:Number = 30;
		
		public function CameraControlPlugin(owner:Game) 
		{
			super(owner);
			
		}
		override public function onEnter():void 
		{
			super.onEnter();
			owner.synchronizer.addInitializationTask(initialize, PriorityInitialization.CAMERA_CONTROL_PLUGIN_INITIALIZATION);
		}
		override public function onExit():void 
		{
			super.onExit();
			
			owner.synchronizer.removeInitializationTask(initialize);
			owner.synchronizer.removeEnterFrameTask(renderCamera);
			
			_camera = null;
			stopFollow();
		}
		public function startFollow(follower:Racer):void
		{
			_follower = follower;
			if (!_follower) return;
			owner.synchronizer.addUpdateTask(advanceFollowing);
		}
		public function stopFollow():void
		{
			owner.synchronizer.removeUpdateTask(advanceFollowing);
			_follower = null;
		}
		
		
		
		
		private function initialize():void
		{
			_camera = owner.camera;
			owner.synchronizer.addEnterFrameTask(renderCamera, PriorityEnterFrame.RENDER_CAMERA);
			for each(var racer:Racer in owner.racers) {
				if (racer.player.type == Player.TYPE_OWNER) {
					startFollow(racer);
					break;
				}
			}
			
		}
		private function renderCamera():void
		{
			owner.camera.render();
		}
		
		private function advanceFollowing():void
		{
			
			var followerHeeading:Vector3D = _helperV1;
			followerHeeading.x = Math.cos(_follower.worldAngle);
			followerHeeading.y = Math.sin(_follower.worldAngle);
			
			var followerLN:Vector3D = _helperV2;
			followerLN.x = Math.cos(_follower.worldAngle - Math.PI * 0.5);
			followerLN.y = Math.sin(_follower.worldAngle - Math.PI * 0.5);
			
			var cameraHeading:Vector3D = _helperV3;
			cameraHeading.x = Math.cos(_camera.wordAngle);
			cameraHeading.y = Math.sin(_camera.wordAngle);
			
			var deviationOrt:int=(followerLN.dotProduct(cameraHeading) > 0)? -1:1;
			
			var absDeviation:Number = Math.abs(Vector3D.angleBetween(cameraHeading, followerHeeading));
			absDeviation = Math.min(absDeviation, 0.48*_follower.racerIfo.maxDeviationAngle / 180.0 * Math.PI);
			
			var appropriateAngle:Number = _follower.worldAngle+deviationOrt*absDeviation;
			
			_helperV1.x = Math.cos(appropriateAngle+Math.PI);
			_helperV1.y = Math.sin(appropriateAngle+Math.PI);
			_helperV1.scaleBy(distanceToFollower);
			
			_helperV1.x += _follower.wordX;
			_helperV1.y += _follower.wordY;
			var worldRotation:Number = appropriateAngle / Math.PI * 180.0;
			
			_camera.setCameraPosition(_helperV1.x, _helperV1.y, worldRotation);
		}
	}

}