package com.guagua.chat.net.socket 
{
	import flash.utils.Timer;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	//import flash.utils.Timer;
	/**
	 * ...843 策略socket
	 * @author Wen
	 */
	public class SecuritySocket extends BaseSocket
	{
		private var _connSucess:Function;
		private var closeTimer:Timer;
		public var is843:Boolean = false;
		private var connIndex:int = 0;
		
		public function SecuritySocket(connSucess:Function,_name:String="SecuritySocket") 
		{
			super();
			this.name=_name;
			this.timeout = 5000;
			this._connSucess = connSucess;
		}
		
		
		public function setConnIndex():void{
			connIndex=0;
		}
		
		override protected function connectHandler(e:Event):void {
			writeUTFBytes("<policy-file-request/>");
			flush();
		}
		override protected function errorHandler(e:ErrorEvent):void {
			is843=false;
			if (this.connecting) {
				this.setImmediatelyClose("");
			}else{
				//callBack(false);
			}
		}
		override protected function dataHandler(e:ProgressEvent):void {
			//trace("SecuritySocket dataHandler");
			Log.out("843返回:"+this.name)//+"\n",XML(this.readUTFBytes(this.bytesAvailable)));
			is843 = true;
			this.setImmediatelyClose("");
			callBack(is843);
		}
		
		override public function closeToDo(arg:String):void {
			Log.out("843端口状态："+arg,is843,"尝试次数：",connIndex,this.name,this._serverIp,this._port);
			if (is843) return;
			
			if(connIndex>0){
				callBack(is843);
				return;
			}			
			
			
			if(closeTimer==null){
				closeTimer = new Timer(200,1);
				closeTimer.addEventListener(TimerEvent.TIMER, closeTimerFun);
				closeTimer.start();
			}else{
				closeTimer.reset();
				closeTimer.start();
			}
			connIndex++;
			/*if (closeTimer.running) {
				return ;
			}*/
		}
		private function closeTimerFun(e:TimerEvent):void {
			//trace("Socket SecuritySocket 843 againConnect");
			this.againConnect();
		}
		
		private function callBack(state:Boolean):void {
			if(this._connSucess!=null)this._connSucess(state);		
		}
		
	}

}