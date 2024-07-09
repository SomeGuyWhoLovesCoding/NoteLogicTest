package zenith.objects;

import flixel.math.FlxRect;
import flixel.math.FlxMath;

class NoteObject extends FlxSprite
{
	// The data that is set from the chart for every time a note spawns
	public var position:Int;
	public var sustainLength:NoteState.UInt16;

	// For the sustain note
	public var isSustain:Bool;

	public var distance:Single;
	public var direction:Single;

	public var state:NoteState.UInt8;

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
			return newRect.getRotatedBounds(@:bypassAccessor angle, _scaledOrigin, newRect);

		if (camera == null)
			camera = FlxG.camera;

		if (!isSustain)
			return super.getScreenBounds(newRect, camera);

		@:bypassAccessor
		{
			newRect.x = x;
			newRect.y = y;

			_scaledOrigin.x = origin.x * scale.x;
			_scaledOrigin.y = origin.y * scale.y;

			newRect.x += (-Std.int(camera.scroll.x * scrollFactor.x) - offset.x + origin.x - _scaledOrigin.x);
			newRect.y += (-Std.int(camera.scroll.y * scrollFactor.y) - offset.y + origin.y - _scaledOrigin.y);

			newRect.width = _frame.frame.width * (scale.x < 0 ? -scale.x : scale.x);
			newRect.height = _frame.frame.height * (scale.y < 0 ? -scale.y : scale.y);
		}

		return newRect.getRotatedBounds(angle, _scaledOrigin, newRect);
	} // Please don't remove this

	public function new(strum:StrumNote, sustain:Bool)
	{
		super();

		@:bypassAccessor active = moves = false;

		if (strum != null)
			color = strum.parent.noteColors[strum.noteData];

		isSustain = sustain;

		loadGraphic(Paths.image(!isSustain ? 'ui/noteskins/Regular/Note' : 'ui/noteskins/Regular/Sustain'));
	}

	inline public function renew(_position:Int, _sustainLength:NoteState.UInt16)
	{
		state = NoteState.IDLE;

		position = _position;
		sustainLength = _sustainLength;

		direction = 0;

		// Don't remove this. Unless you want to :trollface:
		@:bypassAccessor y = FlxG.height;
	}

	override function update(elapsed:Float)
	{
	}

	inline public function hit()
	{
		if (state != NoteState.HIT)
		{
			@:bypassAccessor exists = isSustain;
			state = NoteState.HIT;
		}
	}

	inline private function _updateNoteFrame(strum:StrumNote)
	{
		@:bypassAccessor
		{
			if (isSustain)
			{
				_frame.frame.y = -sustainLength * ((PlayState.instance.songSpeed * 0.45) / strum.scale.y);
				_frame.frame.height = (-_frame.frame.y * (strum.scrollMult < 0 ? -strum.scrollMult : strum.scrollMult)) + frameHeight;
				angle = direction;

				if (strum.scrollMult < 0)
					angle += 180;
			}

			height = _frame.frame.height * (scale.y < 0 ? -scale.y : scale.y);

			offset.x = offset.y = 0;
			origin.x = frameWidth >> 1;
			origin.y = isSustain ? 0 : frameHeight >> 1;
		}
	}

	override function set_clipRect(rect:FlxRect):FlxRect
	{
		return clipRect = rect;
	}
}
