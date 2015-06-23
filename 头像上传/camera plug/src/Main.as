package
{
	import com.adobe.images.PNGEncoder;
	import com.bit101.components.PushButton;
	import com.bit101.components.Style;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import com.guagua.iplugs.IBitmap;

	public class Main extends Sprite
	{

		private var bitmap:Bitmap;

		private var file:FileReference;

		private var pngbyte:ByteArray;

		private var save:PushButton;
		public function Main()
		{
			this.addEventListener(Event.ADDED_TO_STAGE,onAdded);
			bitmap=new Bitmap();
			addChild(bitmap);
		}
		
		private function saveHandler(e:MouseEvent):void
		{			
			file.addEventListener(Event.COMPLETE,saveokHandler);
			file.save(pngbyte,new Date().time+".png");
		}
		
		protected function saveokHandler(event:Event):void
		{
			file.removeEventListener(Event.COMPLETE,saveokHandler);
			save.visible=false;
			bitmap.bitmapData.dispose();
		}
		
		protected function onAdded(event:Event):void
		{
			var loader:Loader=new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onload);
			loader.load(new URLRequest("CameraScreenShot.swf"));
			
			com.bit101.components.Style.fontName="宋体";
			Style.fontSize=12;
			
			save=new PushButton(this,110,0,"保存",saveHandler);
			save.visible=false;
			file=new FileReference();
		}
		
		protected function onload(event:Event):void
		{
			var sprite:Sprite=event.target.content as Sprite;
			this.addChild(sprite);
			
			var ibit:IBitmap=event.target.content as IBitmap;
			ibit.shotComplete(function(bit:BitmapData):void{
				trace("卡完了",bit);
				bitmap.bitmapData=bit;
				bitmap.scaleZ=bitmap.scaleX=bitmap.scaleY=.5;
				bitmap.x=stage.stageWidth-bitmap.width>>1;
				bitmap.y=stage.stageHeight-bitmap.height>>1;
				pngbyte=PNGEncoder.encode(bit);
				save.visible=true;				
			})
		}
	}
}