package xing.screenshot.com
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
	import flash.external.ExternalInterface;
	
	import xing.screenshot.Config;
	import xing.screenshot.SMain;
	public class ImgView extends Sprite
	{
		private var loader:Loader=new Loader();
		private var bit:Bitmap=new Bitmap();
		private var container:Sprite=new Sprite;
		private var shape:Shape=new Shape();
		/**放大比例**/
		private var bigI:Number=1;
		/**图片原始宽**/
		public var imgW:Number=-1;
		/**图片原始高**/
		public var imgH:Number=-1;
		/**宽高比例**/
		private var imgHWProportion:Number=-1;
		public var imgRectV:RectView;
		public function ImgView()
		{
			configureListeners(loader.contentLoaderInfo);
			this.addChild(container);
			container.addChild(bit);
			this.addChild(shape);
			var maskDef:Sprite=new Sprite;
			this.addChild(maskDef);
			this.mask=maskDef;
			maskDef.graphics.beginFill(0x000000);
			maskDef.graphics.drawRect(0,0,SMain.imgContainerW,SMain.imgContainerH);
			maskDef.graphics.endFill();
			container.buttonMode=true;
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
			if(bit!=null&&container.contains(bit)){
				//bit.bitmapData.dispose();
				container.removeChild(bit);
				bit=null;
			}
			
			bigI=1;
			bit=new Bitmap(bitmap.bitmapData);
			container.addChild(bit);
			imgW=bit.width;
			imgH=bit.height;
			Config.isUpLoadHandler(imgW,imgH);
			if(!Config.isUpload){
				trace("ImgView completeHandler fileWHerr-------------");
				if(ExternalInterface.available){
					ExternalInterface.call("fileWHerr");
				}
				
			}
			imgHWProportion=imgH/imgW;
			if(bit.width>=Config.rectW && bit.height>=Config.rectH){
			   bit.width=bit.width/2;
			   bit.height=bit.height/2;
			}else{
				if(imgHWProportion>Config.imgH/Config.imgW){
					bit.height=SMain.imgContainerH;
					bit.width=bit.height/imgHWProportion;
					if(bit.width<Config.imgW){
						bit.width=Config.imgW;
						bit.height=bit.width*imgHWProportion;
					}
				}
				
				if(imgHWProportion<Config.imgH/Config.imgW){
					bit.width=SMain.imgContainerW;
					bit.height=bit.width*imgHWProportion;
					if(bit.height<Config.imgH){
						bit.height=Config.imgH;
						bit.width=bit.height/imgHWProportion;
					}
				}
			}
			
			bit.x=bit.width/2*-1;
			bit.y=bit.height/2*-1;	
			
			if(!container.hasEventListener(MouseEvent.MOUSE_DOWN)){
				container.addEventListener(MouseEvent.MOUSE_DOWN,cDownHandler);
			}
			//container.x=-bit.x;
			//container.y=-bit.y;
			//container.scaleX=0.7;
			//container.scaleY=0.7;
			//container.width=400;
			//container.height=300;
			shape.graphics.clear();
			shape.graphics.beginFill(0x00000,0.5);
			shape.graphics.drawRect(0,0,SMain.imgContainerW,SMain.imgContainerH);
			shape.graphics.endFill();
			this.dispatchEvent(new Event("Event_Img_Complete"));
			
			setContainerXY();
		}
		
		private function setContainerXY():void{
			
			if(container.width>SMain.imgContainerW){
				container.x=-(container.width-SMain.imgContainerW)/2+bit.x*-1;
			}else{
				container.x=(SMain.imgContainerW-container.width)/2+bit.x*-1;
			}
			if(container.height>SMain.imgContainerH){
				container.y=-(container.height-SMain.imgContainerH)/2+bit.y*-1;
			}else{
				container.y=(SMain.imgContainerH-container.height)/2+bit.y*-1;
			}
			imgRectV.setBitXY(container.x+bit.x,container.y+bit.y,container.width,container.height);
			//trace(container.x-bit.x,container.y-bit.y);
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
		
		
		
		private function cDownHandler(e:MouseEvent):void{
			container.startDrag();
			if(!stage.hasEventListener(MouseEvent.MOUSE_UP)){
				stage.addEventListener(MouseEvent.MOUSE_UP,stageUpHandler);
			}	
			if(!this.hasEventListener(Event.ENTER_FRAME)){
				this.addEventListener(Event.ENTER_FRAME,entFrameHandler);
			}
			//trace("------------cDownHandler");
		}
		private function stageUpHandler(e:MouseEvent):void{
			container.stopDrag();
			stage.removeEventListener(MouseEvent.MOUSE_UP,stageUpHandler);
			this.removeEventListener(Event.ENTER_FRAME,entFrameHandler);
			imgRectV.setBitXY(container.x+bit.x,container.y+bit.y,container.width,container.height);
		}
		private function entFrameHandler(e:Event):void{
			imgRectV.setBitXY(container.x+bit.x,container.y+bit.y,container.width,container.height);
		}
		public function bigSmallImg(i:int=1):void{
			bigI=bigI+0.1*i;
			if(bigI>2)bigI=2;
			if(bigI<0.1)bigI=0.1;
			bit.width=imgW*bigI;
			bit.height=imgH*bigI;
			bit.x=bit.width/2*-1;
			bit.y=bit.height/2*-1;	
			setContainerXY();
		}
		
		public function get imgData():BitmapData{
			return bit.bitmapData.clone();
		}
		
		public function clear():void{
			if(bit!=null&&container.contains(bit)&&bit.bitmapData){	
				shape.graphics.clear();
				container.removeChild(bit);
				bit.bitmapData.dispose();				
			}
		}
		
		public function getImgRectDataAry(rect:Rectangle):Vector.<BitmapData>{
			/*var bl:Number=170/rect.width;
			var bl2:Number=50/rect.width;
			var bl3:Number=32/rect.width;
			var bary:Vector.<BitmapData>=new Vector.<BitmapData>();
			
			var matrix:Matrix=new Matrix(1,0,0,1,-rect.x+container.x,-rect.y+container.y);
			matrix.scale(bl,bl);
			var bData:BitmapData=new BitmapData(170,170);
			bData.draw(container,matrix,null,null,new Rectangle(0,0,170,170));	
			bary.push(bData);
			
			var matrix2:Matrix=new Matrix(1,0,0,1,-rect.x+container.x,-rect.y+container.y);
			matrix2.scale(bl2,bl2);
			var bData2:BitmapData=new BitmapData(50,50);
			bData2.draw(container,matrix2,null,null,new Rectangle(0,0,50,50));	
			bary.push(bData2);
			
			var matrix3:Matrix=new Matrix(1,0,0,1,-rect.x+container.x,-rect.y+container.y);
			matrix3.scale(bl3,bl3);
			var bData3:BitmapData=new BitmapData(32,32);
			bData3.draw(container,matrix3,null,null,new Rectangle(0,0,32,32));	
			bary.push(bData3);*/
			
			var bary:Vector.<BitmapData>=new Vector.<BitmapData>();
			var ary:Array=Config.sizeAry;
			
			for(var i:int=0;i<ary.length;i++){
				//trace("999");
				var matrix:Matrix=new Matrix(1,0,0,1,-rect.x+container.x,-rect.y+container.y);
				matrix.scale(ary[i][0]/rect.width,ary[i][1]/rect.height);
				var bData:BitmapData=new BitmapData(ary[i][0],ary[i][1]);
				
				bData.draw(container,matrix,null,null,new Rectangle(0,0,ary[i][0],ary[i][1]));	
				bary.push(bData);
			}
			return bary;
		}
		
		public function reset():void{
			bigI=1;	
			bit.width=imgW;
			bit.height=imgH;
			bit.x=bit.width/2*-1;
			bit.y=bit.height/2*-1;	
			setContainerXY();
		}
		
		
	}
}