package haxe.ui.test.irc;
import browser.events.EventDispatcher;
import sys.net.Socket;
import sys.net.Host;

#if neko
import neko.vm.Thread;
#else
import cpp.vm.Thread;
#end

class SimpleIRCClient extends EventDispatcher {
	public var server:String;
	public var nick:String;
	public var channel:String;
	
	private var socket:Socket;
	private var readThread:Thread;
	
	public function new() {
		super();
	}
	
	public function connect(server:String):Void {
		trace("Connecting to " +  server + "...");
		this.server = server;
		
		try {
			socket = new Socket();
			var host:Host = new Host(server);
			socket.connect(host, 6667);
			dispatchEvent(new IRCEvent(IRCEvent.CONNECTED));
		} catch (e:Dynamic) {
			dispatchEvent(new IRCEvent(IRCEvent.ERROR, e));
			trace("Exception in connecting: " + e);
		}
		
	}
	
	public function login(nick:String):Void {
		this.nick = nick;
		
		var loginThread:Thread = Thread.create(loginAsync);
		loginThread.sendMessage(this);
	}
	
	public function join(channel:String):Void {
		this.channel = channel;
		
        socket.output.writeString("JOIN " + channel + "\r\n");
        socket.output.flush();
		
		dispatchEvent(new IRCEvent(IRCEvent.JOINED_CHANNEL));
		
		readThread = Thread.create(readLoop);
		readThread.sendMessage(this);
	}
	
	public function sendMessage(msg:String):Void {
        socket.output.writeString("PRIVMSG " + channel + " :" + msg + "\r\n");
        socket.output.flush();
		dispatchEvent(new IRCEvent(IRCEvent.DATA_SENT, "me : " + msg));
	}

	private function loginAsync():Void {
		var client:SimpleIRCClient = Thread.readMessage(true);
		
		client.socket.output.writeString("NICK " + client.nick + "\r\n");
		client.socket.output.writeString("USER " + client.nick + " 8 * : " + client.nick + "\r\n");
		client.socket.output.flush();
		
		while (true) {
			var line:String = client.socket.input.readLine();
			trace(line);
			if (line.indexOf("004") >= 0) {
                // We are now logged in.
				client.dispatchEvent(new IRCEvent(IRCEvent.LOGGED_IN));
                break;
            } else if (line.indexOf("432") >= 0) {
                client.dispatchEvent(new IRCEvent(IRCEvent.ERROR, "Invalid nickname"));
                break;
            } else if (line.indexOf("433") >= 0) {
                client.dispatchEvent(new IRCEvent(IRCEvent.ERROR, "Nickname is already in use"));
                break;
            }
		}
	}
	
	private function readLoop():Void {
		var client:SimpleIRCClient = Thread.readMessage(true);
		
		while (true) {
			try {
				var line:String = client.socket.input.readLine();
				trace(line);
				
				var n:Int = line.indexOf("PRIVMSG");
				if (n != -1) {
					
					var n2:Int = line.indexOf(":", n);
					if (n2 != -1) {
						var str:String = line.substr(n2 + 1);
						var n = line.indexOf(":");
						var n2 = line.indexOf("!");
						var name:String = line.substr(n + 1, n2 - 1);
						
						client.dispatchEvent(new IRCEvent(IRCEvent.DATA_RECEIVED, name + ": " + str));
					}
				}
				
				if (line.substr(0, 4).toUpperCase() == "PING") {
					trace("Responding to ping");
					client.socket.output.writeString("PONG " + line.substr(5) + "\r\n");
					client.socket.output.flush();
					//client.writeMessage("I got pinged!");
				}
			} catch (e:Dynamic) {
				trace("Exception in read loop: " + e);
			}
		}
	}
}