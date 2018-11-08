package;

import kha.Scheduler;
import kha.System;

class Main {

	public static function main() {
		System.start({title: "InstancedExample", width: 800, height: 600}, function (_) {
			init();
		});
	}

	static function init() {
		var game = new InstancedExample();
		Scheduler.addTimeTask(game.update, 0, 1 / 60);
		System.notifyOnFrames(function (frames) { game.render(frames[0]); });
	}
}