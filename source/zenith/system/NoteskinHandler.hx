package zenith.system;

@:final
class NoteskinHandler
{
	static public var strumNoteAnimationHolder:FlxSprite = new FlxSprite();
	static public var idleNote:NoteObject;
	static public var idleStrumNote:StrumNote;

	static public function reload()
	{
		strumNoteAnimationHolder.frames = Paths.getSparrowAtlas('ui/noteskins/Regular/Strums');
		strumNoteAnimationHolder.animation.addByPrefix('static', 'static', 0, false);
		strumNoteAnimationHolder.animation.addByPrefix('pressed', 'press', 12, false);
		strumNoteAnimationHolder.animation.addByPrefix('confirm', 'confirm', 24, false);

		if (idleNote == null)
			idleNote = new NoteObject(false);

		if (idleStrumNote == null)
			idleStrumNote = new StrumNote();

		if (idleStrumNote.parent == null)
			idleStrumNote.parent = new Strumline();

		idleStrumNote._reset();

		idleNote.active = idleStrumNote.active = idleNote.visible = idleStrumNote.visible = false;
	}
}