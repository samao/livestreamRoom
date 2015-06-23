package
{
	import com.bit101.components.PushButton;
	import com.bit101.components.Style;
	import com.guagua.iplugs.IBitmap;
	
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	[SWF(width="250",height="250")]
	public class CameraScreenShot extends Sprite implements IBitmap
	{
		private var camScreen:CamScreen=new CamScreen();

		private var backFun:Function;
		
		private var W:Number=250;
		private var H:Number=250;
		
		public function CameraScreenShot()
		{
			this.addEventListener(Event.ADDED_TO_STAGE,onAdded);
			camScreen.addEventListener(Event.COMPLETE,shotReady);
		}
		
		protected function shotReady(event:Event):void
		{			
			trace("咔！");
			//this.addChild(new Bitmap(this.bitmapdata));
			if(backFun)
			{
				backFun(this.bitmapdata);
			}
			if(this.contains(this.camScreen))
			{
				this.removeChild(camScreen);
			}	
			camScreen.dispose();
		}
		
		protected function onAdded(event:Event):void
		{
			Style.fontSize=12;
			Style.fontName="宋体";
			var push:PushButton=new PushButton(this,0,0,"开始",shotHandler);
			push.x=W-push.width>>1;
			push.y=H-push.height>>1;
			this.removeEventListener(Event.ADDED_TO_STAGE,onAdded);
			this.addEventListener(Event.REMOVED_FROM_STAGE,function():void
			{
				camScreen.dispose();
			})
		}
		
		private function shotHandler(e:MouseEvent):void
		{
			if(CamScreen.isSupported)
			{
				setWH();
				this.addChild(camScreen);
			}
		}
		
		public function shotComplete(fun:Function):void
		{
			backFun=fun;
		}
		
		public function get bitmapdata():BitmapData
		{
			return camScreen.bitmapdata?camScreen.bitmapdata.clone():null;
		}
		
		public 	function setWH(w:Number=250,h:Number=250):void
		{
			W=w;
			H=h;
			this.camScreen.setSize(w,h);
		}
	}
}