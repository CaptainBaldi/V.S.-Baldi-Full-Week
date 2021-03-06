package;

import Alphabet.Skebeep;
import flixel.input.gamepad.FlxGamepad;
import Controls.KeyboardScheme;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import io.newgrounds.NG;
import lime.app.Application;
import flash.system.System;
import flixel.input.mouse.FlxMouseEventManager;

#if windows
import Discord.DiscordClient;
#end

using StringTools;

class MainMenuState extends MusicBeatState
{
	var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;

	var newGaming:FlxText;
	var newGaming2:FlxText;

	public static var nightly:String = "";

	public static var kadeEngineVer:String = "1.5.4" + nightly;
	public static var gameVer:String = "0.2.7.1";
	public static var baldiVer:String = "v0.1";

	static var firstStart:Bool = true;
	
	var leaving:Bool = false;

	override function create()
	{
		#if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();
		if(firstStart)
		{
			FlxG.sound.play(Paths.sound('baldiIntro'));
			firstStart = false;
		}
		

		persistentUpdate = persistentDraw = true;

		var baldi:FlxSprite = new FlxSprite().loadGraphic(Paths.image('baldiBG'));
		baldi.scrollFactor.set();
		baldi.updateHitbox();
		baldi.screenCenter();
		baldi.antialiasing = false;
		add(baldi);

		var bars:FlxSprite = new FlxSprite().loadGraphic(Paths.image('bars'));
		bars.scrollFactor.set();
		bars.updateHitbox();
		bars.screenCenter();
		bars.antialiasing = false;
		add(bars);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var tex = Paths.getSparrowAtlas('MainMenuButtons');

		var playButton:FlxSprite = new FlxSprite();
		playButton.frames = tex;
		playButton.animation.addByPrefix('idle', "play off", 24);
		playButton.animation.addByPrefix('selected', "play on", 24);
		playButton.animation.play('idle');
		playButton.ID = 0;
		playButton.x = 684;
		playButton.y = 196;
		playButton.scrollFactor.set();
		playButton.antialiasing = false;
		menuItems.add(playButton);

		var optionsButton:FlxSprite = new FlxSprite();
		optionsButton.frames = tex;
		optionsButton.animation.addByPrefix('idle', "options off", 24);
		optionsButton.animation.addByPrefix('selected', "options on", 24);
		optionsButton.animation.play('idle');
		optionsButton.ID = 1;
		optionsButton.x = 636;
		optionsButton.y = 290;
		optionsButton.scrollFactor.set();
		optionsButton.antialiasing = false;
		menuItems.add(optionsButton);

		var aboutButton:FlxSprite = new FlxSprite();
		aboutButton.frames = tex;
		aboutButton.animation.addByPrefix('idle', "about off", 24);
		aboutButton.animation.addByPrefix('selected', "about on", 24);
		aboutButton.animation.play('idle');
		aboutButton.ID = 2;
		aboutButton.x = 604;
		aboutButton.y = 368;
		aboutButton.scrollFactor.set();
		aboutButton.antialiasing = false;
		menuItems.add(aboutButton);

		var exitButton:FlxSprite = new FlxSprite();
		exitButton.frames = tex;
		exitButton.animation.addByPrefix('idle', "exit off", 24);
		exitButton.animation.addByPrefix('selected', "exit on", 24);
		exitButton.animation.play('idle');
		exitButton.ID = 3;
		exitButton.x = 160;
		exitButton.y = 592;
		exitButton.scrollFactor.set();
		exitButton.antialiasing = false;
		menuItems.add(exitButton);

		var versionStuff:Skebeep = new Skebeep(2);
		versionStuff.color = FlxColor.BLACK;
		versionStuff.setPosition(930, 166);
		versionStuff.text = baldiVer;
		versionStuff.scale.set(3, 3);
		versionStuff.scrollFactor.set();
		add(versionStuff);

		var versionShit:FlxText = new FlxText(5, FlxG.height - 18, 0, "FNF - " + gameVer +  " | KE - " + kadeEngineVer, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();


		if (FlxG.save.data.dfjk)
			controls.setKeyboardScheme(KeyboardScheme.Solo, true);
		else
			controls.setKeyboardScheme(KeyboardScheme.Duo(true), true);

		changeItem();

		for (i in 0...menuItems.length)
		{
			var spr:FlxSprite = menuItems.members[i];
			FlxMouseEventManager.add(spr, onMouseDown, null, onMouseOver, onMouseOut);
		}

		super.create();
	}

	var selectedSomethin:Bool = false;

	var mouse:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (!selectedSomethin)
		{
			if (!mouse && FlxG.mouse.justMoved || FlxG.mouse.justPressed || FlxG.mouse.justPressedMiddle || FlxG.mouse.justPressedRight || FlxG.mouse.wheel != 0)
			{
				switchToMouse();
			}

			var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

			if (gamepad != null)
			{
				if (gamepad.justPressed.DPAD_UP)
				{
					if (mouse)
						switchFromMouse();
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
					changeItem(-1);
				}
				if (gamepad.justPressed.DPAD_DOWN)
				{
					if (mouse)
						switchFromMouse();
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
					changeItem(1);
				}
			}

			if (FlxG.keys.justPressed.UP)
			{
				if (mouse)
					switchFromMouse();
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
				changeItem(-1);
			}

			if (FlxG.keys.justPressed.DOWN)
			{
				if (mouse)
					switchFromMouse();
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
				changeItem(1);
			}

			if (controls.ACCEPT)
			{
				if (mouse)
					switchFromMouse();

				menuItems.forEach(function(spr:FlxSprite)
				{
					menuButton(curSelected);
				});
			}
		}

		super.update(elapsed);
	}
	
	function menuButton(button:Int)
	{
		selectedSomethin = true;

		if (!leaving)
		{
			switch (button)
			{
				case 0:
					FlxG.sound.play(Paths.sound('confirmMenu'));
					FlxG.switchState(new PlayMenuState());
				case 1:
					FlxG.sound.play(Paths.sound('confirmMenu'));
					FlxG.switchState(new OptionsMenu());
				case 2:
					FlxG.sound.play(Paths.sound('confirmMenu'));
					FlxG.switchState(new AboutMenuState());
				case 3:
					FlxG.sound.play(Paths.sound('thanksForPlaying'), 0.9);
					new FlxTimer().start(4, function(tmr:FlxTimer)
					{
						System.exit(0);
					});
			}
		}
		leaving = true;
	}
	
	function changeItem(huh:Int = 0)
	{
			curSelected += huh;

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
			}

			spr.updateHitbox();
		});
	}

	function switchFromMouse()
	{
		mouse = false;
		FlxG.mouse.visible = false;
		changeItem();
	}
	
	function switchToMouse()
	{
		mouse = true;
		FlxG.mouse.visible = true;
		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.updateHitbox();
		});
	}

	function onMouseOver(spr:FlxSprite)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		spr.animation.play('selected');
	}

	function onMouseOut(spr:FlxSprite)
	{
		spr.animation.play('idle');
	}

	function onMouseDown(spr:FlxSprite)
	{
		menuButton(spr.ID);
	}
}
