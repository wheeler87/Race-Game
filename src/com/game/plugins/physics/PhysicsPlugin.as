package com.game.plugins.physics 
{
	import com.Facade;
	import com.game.entity.BaseEntity;
	import com.game.entity.LocationObject;
	import com.game.entity.Racer;
	import com.game.Game;
	import com.game.plugins.BasePlugin;
	import com.game.plugins.task.PriorityInitialization;
	import com.game.plugins.task.PriorityUpdate;
	import com.geom.LineSegment;
	import com.geom.Polygon;
	import com.managers.info.components.LocationInfo;
	import flash.display.BitmapData;
	import flash.geom.Vector3D;
	
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class PhysicsPlugin extends BasePlugin 
	{
		private var _helperV1:Vector3D = new Vector3D();
		private var _helperV2:Vector3D = new Vector3D();
		private var _helperV3:Vector3D = new Vector3D();
		
		private var _locationInfo:LocationInfo
		private var _bounds:Vector.<Polygon>
		
		
		public function PhysicsPlugin(owner:Game) 
		{
			super(owner);
			
		}
		override public function onEnter():void 
		{
			super.onEnter();
			owner.synchronizer.addInitializationTask(initialize, PriorityInitialization.PHYSICS_PLUGIN_INITIALIZATION);
		}
		override public function onExit():void 
		{
			super.onExit();
			
			owner.synchronizer.removeInitializationTask(initialize);
			owner.synchronizer.removeUpdateTask(simulateMovement);
			owner.synchronizer.removeUpdateTask(resloveCollisions);
			owner.synchronizer.removeUpdateTask(applyFrictionMap);
		}
		
		
		
		private function initialize():void
		{
			_locationInfo = Facade.instance.info.getInfoComponentByID(owner.settings.locationID) as LocationInfo;
			_bounds = _locationInfo.bounds;
			
			
			owner.synchronizer.addUpdateTask(simulateMovement, PriorityUpdate.PHYSICS_SIMULATE_MOVEMENT);
			owner.synchronizer.addUpdateTask(resloveCollisions, PriorityUpdate.PHYSICS_RESLOVE_COLLISIONS);
			owner.synchronizer.addUpdateTask(applyFrictionMap, PriorityUpdate.APPLY_FRICTION_MAP);
		}
		
		private function simulateMovement():void
		{
			var timeElapsed:Number = owner.settings.frameStepDuration * 0.001;
			var entity:BaseEntity;
			for each(var object:LocationObject in owner.objects) {
				advanceEntityMovement(object, timeElapsed);
			}
			for each(var racer:Racer in owner.racers) {
				advanceEntityMovement(racer, timeElapsed);
			}
		}
		private function applyFrictionMap():void
		{
			var map:BitmapData = _locationInfo.frictionMapBD;
			var scaleX:Number = map.width / _locationInfo.width;
			var scaleY:Number = map.height/ _locationInfo.height;
			
			var entity:BaseEntity
			for each(entity in owner.racers) {
				recalculateFrictionPercent(entity, map, scaleX, scaleY);
			}
		}
		private function recalculateFrictionPercent(target:BaseEntity,map:BitmapData,scaleX:Number,scaleY:Number):void
		{
			var mapX:Number = target.wordX * scaleX;
			var mapY:Number = target.wordY * scaleY;
			var colorValue:uint = map.getPixel(mapX, mapY);
			var greenChannel:int = (colorValue & 0x00ff00) >> 8;
			var extraFrictionPercent:Number = greenChannel / 255.0;
			var friction:Number = 1 - _locationInfo.frictionMin - (_locationInfo.frictionMax - _locationInfo.frictionMin) * extraFrictionPercent;
			target.frictionRatio = friction;
			
			
		}
		
		
		private function resloveCollisions():void
		{
			skipCollisionTags();
			reslovwBoundsCollisions();
			detectEntitiesGroupOverlap(owner.racers, owner.racers,resloveEntityToEntityCollision);
			detectEntitiesGroupOverlap(owner.racers, owner.objects,resloveEntityToEntityCollision);
		}
		private function skipCollisionTags():void
		{
			for each(var racer:Racer in owner.racers) {
				racer.justCollidedWithBound = false;
				racer.justCollidedWithEntity = false;
			}
		}
		
		private function reslovwBoundsCollisions():void
		{
			var entity:BaseEntity;
			var bound:Polygon
			for each(entity in owner.racers) {
				for each(bound in _bounds) {
					validateEntityPositionRelativelyBound(entity, bound);
				}
			}
		}
		private function validateEntityPositionRelativelyBound(entity:BaseEntity,bound:Polygon):void
		{
			var closestSegment:LineSegment = bound.getAppropriateSideToPoint(entity.wordX, entity.wordY);
			if (!closestSegment) return;
			var segmentAngle:Number = Math.atan2(closestSegment.endP.y - closestSegment.startP.y, closestSegment.endP.x - closestSegment.startP.x);
			var segmentLength:Number = closestSegment.length;
			
			var toEntity:Vector3D = _helperV1;
			toEntity.x = entity.wordX - closestSegment.startP.x;
			toEntity.y = entity.wordY - closestSegment.startP.y;
			
			var heading:Vector3D = _helperV2;
			heading.x = Math.cos(segmentAngle);
			heading.y = Math.sin(segmentAngle);
			
			var lNormal:Vector3D = _helperV3;
			lNormal.x = Math.cos(segmentAngle-Math.PI * 0.5);
			lNormal.y = Math.sin(segmentAngle-Math.PI * 0.5);
			
			var logitudinalProjection:Number = heading.dotProduct(toEntity);
			
			if ((logitudinalProjection<0)||(logitudinalProjection>segmentLength)) return;
			
			var normalProjection:Number = lNormal.dotProduct(toEntity);
			var overlapAmount:Number=-normalProjection+entity.boundRadius
			if (overlapAmount <= 0) return;
			entity.wordX += lNormal.x * overlapAmount;
			entity.wordY  += lNormal.y * overlapAmount;
			entity.justCollidedWithBound = true;
			
			var velocityLongitudinalProjection:Number = heading.dotProduct(entity.velocity);
			var velocityNormalProjection:Number = lNormal.dotProduct(entity.velocity);
			
			entity.velocity.x = velocityLongitudinalProjection * heading.x - 0.25*velocityNormalProjection * lNormal.x;
			entity.velocity.y = velocityLongitudinalProjection * heading.y - 0.25*velocityNormalProjection * lNormal.y;
			
			
			
		}
		
		private function advanceEntityMovement(entity:BaseEntity, timeElapsed:Number):void
		{
			if (!entity) return;
			if (!entity.movable) return;
			
			var velocityValue:Vector3D = _helperV1;
			velocityValue.x = entity.velocity.x;
			velocityValue.y = entity.velocity.y;
			
			velocityValue.x += timeElapsed * entity.dragForce.x / entity.mass;
			velocityValue.y += timeElapsed * entity.dragForce.y / entity.mass;
			
			velocityValue.scaleBy(entity.frictionRatio);
			
			entity.velocity.x = velocityValue.x;
			entity.velocity.y = velocityValue.y;
			
			
			var displacement:Vector3D = _helperV2;
			displacement.x = entity.velocity.x * timeElapsed;
			displacement.y = entity.velocity.y * timeElapsed;
			
			
			entity.wordX += displacement.x;
			entity.wordY += displacement.y;
			
			
			var angualrVelocityValue:Number = entity.angularVelocity;
			angualrVelocityValue += timeElapsed * entity.turnForce / entity.mass;
			angualrVelocityValue *= entity.frictionRatio;
			entity.angularVelocity = angualrVelocityValue;
			
			var angularDisplacement:Number = entity.angularVelocity * timeElapsed;
			entity.worldAngle += angularDisplacement;
			if (entity.velocity.length > 0.5) {
				trace(entity.velocity.length)
			}
			
		}
		
		private function resloveEntityToEntityCollision(entity1:BaseEntity, entity2:BaseEntity):void
		{
			var centerlineAngle:Number = Math.atan2(entity2.wordY - entity1.wordY, entity2.wordX - entity1.wordX);
			
			var heading:Vector3D = _helperV1;
			heading.x = Math.cos(centerlineAngle);
			heading.y = Math.sin(centerlineAngle);
			
			var normalL:Vector3D = _helperV2;
			normalL.x = Math.cos(centerlineAngle-Math.PI * 0.5);
			normalL.y = Math.sin(centerlineAngle-Math.PI * 0.5);
			
			
			var startSpeedX1:Number = heading.dotProduct(entity1.velocity);
			var startSpeedX2:Number = heading.dotProduct(entity2.velocity);
			
			var startSpeedY1:Number = normalL.dotProduct(entity1.velocity);
			var startSpeedY2:Number = normalL.dotProduct(entity2.velocity);
			
			var mass1:Number = entity1.mass;
			var mass2:Number = entity2.mass;
			
			var endSpeedX1:Number = ((mass1 - mass2) * startSpeedX1 + 2 * mass2 * startSpeedX2) / (mass1 + mass2);
			var endSpeedX2:Number = (2 * mass1 * startSpeedX1 + (mass2 - mass1) * startSpeedX2) / (mass1 + mass2);
			
			entity1.velocity.x = endSpeedX1 * heading.x + startSpeedY1 * normalL.x;
			entity1.velocity.y = endSpeedX1 * heading.y + startSpeedY1 * normalL.y;
			entity1.justCollidedWithEntity = true;
			
			entity2.velocity.x = endSpeedX2 * heading.x + startSpeedY2 * normalL.x;
			entity2.velocity.y = endSpeedX2 * heading.y + startSpeedY2 * normalL.y;
			entity2.justCollidedWithEntity = true;
			
		}
		
		
		
		
		
		private function detectEntitiesGroupOverlap(group1:Object, group2:Object,notifier:Function):void
		{
			if (group1 is BaseEntity) {
				group1 = [group1];
			}
			if (!group2) {
				group2 = group1;
			}else if (group2 is BaseEntity) {
				group2 = [group2];
			}
			var length1:int = group1.length;
			var length2:int = group2.length;
			var entity1:BaseEntity;
			var entity2:BaseEntity;
			
			for (var i:int = 0; i < length1; i++ ) {
				for (var j:int = (group1 == group2)?i + 1:0; j < length2; j++ ) {
					entity1 = group1[i];
					entity2 = group2[j];
					detectEntitiesOverlap(entity1, entity2, notifier);
				}
			}
		}
		
		private function detectEntitiesOverlap(entity1:BaseEntity, entity2:BaseEntity, notifier:Function):void
		{
			if ((!entity1)||(!entity2)) return;
			if ((!entity1.solid) || (!entity2.solid)) return
			
			var originsVect:Vector3D = _helperV1;
			originsVect.x = entity2.wordX - entity1.wordX;
			originsVect.y = entity2.wordY - entity1.wordY;
			
			var helper:Number = entity1.boundRadius * 0.5 + entity2.boundRadius * 0.5;
			
			if (originsVect.lengthSquared < (helper * helper)) {
				notifier(entity1, entity2);
			}
		}
	}

}