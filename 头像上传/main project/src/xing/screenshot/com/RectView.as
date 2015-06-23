package xing.screenshot.com
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import xing.screenshot.SMain;
	import xing.screenshot.Config;

	public class RectView extends Sprite
	{
		private var bit:Bitmap=new Bitmap;
		private var baskView:Sprite=new Sprite;
		private var rectView:Sprite=new Sprite;
		/**四方形宽**/
		private var sWith:Number=0;
		/**四方形高**/
		private var sHeight:Number;
		private var btnAry:Vector.<RectBtn>=new Vector.<RectBtn>;
		private var downType:String="";
		private var btnId:int=-1;
		public var rect:Rectangle;
		private var mPoint:Point=new Point(-1,-1);
		public function RectView()
		{
			this.addChild(bit);
			this.addChild(baskView);
			this.addChild(rectView);	
		}
		/**初始化**/
		private function initRect(w:Number=100,h:Number=100):void{
			rectView.graphics.clear();
			rectView.graphics.beginFill(0xCCCCCC,1);
			//rectView.graphics.lineStyle(1, 0xFF0000);
			rectView.graphics.drawRect(0, 0, w, h);
			rectView.graphics.endFill();
			
			baskView.graphics.clear();
			baskView.graphics.beginFill(0xCCCCCC,0);
			baskView.graphics.lineStyle(1, 0xFF0000);
			baskView.graphics.drawRect(0, 0, w, h);
			baskView.graphics.endFill();	
		}
		
		public function setBitXY(_x:Number=0,_y:Number=0,_w:Number=0,_h:Number=0):void{
			bit.x=_x;
			bit.y=_y;
			bit.width=_w;
			bit.height=_h;
			rect=new Rectangle(rectView.x,rectView.y,rectView.width,rectView.height);
			this.dispatchEvent(new Event("Event_ImgRect_Complete"));
		}
		/**4角**/
		private function initBtn():void{
			if(btnAry.length>0)return;
			for(var i:int=0;i<4;i++){
				var btn:RectBtn=new RectBtn(i);
				this.addChild(btn);
				btnAry.push(btn);
				btn.addEventListener(MouseEvent.MOUSE_DOWN,btnDownHandler);
			}
		}
		
		private function setBtnXY():void{
			btnAry[0].x=baskView.x;
			btnAry[0].y=baskView.y;
	
			btnAry[1].x=baskView.x+baskView.width-1;
			btnAry[1].y=baskView.y;
			
			btnAry[2].x=baskView.x;
			btnAry[2].y=baskView.y+baskView.height-1;
		
			btnAry[3].x=baskView.x+baskView.width-1;
			btnAry[3].y=baskView.y+baskView.height-1;
		}
		/**设置四四方形的宽高**/
		public function setWH(w:Number,h:Number,b:BitmapData):void{
			this.baskView.visible=rectView.visible=true;
			
			if(btnAry.length>0){
				for(var i:int=0;i<btnAry.length;i++){
					btnAry[i].visible=true;
				}
			}
			
			bit.bitmapData=b;
			sWith=w;
			//if(b.width<w)sWith=b.width;
			sHeight=h;
			//if(b.height<h)sHeight=b.height;
			
			initRect(sWith,sHeight);
			if(!baskView.hasEventListener(MouseEvent.MOUSE_DOWN)){
				baskView.addEventListener(MouseEvent.MOUSE_DOWN,bDownHandel);
			}
			
			initBtn();
			
			baskView.y=rectView.y=(SMain.imgContainerH-rectView.height)/2;
			baskView.x=rectView.x=(SMain.imgContainerW-rectView.width)/2;
			
			bit.mask=rectView;
			
			setBtnXY();
		}
		
		public function clear():void
		{
			if(btnAry.length>0){
				for(var i:int=0;i<btnAry.length;i++){
					btnAry[i].visible=false;
				}
			}
			baskView.visible=rectView.visible=false;
			if(bit.bitmapData)
			{				
				bit.bitmapData.dispose();
			}
		}
		
		private function bDownHandel(e:MouseEvent):void{
			downType="bask";
			
			baskView.startDrag(false,new Rectangle(0,0,SMain.imgContainerW-baskView.width,SMain.imgContainerH-baskView.height));
			if(!stage.hasEventListener(MouseEvent.MOUSE_UP)){
				stage.addEventListener(MouseEvent.MOUSE_UP,stageUpHandler);
			}	
			if(!this.hasEventListener(Event.ENTER_FRAME)){
				this.addEventListener(Event.ENTER_FRAME,entFrameHandler);
			}
		}
		
		private function stageUpHandler(e:MouseEvent):void{
			baskView.stopDrag();
			if(btnAry.length>0){
				for(var i:int=0;i<btnAry.length;i++){
					btnAry[i].stopDrag();
				}
			}
			stage.removeEventListener(MouseEvent.MOUSE_UP,stageUpHandler);
			this.removeEventListener(Event.ENTER_FRAME,entFrameHandler);
			
			rectView.x=baskView.x;
			rectView.y=baskView.y;
			if(downType=="bask")setBtnXY();
			if(downType=="btn")btnDragHandler();	
			mPoint.x=mPoint.y=-1;
			downType="";
			btnId=-1;
			rect=new Rectangle(rectView.x,rectView.y,rectView.width,rectView.height);
			this.dispatchEvent(new Event("Event_ImgRect_Complete"));
		}
		private function btnDownHandler(e:MouseEvent):void{
			downType="btn";
			btnId=e.target["id"];
			//trace("RectView btnDownHandler",e.target["name"],btnId);
			mPoint.x=btnAry[btnId].x;
			mPoint.y=btnAry[btnId].y;
			if(btnId==0){
				btnAry[btnId].startDrag(false,new Rectangle(0,0,btnAry[3].x-10,btnAry[3].y-10));
			}
			if(btnId==1){
				btnAry[btnId].startDrag(false,new Rectangle(btnAry[0].x+10,0,SMain.imgContainerW-btnAry[2].x-10,btnAry[2].y-10));
			}
			if(btnId==2){
				btnAry[btnId].startDrag(false,new Rectangle(0,btnAry[1].y+10,btnAry[1].x-10,SMain.imgContainerH-btnAry[1].y-10));
			}
			if(btnId==3){
				btnAry[btnId].startDrag(false,new Rectangle(btnAry[0].x+10,btnAry[0].y+10,SMain.imgContainerW-btnAry[0].x-10,SMain.imgContainerH-btnAry[0].y-10));
			}
			if(!stage.hasEventListener(MouseEvent.MOUSE_UP)){
				stage.addEventListener(MouseEvent.MOUSE_UP,stageUpHandler);
			}	
			if(!this.hasEventListener(Event.ENTER_FRAME)){
				this.addEventListener(Event.ENTER_FRAME,entFrameHandler);
			}
		}
		private function entFrameHandler(e:Event):void{
			rectView.x=baskView.x;
			rectView.y=baskView.y;
			if(downType=="bask")setBtnXY();
			
			if(downType=="btn"){
				btnDragHandler();	
			}
		}
		
		private function btnDragHandler():void{
			var _x:Number=btnAry[btnId].x-mPoint.x;
			var _y:Number=btnAry[btnId].y-mPoint.y;
			var _jl:Number=Math.abs(_x)-Math.abs(_y);	
			
			if(btnId==0){
				/*if(_jl<0){
					btnAry[btnId].y=btnAry[2].y-(btnAry[1].x-btnAry[0].x);
				}
				if(_jl>0){
					btnAry[btnId].x=btnAry[1].x-(btnAry[2].y-btnAry[0].y);
				}*/
				
				btnAry[btnId].y=btnAry[2].y-(btnAry[1].x-btnAry[btnId].x)*Config.imgH/Config.imgW;
				
				btnAry[1].y=btnAry[btnId].y;
				btnAry[2].x=btnAry[btnId].x;
			}
			if(btnId==1){
				/*if(_jl<0){
					btnAry[btnId].y=btnAry[3].y-(btnAry[1].x-btnAry[0].x);
				}
				if(_jl>0){
					btnAry[btnId].x=btnAry[0].x+(btnAry[3].y-btnAry[1].y);
				}*/
				
				btnAry[btnId].y=btnAry[3].y-(btnAry[1].x-btnAry[0].x)*Config.imgH/Config.imgW;
				
				btnAry[0].y=btnAry[btnId].y;
				btnAry[3].x=btnAry[btnId].x;
			}
			
			if(btnId==2){
				/*if(_jl<0){
					btnAry[btnId].y=btnAry[0].y+(btnAry[3].x-btnAry[2].x);
				}
				if(_jl>0){
					btnAry[btnId].x=btnAry[3].x-(btnAry[2].y-btnAry[0].y);
				}*/
				
				btnAry[btnId].y=btnAry[0].y+(btnAry[3].x-btnAry[btnId].x)*Config.imgH/Config.imgW;
				btnAry[3].y=btnAry[btnId].y;
				btnAry[0].x=btnAry[btnId].x;
			}
			
			if(btnId==3){
				/*if(_jl<0){
					btnAry[btnId].y=btnAry[1].y+(btnAry[3].x-btnAry[2].x);
				}
				if(_jl>0){
					btnAry[btnId].x=btnAry[2].x+(btnAry[3].y-btnAry[1].y);
				}*/
				
				btnAry[btnId].y=btnAry[1].y+(btnAry[3].x-btnAry[2].x)*Config.imgH/Config.imgW;
				btnAry[2].y=btnAry[btnId].y;
				btnAry[1].x=btnAry[btnId].x;
			}
			mPoint.x=btnAry[btnId].x;
			mPoint.y=btnAry[btnId].y;
			initRect(btnAry[1].x-btnAry[0].x,btnAry[3].y-btnAry[1].y);
			baskView.y=rectView.y=btnAry[0].y;
			baskView.x=rectView.x=btnAry[0].x;
		}
		
		
	}
}