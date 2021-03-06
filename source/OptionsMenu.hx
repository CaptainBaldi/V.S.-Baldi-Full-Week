package;

import flixel.graphics.frames.FlxBitmapFont;
import Alphabet.Skebeep;
import flixel.input.gamepad.FlxGamepad;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import openfl.Lib;
import Options;
import Controls.Control;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;

using StringTools;
class OptionsMenu extends MusicBeatState
{
	public static var instance:OptionsMenu;

	var selector:FlxText;
	var curSelected:Int = 0;

	var options:Array<OptionCategory> = [
		new OptionCategory("Appearance", [
			new Fullscreen("Toggle Fullscreen."),
			new DistractionsAndEffectsOption("Toggle stage distractions that can hinder your gameplay."),
			new CamZoomOption("Toggle the camera zoom in-game."),
			new AccuracyOption("Display accuracy information."),
			new NPSDisplayOption("Shows your current Notes Per Second."),
			new HealthDisplayOption("Shows your current Health."),
			new SongPositionOption("Show the songs current position (as a bar)"),
			new CpuStrums("CPU's strumline lights up when a note hits it.")
		]),
		new OptionCategory("Gameplay", [
			new DFJKOption(controls),
			new DownscrollOption("Change the layout of the strumline."),
			new GhostTapOption("Ghost Tapping is when you tap a direction and it doesn't give you a miss."),
			new Judgement("Customize your Hit Timings (LEFT or RIGHT)"),
			#if desktop
			new FPSCapOption("Cap your FPS"),
			#end
			new AccuracyDOption("Change how accuracy is calculated. (Accurate = Simple, Complex = Milisecond Based)"),
			new ResetButtonOption("Toggle pressing R to gameover."),
			new CustomizeGameplay("Drag'n'Drop Gameplay Modules around to your preference")
		]),
		new OptionCategory("Misc", [
			#if desktop
			new ReplayOption("View replays"),
			#end
			new FPSOption("Toggle the FPS Counter"),
			new RainbowFPSOption("Make the FPS Counter Rainbow"),
			new FlashingLightsOption("Toggle flashing lights that can cause epileptic seizures and strain."),
			new ShowInput("Display every single input in the score screen."),
			new Optimization("No backgrounds, no characters, centered notes, no player 2."),
			new BotPlay("Showcase your charts and mods with autoplay."),
			new ScoreScreen("Show the score screen after the end of a song")
		]),
		#if !final
		new OptionCategory("Debug", [
			new OffsetMenu("Get a note offset based off of your inputs!")
		]),
		#end
		new OptionCategory("Manage Save Data", [
			new ResetScoreOption("Reset your score on all songs and weeks."),
			new LockWeeksOption("Reset your storymode progress. (only Tutorial + Week 1 will be unlocked)"),
			new ResetSettings("Reset ALL your settings.")
		])
	];

	public var acceptInput:Bool = true;

	private var currentDescription:String = "";
	private var grpControls:FlxTypedGroup<Skebeep>;
	public static var versionShit:FlxText;

	var currentSelectedCat:OptionCategory;
	var blackBorder:FlxSprite;
	override function create()
	{
		FlxG.sound.playMusic(Paths.music('TheSideEffectsOfSchool'));

		if (FlxG.save.data.secret)
		{
			var secretSoundTest:OptionCategory = new OptionCategory("Sound Test", [
				new RandomGoodSound("Get a Random Good Sound."),
				new RandomBadSound("Get a Random Bad Sound.")
			]);

			options.insert(3, secretSoundTest);
		}

		instance = this;
		var menuBG:FlxBackdrop = new FlxBackdrop(Paths.image("wall"));
		menuBG.antialiasing = true;
		add(menuBG);
		
		var bars:FlxSprite = new FlxSprite().loadGraphic(Paths.image('bars'));
		bars.scrollFactor.set();
		bars.updateHitbox();
		bars.screenCenter();
		bars.antialiasing = false;
		add(bars);

		grpControls = new FlxTypedGroup<Skebeep>();
		add(grpControls);

		for (i in 0...options.length)
		{
			var controlLabel:Skebeep = new Skebeep();
			controlLabel.color = FlxColor.BLACK;
			controlLabel.setPosition(0, (70 * i) + 30);
			controlLabel.text = options[i].getName().replace(" ", ";");
			controlLabel.isMenuItem = true;
			controlLabel.myID = i;
			controlLabel.scale.set(3, 3);
			controlLabel.updateHitbox();
			controlLabel.screenCenter(X);
			grpControls.add(controlLabel);
		}

		currentDescription = "none";

		versionShit = new FlxText(5, FlxG.height + 40, 0, "Offset (Left, Right, Shift for slow): " + HelperFunctions.truncateFloat(FlxG.save.data.offset,2) + " - Description - " + currentDescription, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		
		blackBorder = new FlxSprite(-30,FlxG.height + 40).makeGraphic((Std.int(versionShit.width + 900)),Std.int(versionShit.height + 600),FlxColor.BLACK);
		blackBorder.alpha = 0.5;

		add(blackBorder);

		add(versionShit);

		FlxTween.tween(versionShit,{y: FlxG.height - 18},2,{ease: FlxEase.elasticInOut});
		FlxTween.tween(blackBorder,{y: FlxG.height - 18},2, {ease: FlxEase.elasticInOut});

		super.create();

		changeSelection();
	}

	var isCat:Bool = false;
	

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (acceptInput)
		{
			if (controls.BACK && !isCat)
				FlxG.switchState(new MainMenuState());
			else if (controls.BACK)
			{
				isCat = false;
				grpControls.clear();
				for (i in 0...options.length)
				{
					var controlLabel:Skebeep = new Skebeep();
					controlLabel.color = FlxColor.BLACK;
					controlLabel.setPosition(0, (70 * i) + 30);
					controlLabel.text = options[i].getName().replace(" ", ";");
					controlLabel.isMenuItem = true;
					controlLabel.myID = i;
					controlLabel.scale.set(3, 3);
					controlLabel.updateHitbox();
					controlLabel.screenCenter(X);
					grpControls.add(controlLabel);
					// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
				}
				
				curSelected = 0;
				
				changeSelection(curSelected);
			}

			var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

			if (gamepad != null)
			{
				if (gamepad.justPressed.DPAD_UP)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
					changeSelection(-1);
				}
				if (gamepad.justPressed.DPAD_DOWN)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
					changeSelection(1);
				}
			}
			
			if (FlxG.keys.justPressed.UP)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
				changeSelection(-1);
			}
			if (FlxG.keys.justPressed.DOWN)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
				changeSelection(1);
			}
			
			if (isCat)
			{
				if (currentSelectedCat.getOptions()[curSelected].getAccept())
				{
					if (FlxG.keys.pressed.SHIFT)
						{
							if (FlxG.keys.pressed.RIGHT)
								currentSelectedCat.getOptions()[curSelected].right();
							if (FlxG.keys.pressed.LEFT)
								currentSelectedCat.getOptions()[curSelected].left();
						}
					else
					{
						if (FlxG.keys.justPressed.RIGHT)
							currentSelectedCat.getOptions()[curSelected].right();
						if (FlxG.keys.justPressed.LEFT)
							currentSelectedCat.getOptions()[curSelected].left();
					}
				}
				else
				{
					if (FlxG.keys.pressed.SHIFT)
					{
						if (FlxG.keys.justPressed.RIGHT)
							FlxG.save.data.offset += 0.1;
						else if (FlxG.keys.justPressed.LEFT)
							FlxG.save.data.offset -= 0.1;
					}
					else if (FlxG.keys.pressed.RIGHT)
						FlxG.save.data.offset += 0.1;
					else if (FlxG.keys.pressed.LEFT)
						FlxG.save.data.offset -= 0.1;
					
					versionShit.text = "Offset (Left, Right, Shift for slow): " + HelperFunctions.truncateFloat(FlxG.save.data.offset,2) + " - Description - " + currentDescription;
				}
				if (currentSelectedCat.getOptions()[curSelected].getAccept())
					versionShit.text =  currentSelectedCat.getOptions()[curSelected].getValue() + " - Description - " + currentDescription;
				else
					versionShit.text = "Offset (Left, Right, Shift for slow): " + HelperFunctions.truncateFloat(FlxG.save.data.offset,2) + " - Description - " + currentDescription;
			}
			else
			{
				if (FlxG.keys.pressed.SHIFT)
				{
					if (FlxG.keys.justPressed.RIGHT)
						FlxG.save.data.offset += 0.1;
					else if (FlxG.keys.justPressed.LEFT)
						FlxG.save.data.offset -= 0.1;
				}
				else if (FlxG.keys.pressed.RIGHT)
					FlxG.save.data.offset += 0.1;
				else if (FlxG.keys.pressed.LEFT)
					FlxG.save.data.offset -= 0.1;
				
				versionShit.text = "Offset (Left, Right, Shift for slow): " + HelperFunctions.truncateFloat(FlxG.save.data.offset,2) + " - Description - " + currentDescription;
			}
		

			if (controls.RESET)
					FlxG.save.data.offset = 0;

			if (controls.ACCEPT)
			{
				if (isCat)
				{
					if (currentSelectedCat.getOptions()[curSelected].press()) {
						grpControls.members[curSelected].text = currentSelectedCat.getOptions()[curSelected].getDisplay().replace(" ", ";");
						trace(currentSelectedCat.getOptions()[curSelected].getDisplay());
					}
				}
				else
				{
					currentSelectedCat = options[curSelected];
					isCat = true;
					grpControls.clear();
					for (i in 0...currentSelectedCat.getOptions().length)
						{
							var controlLabel:Skebeep = new Skebeep();
							controlLabel.color = FlxColor.BLACK;
							controlLabel.setPosition(0, (70 * i) + 30);
							controlLabel.text = currentSelectedCat.getOptions()[i].getDisplay().replace(" ", ";");
							controlLabel.isMenuItem = true;
							controlLabel.myID = i;
							controlLabel.scale.set(3, 3);
							controlLabel.updateHitbox();
							controlLabel.screenCenter(X);
							grpControls.add(controlLabel);
							// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
						}
					curSelected = 0;
				}
				
				changeSelection();
			}
		}
		FlxG.save.flush();
	}

	var isSettingControl:Bool = false;

	function changeSelection(change:Int = 0)
	{
		#if !switch
		// NGio.logEvent("Fresh");
		#end
		
		curSelected += change;

		if (curSelected < 0)
			curSelected = grpControls.length - 1;
		if (curSelected >= grpControls.length)
			curSelected = 0;

		if (isCat)
			currentDescription = currentSelectedCat.getOptions()[curSelected].getDescription();
		else
			currentDescription = "Please select a category";
		if (isCat)
		{
			if (currentSelectedCat.getOptions()[curSelected].getAccept())
				versionShit.text =  currentSelectedCat.getOptions()[curSelected].getValue() + " - Description - " + currentDescription;
			else
				versionShit.text = "Offset (Left, Right, Shift for slow): " + HelperFunctions.truncateFloat(FlxG.save.data.offset,2) + " - Description - " + currentDescription;
		}
		else
			versionShit.text = "Offset (Left, Right, Shift for slow): " + HelperFunctions.truncateFloat(FlxG.save.data.offset,2) + " - Description - " + currentDescription;
		// selector.y = (70 * curSelected) + 30;

		var bullShit:Int = 0;

		var comicSans:FlxBitmapFont = FlxBitmapFont.fromAngelCode(Paths.font('bitmap/comic-sans-without-underline.png'),Paths.font('bitmap/comic-sans-without-underline.fnt'));
		var comicSansUnderlined:FlxBitmapFont = FlxBitmapFont.fromAngelCode(Paths.font('bitmap/comic-sans-underlined.png'),Paths.font('bitmap/comic-sans-underlined.fnt'));
		
		for (item in grpControls.members)
		{
			item.myID = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			item.font = comicSans;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.myID == 0)
			{
				item.alpha = 1;
				item.font = comicSansUnderlined;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}
