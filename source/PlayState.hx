package;

import flixel.FlxState;
import lime.app.Application;

class PlayState extends FlxState
{
	private var chartBytesData:ChartBytesData;

	public var strumlines:Array<Strumline> = [];
	public var songSpeed:Float = 3;
	public var songPosition:Float = 0.0;

	static public var instance:PlayState;

	override public function create()
	{
		FlxG.fixedTimestep = false;

		Paths.initNoteShit();

		instance = this;

		chartBytesData = new ChartBytesData('normal');

		// FlxG.cameras.bgColor = 0xFF999999;
		FlxG.camera.bgColor.alpha = 0;

		for (player in 0...2)
			strumlines.push(new Strumline(4, player, player == 1));

		// Pretend that this is Utils.strumlineChangeDownScroll but extracted

		for (strum in strumlines)
		{
			for (i in 0...strum.members.length)
				strum.members[i].scrollMult = -1.0;

			strum.downScroll = true;
			strum.y = FlxG.height - 160.0;
		}

		resetKeybinds([[0x61, 1073741904], [0x73, 1073741905], [0x77, 1073741906], [0x64, 1073741903]]);

		super.create();

		Application.current.window.onKeyDown.add(onKeyDown);
		Application.current.window.onKeyUp.add(onKeyUp);

		openfl.system.System.gc();
	}

	override public function destroy()
	{
		Application.current.window.onKeyDown.remove(onKeyDown);
		Application.current.window.onKeyUp.remove(onKeyUp);
	}

	var inputKeybinds:Array<StrumNote> = [];

	public function resetKeybinds(?customBinds:Array<Array<Int>>):Void
	{
		final playerStrum = strumlines[1]; // Prevent redundant array access
		final binds = customBinds;

		inputKeybinds.resize(0);

		for (i in 0...1024)
		{
			inputKeybinds.push(Paths.idleStrumNote);
		}

		for (i in 0...binds.length)
		{
			for (j in 0...binds[i].length)
			{
				inputKeybinds[binds[i][j] % 1024] = playerStrum.members[i];
			}
		}
	}

	var st(default, null):StrumNote;

	inline function onKeyDown(keyCode:Int, keyMod:Int):Void
	{
		st = inputKeybinds[keyCode % 1024] ?? Paths.idleStrumNote;

		if (!st.active)
		{
			st.playAnim("pressed");
			st.handlePress();
		}
	}

	inline function onKeyUp(keyCode:Int, keyMod:Int):Void
	{
		st = inputKeybinds[keyCode % 1024] ?? Paths.idleStrumNote;

		if (st.active)
		{
			st.playAnim("static");
			st.handleRelease();
		}
	}

	var _songPos(default, null):Single = 0.0;

	override public function update(elapsed:Float)
	{
		songPosition += elapsed * 1000.0;
		chartBytesData.update();

		/*if (songPosition + 700.0 > _songPos)
			strumlines[1].members[FlxG.random.int(0, 3)].spawnNote(Std.int(_songPos += 120.0)); */

		super.update(elapsed);
	}

	override function draw():Void
	{
		super.draw();

		for (i in 0...strumlines.length)
		{
			strumlines[i].draw();
		}
	}
}
