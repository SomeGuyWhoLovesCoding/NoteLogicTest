package zenith.objects;

@:access(zenith.objects.StrumNote)
class Strumline extends FlxBasic
{
	public var keys(default, set):Int;

	function set_keys(value:Int):Int
	{
		for (i in 0...value)
		{
			m = members[i];

			members[i] = m = new StrumNote(i, lane);
			@:bypassAccessor m.scale.x = m.scale.y = scale;
			m.parent = this;
			m.index = i * lane;
			m._reset();
		}

		if (value <= keys)
		{
			members.resize(value);
		}

		moveX(x);
		moveY(y);
		return keys = value;
	}

	public var lane:Int = 0;
	public var player:Bool = false;
	public var downScroll:Bool = false;

	public var x(default, set):Int;

	function set_x(value:Int):Int
	{
		moveX(value);
		return x = value;
	}

	public var y(default, set):Int;

	function set_y(value:Int):Int
	{
		moveY(value);
		return y = value;
	}

	public var alpha(default, set):Single;

	function set_alpha(value:Single):Single
	{
		if (members.length == 0)
			return alpha;

		for (i in 0...members.length)
		{
			members[i].alpha = value;
		}

		return alpha = value;
	}

	public var members:Array<StrumNote> = [];

	public var gap(default, set):Int;

	function set_gap(value:Int):Int
	{
		if (members.length == 0)
			return gap;

		gap = value;
		moveX(x);

		return gap = value;
	}

	public var scale(default, set):Single;

	function set_scale(value:Single):Single
	{
		if (members.length == 0)
			return scale;

		scale = value;

		for (i in 0...members.length)
		{
			members[i].scale.set(scale, scale);
		}

		moveX(x);

		return value;
	}

	public var playable(default, set):Bool;

	function set_playable(value:Bool):Bool
	{
		if (members.length == 0)
			return playable;

		for (i in 0...members.length)
		{
			members[i].playable = value;
		}

		return playable = value;
	}

	public function new(keys:Int = 4, lane:Int = 0, playable:Bool = false)
	{
		super();

		this.lane = lane;
		this.keys = keys;
		gap = 112;
		scale = 1;
		this.playable = playable;

		// Default strumline positions
		x = (y = 60) + (Std.int(FlxG.width * 0.5587511111112) * lane);
	}

	public function reset()
	{
		keys = 4;
		gap = 112;
		scale = 1;

		// Default strumline positions
		x = (y = 60) + (Std.int(FlxG.width * 0.5587511111112) * lane);
	}

	override function update(elapsed:Float)
	{
	}

	var m(default, null):StrumNote;

	override function draw()
	{
		if (members.length == 0)
			return;

		for (i in 0...members.length)
		{
			m = members[i];
			if (@:bypassAccessor m.exists && m.visible && m.alpha != 0)
			{
				if (m.active)
					m.update(FlxG.elapsed);
				m.draw();
			}
		}
	}

	public function moveX(x:Int)
	{
		if (members.length == 0)
			return;

		for (i in 0...members.length)
		{
			@:bypassAccessor members[i].x = x + (gap * i);
		}
	}

	public function moveY(y:Int)
	{
		if (members.length == 0)
			return;

		for (i in 0...members.length)
		{
			@:bypassAccessor members[i].y = y;
		}
	}

	public function clear()
	{
		while (members.length != 0)
		{
			members.pop().destroy();
		}
	}

	public function updateHitbox()
	{
		for (i in 0...members.length)
		{
			m = members[i];
			@:bypassAccessor
			{
				m.offset.x = (m.frameWidth >> 1) - 54;
				m.offset.y = (m.frameHeight >> 1) - 56;
				m.origin.x = m.offset.x + 54;
				m.origin.y = m.offset.y + 56;
			}
		}
	}

	public var singPrefix:String = "sing";
	public var singSuffix:String = "";
	public var singAnimations:Array<String> = ["LEFT", "DOWN", "UP", "RIGHT"];
	public var noteColors:Array<Int> = [0xFF9966BB, 0xFF00FFFF, 0xFF00FF00, 0xFFFF0000];
	public var noteAngles:Array<Int> = [0, -90, 90, 180];
}
