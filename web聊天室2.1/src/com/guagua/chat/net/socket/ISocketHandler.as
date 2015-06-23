package com.guagua.chat.net.socket 
{
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author Wen
	 */
	public interface ISocketHandler 
	{
		function set socket(socket:ISocket):void;
		function get socket():ISocket;
		
		function handle(data:ByteArray,eType:int=0):Boolean;
		function whandle(data:ByteArray):Boolean;
		function wcmd(cmd:int):void;
		
		function get command():String;
		
		function set cmds(cmds:Array):void;
		function get cmds():Array;
		
		function set wcmds(wcmds:Array):void;
		function get wcmds():Array;
		//socket连接成功
		function socketConnComplete():void;
		//socket关闭
		function socketCloseComplete():void;
		//益处
		function gc():void;
	}
	
}