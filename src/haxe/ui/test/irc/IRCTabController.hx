package haxe.ui.test.irc;

import haxe.ui.containers.ListView;
import haxe.ui.core.ComponentParser;
import haxe.ui.core.Controller;
import haxe.ui.popup.Popup;
import nme.events.Event;
import nme.events.MouseEvent;

class IRCTabController extends Controller {
	private var connection:IRCConnection;
	
	public function new(connection:IRCConnection, nickname:String) {
		super(ComponentParser.fromXMLResource("ui/ircTab.xml"));
		getComponent("dataToSend").enabled = false;
		getComponent("sendButton").enabled = false;
		getComponent("data").enabled = false;
		
		this.connection = connection;
		connection.addEventListener(IRCEvent.DATA_RECEIVED, onDataReceived);
		/*
		getComponentAs("data", ListView).dataSource.addEventListener(Event.CHANGE, function(e) {
			getComponentAs("data", ListView).vscrollPosition = getComponentAs("data", ListView).vscrollMax;
		});
		*/
		
		connection.addEventListener(IRCEvent.LOGGED_IN, function(e) {
			getComponent("dataToSend").enabled = true;
			getComponent("sendButton").enabled = true;
			getComponent("data").enabled = true;

			var controller:Controller = new Controller(ComponentParser.fromXMLResource("ui/joinChannelPopup.xml"));
			var joinChannelPopup:Popup = Popup.showCustom(view.root, controller.view, "Join Channel", true);
			controller.attachEvent("cancelButton", MouseEvent.CLICK, function (e) {
				Popup.hidePopup(joinChannelPopup);
			});
			
			controller.attachEvent("joinButton", MouseEvent.CLICK, function (e) {
				var channel:String = controller.getComponent("channel").text;
				Popup.hidePopup(joinChannelPopup);
				
				connection.join(channel);
			});
		});
		
		connection.addEventListener(IRCEvent.JOINED_CHANNEL, function(e:IRCEvent) {
			var tabController:IRCChannelController = new IRCChannelController(connection, e.data);
			tabController.view.text = e.data;
			IRCController.mainTabs.addChild(tabController.view);
			IRCController.mainTabs.selectedIndex = IRCController.mainTabs.pageCount - 1;
		});
		
		connection.login(nickname);
	}
	
	private function onDataReceived(event:IRCEvent):Void {
		var list:ListView = getComponentAs("data", ListView);
		list.dataSource.add( { text: event.data } );
		list.vscrollPosition = list.vscrollMax;
	}
	
}