package com.guagua.chat.net.socket 
{
	import flash.utils.ByteArray;
	import com.guagua.events.RoomEvent;
	
	/**
	 * ...
	 * @author Wen
	 */
	public interface ISocket 
	{
		//名称 唯一值
		function set name(name:String):void
		function get name():String;
		//设定IP
		function get serverIp():String
		function set serverIp(serverIp:String):void
		//设定端口
		function get port():int
		function set port(port:int):void;	
		//处理接口
		function addHandler(handler:ISocketHandler):void;
		function removeHandler():void;
        //发送消息
		function sendMessage(msg:ByteArray):void;
	    //连接
		function get connecting():Boolean;
		
		function connectServer(ip:String, port:int,backCall:Function=null):void;
		//重新连接
		function againConnect():void;
		
		function GC():void;
		/**
		 * socket连接成功后操作
		 */
		function connectComplete():void;
		/**
		 * socket关闭后操作
		 */
		function closeToDo(arg:String):void;
		
		function sClose():void;
		
		//发送消息
		function dispathEvent(e:RoomEvent):void;
		
		function get connectWatcher():Function;
		
		function changeIpAndConnect(arg:String):void;
	}
	
}