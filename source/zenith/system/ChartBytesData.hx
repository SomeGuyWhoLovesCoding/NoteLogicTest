package zenith.system;

import sys.io.FileInput;
import sys.io.FileOutput;
import sys.io.File;

class ChartBytesData
{
	public var input:FileInput;

	var bytesTotal(default, null):Int = 1;

	public function new(songName:String)
	{
		if (sys.FileSystem.exists('assets/data/$songName.json'))
			saveChartFromJson(songName);

		input = File.read('assets/data/$songName.bin');

		var song_len = input.readByte();
		var song:String = input.readString(song_len);

		var speed = input.readDouble();
		var bpm = input.readDouble();

		var player1_len = input.readByte();
		var player1:String = input.readString(player1_len);

		var player2_len = input.readByte();
		var player2:String = input.readString(player2_len);

		var spectator_len = input.readByte();
		var spectator:String = input.readString(spectator_len);

		var stage_len = input.readByte();
		var stage:String = input.readString(stage_len);

		var steps = input.readByte();
		var beats = input.readByte();

		var needsVoices:Bool = input.readByte() == 1;
		var strumlines = input.readByte();

		// All of this is commented out because it's supposed to be a test project showcasing the third note system rewrite.
		/*
			Gameplay.SONG = new Song(song, {
				speed: speed,
				bpm: bpm,
				player1: player1,
				player2: player2,
				spectator: spectator,
				stage: stage,
				time_signature: [beats, steps],
				needsVoices: needsVoices,
				strumlines: strumlines
			});

			trace(Gameplay.SONG.song);
			trace(Gameplay.SONG.info.speed);
			trace(Gameplay.SONG.info.bpm);
			trace(Gameplay.SONG.info.player1);
			trace(Gameplay.SONG.info.player2);
			trace(Gameplay.SONG.info.spectator);
			trace(Gameplay.SONG.info.stage);
			trace(Gameplay.SONG.info.time_signature);
			trace(Gameplay.SONG.info.needsVoices);
			trace(Gameplay.SONG.info.strumlines);
		 */

		bytesTotal = sys.FileSystem.stat('assets/data/$songName.bin').size;

		_moveToNext();
	}

	// Chart note data (but with raw variables)
	// This is 8 bytes in size for each note
	// Proof: Int32 (4 bytes), UInt8 (1 byte), UInt16 (2 bytes), and UInt8 (1 byte again)
	var position(default, null):Int;
	var noteData(default, null):NoteState.UInt8;
	var length(default, null):NoteState.UInt16;
	var lane(default, null):NoteState.UInt8;

	public function update()
	{
		if (bytesTotal == 0)
			return;

		while (PlayState.instance.songPosition > position - (1880.0 / PlayState.instance.songSpeed))
		{
			PlayState.instance.strumlines[lane].members[noteData].spawnNote(position, length);

			if (input.tell() == bytesTotal)
			{
				input.close();
				bytesTotal = 0;
				break;
			}

			_moveToNext();
		}
	}

	inline function _moveToNext()
	{
		position = (inline input.readByte()) | (inline input.readByte() << 8) | (inline input.readByte() << 16) | (inline input.readByte() << 24);

		noteData = inline input.readByte();
		length = inline input.readByte() | (inline input.readByte() << 8);
		lane = inline input.readByte();
	}

	static public function saveChartFromJson(songName:String)
	{
		trace("Parsing json...");

		var json = haxe.Json.parse(File.getContent('assets/data/$songName.json'));

		trace('Done! Now let\'s start writing to "assets/data/$songName.bin".');

		var output:FileOutput = File.write('assets/data/$songName.bin');

		// Song
		inline output.writeByte(json.song.length);
		output.writeString(json.song);

		// Speed
		inline output.writeDouble(json.info.speed);

		// BPM
		inline output.writeDouble(json.info.bpm);

		// Player 1
		inline output.writeByte(json.info.player1.length);
		output.writeString(json.info.player1);

		// Player 2
		inline output.writeByte(json.info.player2.length);
		output.writeString(json.info.player2);

		// Spectator
		json.info.spectator = json.info.spectator ?? "gf";
		inline output.writeByte(json.info.spectator.length);
		output.writeString(json.info.spectator);

		// Stage
		json.info.stage = json.info.stage ?? "stage";
		inline output.writeByte(json.info.stage.length);
		output.writeString(json.info.stage);

		// Time signature (steps)
		inline output.writeByte(json.info.time_signature[0]);

		// Time signature (beats)
		inline output.writeByte(json.info.time_signature[1]);

		// Needs voices
		inline output.writeByte(json.info.needsVoices ? 1 : 0);

		// Strumline count
		inline output.writeByte(json.info.strumlines);

		var nd:Array<Array<Float>> = json.noteData; // Workaround for the dynamic iteration error
		for (note in nd)
		{
			// Basically writeInt32
			inline output.writeByte(Std.int(note[0]) & 0xFF);
			inline output.writeByte((Std.int(note[0]) >> 8) & 0xFF);
			inline output.writeByte((Std.int(note[0]) >> 16) & 0xFF);
			inline output.writeByte(Std.int(note[0]) >>> 24);

			inline output.writeByte(Std.int(note[1]));

			// Basically writeUInt16
			inline output.writeByte(Std.int(note[2]) & 0xFF);
			inline output.writeByte(Std.int(note[2]) >> 8);

			inline output.writeByte(Std.int(note[3]));
		}

		output.close(); // LMAO
	}

	static public function saveJsonFromChart(songName:String)
	{
		trace("Parsing chart...");

		var _input:FileInput = File.read('assets/data/$songName.bin');

		trace('Done! Now let\'s start writing to "assets/data/$songName.json".');

		var song_len = _input.readByte();
		var song:String = _input.readString(song_len);

		var speed = _input.readDouble();
		var bpm = _input.readDouble();

		var player1_len = _input.readByte();
		var player1:String = _input.readString(player1_len);

		var player2_len = _input.readByte();
		var player2:String = _input.readString(player2_len);

		var spectator_len = _input.readByte();
		var spectator:String = _input.readString(spectator_len);

		var stage_len = _input.readByte();
		var stage:String = _input.readString(stage_len);

		var steps = _input.readByte();
		var beats = _input.readByte();

		var needsVoices:Bool = _input.readByte() == 1;
		var strumlines = _input.readByte();

		var noteData:Array<Array<Float>> = [];

		while (true)
		{
			try
			{
				noteData.push([
					(inline _input.readByte()) | (inline _input.readByte() << 8) | (inline _input.readByte() << 16) | (inline _input.readByte() << 24), inline
					_input.readByte(),
					(inline _input.readByte()) | (inline _input.readByte() << 8), inline
					_input.readByte()
				]);
			}
			catch (e)
			{
				break;
			}
		}

		File.saveContent('assets/data/$songName.json',
			'{"song":"$song","info":{"stage":"$stage","player1":"$player1","player2":"$player2","spectator":"$spectator","speed":$speed,"bpm":$bpm,"time_signature":[$beats, $steps],"needsVoices":$needsVoices,"strumlines":$strumlines},"noteData":$noteData}');
	}
}
