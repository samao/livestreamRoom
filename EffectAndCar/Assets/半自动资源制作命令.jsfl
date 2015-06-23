/**
*1.主要功能添加第一帧代码；
*2.修改库里3个元件PMC(停车场)，LMC(登场特效)，IMC(车标)的连接名和基类名
*3.连接名按从1970 年 1 月 1 日至文件创建时间之间的秒数
*
*/

fl.getDocumentDOM().getTimeline().addNewLayer("AS");
var layerIndex = fl.getDocumentDOM().getTimeline().findLayerIndex("AS");
var s=fl.getDocumentDOM().pathURI;
var creationTime = FLfile.getCreationDate(s); 
var modificationTime = FLfile.getModificationDate(s); 

var itemArray = fl.getDocumentDOM().library.items;
var header="";

//改变库里面3个元件的类名和基类
for(var i in itemArray){
	switch(itemArray[i].name){
		case "PMC":
		header="P";
		break;
		case "LMC":
		header="L";
		break;
		case "IMC":
		header="I";
		break;
	}	
	if(header!=""){
		itemArray[i].linkageExportForAS=true;
		itemArray[i].linkageExportInFirstFrame = true;
		itemArray[i].linkageClassName="com.guagua.display."+header+"_"+creationTime;
		itemArray[i].linkageBaseClass="flash.display.Sprite";		
		alert(header+" 已经完成！")
	}
	header=""
}

//as 代码
var asStr="import flash.system.Security;\nSecurity.allowDomain(\"*\");\nvar libId:String=\"_"+creationTime+"\";\n";
//添加到时间轴上
fl.getDocumentDOM().getTimeline().layers[layerIndex].frames[0].actionScript=asStr;

fl.getDocumentDOM().testMovie(1);
