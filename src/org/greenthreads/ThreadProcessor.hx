/**
   Copyright 2009 Charles E Hubbard

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
 */ 
   
package org.greenthreads;

import haxe.io.Error;
import nme.events.Event;
import nme.Lib;

class ThreadProcessor {
	private static var _instance:ThreadProcessor;
	private static var EPSILON:Int = 1;

	private var frameRate:Int;
	private var _share:Float;
	private var activeThreads:Array<GreenThread>;
	private var errorTerm:Int = 0;
	
	public var timerDelay(get_timerDelay, null):Float;
	public var share(get_share, set_share):Float;
	
	public function new(share:Float = 0.99) {
		if (_instance == null) {
			this.frameRate = 60;
			this.share = share;
			this.activeThreads = [];
			_instance = this;
		} else {
			trace("Error: Instantiation failed: Use ThreadProcessor.getInstance() instead of new.");
		}
	}

	public static function getInstance(share:Float = 0.99):ThreadProcessor {
		if (_instance == null) {
			_instance = new ThreadProcessor(share);
		}
		return _instance;
	}
	
	public function addThread(thread:GreenThread):GreenThread {
		if (activeThreads.length == 0) {
			start();
		}
		activeThreads.push(thread);
		return thread;
	}
	
	private function start():Void {
		Lib.current.addEventListener(Event.ENTER_FRAME, doCycle);
	}
	
	public function isRunning(thread:GreenThread):Bool {
		return Lambda.has(activeThreads, thread);
	}
	
	public function stop(thread:GreenThread):Void {
		var index:Int = Lambda.indexOf(activeThreads, thread);
		if (index >= 0) {
			activeThreads.splice(index, 1);
		}
		if (activeThreads.length == 0) {
			stopAll();
		}
	}
	
	public function stopAll():Void {
		activeThreads = []; 
		Lib.current.removeEventListener(Event.ENTER_FRAME, doCycle);
	}
	
	private function doCycle(event:Event):Void {
		var timeAllocation:Float = share < 1.0 ? timerDelay * share + 1 : frameRate - share;
		timeAllocation = Math.max(timeAllocation, EPSILON * activeThreads.length);

		//if the error term is too large, skip a cycle
		if(errorTerm > timeAllocation - 1) {
			errorTerm = 0;
			return;
		}
													
		var cycleStart:Int = Lib.getTimer();
		var cycleAllocation:Float = timeAllocation - errorTerm;
		var processAllocation:Float = cycleAllocation / activeThreads.length;                     
							
		//decrement for easy removal of processes from list
		//for( var i:int = activeThreads.length - 1; i > -1; i-- ) {
		var process:GreenThread = null;
		for (process in activeThreads) {
			//var process:GreenThread = cast(activeThreads[i], GreenThread);
			if( !process.execute( processAllocation ) ) {
				if( activeThreads.length >= 0 ) {
					//open up more allocation to remaining processes
					processAllocation = cycleAllocation / activeThreads.length;
				} else {
					break;
				}
			}
		}

		//solve for cycle time
		var cycleTime:Float = Lib.getTimer() - cycleStart;
		var delta:Int = Std.int(cycleTime - timeAllocation);

		//update the error term
		errorTerm = ( errorTerm + delta ) >> 1;
	}
				
	public function get_timerDelay():Float {
		return 1000 / frameRate;
	}
                
	public function get_share():Float {
		return _share;
	}

	public function set_share(percent:Float):Float {
		_share = percent;
		return percent;
	}
}