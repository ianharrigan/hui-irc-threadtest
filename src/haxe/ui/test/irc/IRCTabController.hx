package haxe.ui.test.irc;

import flash.events.Event;
import flash.events.MouseEvent;
import haxe.ui.toolkit.containers.ListView;
import haxe.ui.toolkit.controls.popups.Popup;
import haxe.ui.toolkit.core.Component;
import haxe.ui.toolkit.core.Controller;
import haxe.ui.toolkit.core.PopupManager;
import haxe.ui.toolkit.core.XMLController;

class IRCTabController extends XMLController {
	private var connection:IRCConnection;
	
	public function new(connection:IRCConnection, nickname:String) {
		super("ui/ircTab.xml");
		
		this.connection = connection;
		connection.addEventListener(IRCEvent.DATA_RECEIVED, onDataReceived);

		var joiningPopup:Popup = null;
		attachEvent("joinChannelButton", MouseEvent.CLICK, function (e) {
			var controller:Controller = new XMLController("ui/joinChannelPopup.xml");
			var joinChannelPopup:Popup = PopupManager.instance.showCustom(controller.view, "Join Channel", PopupButton.CONFIRM | PopupButton.CANCEL, function(b) {
				if (b == PopupButton.CONFIRM) {
					var channel:String = controller.getComponent("channel").text;
					joiningPopup = PopupManager.instance.showBusy("Joining " + channel + "...");
					connection.join(channel);
				}
			});
		});
		
		connection.addEventListener(IRCEvent.JOINED_CHANNEL, function(e:IRCEvent) {
			PopupManager.instance.hidePopup(joiningPopup);
			var tabController:IRCChannelController = new IRCChannelController(connection, e.data);
			cast(tabController.view, Component).text = e.data;
			tabController.view.id = "ircChannel";
			IRCController.mainTabs.addChild(tabController.view);
			IRCController.mainTabs.selectedIndex = IRCController.mainTabs.pageCount - 1;
		});
	}
	
	private var showRawData:Bool = true;
	private function onDataReceived(event:IRCEvent):Void {
		#if android
			showRawData = true;
		#end
		if (showRawData == false) {
			return;
		}

		var list:ListView = getComponentAs("ircTabData", ListView);
		list.dataSource.add( { text: event.data } );
		list.vscrollPos = list.vscrollMax;
	}
	
}