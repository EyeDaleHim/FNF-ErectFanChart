package;

import flixel.FlxG;
import flixel.math.FlxMath;

class ScoreFunctions
{
	public function new()
	{
		throw 'Cannot be instantiated';
	}

	public static function calculateNote(ratings:String, factor:Float = 0):Int
	{
		var practiceMode:Bool = false;

		// your score will be subtracted by the hit window of the note
		var newScore:Float = 0;
		var roundedScore:Int = 0;

		switch (ratings)
		{
			// this was made higher because your rating score gets subtracted by the factor
			case 'sick':
				newScore = 450;
			case 'good':
				newScore = 450 * 0.75;
			case 'bad':
				newScore = 450 * 0.50;
			case 'shit':
				newScore = 450 * 0.2;
			default:
				// its a bad idea to add misses because its WAYYYY over the safe time zone.
				newScore = 0;
		}
		if (factor < 0)
		{
			factor = -factor;
		}
		newScore = (newScore - factor);
		roundedScore = Math.floor(newScore);
		// always subtract by 25 if rating is miss
		if (ratings == 'miss')
			roundedScore = 25;
		if (practiceMode)
			roundedScore = 0;
		return roundedScore;
	}

	public inline static function calculateHeld(ratings:String, factor:Float):Int
	{
		// your score will be subtracted by the hit window of the note
		var newScore:Float = 0;
		var roundedScore:Int = 0;

		switch (ratings)
		{
			// this was made higher because your rating score gets subtracted by the factor
			case 'sick':
				newScore = 450 * 0.55;
			case 'good':
				newScore = 450 * 0.55;
			// idc if you get minus score cuz fuck you
			case 'bad':
				newScore = 450 * 0.55;
			case 'shit':
				newScore = 450 * 0.55;
			default:
				// its a bad idea to add misses because its WAYYYY over the safe time zone.
				newScore = 0;
		}

		if (factor < 0)
		{
			factor = -factor;
		}

		newScore = (newScore - factor);

		roundedScore = Math.floor(newScore);

		return roundedScore;
	}
}
