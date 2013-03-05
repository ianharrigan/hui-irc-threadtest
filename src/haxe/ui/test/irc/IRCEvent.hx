package haxe.ui.test.irc;
import nme.events.Event;

class IRCEvent extends Event {
	public static var CONNECTED:String = "Connected";
	public static var LOGGED_IN:String = "LoggedIn";
	public static var JOINED_CHANNEL:String = "JoinedChannel";
	public static var DISCONNECTED:String = "Disconnected";
	public static var DATA_RECEIVED:String = "DataReceived";
	public static var DATA_SENT:String = "DataSent";
	public static var ERROR:String = "Error";
	
	public var data:Dynamic;
	
	public function new(type:String, data:Dynamic = null) {
		super(type);
		this.data = data;
	}
	
}