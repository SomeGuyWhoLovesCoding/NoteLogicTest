// Side note: please don't use @:bypassAccessor on angle for xml animations if you don't put animation.update(0) after it at the cost of a tiny overhead
package zenith.objects;

import flixel.math.FlxRect;
import flixel.math.FlxMath;
import flixel.math.FlxAngle;

@:access(zenith.objects.NoteObject)
class StrumNote extends FlxSprite
{
	public var noteData:UInt = 0;
	public var player:UInt = 0;
	public var scrollMult:Float = 1.0;
	public var playable(default, set):Bool = false;

	inline function set_playable(value:Bool):Bool
	{
		animation.finishCallback = value ? null : finishCallbackFunc;
		return playable = value;
	}

	var initial_width:Int = 0;
	var initial_height:Int = 0;

	public var parent:Strumline;
	public var index:UInt = 0;
	public var isIdle:Bool = true;

	public function new(data:UInt, plr:UInt)
	{
		super();

		noteData = data;
		player = plr;

		notes = [];
		_notePool = [];

		_hittableNote = Paths.idleNote;
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
		isIdle = !active;
		color = isIdle ? 0xffffffff : parent.noteColors[noteData];

		animation.play(anim, true);

		@:bypassAccessor width = (scale.x < 0.0 ? -scale.x : scale.x) * frameWidth;
		@:bypassAccessor height = (scale.y < 0.0 ? -scale.y : scale.y) * frameHeight;
		offset.x = (frameWidth >> 1) - 54.0;
		offset.y = (frameHeight >> 1) - 56.0;
		origin.x = offset.x + 54.0;
		origin.y = offset.y + 56.0;
	}

	override function set_clipRect(rect:FlxRect):FlxRect
	{
		if (clipRect != null)
		{
			clipRect.put();
		}

		return clipRect = rect;
	}

	function finishCallbackFunc(anim:String)
	{
		if (anim != "confirm" || playable)
			return;

		animation.play("static", true);

		@:bypassAccessor active = false;
		color = 0xffffffff;

		@:bypassAccessor width = (scale.x < 0.0 ? -scale.x : scale.x) * frameWidth;
		@:bypassAccessor height = (scale.y < 0.0 ? -scale.y : scale.y) * frameHeight;
		offset.x = (frameWidth >> 1) - 54;
		offset.y = (frameHeight >> 1) - 56;
		origin.x = offset.x + 54;
		origin.y = offset.y + 56;
	}

	// Note system
	public var notes:Array<NoteObject>;

	var _notePool(default, null):Array<NoteObject>;
	var _note(default, null):NoteObject;
	var _hittableNote(default, null):NoteObject; // The target note for the hitreg

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

				_note.draw();

				/**
				 * For some reason, a weird bug appears which is that you can still hit the note if it has missed and even if it's outside the hitbox
				 * So, please don't remove the second check in the if condition below this long comment. Istg (>X()
				 */
				if (_note.state == NoteState.IDLE)
				{
					if (!_note.isSustain)
					{
						if (!playable)
						{
							// This is so stupid but hey it works
							if (PlayState.instance.songPosition > _note.position)
							{
								_note.hit(this);
								playAnim("confirm");
							}
						}
						else
						{
							if (_hittableNote == Paths.idleNote
								&& !_note.isSustain
								&& _note.position - PlayState.instance.songPosition < 175.0
								|| (_hittableNote.state == NoteState.HIT
									|| _hittableNote.position > _note.position)) // Might implement a feature that consists of constantly targeting the closest note to the strumnote
							{
								_hittableNote = _note;
							}
						}

						if (_hittableNote != Paths.idleNote && PlayState.instance.songPosition - (_hittableNote.position + (_hittableNote.sustainLength << 5)) > 262.5 / PlayState.instance.songSpeed)
						{
							//trace("Note miss " + noteData);
							_hittableNote.state = NoteState.MISS;
							_hittableNote = Paths.idleNote;
						}
					}
					else
					{
						
					}
				}

				if (PlayState.instance.songPosition - (_note.position + (_note.sustainLength << 5)) > 350.0 / PlayState.instance.songSpeed)
				{
					@:bypassAccessor _note.exists = false;
					_notePool.push(_note);
					continue;
				}

				_note.distance = 0.45 * (PlayState.instance.songPosition - _note.position) * PlayState.instance.songSpeed;
				_note._updateNoteFrame(this);

				@:bypassAccessor
				{
					_note.x = x
						+ (!_note.isSustain ? 0.0 : initial_width - Std.int(_note.width) >> 1)
						+ ((scrollMult < 0.0 ? -scrollMult : scrollMult) * _note.distance) * FlxMath.fastCos(FlxAngle.asRadians(_note.direction - 90.0));
					_note.y = y
						+ (!_note.isSustain ? 0.0 : initial_height >> 1)
						+ (scrollMult * _note.distance) * FlxMath.fastSin(FlxAngle.asRadians(_note.direction - 90.0));
				}
			}
		}
	}

	inline public function spawnNote(position:Int, sustainLength:NoteState.UInt8 = 0)
	{
		var note:NoteObject = _notePool.pop() ?? (notes[notes.length] = new NoteObject(this));
		note.renew(false, position, sustainLength);
		note.angle = angle;
		@:bypassAccessor note.exists = true;

		if (note.sustainLength > 2 && !note.isSustain)
		{
			var note:NoteObject = _notePool.pop() ?? (notes[notes.length] = new NoteObject(this));
			note.renew(true, position, sustainLength);
			note.angle = 0.0;
			@:bypassAccessor note.exists = true;
		}
	}

	// Only 2 lines of code for the hitreg behaviour (not including the if condition)
	inline public function handlePress()
	{
		if (_hittableNote != Paths.idleNote)
		{
			_hittableNote.hit(this);
			_hittableNote = Paths.idleNote;
		}
	}

	public function handleRelease() {}
}
