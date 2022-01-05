package;

#if desktop
import Discord.DiscordClient;
#end
import GameData.MenuStyles;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.TransitionData;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.graphics.FlxGraphic;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import lime.utils.Assets;

using StringTools;

// might do this shit later: import flixel.addons.display.FlxBackdrop;
// import io.newgrounds.NG;
class MainMenuState extends MusicBeatState
{
	public static var lastSelected:Int = 0;

	var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	var songItems:FlxTypedGroup<Alphabet>;

	var optionShit:Array<String> = ['story mode', 'freeplay', 'donate', 'options'];
	var songList:Array<String> = ['dadbattle', 'south'];

	var bg:FlxSprite;
	var magenta:FlxSprite;
	var darken:FlxSprite;
	var chars:FlxTypedGroup<Character>;
	var selectedSpr:FlxSprite;

	public static var camFollow:FlxObject;

	override function create()
	{
		Settings.init();

		initData();
		Conductor.bpm = 102;

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(GameData.globalMusic);
		}

		persistentUpdate = persistentDraw = true;

		bg = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.15;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.x = 0;
		magenta.scrollFactor.y = 0.15;
		magenta.setGraphicSize(Std.int(magenta.width * 1.1));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = true;
		magenta.color = 0xFFfd719b;
		add(magenta);

		darken = new FlxSprite();
		darken.scrollFactor.set();
		darken.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		darken.alpha = 0.4;
		add(darken);
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		songItems = new FlxTypedGroup<Alphabet>();
		chars = new FlxTypedGroup<Character>();
		add(menuItems);
		add(songItems);
		add(chars);

		var tex = Paths.getSparrowAtlas('FNF_main_menu_assets');

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(0, 60 + (i * 160));
			menuItem.frames = tex;
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			switch (GameData.menuStyle)
			{
				case MenuStyles.LEFT:
					menuItem.x -= 290;
				case MenuStyles.MIDDLE:
					menuItem.screenCenter(X);
				case MenuStyles.RIGHT:
					menuItem.x = 640;
			}
			menuItems.add(menuItem);
			menuItem.scrollFactor.set(0.02, 0.02);
			menuItem.antialiasing = true;
			menuItem.alpha = 0;
		}

		for (i in 0...songList.length)
		{
			var songItem:Alphabet = new Alphabet(0, (FlxG.height / 2), songList[i], true, false);
			songItem.targetY = i;
			songItem.screenCenter(Y);
			songItem.y += 240;
			songItem.isMenuItem = true;
			songItem.antialiasing = true;
			songItem.scrollFactor.set();
			songItem.scale.set(0.8, 0.8);
			// songItem.updateHitbox(); ruins positions so im not doing it
			var charName:String = '';
			if (i == 0)
			{
				songItem.x += 130;
				charName = 'dad';
			}
			if (i == 1)
			{
				songItem.x += (FlxG.width - 130) - songItem.width;
				charName = 'spooky';
			}

			var char:Character = new Character(songItem.x - 30, songItem.y - 430, charName);
			char.scrollFactor.set();
			char.scale.set(0.6, 0.6);
			char.updateHitbox();
			if (i == 0)
			{
				char.dance();
				char.y -= 190;
			}
			if (i == 1)
			{
				char.x -= 90;
				char.y -= 30;
				char.playAnim('danceRight');
			}
			chars.add(char);

			var danced:Bool = false;

			// this is stupid
			var time:Float = (((((60 / 102) * 1000) / 1000)) / 4);

			new FlxTimer().start(time * 2, function(tmr:FlxTimer)
			{
				if (i == 1 && selected == 1)
				{
					if (!danced)
						char.playAnim('danceLeft');
					if (danced)
						char.playAnim('danceRight');

					danced = !danced;
				}
				tmr.reset(time * 2);
			});
			songItems.add(songItem);
		}

		FlxG.camera.follow(camFollow, null, 0.06);

		if (GameData.showVersion)
		{
			var coolString:String = Assets.getText("version/version.txt");

			var versionShit:FlxText = new FlxText(5, FlxG.height - 18, 0, coolString, 12);
			versionShit.scrollFactor.set();
			versionShit.setFormat(GameData.globalFont, 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			#if tester
			versionShit.text += '-TESTER';
			#end
			add(versionShit);
		}

		// NG.core.calls.event.logEvent('swag').send();

		curSelected = lastSelected;

		changeItem();
		changeSong();

		super.create();
	}

	var selectedSomethin:Bool = false;
	var selected:Int = 0;

	override function update(elapsed:Float)
	{
		if (FlxG.save.data.musicVolume == 100)
		{
			if (FlxG.sound.music.volume < 0.8)
				FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}
		else
		{
			if (FlxG.sound.music.volume < FlxG.save.data.musicVolume / 100)
				FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		Conductor.songPosition = FlxG.sound.music.time;

		if (!selectedSomethin)
		{
			if (controls.LEFT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), FlxG.save.data.soundVolume);
				changeSong(-1);
			}

			if (controls.RIGHT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), FlxG.save.data.soundVolume);
				changeSong(1);
			}

			/*
				#if debug
				if (controls.RIGHT_P)
				{
					var code:Int = 0;
					
					trace('exited game with code of ' + code);
					Sys.exit(code);
				}
				#end */
			/*if (controls.BACK)
				{
					FlxG.switchState(new TitleState());
			}*/

			if (controls.ACCEPT)
			{
				if (!selectedSomethin)
				{
					selectedSomethin = true;

					var goAway:Int = 0;

					if (selected == 0)
						goAway = 1;

					FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

					FlxFlicker.flicker(songItems.members[selected], 0, 0.08);

					var pos:Float;

					if (selected == 1)
						pos = 0 - FlxG.width / 2;
					else
						pos = FlxG.width + FlxG.width / 2;

					var offset:Array<Float> = [240, 230];

					FlxTween.tween(chars.members[goAway], {x: pos}, 1.2, {
						ease: FlxEase.sineOut
					});

					FlxTween.tween(songItems.members[goAway], {x: pos}, 1.2, {
						ease: FlxEase.sineOut
					});

					if (selected == 1)
						offset[1] -= 110;

					FlxTween.tween(songItems.members[selected], {x: FlxG.width / 2 - offset[1]}, 1, {
						ease: FlxEase.sineOut
					});

					FlxTween.tween(chars.members[selected], {x: FlxG.width / 2 - offset[0]}, 1, {
						ease: FlxEase.sineOut,
						onComplete: function(twn:FlxTween)
						{
							new FlxTimer().start(1, function(tmr:FlxTimer)
							{
								persistentUpdate = false;

								var coolSong:String = '';
								switch (songList[selected].toLowerCase())
								{
									case 'philly-nice':
										coolSong = 'philly';
									case 'dad-battle':
										coolSong = 'dadbattle';
									default:
										coolSong = songList[selected].toLowerCase();
								}

								var poop:String = Highscore.formatSong(coolSong, 2);

								trace(coolSong);
								trace(poop);

								PlayState.SONG = Song.loadFromJson(poop, coolSong);
								PlayState.isStoryMode = false;
								PlayState.storyDifficulty = 2;

								if (selected == 0)
									PlayState.storyWeek = 1;
								else
									PlayState.storyWeek = 2;
								PlayState.lastSelected = selected;

								FlxG.sound.music.fadeOut(0.4, 0);

								FlxG.sound.cache('songs:assets/songs/${PlayState.SONG.song}/Inst' + TitleState.soundExt);
								if (PlayState.SONG.needsVoices)
									FlxG.sound.cache('songs:assets/songs/${PlayState.SONG.song}/Voices' + TitleState.soundExt);

								trace('CUR WEEK' + PlayState.storyWeek);
								trace(poop, songList[selected].toLowerCase());
								LoadingState.loadAndSwitchState(new PlayState());
							});
						}
					});
				}
			}
		}

		super.update(elapsed);
		if (GameData.menuStyle == MIDDLE)
		{
			menuItems.forEach(function(spr:FlxSprite)
			{
				spr.screenCenter(X);
			});
		}
	}

	function changeSong(change:Int = 0)
	{
		selected += change;

		if (selected == 2)
			selected = 0;
		if (selected == -1)
			selected = 1;
		trace(selected);

		chars.forEach(function(char:Character)
		{
			char.colorTransform.redOffset = -40;
			char.colorTransform.blueOffset = -40;
			char.colorTransform.greenOffset = -40;
			char.animation.pause();

			chars.members[selected].colorTransform.redOffset = 0;
			chars.members[selected].colorTransform.blueOffset = 0;
			chars.members[selected].colorTransform.greenOffset = 0;
			chars.members[selected].animation.resume();
		});

		songItems.forEach(function(song:Alphabet)
		{
			song.alpha = 0.6;
			songItems.members[selected].alpha = 1;
		});
	}

	function changeItem(change:Int = 0)
	{
		curSelected += change;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				// camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
				camFollow.setPosition(FlxG.width * 0.5, spr.getGraphicMidpoint().y);
			}

			if (GameData.menuStyle == MenuStyles.RIGHT)
			{
				if (spr.ID == 0 && spr.animation.curAnim.name == 'selected')
					spr.x = 640 * 0.76;
				else if (spr.ID == 0 && spr.animation.curAnim.name != 'selected')
					spr.x = 640;
			}

			spr.updateHitbox();
		});
	}
}
