package zenith.objects;

@:access(zenith.Gameplay)
@:access(zenith.objects.StrumNote)
class Strumline extends FlxBasic
{
	public var keys(default, set):UInt;

	function set_keys(value:UInt):UInt
	{
		for (i in 0...value)
		{
			m = members[i];

			members[i] = m = new StrumNote(i, lane);
			m.scale.x = m.scale.y = scale;
			m.parent = this;
			m.index = i * lane;
			m._reset();
			@:bypassAccessor m.angle = noteAngles[m.noteData];

			m.index = i * lane;
		}

		if (value <= keys)
		{
			members.resize(value);
		}

		moveX(x);
		moveY(y);
		return keys = value;
	}

	public var lane:UInt = 0;
	public var player:Bool = false;
	public var downScroll:Bool = false;

	public var x(default, set):Float;

	function set_x(value:Float):Float
	{
		moveX(value);
		return x = value;
	}

	public var y(default, set):Float;

	function set_y(value:Float):Float
	{
		moveY(value);
		return y = value;
	}

	public var alpha(default, set):Float;

	function set_alpha(value:Float):Float
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

	public var gap(default, set):Float;

	function set_gap(value:Float):Float
	{
		if (members.length == 0)
			return gap;

		gap = value;
		moveX(x);

		return gap = value;
	}

	public var scale(default, set):Float;

	function set_scale(value:Float):Float
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

	public function new(keys:UInt = 4, lane:UInt = 0, playable:Bool = false)
	{
		super();

		this.lane = lane;
		this.keys = keys;
		gap = 112.0;
		scale = 1.0;
		this.playable = playable;

		// Default strumline positions
		x = (y = 60.0) + ((FlxG.width * 0.5587511111112) * lane);
	}

	public function reset():Strumline
	{
		keys = 4;
		gap = 112.0;
		scale = 1.0;

		// Default strumline positions
		x = (y = 60.0) + ((FlxG.width * 0.5587511111112) * lane);

		return this;
	}

	override function update(elapsed:Float) {}

	var m:StrumNote;

	override function draw()
	{
		if (members.length == 0)
			return;

		for (i in 0...members.length)
		{
			m = members[i];
			if (m.exists && m.visible && m.alpha != 0.0)
			{
				if (m.active)
					m.update(FlxG.elapsed);
				m.draw();
			}
		}
	}

	public function moveX(x:Float)
	{
		if (members.length == 0)
			return;

		for (i in 0...members.length)
		{
			@:bypassAccessor members[i].x = x + (gap * i);
		}
	}

	public function moveY(y:Float)
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
			@:bypassAccessor m.width = (m.scale.x < 0.0 ? -m.scale.x : m.scale.x) * m.frameWidth;
			@:bypassAccessor m.height = (m.scale.y < 0.0 ? -m.scale.y : m.scale.y) * m.frameHeight;
			m.offset.x = (m.frameWidth >> 1) - 54;
			m.offset.y = (m.frameHeight >> 1) - 56;
			m.origin.x = m.offset.x + 54;
			m.origin.y = m.offset.y + 56;
		}
	}

	public var singAnimations:Array<String> = ["singLEFT", "singDOWN", "singUP", "singRIGHT"];
	public var noteColors:Array<Int> = [0xFF9966BB, 0xFF00FFFF, 0xFF00FF00, 0xFFFF0000];
	public var noteAngles:Array<Float> = [0.0, -90.0, 90.0, 180.0];
}
