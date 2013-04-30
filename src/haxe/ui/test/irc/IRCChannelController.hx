package haxe.ui.test.irc;

import haxe.ui.containers.ListView;
import haxe.ui.controls.Button;
import haxe.ui.core.ComponentParser;
import haxe.ui.core.Controller;
import nme.events.Event;
import nme.events.MouseEvent;

class IRCChannelController extends Controller {
	private var connection:IRCConnection;
	private var channel:String;

	public function new(connection:IRCConnection, channel:String) {
		super(ComponentParser.fromXMLResource("ui/ircChannelTab.xml"));
		
		this.connection = connection;
		this.channel = channel;
		connection.addEventListener(IRCEvent.DATA_RECEIVED, onDataReceived);
		getComponentAs("sendButton", Button).addEventListener(MouseEvent.CLICK, function(e) {
			var data:String = getComponent("dataToSend").text;
			connection.writeString("PRIVMSG " + channel + " :" + data + "\r\n");
			var list:ListView = getComponentAs("data", ListView);
			list.dataSource.add( { text: "Me:", subtext: data } );
			list.vscrollPosition = list.vscrollMax;
		});
	}
	
	private function onDataReceived(event:IRCEvent):Void {
		var line:String = cast(event.data, String);
		if (line.indexOf(channel) != -1) {
//			trace(line);
			var list:ListView = getComponentAs("data", ListView);
			
			var arr:Array<String> = line.split(" ");
			if (arr[1] == "PRIVMSG") {
				var name:String = arr[0];
				if (name.indexOf(":") == 0) {
					name = name.substr(1, name.length);
				}
				var n:Int = name.indexOf("!");
				if (n != -1) {
					name = name.substr(0, n);
				}
				
				name += ":";
				
				arr = arr.splice(3, arr.length);
				var msg:String = arr.join(" ");
				if (msg.indexOf(":") == 0) {
					msg = msg.substr(1, msg.length);
				}
				
				list.dataSource.add( { text: name, subtext: msg } );
			} else if (arr[1] == "332") {
				arr = arr.splice(4, arr.length);
				var msg:String = arr.join(" ");
				if (msg.indexOf(":") == 0) {
					msg = msg.substr(1, msg.length);
				}
				
				list.dataSource.add( { text: "Joined " + channel, subtext: msg} );
			}
			
			list.vscrollPosition = list.vscrollMax;
		}
	}
}