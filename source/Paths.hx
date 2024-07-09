package;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;

using StringTools;

@:final
class Paths
{
	inline static public var ASSET_PATH:String = "assets";
	inline static public var SOUND_EXT:String = "ogg";

	static public function image(key:String)
	{
		var imagePath:String = '$ASSET_PATH/images/$key.png';

		if (sys.FileSystem.exists(imagePath))
		{
			return FlxGraphic.fromBitmapData(openfl.display.BitmapData.fromFile(imagePath), false, key);
		}

		trace("Image file \"" + imagePath + "\" doesn't exist.");

		return null;
	}

	static public function sound(key:String)
	{
		return '$ASSET_PATH/$key.$SOUND_EXT';
	}

	static public function font(key:String, ext:String = "ttf"):String
	{
		return '$ASSET_PATH/fonts/$key.$ext';
	}

	static public function inst(song:String)
	{
		return sound('data/${formatToSongPath(song)}/audio/inst');
	}

	static public function voices(song:String)
	{
		return sound('data/${formatToSongPath(song)}/audio/vocals');
	}

	static public function getSparrowAtlas(key:String):FlxAtlasFrames
	{
		return FlxAtlasFrames.fromSparrow(image(key), '$ASSET_PATH/images/$key.xml');
	}

	static public function formatToSongPath(path:String):String
	{
		return path.replace(' ', '-').toLowerCase();
	}

	// Weird stuff that belongs to the end. Used for making stuff hacky while allowing you to have your custom noteskin btw
	static public var strumNoteAnimationHolder:FlxSprite = new FlxSprite();
	static public var idleNote:NoteObject;
	static public var idleStrumNote:StrumNote;

	static public function initNoteShit()
	{
		strumNoteAnimationHolder.frames = getSparrowAtlas('ui/noteskins/Regular/Strums');
		strumNoteAnimationHolder.animation.addByPrefix('static', 'static', 0, false);
		strumNoteAnimationHolder.animation.addByPrefix('pressed', 'press', 12, false);
		strumNoteAnimationHolder.animation.addByPrefix('confirm', 'confirm', 24, false);

		if (idleNote == null)
			idleNote = new NoteObject(null, false);

		if (idleStrumNote == null)
			idleStrumNote = new StrumNote();

		if (idleStrumNote.parent == null)
			idleStrumNote.parent = new Strumline();

		idleStrumNote._reset();

		idleNote.active = idleStrumNote.active = idleNote.visible = idleStrumNote.visible = false;
	}
}
