package zenith.objects;

class NoteObject extends FlxSprite
{
	// The data that is set from the chart for every time a note spawns
	public var position:Float;
	public var sustainLength:Int;

	// For the sustain note
	public var isSustain:Bool;
	public var _clip:Float = 1.0;

	public var strum:StrumNote;

	public var distance:Float = 20.0;
	public var direction:Float;

	public var wasHit:Bool = false;

	inline function set_direction(dir:Float):Float
	{
		return @:bypassAccessor angle = isSustain ? (direction = dir) + (strum.scrollMult < 0.0 ? 180.0 : 0.0) : 0.0;
	}

	override function draw()
	{
		scale.x = strum.scale.x;
		scale.y = strum.scale.y;

		if (isSustain)
		{
			_frame.frame.y = -(sustainLength * _clip) * (((PlayState.instance.songSpeed ?? 1.0) * 0.6428571428571431) / (strum.scale.y * 1.428571428571429));
			_frame.frame.height = (-_frame.frame.y * (strum.scrollMult < 0.0 ? -strum.scrollMult : strum.scrollMult)) + frameHeight;
		}
		else
		{
			_frame.frame.y = 0.0;
			_frame.frame.height = frameHeight;
		}

		if (_frame.frame.height < 0.0)
			return;

		@:bypassAccessor height = _frame.frame.height * (scale.y < 0.0 ? -scale.y : scale.y);

		offset.x = offset.y = 0.0;
		origin.x = frameWidth >> 1;
		origin.y = isSustain ? 0.0 : frameHeight >> 1;

		super.draw();
	}

	public function new(noteData:UInt = 0, lane:UInt = 0, setUp:Bool = false)
	{
		super();
		@:bypassAccessor active = moves = false;

		if (!setUp)
			return;

		strum = PlayState.instance.strumlines[lane].members[noteData];
		color = strum.parent.noteColors[noteData];
		@:bypassAccessor angle = !isSustain ? strum.angle : 0.0;
	}

	inline public function renew(sustain:Bool, _position:Float, _sustainLength:Int):NoteObject
	{
		isSustain = sustain;
		wasHit = false;

		frames = !isSustain ? Paths.noteAnimationHolder.frames : Paths.sustainAnimationHolder.frames;
		animation.copyFrom(!isSustain ? Paths.noteAnimationHolder.animation : Paths.sustainAnimationHolder.animation);
		inline animation.play("preview");

		position = _position;
		sustainLength = _sustainLength;

		direction = 0.0;

		scale.set(strum.scale.x, strum.scale.y);

		return this;
	}

	override function update(elapsed:Float) {}

	// Does this really need to be inlined?
	// Yes.
	inline public function hit()
	{
		@:bypassAccessor exists = isSustain;
		wasHit = true;
	}
}