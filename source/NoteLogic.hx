package;

class NoteLogic extends FlxBasic
{
	public var _pool:Array<NoteObject>;
	public var members:Array<NoteObject>;
	public var strumlines:Array<Strumline>;

	public function new():Void
	{
		super();

		_pool = [];
		members = [];
		strumlines = [];

		active = false;
	}

	override function update(elapsed:Float) {}

	var note(default, null):NoteObject;
	override function draw():Void
	{
		for (i in 0...members.length)
		{
			note = members[i];

			note.draw();
		}

		renderStrumlines();
	}

	function renderStrumlines():Void
	{
		for (i in 0...strumlines.length)
			strumlines[i].draw();
	}

	public function spawn(position:Single, noteData:Int, sustainLength:Int, lane:Int):NoteObject
	{
		trace(position, noteData, sustainLength, lane);
		var note:NoteObject = _pool.pop() ?? (members[members.length] = new NoteObject());
		note.exists = true;
		return note.renew(false, position, noteData, sustainLength, lane);
	}
}