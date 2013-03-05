package haxe.ui.test.irc;
import haxe.ui.containers.ListView;
import haxe.ui.core.ComponentParser;
import haxe.ui.core.Controller;
import haxe.ui.popup.Popup;
import native.events.MouseEvent;

class IRCController extends Controller {
	private var irc:SimpleIRCClient;
	
	public function new() {
		super(ComponentParser.fromXMLAsset("ui/irc.xml"));
		
		attachEvent("connectButton", MouseEvent.CLICK, onConnect);
		attachEvent("sendButton", MouseEvent.CLICK, function(e) {
			irc.sendMessage(getComponent("dataToSend").text);
		});
	}
	
	private function onConnect(event:MouseEvent):Void {
		irc = new SimpleIRCClient();
		irc.addEventListener(IRCEvent.CONNECTED, onConnected);
		irc.addEventListener(IRCEvent.LOGGED_IN, onLoggedIn);
		irc.addEventListener(IRCEvent.JOINED_CHANNEL, onJoinedChannel);
		irc.addEventListener(IRCEvent.DATA_RECEIVED, onDataReceived);
		irc.addEventListener(IRCEvent.DATA_SENT, onDataSent);
		irc.addEventListener(IRCEvent.ERROR, onError);
		irc.connect(getComponent("server").text);
	}
	
	private function onConnected(event:IRCEvent):Void {
		trace("Connected to: " + irc.server + "...");
		irc.login(getComponent("nickname").text);
	}
	
	private function onLoggedIn(event:IRCEvent):Void {
		trace("Logged in as: " + irc.nick);
		irc.join(getComponent("channel").text);
	}

	private function onJoinedChannel(event:IRCEvent):Void {
		trace("Joined channel: " + irc.channel);
	}
	
	private function onDataReceived(event:IRCEvent):Void {
		trace("Got data: " + event.data);
		var item:Dynamic = { };
		item.text = event.data;
		getComponentAs("data", ListView).addItem(item); // TODO: should use data source
	}

	private function onDataSent(event:IRCEvent):Void {
		trace("Sent data: " + event.data);
		var item:Dynamic = { };
		item.text = event.data;
		getComponentAs("data", ListView).addItem(item); // TODO: should use data source
	}
	
	private function onError(event:IRCEvent):Void {
		trace("Error: " + event.data);
		Popup.showSimple(view.root, event.data, "Error", true);
	}
}