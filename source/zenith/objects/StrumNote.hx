package zenith.objects;

import flixel.math.FlxRect;
import flixel.math.FlxMath;
import flixel.math.FlxAngle;

@:access(zenith.objects.NoteObject)
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

	public var parent:Strumline;
	public var index:NoteState.UInt8;

	public function new(data:NoteState.UInt8 = 0, plr:NoteState.UInt8 = 0)
	{
		super();

		noteData = data;
		player = plr;

		_hittableNote = Paths.idleNote;
		_hittableSustain = Paths.idleNote;
	}

	inline public function _reset()
	{
		frames = Paths.strumNoteAnimationHolder.frames;
		animation.copyFrom(Paths.strumNoteAnimationHolder.animation);
		@:bypassAccessor angle = parent.noteAngles[noteData];
		playAnim("static");

		// Note: frameWidth and frameHeight only works for this lmao
		initial_width = frameWidth;
		initial_height = frameHeight;
	}

	override function update(elapsed:Float)
	{
		if (active)
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
		if (!playable && active)
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
	// TODO: Implement the sustain logic
	public var notes:Array<NoteObject> = [];

	var _notePool(default, null):Array<NoteObject> = [];
	var _note(default, null):NoteObject;
	var _hittableNote(default, null):NoteObject; // The target note for the hitreg
	var _hittableSustain(default, null):NoteObject; // The target sustain note

	override function draw()
	{
		super.draw();
		renderNotes();
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

				if (PlayState.instance.songPosition - _note.position > _note.sustainLength + 300)
				{
					@:bypassAccessor _note.exists = false;
					_notePool.push(_note);
					continue;
				}

				_note.draw();

				if (_note.state == NoteState.IDLE)
				{
					if (!_note.isSustain)
					{
						if (!playable)
						{
							if (PlayState.instance.songPosition > _note.position)
							{
								_note.hit();
								playAnim("confirm");
							}
						}

						if ((_hittableNote == Paths.idleNote && _note.position - PlayState.instance.songPosition < 150)
							|| (_hittableNote.state == NoteState.HIT || _hittableNote.position > _note.position))
							// TODO: Implement a center target feature for the target note (basically targeting the closest note to the strumnote constantly)
						{
							_hittableNote = _note;
						}

						if (_hittableNote != Paths.idleNote && PlayState.instance.songPosition - _hittableNote.position > 200)
						{
							_hittableNote.state = NoteState.MISS;
							_hittableNote = Paths.idleNote;
						}
					}
					else
					{
						// Literally the sustain logic system

						if (animation.curAnim.name == "confirm"
							&& PlayState.instance.songPosition > _note.position
							&& PlayState.instance.songPosition < _note.position + (_note.sustainLength - 50))
						{
							playAnim("confirm");
						}
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

	inline public function spawnNote(position:Int, sustainLength:NoteState.UInt16 = 0)
	{
		var note:NoteObject = _notePool.pop() ?? (notes[notes.length] = new NoteObject(this));
		note.renew(false, position);
		note.angle = angle;
		@:bypassAccessor note.exists = true;

		if (sustainLength > 20 && !note.isSustain)
		{
			var note:NoteObject = _notePool.pop() ?? (notes[notes.length] = new NoteObject(this));
			note.renew(true, position, sustainLength);
			note.angle = 0;
			@:bypassAccessor note.exists = true;
		}
	}

	// Only 2 lines of code for the hitreg behaviour (not including the if condition)
	inline public function handlePress()
	{
		if (_hittableNote != Paths.idleNote)
		{
			_hittableNote.hit();
			_hittableNote = Paths.idleNote;
			playAnim("confirm");
		}
	}
}
