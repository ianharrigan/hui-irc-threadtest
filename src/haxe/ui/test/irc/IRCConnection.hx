package haxe.ui.test.irc;

import haxe.ui.data.DataSource;
import haxe.ui.test.irc.IRCEvent;
import org.greenthreads.GreenThread;

#if flash
import flash.net.Socket;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.utils.ByteArray;
#else
import sys.net.Socket;
import sys.net.Host;
#end

class IRCConnection extends GreenThread {
	private var socket:Socket;

	private var nickname:String = "";
	private var host:String = "";
	
	public function new(host:String) {
		super();
		this.host = host;
	}
	
	override private function initialize():Void {
		super.initialize();

		socket = new Socket();
		#if flash
			socket.addEventListener(Event.CLOSE, this.onClose);
			socket.addEventListener(Event.CONNECT, this.onConnect);
			socket.addEventListener(IOErrorEvent.IO_ERROR, this.onError);
			socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onError);
			socket.addEventListener(ProgressEvent.SOCKET_DATA, this.onData);
			socket.connect(host, 6667);
		#else
			socket.connect(new Host(host), 6667);
			socket.setBlocking(false);
			dispatchEvent(new IRCEvent(IRCEvent.CONNECTED));
		#end
	}
	
	private var data:String = "";
	#if flash
	private function onClose(event:Event):Void {
		trace("onClose");
	}
	
	private function onConnect(event:Event):Void {
		dispatchEvent(new IRCEvent(IRCEvent.CONNECTED));
	}
	
	private function onError(event:IOErrorEvent):Void {
		trace("onError");
	}
	
	private function onData(event:ProgressEvent):Void {
		var bytes:ByteArray = new ByteArray();
		socket.readBytes(bytes, 0, Std.int(event.bytesLoaded));
		data += bytes.toString();
		processData();
	}
	
	#else
	
	override private function run():Bool {
		var r = Socket.select([socket], null, null, 0);
		
		if (r.read.length > 0) {
			for (s in r.read) {
				while (true) {
					try {
						data += s.input.readString(1);
						processData();
					} catch (e:Dynamic) {
						break;
					}
				}
			}
		}
			
		return true;
	}
	#end
	
	private function processData():Void {
		var n:Int = data.indexOf("\n");
		while (n != -1) {
			var line:String = data.substr(0, n - 1);
			data = data.substr(n+1, data.length);
			n = data.indexOf("\n");
			//trace("LINE = '" + line + "'");
			dispatchEvent(new IRCEvent(IRCEvent.DATA_RECEIVED, line ));
			if (line.indexOf("004") != -1) {
				dispatchEvent(new IRCEvent(IRCEvent.LOGGED_IN));
			} if (line.indexOf("JOIN") != -1) {
				if (line.indexOf(nickname) != -1) {
					// joined channel
					var arr:Array<String> = line.split(" ");
					dispatchEvent(new IRCEvent(IRCEvent.JOINED_CHANNEL, arr[2] ));
				}
			}
		}
	}
	
	public function writeString(s:String):Void {
		#if flash
			var bytes:ByteArray = new ByteArray();
			bytes.writeUTFBytes(s);
			socket.writeBytes(bytes);
			socket.flush();
		#else
			socket.output.writeString(s);
			socket.output.flush();
		#end
	}
	
	public function login(nickname:String):Void {
		this.nickname = nickname;
		writeString("NICK " + nickname + "\r\n");
		writeString("USER " + nickname + " 8 * : " + nickname + "\r\n");
	}
	
	public function join(channel:String):Void {
		writeString("JOIN " + channel + "\r\n");
	}
}