package;

import flixel.animation.FlxAnimationController;
import flixel.animation.FlxAnimation;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.display.BitmapData;
import openfl.media.Sound;

using StringTools;

@:access(flixel.animation.FlxAnimationController)
@:final
class Paths
{
	inline static public var ASSET_PATH:String = "assets";
	inline static public var SOUND_EXT:String = "ogg";

	static public function image(key:String):BitmapData
	{
		var imagePath:String = '$ASSET_PATH/images/$key.png';

		if (sys.FileSystem.exists(imagePath))
		{
			var bitmapData:BitmapData = FlxG.bitmap.add(imagePath).bitmap;
			return bitmapData;
		}

		trace("Image file \"" + imagePath + "\" doesn't exist.");

		return null;
	}

	static private var soundCache:Map<String, Sound> = new Map<String, Sound>();

	static public function sound(key:String):Sound
	{
		var soundPath:String = '$ASSET_PATH/$key.$SOUND_EXT';

		if (sys.FileSystem.exists(soundPath))
		{
			if (!soundCache.exists(soundPath))
			{
				var sound:Sound = Sound.fromFile(soundPath);
				soundCache.set(soundPath, sound);
			}

			return soundCache.get(soundPath);
		}

		trace('Sound file "$soundPath" doesn\'t exist.');

		return null;
	}

	static public function font(key:String, ext:String = "ttf"):String
	{
		return '$ASSET_PATH/fonts/$key.$ext';
	}

	static public function inst(song:String):Sound
	{
		return sound('data/${formatToSongPath(song)}/audio/inst');
	}

	static public function voices(song:String):Sound
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
	static public var noteAnimationHolder:FlxSprite = new FlxSprite();
	static public var sustainAnimationHolder:FlxSprite = new FlxSprite();

	static public var idleNote:NoteObject;
	static public var idleStrumNote:StrumNote;
	static public var idleStrumline:Strumline;

	static public function initNoteShit()
	{
		strumNoteAnimationHolder.frames = getSparrowAtlas('ui/noteskins/Regular/Strums');
		strumNoteAnimationHolder.animation.addByPrefix('static', 'static', 0, false);
		strumNoteAnimationHolder.animation.addByPrefix('pressed', 'press', 12, false);
		strumNoteAnimationHolder.animation.addByPrefix('confirm', 'confirm', 24, false);

		noteAnimationHolder.frames = getSparrowAtlas('ui/noteskins/Regular/Note');
		noteAnimationHolder.animation.addByPrefix('preview', 'preview', 0, false);

		sustainAnimationHolder.frames = getSparrowAtlas('ui/noteskins/Regular/Sustain');
		sustainAnimationHolder.animation.addByPrefix('preview', 'preview', 0, false);

		idleNote = idleNote ?? new NoteObject();
		idleStrumNote = idleStrumNote ?? new StrumNote(0, 0);
		idleStrumline = idleStrumline ?? new Strumline(4, 0);

		idleStrumNote.parent = idleStrumline;
		idleStrumNote._reset();

		idleNote.strum = idleStrumNote;
		idleNote.active = idleStrumNote.active = idleNote.visible = idleStrumNote.visible = false;
	}
}
