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

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.ProgressEvent;
import flash.Lib;

class GreenThread extends EventDispatcher {
	private var _debug:Bool;
	private var _statistics:ThreadStatistics;
	
	public var debug(get, set):Bool;
	public var statistics(get, null):ThreadStatistics;
	
	public function new(debug:Bool = false) {
		super();
		_debug = debug;
	}
	
	public function start(share:Float = 0.99 ):Void {
		ThreadProcessor.getInstance(share).addThread( this );
		if( debug ) {
			_statistics = new ThreadStatistics();
		}
		initialize();		
	}
	
	public function stop():Void {
		ThreadProcessor.getInstance().stop( this );
	}
	
	private function initialize():Void {
	}	
	
	private function run():Bool {
		return false;
	}
	
	public function isRunning():Bool {
		return ThreadProcessor.getInstance().isRunning( this );
	}
	
	public function execute(processAllocation:Float):Bool {
		if( debug ) statistics.startCycle();

		var loop : Bool = true;
		try {
			var processStart:Int = Lib.getTimer();

			while( Lib.getTimer() - processStart < processAllocation && loop ) {
				loop = run();
			} 
		} catch( error:Dynamic ) {
			if( debug ) statistics.recordTimeout();
			dispatchEvent( new ThreadEvent( ThreadEvent.TIMEOUT ) );
		}
		//record post process time
		if( debug ) statistics.endCycle( processAllocation );

		if( !loop ) {
			dispatchProgress();
			dispatchEvent( new Event( Event.COMPLETE ) );
			//do any cleanup
			stop();
			return false;
		} else {
			dispatchProgress();
		}
		return true;
	}
	
	private function dispatchProgress():Void {
	}
	
	public function get_debug():Bool {
		return _debug;
	}

	public function set_debug(value:Bool):Bool {
		_debug = value;
		return value;
	}

	public function get_statistics():ThreadStatistics {
		if (_statistics == null) {
			_statistics = new ThreadStatistics();
		}
		return _statistics;
	}	
	
	
}