package zenith.objects;

import flixel.math.FlxRect;
import flixel.math.FlxMath;

class NoteObject extends FlxSprite
{
	// The data that is set from the chart for every time a note spawns
	public var position:Float;
	public var sustainLength:Int;

	// For the sustain note
	public var isSustain:Bool;

	public var distance:Float = 20.0;
	public var direction:Float;

	public var wasHit:Bool = false;
	public var missed:Bool = false;

	// Random internals for when I removed the ``strum`` variable to save space on this class (Will remove)
	var _scrollMult:Float = 1.0;
	var strum_scale_y:Float = 1.0;

	/**
	 * Calculates the smallest globally aligned bounding box that encompasses this sprite's graphic as it
	 * would be displayed. Honors scrollFactor, rotation, scale, offset and origin.
	 * @param newRect Optional output `FlxRect`, if `null`, a new one is created.
	 * @param camera  Optional camera used for scrollFactor, if null `FlxG.camera` is used.
	 * @return A globally aligned `FlxRect` that fully contains the input sprite.
	 * @since 4.11.0
	 */
	override public function getScreenBounds(?newRect:FlxRect, ?camera:FlxCamera)
	{
		if (newRect == null)
			newRect = FlxRect.get();

		if (_frame == null)
			return newRect.getRotatedBounds(angle, _scaledOrigin, newRect);

		if (camera == null)
			camera = FlxG.camera;

		if (!isSustain)
			return super.getScreenBounds(newRect, camera);

		newRect.x = x;
		newRect.y = y;

		_scaledOrigin.x = origin.x * scale.x;
		_scaledOrigin.y = origin.y * scale.y;

		newRect.x += (-Std.int(camera.scroll.x * scrollFactor.x) - offset.x + origin.x - _scaledOrigin.x);
		newRect.y += (-Std.int(camera.scroll.y * scrollFactor.y) - offset.y + origin.y - _scaledOrigin.y);

		newRect.width = _frame.frame.width * (scale.x < 0.0 ? -scale.x : scale.x);
		newRect.height = _frame.frame.height * (scale.y < 0.0 ? -scale.y : scale.y);

		return newRect.getRotatedBounds(angle, _scaledOrigin, newRect);
	} // Please don't remove this

	public function new(strum:StrumNote = null)
	{
		super();

		@:bypassAccessor active = moves = false;

		if (strum == null)
		{
			return;
		}

		color = strum.parent.noteColors[strum.noteData];
	}

	inline public function renew(sustain:Bool, _position:Float, _sustainLength:Int)
	{
		isSustain = sustain;
		wasHit = missed = false;

		frames = !isSustain ? Paths.noteAnimationHolder.frames : Paths.sustainAnimationHolder.frames;
		animation.copyFrom(!isSustain ? Paths.noteAnimationHolder.animation : Paths.sustainAnimationHolder.animation);
		inline animation.play("preview");

		position = _position;
		sustainLength = _sustainLength;

		direction = 0.0;

		// Don't remove this. Unless you want to :trollface:
		@:bypassAccessor y = FlxG.height;
	}

	override function update(elapsed:Float) {}

	// Does this really need to be inlined?
	// Yes.
	inline public function hit(strum:StrumNote)
	{
		@:bypassAccessor exists = isSustain;
		strum.playAnim("confirm");
		wasHit = !isSustain || PlayState.instance.songPosition + (frameHeight << 1) > position + sustainLength;
	}

	inline function _updateNoteFrame(strum:StrumNote)
	{
		_frame.frame.y = 0.0;
		_frame.frame.height = frameHeight;

		if (isSustain)
		{
			_frame.frame.y = -sustainLength * ((PlayState.instance.songSpeed * 0.45) / strum.scale.y);
			_frame.frame.height = (-_frame.frame.y * (strum.scrollMult < 0.0 ? -strum.scrollMult : strum.scrollMult)) + frameHeight;
			angle = direction;

			if (strum.scrollMult < 0.0)
				angle += 180;
		}

		@:bypassAccessor height = _frame.frame.height * (scale.y < 0.0 ? -scale.y : scale.y);

		offset.x = offset.y = 0.0;
		origin.x = frameWidth >> 1;
		origin.y = isSustain ? 0.0 : frameHeight >> 1;
	}
}