package haxe.ui.test.irc;
import browser.events.MouseEvent;
import haxe.ui.containers.ListView;
import haxe.ui.core.ComponentParser;
import haxe.ui.core.Controller;

class IRCTabController extends Controller {
	private var irc:SimpleIRCClient;
	
	public function new(irc:SimpleIRCClient) {
		super(ComponentParser.fromXMLAsset("ui/ircTab.xml"));
		this.irc = irc;

		attachEvent("sendButton", MouseEvent.CLICK, function(e) {
			irc.sendMessage(getComponent("dataToSend").text);
		});
		irc.addEventListener(IRCEvent.DATA_RECEIVED, onDataReceived);
		irc.addEventListener(IRCEvent.DATA_SENT, onDataSent);
		
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
}