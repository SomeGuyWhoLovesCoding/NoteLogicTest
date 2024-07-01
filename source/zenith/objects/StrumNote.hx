package zenith.objects;

import flixel.math.FlxRect;
import flixel.math.FlxMath;
import flixel.math.FlxAngle;

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
	}

	inline public function _reset()
	{
		frames = Paths.strumNoteAnimationHolder.frames;
		animation.copyFrom(Paths.strumNoteAnimationHolder.animation);
		@:bypassAccessor angle = parent?.noteAngles[noteData];
		playAnim("static");
	}

	override function update(elapsed:Float)
	{
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

	override function draw()
	{
		super.draw();
		renderNotes();
	}

	function renderNotes()
	{
		if (notes.length == 0)
		{
			return;
		}

		for (i in 0...notes.length)
		{
			_note = notes[i];

			if (@:bypassAccessor !_note.exists)
				continue;

			if (PlayState.instance.songPosition - _note.position > 700.0 / PlayState.instance.songSpeed)
			{
				@:bypassAccessor _note.exists = false;
				_notePool.push(_note);
				continue;
			}

			_note.distance = 0.45 * (PlayState.instance.songPosition - _note.position) * PlayState.instance.songSpeed;

			@:bypassAccessor
			{
				_note.x = x + ((scrollMult < 0.0 ? -scrollMult : scrollMult) * _note.distance) * FlxMath.fastCos(FlxAngle.asRadians(_note.direction - 90.0));
				_note.y = y + (scrollMult * _note.distance) * FlxMath.fastSin(FlxAngle.asRadians(_note.direction - 90.0));
			}

			_note.draw();
		}
	}

	public function spawnNote(position:Single, sustainLength:Int = 0):NoteObject
	{
		var note:NoteObject = _notePool.pop() ?? (notes[notes.length] = new NoteObject(noteData, player, true));
		@:bypassAccessor note.exists = true;

		if (note.sustainLength >= 20 && !note.isSustain)
		{
			var note:NoteObject = _notePool.pop() ?? (notes[notes.length] = new NoteObject(noteData, player, true)).renew(true, position, sustainLength);
			@:bypassAccessor note.exists = true;
		}

		return note.renew(false, position, sustainLength);
	}

	public function handlePress()
	{
		if (notes.length == 0)
		{
			return;
		}

		// Trying to brainstorm a concept of the fastest note hitreg ever
		/*if (!_hittableNote.wasHit)
		{
			_hittableNote.hit();
			playAnim("confirm");
			_notePool.push(_hittableNote);
		}*/
	}

	public function handleRelease()
	{
		
	}
}
