package;

import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
//import Config;
#if windows
import Discord.DiscordClient;
#end

import flixel.util.FlxSave;

class OptionsMenu extends MusicBeatState
{
	var selector:FlxText;
	var curSelected:Int = 0;

	private var grpControls:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String> = ['options', 'misc', 'achievements', 'exit'];

	var notice:FlxText;

	override function create()
	{
		FlxG.sound.playMusic(Paths.music('options','shared'));
		var menuBG:FlxSprite = new FlxSprite().loadGraphic('assets/images/menuDesat.png');
		menuBG.color = 0xFF108C00;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);
		#if windows
		if (FlxG.save.data.discordPresence)
			DiscordClient.changePresence("Setting up options", null);
		#end

		grpControls = new FlxTypedGroup<Alphabet>();
		add(grpControls);

		for (i in 0...menuItems.length)
		{ 
			var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			controlLabel.screenCenter();
			controlLabel.y = (100 * i) + 70;
			grpControls.add(controlLabel);
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
		}

		changeSelection();
		#if (android || ios)
		addVirtualPad(UP_DOWN, A_B);
		#end
		super.create();
	}

	override function update(elapsed:Float)
	{
		if (FlxG.save.data.lessUpdate)
			super.update(elapsed/2);
		else
			super.update(elapsed);
		if (controls.ACCEPT)
		{
			var daSelected:String = menuItems[curSelected];

			switch (daSelected)
			{
				case "options":
					FlxG.switchState(new OptionsState());
				case "credits":
					//FlxG.switchState(new options.AboutState());
				case "exit":
					FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
					FlxG.switchState(new MainMenuState());
				case "misc":
					FlxG.switchState(new OldOptionsMenu());
				case "achievements":
					FlxG.switchState(new MedalState());
			}
		}

		if (controls.BACK #if (android || ios) || FlxG.android.justReleased.BACK #end) {
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
			FlxG.switchState(new MainMenuState());
		}

		if (controls.UP_P)
			changeSelection(-1);
		if (controls.DOWN_P)
			changeSelection(1);

	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = grpControls.length - 1;
		if (curSelected >= grpControls.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpControls.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}

	override function closeSubState()
		{
			super.closeSubState();
		}
}
