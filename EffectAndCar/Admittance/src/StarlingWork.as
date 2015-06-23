package
{
	import com.guagua.normal.World;
	import com.guagua.starling.World;
	
	import flash.display.Sprite;
	import flash.display.Stage3D;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.system.ApplicationDomain;
	
	import net.hires.debug.Stats;
	
	import starling.core.Starling;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	
	
	/**
	 *@Date:2012-10-25 下午02:05:56	
	 */
	[SWF (frameRate="24",width="800",height="80",backgroundColor="#ffffff")]
	public class StarlingWork extends Sprite
	{
		
		private var ms:Starling
		
		public function StarlingWork()
		{
			super();
			this.addEventListener(Event.ADDED_TO_STAGE,init);
		}
		
		
		protected function init(event:Event):void
		{
			//var stats:Stats=new Stats();			
			
			//this.stage.addChild(stats);	
			
			stage.scaleMode=StageScaleMode.NO_SCALE;
			stage.align=StageAlign.TOP_LEFT;
			
			startWorld("渲染失败，切换显示")
			//initGUI();				
		}
		
		/**检测客户端是否支持stage3d加速*/
		private function initGUI():void
		{			
			var stage3DAvailable:Boolean =ApplicationDomain.currentDomain.hasDefinition("flash.display.Stage3D");
			if(stage3DAvailable){
				ms=new Starling(com.guagua.starling.World,stage);
				ms.antiAliasing=1;	
				ms.start();
				ms.stage3D.addEventListener(Event.CONTEXT3D_CREATE, onContextCreated);
				ms.stage3D.addEventListener(ErrorEvent.ERROR,this.onStage3DError);	
			}else{
				startWorld("您的系统不支持stage3D")	
			}			
		}
		
		private function onContextCreated(event:Event):void
		{
			// set framerate to 30 in software mode	
			//trace(Starling.context.driverInfo.toLowerCase())
			if (Starling.context.driverInfo.toLowerCase().indexOf("software") != -1){				
				Starling.current.nativeStage.frameRate = 30;
				trace("软件加速"+Starling.current.nativeStage.frameRate)
				return 
			}
			trace("硬件加速"+this.stage.frameRate)
			//startWorld("创建starling失败");
		}			
		
		
		protected function onStage3DError(event:ErrorEvent):void
		{				
			startWorld("渲染失败，切换显示")
		}
		
		private function startStarling():void
		{
			
		}
		
		private function startWorld(arg:String):void{
			//trace(arg);
			this.stage.addChild(new com.guagua.normal.World())
		}
	}
}