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

import flash.Lib;

class ThreadStatistics {
	public var numCycles:Int = 0;
	public var numTimeouts:Int = 0;

	public var totalTime:Float = 0;

	public var times:Array<Float>;
	public var allocationDifferentials:Array<Float>;

	public var meanTime(get, null):Float;
	public var averageDifferential(get, null):Float;
	public var maxTime(get, null):Float;
	public var minTime(get, null):Float;
	
	private var currentCycleStart:Int;
				
	public function new() {
		times = [];
		allocationDifferentials = [];
	}

	public function startCycle():Void {
		currentCycleStart = Lib.getTimer();
	}
	
	public function endCycle(allocation:Float):Void {
		var time:Float = Lib.getTimer() - currentCycleStart;

		totalTime += time;

		times[numCycles] = time;
		allocationDifferentials[numCycles] = time - allocation;

		numCycles++;
	}
	
	public function recordTimeout():Void {
		numTimeouts++;
	}
	
	public function get_meanTime():Float {
		return totalTime / numCycles; 
	}
	
	public function get_averageDifferential():Float {
		var sum:Float = 0;

		for (differential in allocationDifferentials) {
			sum += differential;
		}

		return sum / numCycles;		
	}
	
	public function get_maxTime():Float {
		var max:Float = 0;

		for (time in times) {
			max = Math.max( max, time );
		}

		return max;		
	}
	
	public function get_minTime():Float {
		var min:Float = Math.POSITIVE_INFINITY;

		for (time in times) {
			min = Math.min( min, time );
		}

		return min;
	}
	
	public function toString():String {
		return "Total Time: " + totalTime + "(ms)" + 
			"\nNumber Of Cycles: " + numCycles + 
			"\nMean time per cycle: " + this.meanTime + "(ms)" +
			"\nMinimum Time, Maximum Time " + this.minTime + "(ms), " + this.maxTime + " (ms)" +
			"\nAverage Differential: " + this.averageDifferential + "(ms)" +
			"\nAverage Allocation Diff: " + this.allocationDifferentials + "(ms)" +
			"\nNumber Of Timeouts: " + numTimeouts;   
	}
}