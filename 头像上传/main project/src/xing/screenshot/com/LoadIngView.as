package xing.screenshot.com
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	public class LoadIngView extends Sprite
	{
		public var loadMc:LoadIngMc=new LoadIngMc();
		public function LoadIngView()
		{
			
		}
		public function init():void{
			this.graphics.beginFill(0x000000,0.5);
			this.graphics.drawRect(0,0,stage.stageWidth,stage.stageHeight);
			this.graphics.endFill();
			this.addChild(loadMc);
			loadMc.x=(this.width-loadMc.width)/2;
			loadMc.y=(this.height-loadMc.height)/2;
			loadMc.outBtn.addEventListener(MouseEvent.CLICK,click);
			this.visible=false;
		}
		
		public function show(str:String,i:int=1,b:Boolean=false):void{
			if(!this.visible)this.visible=true;
			loadMc.outBtn.visible=b;
			loadMc.messTxt.text=str;
			loadMc.loadIng.gotoAndStop(i);
			
		}
		
		public function close():void{
			loadMc.outBtn.visible=false;
			loadMc.messTxt.text="";
			loadMc.loadIng.gotoAndStop(1);
			this.visible=false;
		}
		
		private function click(e:MouseEvent):void{
			this.visible=false;
		}
	}
}