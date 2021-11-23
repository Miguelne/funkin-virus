package;

import flixel.util.FlxColor;
import flixel.FlxSprite;
import Checkbox;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import BitData;

class OptionsState extends MusicBeatState
{
	private var grptext:FlxTypedGroup<Alphabet>;

	private var checkboxGroup:FlxTypedGroup<Checkbox>;

	var curSelected:Int = 0;

	var menuItems:Array<String> = [];

	var notice:FlxText;
	//var data:BitData = new BitData();

	override public function create() 
	{
		#if (android || ios || desktop)
		menuItems = ['downscroll',
			'ghost tap',
			'less update',
			'smooth iconbop',
			'note splash',
			#if desktop
			'reset button'
			#end
		];
		#end
		var menuBG:FlxSprite = new FlxSprite().loadGraphic('assets/images/menuDesat.png');
		menuBG.color = FlxColor.fromRGB(82, 79, 78);
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);

		grptext = new FlxTypedGroup<Alphabet>();
		add(grptext);

		checkboxGroup = new FlxTypedGroup<Checkbox>();
		add(checkboxGroup);

		for (i in 0...menuItems.length)
		{ 
			var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			controlLabel.isMenuItem = true;
			controlLabel.targetY = i;
			grptext.add(controlLabel);

			var ch = new Checkbox(controlLabel.x + controlLabel.width + 10, controlLabel.y - 20);
			checkboxGroup.add(ch);
			add(ch);
			//FlxG.save.data

			switch (menuItems[i]){
				case 'dfjk':
					ch.change(FlxG.save.data.dfjk);
				case 'downscroll':
					ch.change(FlxG.save.data.downscroll);
				case 'ghost tap':
					ch.change(FlxG.save.data.ghost);
				case 'reset button':
					ch.change(FlxG.save.data.resetButton);
				case 'less update':
					ch.change(FlxG.save.data.lessUpdate);
				case 'smooth iconbop':
					ch.change(FlxG.save.data.smoothIcon);
				case 'note splash':
					ch.change(FlxG.save.data.noteSplash);
			}

			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
		}

		var noticebg = new FlxSprite(0, FlxG.height - 56).makeGraphic(FlxG.width, 60, FlxColor.BLACK);
		noticebg.alpha = 0.25;

		notice = new FlxText(0, 0, 0, "", 24);

		notice.screenCenter();
		notice.y = FlxG.height - 56;
		notice.alpha = 0.6;
		notice.autoSize = false;
		notice.alignment = CENTER;
		add(noticebg);
		add(notice);
		#if (android || ios)
		addVirtualPad(FULL, A_B);
		#end
		changeSelection();
	}

	override function update(elapsed:Float)
	{
		if (FlxG.save.data.lessUpdate)
			super.update(elapsed/2);
		else
			super.update(elapsed);

		for (i in 0...checkboxGroup.length)
		{
			checkboxGroup.members[i].x = grptext.members[i].x + grptext.members[i].width + 10;
			checkboxGroup.members[i].y = grptext.members[i].y - 20;
		} 
		var daSelected:String = menuItems[curSelected];

		switch (daSelected){
			case 'note splash':
				notice.text = "Toggle note splashes.\nSwitch pages using RIGHT\n";
			case 'smooth iconbop':
				notice.text = "Toggle smooth bopping.\nSwitch pages using RIGHT\n";
			case 'dfjk':
				notice.text = 'Change your keybinds to D F J K.\nSwitch pages using RIGHT\n';
			case 'downscroll':
				notice.text = 'Toggle making the notes scroll down rather than up.\nSwitch pages using RIGHT\n';
			case 'ghost tap':
				notice.text = 'Toggle counting pressing a directional input when no arrow is there as a miss.\nSwitch pages using RIGHT\n';
			case 'reset button':
				notice.text = 'Toggle pressing R to gameover.\nSwitch pages using RIGHT\n';
			case 'less update':
				notice.text = 'Makes update frames way slower but increases performance (Might cause bugs)\nSwitch pages using RIGHT\n';
		}

		if (controls.ACCEPT)
		{

			trace(curSelected);

			switch (daSelected)
			{
				case 'dfjk':
					FlxG.save.data.dfjk = checkboxGroup.members[curSelected].change();
				case 'downscroll':
					FlxG.save.data.downscroll = checkboxGroup.members[curSelected].change();
				case 'ghost tap':
					FlxG.save.data.ghost = checkboxGroup.members[curSelected].change();
				case 'reset button':
					FlxG.save.data.downscroll = checkboxGroup.members[curSelected].change();
				case 'less update':
					FlxG.save.data.lessUpdate = checkboxGroup.members[curSelected].change();
			}
			FlxG.save.flush();
		}

		if (controls.BACK #if android || FlxG.android.justReleased.BACK #end) {
			FlxG.save.flush();
			FlxG.switchState(new OptionsMenu());
		}

		if (controls.UP_P)
			changeSelection(-1);
		if (controls.DOWN_P)
			changeSelection(1);

		if (controls.RIGHT_P)
			FlxG.switchState(new OptionsState3());

	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = grptext.length - 1;
		if (curSelected >= grptext.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grptext.members)
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

	// code from here https://stackoverflow.com/questions/23689001/how-to-reliably-format-a-floating-point-number-to-a-specified-number-of-decimal
	public static function floatToStringPrecision(n:Float, prec:Int){
		n = Math.round(n * Math.pow(10, prec));
		var str = ''+n;
		var len = str.length;
		if(len <= prec){
		  while(len < prec){
			str = '0'+str;
			len++;
		  }
		  return Std.parseFloat('0.'+str);
		}
		else{
		  return Std.parseFloat(str.substr(0, str.length-prec) + '.'+str.substr(str.length-prec));
		}//what.
	  }
}