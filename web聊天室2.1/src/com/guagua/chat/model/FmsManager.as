package com.guagua.chat.model
{
	import com.guagua.events.FmsEvent;
	import com.guagua.chat.net.handler.room.RoomCmdHandler;	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	
	/**
	 *@Date:2012-11-12 上午10:11:39	
	 */
	
	public class FmsManager extends EventDispatcher
	{
		private var fmsVector:Vector.<FmsModel>=new Vector.<FmsModel>();
		
		static private var instance:FmsManager;
		
		private var _status:String="empty";
		
		public function FmsManager(target:IEventDispatcher=null)
		{
			super(target);
			
			this.addEventListener(FmsEvent.FMS_GETTING,getfmsHandler);
			this.addEventListener(FmsEvent.FMS_RECEIVE,receiveHandler);
		}
		
		public function set status(value:String):void
		{
			_status = value;
		}

		protected function receiveHandler(event:Event):void
		{
			this.status=FmsEvent.FMS_RECEIVE;
		}
		
		/**fms状态*/
		public function get status():String
		{
			return _status;
		}

		protected function getfmsHandler(event:Event):void
		{
			if(_status==FmsEvent.FMS_GETTING){
				return;
			}
			Log.out("最优fms质量太差，请求下一批数据");
			_status=FmsEvent.FMS_GETTING;
			RoomModel.getRoomModel().casAPI.whandle(RoomModel.getRoomModel().casAPI.write._1003(6));
		}
		
		static public function getInstance():FmsManager{
			if(instance==null){
				instance=new FmsManager();
			}
			return instance;
		}
		
		/**重置所有lag*/
		public function resetAllLag():void {
			for each(var i:FmsModel in fmsVector) {
				i.resetLAG();
			}
		}
		
		
		/** 往列表里面添加一条fms数据*/
		public function addFms(value:FmsModel):FmsModel{
			if(this.status==FmsEvent.FMS_RECEIVE){
				return null;
			}
			
			for each(var i:FmsModel in fmsVector){
				if (i.ip == value.ip && i.port == value.port) {
					//已经存在的话重置lag
					i.resetLAG();
					Log.out("FMS已经存在重置lag：" + i.toString());					
					resortFMS();
					return null;
				}
			}		
			
			fmsVector.push(value);
			
			resortFMS();			
			return value;
		}
		
		/**重新排列fms*/
		public function resortFMS():void {				
			fmsVector.sort(orderFMSByLag);
		}
		
		/**按照lag逆序排列fms*/
		private function orderFMSByLag(a:FmsModel,b:FmsModel):Number {
			if (a.lag > b.lag) {
				return 1;
			}else if (a.lag < b.lag) {
				return -1;
			}
			return 0;
		}
		
		/**清空列表信息*/
		public function clearFms():void{
			fmsVector = new Vector.<FmsModel>();
		}
		
		/**随机从列表里面抽取一条数据*/
		public function getFms():FmsModel {
			
			if(fmsVector[0].lag==uint.MAX_VALUE){
				//申请下一批数据
				//trace("列表空了哦")					
				
				return fmsVector[0];
			}
			var index:uint=Math.floor(Math.random()*fmsVector.length);
			return fmsVector[0];
		}
		
		/**删除一条数据*/
		public function delFms(ip:String,port:uint):Boolean{
			
			if(fmsVector.length<=0){
				Log.out("连接池中已经没有数据了");
			}
			for(var i:uint=0;i<fmsVector.length;i++){
				if(fmsVector[i].ip==ip&&fmsVector[i].port==port){
					fmsVector.splice(i,1);
					return true;
				}
			}
			return false;
		}
		
		/**打印列表信息*/
		override public function toString():String{
			var szInfor:String="\nFMS地址_________________\n";
			
			for each(var i:FmsModel in fmsVector){
				szInfor+=i.toString()+"\n";
			}
			szInfor+="-----------------\n"
			return szInfor;
		}
	}
}