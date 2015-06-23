package xing.upLoad
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.geom.*;
	import flash.net.URLRequest;
	import flash.text.*;
	import flash.utils.ByteArray;
	

	public class ImgView extends Sprite
	{
		private var loader:Loader=new Loader();
		private var bit:Bitmap=new Bitmap();


		private var bigI:Number=1;
		public var imgW:Number=-1;
		public var imgH:Number=-1;
		private var imgHWProportion:Number=-1;

		public function ImgView()
		{
			configureListeners(loader.contentLoaderInfo);

			this.addChild(bit);

			
		}
		
		public function LoadBty(data:ByteArray):void{
			
			loader.loadBytes(data);
			
		}
		
		private function configureListeners(dispatcher:IEventDispatcher):void {
			dispatcher.addEventListener(Event.COMPLETE, completeHandler);
			dispatcher.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
			dispatcher.addEventListener(Event.INIT, initHandler);
			dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			dispatcher.addEventListener(Event.OPEN, openHandler);
			dispatcher.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			dispatcher.addEventListener(Event.UNLOAD, unLoadHandler);
			
			//_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
		}
		
		private function completeHandler(event:Event):void {
			
			var bitmap:Bitmap = Bitmap(loader.content);
			if(bit!=null){
				//bit.bitmapData.dispose();
				this.removeChild(bit);
				bit=null;
			}
			bigI=1;
			bit=new Bitmap(bitmap.bitmapData);
			this.addChild(bit);

			imgW=bit.width;
			imgH=bit.height;
			imgHWProportion=imgH/imgW;
			trace(imgW,imgH);
			var stageBl:Number=UpLoadFile2.imgHeight/UpLoadFile2.imgWidth;
			if(imgW<=UpLoadFile2.imgWidth && imgH<=UpLoadFile2.imgHeight){
				bit.x=(UpLoadFile2.imgWidth-bit.width)/2;
				bit.y=(UpLoadFile2.imgHeight-bit.height)/2;
				return;
			}

			if(imgHWProportion>stageBl){
				bit.height=UpLoadFile2.imgHeight;
				bit.width=bit.height/imgHWProportion;
			}else{
				
				bit.width=UpLoadFile2.imgWidth;
				bit.height=bit.width*imgHWProportion;
			}
			trace(bit.width,bit.height,UpLoadFile2.imgHeight,UpLoadFile2.imgWidth);
			bit.x=(UpLoadFile2.imgWidth-bit.width)/2;
			bit.y=(UpLoadFile2.imgHeight-bit.height)/2;
		}
		
		
		
		private function httpStatusHandler(event:HTTPStatusEvent):void {
			//trace("httpStatusHandler: " + event);
		}
		
		private function initHandler(event:Event):void {
			//trace("initHandler: " + event);
		}
		
		private function ioErrorHandler(event:IOErrorEvent):void {
			//trace("ioErrorHandler: " + event);
		}
		
		private function openHandler(event:Event):void {
			//trace("openHandler: " + event);
		}
		
		private function progressHandler(event:ProgressEvent):void {
			//trace("progressHandler: bytesLoaded=" + event.bytesLoaded + " bytesTotal=" + event.bytesTotal);
		}
		
		private function unLoadHandler(event:Event):void {
			// trace("unLoadHandler: " + event);
		}
		
		
	}
}