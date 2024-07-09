package zenith.objects;

import flixel.math.FlxRect;
import flixel.math.FlxMath;
import flixel.math.FlxAngle;

@:access(zenith.objects.NoteObject)
@:access(flixel.FlxCamera)
class StrumNote extends FlxSprite
{
	public var noteData:NoteState.UInt8;
	public var player:NoteState.UInt8;
	public var scrollMult:Single = 1.0;
	public var playable(default, set):Bool;

	inline function set_playable(value:Bool):Bool
	{
		animation.finishCallback = value ? null : finishCallbackFunc;
		return playable = value;
	}

	var initial_width:NoteState.UInt8;
	var initial_height:NoteState.UInt8;
	var _holding:Bool;

	public var parent:Strumline;
	public var index:NoteState.UInt8;

	public function new(data:NoteState.UInt8 = 0, plr:NoteState.UInt8 = 0)
	{
		super();

		noteData = data;
		player = plr;

		_hittableNote = Paths.idleNote;

		@:bypassAccessor moves = false;
	}

	inline public function _reset()
	{
		@:bypassAccessor angle = parent.noteAngles[noteData];
		frames = Paths.strumNoteAnimationHolder.frames;
		animation.copyFrom(Paths.strumNoteAnimationHolder.animation);
		playAnim("static");

		// Note: frameWidth and frameHeight only works for this lmao
		initial_width = frameWidth;
		initial_height = frameHeight;
	}

	override function update(elapsed:Float)
	{
		if (@:bypassAccessor active)
			animation.update(elapsed);
	}

	inline public function playAnim(anim:String)
	{
		@:bypassAccessor active = anim != "static";
		color = !active ? 0xffffffff : parent.noteColors[noteData];

		animation.play(anim, true);

		@:bypassAccessor
		{
			offset.x = (frameWidth >> 1) - 54;
			offset.y = (frameHeight >> 1) - 56;
			origin.x = offset.x + 54;
			origin.y = offset.y + 56;
		}
	}

	override function set_clipRect(rect:FlxRect):FlxRect
	{
		return clipRect = rect;
	}

	// Please don't mess with this function.
	inline function finishCallbackFunc(anim:String = "")
	{
		if (!playable && @:bypassAccessor active)
		{
			@:bypassAccessor active = false;
			color = 0xffffffff;

			animation.play("static", true);

			@:bypassAccessor
			{
				offset.x = (frameWidth >> 1) - 54;
				offset.y = (frameHeight >> 1) - 56;
				origin.x = offset.x + 54;
				origin.y = offset.y + 56;
			}
		}
	}

	/*
	 * //! The note system.
	 * //? Explanation: This is organized so that the note members are based on
	 * strumnotes instead of a single array in the note system class.
	 * Doing said method allows for the note system to be much faster
	 * since the group is split to [number of members in the parent strumline] parts,
	 * and you can basically skip array access when you get the hittable note which
	 * allows for much faster inputs under the hood.
	 * Also, the note object class is meant to be small as possible, so there are
	 * only 6 variables in there (excluding the inherited classes).
	 * //? Behavior
	 * It's very simple but it was almost complicated to make.
	 * Basically, it has a target note variable named _hittableNote, which tracks the closest note to the strumnote.
	 * It's currently unfinished but most of it is polished.
	 */
	public var notes:Array<NoteObject> = [];
	public var sustains:Array<NoteObject> = [];

	var _notePool(default, null):Array<NoteObject> = [];
	var _susPool(default, null):Array<NoteObject> = [];
	var _note(default, null):NoteObject;
	var _hittableNote(default, null):NoteObject; // The target note for the hitreg

	override function draw()
	{
		final oldDefaultCameras = FlxCamera._defaultCameras;
		if (_cameras != null)
		{
			FlxCamera._defaultCameras = _cameras;
		}

		renderSustains();
		super.draw();
		renderNotes();

		FlxCamera._defaultCameras = oldDefaultCameras;
	}

	override function destroy()
	{
		super.destroy();

		for (i in 0...notes.length)
		{
			notes[i].destroy();
		}

		for (i in 0...sustains.length)
		{
			sustains[i].destroy();
		}
	}

	function renderSustains()
	{
		if (sustains.length != 0)
		{
			for (i in 0...sustains.length)
			{
				_note = sustains[i];

				if (@:bypassAccessor !_note.exists)
					continue;

				if (PlayState.instance.songPosition - _note.position > _note.sustainLength + (500 / PlayState.instance.songSpeed))
				{
					@:bypassAccessor _note.exists = false;
					_susPool.push(_note);
					continue;
				}

				if (@:bypassAccessor _note.visible && _note.alpha != 0)
					_note.draw();

				if (_note.state == NoteState.IDLE)
				{
					// Literally the sustain logic system

					_holding = @:bypassAccessor animation.curAnim.name == "confirm"
						&& PlayState.instance.songPosition > _note.position
						&& PlayState.instance.songPosition < _note.position + (_note.sustainLength - 50);

					if (_holding)
					{
						playAnim("confirm");
					}
				}

				_note.distance = 0.45 * (PlayState.instance.songPosition - _note.position) * PlayState.instance.songSpeed;
				_note._updateNoteFrame(this);

				@:bypassAccessor
				{
					_note.x = x
						+ (!_note.isSustain ? 0 : initial_width - Std.int(_note.width) >> 1)
						+ ((scrollMult < 0 ? -scrollMult : scrollMult) * _note.distance) * FlxMath.fastCos(FlxAngle.asRadians(_note.direction - 90));
					_note.y = y
						+ (!_note.isSustain ? 0 : initial_height >> 1)
						+ (scrollMult * _note.distance) * FlxMath.fastSin(FlxAngle.asRadians(_note.direction - 90));
				}
			}
		}
	}

	function renderNotes()
	{
		if (notes.length != 0)
		{
			for (i in 0...notes.length)
			{
				_note = notes[i];

				if (@:bypassAccessor !_note.exists)
					continue;

				if (PlayState.instance.songPosition - _note.position > _note.sustainLength + (500 / PlayState.instance.songSpeed))
				{
					@:bypassAccessor _note.exists = false;
					_notePool.push(_note);
					continue;
				}

				if (@:bypassAccessor _note.visible && _note.alpha != 0)
					_note.draw();

				if (_note.state == NoteState.IDLE)
				{
					if (!playable)
					{
						if (PlayState.instance.songPosition > _note.position)
						{
							_note.hit();
							playAnim("confirm");
						}
					}

					if ((_hittableNote == Paths.idleNote && _note.position - PlayState.instance.songPosition < (250 / PlayState.instance.songSpeed))
						|| (_hittableNote.state == NoteState.HIT || _hittableNote.position > _note.position))
						// TODO: Implement a center target feature for the target note (basically targeting the closest note to the strumnote constantly)
					{
						_hittableNote = _note;
					}

					if (_hittableNote != Paths.idleNote && PlayState.instance.songPosition - _hittableNote.position > (250 / PlayState.instance.songSpeed))
					{
						_hittableNote.state = NoteState.MISS;
						_hittableNote = Paths.idleNote;
					}
				}

				_note.distance = 0.45 * (PlayState.instance.songPosition - _note.position) * PlayState.instance.songSpeed;
				_note._updateNoteFrame(this);

				@:bypassAccessor
				{
					_note.x = x
						+ (!_note.isSustain ? 0 : initial_width - Std.int(_note.width) >> 1)
						+ ((scrollMult < 0 ? -scrollMult : scrollMult) * _note.distance) * FlxMath.fastCos(FlxAngle.asRadians(_note.direction - 90));
					_note.y = y
						+ (!_note.isSustain ? 0 : initial_height >> 1)
						+ (scrollMult * _note.distance) * FlxMath.fastSin(FlxAngle.asRadians(_note.direction - 90));
				}
			}
		}
	}

	inline public function spawnNote(position:Int, sustainLength:NoteState.UInt16)
	{
		var note:NoteObject = _notePool.pop();

		if (note == null)
		{
			note = new NoteObject(this, false);
			notes.push(note);
		}

		note.renew(position, 0);
		note.angle = angle;
		@:bypassAccessor note.exists = true;

		if (sustainLength > 20 && !note.isSustain)
		{
			var sustain:NoteObject = _susPool.pop();

			if (sustain == null)
			{
				sustain = new NoteObject(this, true);
				sustains.push(sustain);
			}

			sustain.renew(position, sustainLength);
			sustain.angle = 0;
			@:bypassAccessor sustain.exists = true;
		}
	}

	// The rest of the input stuff

	inline public function handlePress()
	{
		playAnim("pressed");
		if (_hittableNote != Paths.idleNote)
		{
			_hittableNote.hit();
			_hittableNote = Paths.idleNote;
			playAnim("confirm");
		}
	}

	inline public function handleRelease()
	{
		playAnim("static");

		if (_holding)
		{
			trace('Sustain miss $noteData');
			_holding = false;
		}
	}
}
