package;

import Song.Event;
import openfl.media.Sound;
#if sys
import sys.io.File;
import smTools.SMFile;
#end
import openfl.ui.KeyLocation;
import openfl.events.Event;
import haxe.EnumTools;
import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import Replay.Ana;
import Replay.Analysis;
#if cpp
import webm.WebmPlayer;
#end
import flixel.input.keyboard.FlxKey;
import haxe.Exception;
import openfl.geom.Matrix;
import openfl.display.BitmapData;
import openfl.utils.AssetType;
import lime.graphics.Image;
import flixel.graphics.FlxGraphic;
import openfl.utils.AssetManifest;
import openfl.utils.AssetLibrary;
import flixel.system.FlxAssets;
import lime.app.Application;
import lime.media.AudioContext;
import lime.media.AudioManager;
import openfl.Lib;
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
#if windows
import Discord.DiscordClient;
#end
#if sys
import Sys;
import sys.FileSystem;
#end
import BitData;
#if (android || ios)
import ui.Mobilecontrols;
#end
import NoteSplash;

using StringTools;

class PlayState extends MusicBeatState
{
	//public static vars
	public static var instance:PlayState = null;

	public static var isEasy:Bool = false;

	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var weekSong:Int = 0;
	public static var weekScore:Int = 0;
	public static var shits:Int = 0;
	public static var bads:Int = 0;
	public static var goods:Int = 0;
	public static var sicks:Int = 0;

	public static var songPosBG:FlxSprite;
	public static var songPosBar:FlxBar;

	public static var rep:Replay;
	public static var loadRep:Bool = false;
	public static var inResults:Bool = false;

	public static var noteBools:Array<Bool> = [false, false, false, false];

	public static var isSM:Bool = false;
	#if sys
	public static var sm:SMFile;
	public static var pathToSm:String;
	#end

	public static var dad:Character;
	public static var gf:Character;
	public static var boyfriend:Boyfriend;

	private static var prevCamFollow:FlxObject;

	public static var strumLineNotes:FlxTypedGroup<FlxSprite> = null;
	public static var playerStrums:FlxTypedGroup<FlxSprite> = null;
	public static var cpuStrums:FlxTypedGroup<FlxSprite> = null;

	public static var misses:Int = 0;
	public static var campaignMisses:Int = 0;

	public static var offsetTesting:Bool = false;

	public static var campaignScore:Int = 0;

	public static var daPixelZoom:Float = 6;

	public static var theFunne:Bool = true;

	public static var repPresses:Int = 0;
	public static var repReleases:Int = 0;

	public static var timeCurrently:Float = 0;
	public static var timeCurrentlyR:Float = 0;

	public static var highestCombo:Int = 0;

	public static var startTime = 0.0;

	// Per song additive offset
	public static var songOffset:Float = 0;

	#if windows
	public static var luaModchart:ModchartState = null;
	#end

	public static var songRate = 1.5;

	public static var webmHandler:WebmHandler;

//Public vars
	public var flot:FlxSprite;

	public var originalX:Float;

	public var notes:FlxTypedGroup<Note>;

	private var unspawnNotes:Array<Note> = [];

	public var strumLine:FlxSprite;

	public var health:Float = 1; // making public because sethealth doesnt work without it

	public var combo:Int = 0;

	public var accuracy:Float = 0.00;

	public var iconP1:HealthIcon; // making these public again because i may be stupid
	public var iconP2:HealthIcon; // what could go wrong?
	public var camHUD:FlxCamera;

	public var camHUDNOTES:FlxCamera; // seperated camera for notes.

	public var cannotDie = false;

	public var isSMFile:Bool = false;

	public var dialogue:Array<String> = ['dad:blah blah blah', 'bf:coolswag'];

	public var songScore:Int = 0;

	public var stopUpdate = false;
	public var removedVideo = false;

	public var currentBPM = 0;

	public var updateFrame = 0;

	public var fuckingVolume:Float = 1;
	public var useVideo = false;

	public var playingDathing = false;

	public var videoSprite:FlxSprite;

//Private vars
	private var SplashNote:NoteSplash;//for note splashs.

	private var vocals:FlxSound;

	private var curSection:Int = 0;

	private var camFollow:FlxObject;

	private var camZooming:Bool = false;
	private var curSong:String = "";

	private var gfSpeed:Int = 1;

	private var accuracyDefault:Float = 0.00;
	private var totalNotesHit:Float = 0;
	private var totalNotesHitDefault:Float = 0;
	private var totalPlayed:Int = 0;
	private var ss:Bool = false;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;
	private var songPositionBar:Float = 0;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	private var camGame:FlxCamera;

	// Will fire once to prevent debug spam messages and broken animations
	private var triggeredAlready:Bool = false;

	// Will decide if she's even allowed to headbang at all depending on the song
	private var allowedToHeadbang:Bool = false;

	// BotPlay text
	private var botPlayState:FlxText;
	// Replay shit
	private var saveNotes:Array<Dynamic> = [];
	private var saveJudge:Array<String> = [];
	private var replayAna:Analysis = new Analysis(); // replay analysis

	private var executeModchart = false;

	// Animation common suffixes
	private var dataSuffix:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
	private var dataColor:Array<String> = ['purple', 'blue', 'green', 'red'];

	private var paused:Bool = false;

	//Enemy color
	private var color1:FlxColor;
	//Player color
	private var color2:FlxColor;

//Normal vars
	var cool:Bool;
	var morecrap:Bool = false;

	var babyArrow:FlxSprite;

	var bg:FlxSprite;
	var bg2:FlxSprite;
	var sky:FlxSprite;
	var things:FlxSprite;
	var things2:FlxSprite;

	var flor1:FlxSprite;
	var flor2:FlxSprite;
	var flor3:FlxSprite;

//For custom notes.
	var noteTypeID:Int = 0;
	var noteTypeStyles:Array<String> = ["normal", "coins"];

	var zack:FlxSprite;//me

	var grpNoteSplashes:FlxTypedGroup<NoteSplash>;
//Crap for settings.
	var fpsCap:Int;
	var downscroll:Bool;
	var frames:Int;
	var scrollSpeed:Int;
	var botplay:Bool;
	var optimize:Bool;
	var antialiasing:Bool;
	var distractions:Bool;
	var songPosition:Bool;
	var ghost:Bool;
	var offset:Int;
	var resetButton:Bool;
	var cpuStrumsA:Bool;
	var scoreScreen:Bool;
	var accuracyMod:Int;
	var changedHit:Bool;
	var missSounds:Bool;
	var camzoom:Bool;

	
	var fallenCrap=false;
	var virusCrap=false;

	var halloweenLevel:Bool = false;

	var songLength:Float = 0;
	var kadeEngineWatermark:FlxText;

	#if windows
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	var virusMan:Character;//For 2nd bit in d1sc0

	var notesHitArray:Array<Date> = [];
	var currentFrames:Int = 0;
	var idleToBeat:Bool = true; // change if bf and dad would idle to the beat of the song
	var idleBeat:Int = 2; // how frequently bf and dad would play their idle animation(1 - every beat, 2 - every 2 beats and so on)

	var halloweenBG:FlxSprite;
	var isHalloween:Bool = false;

	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var phillyTrain:FlxSprite;
	var trainSound:FlxSound;

	var limo:FlxSprite;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:FlxSprite;
	var songName:FlxText;
	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var santa:FlxSprite;

	var fc:Bool = true;//check if fced.

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();

	var talking:Bool = true;

	var songScoreDef:Int = 0;
	var scoreTxt:FlxText;
	var replayTxt:FlxText;

	var defaultCamZoom:Float = 1.05;

	var funneEffect:FlxSprite;
	var inCutscene:Bool = false;
	var usedTimeTravel:Bool = false;

	var hasLua:Bool = false;

//MobileControls.
	#if (android || ios)
	var mcontrols:Mobilecontrols; 
	#end

//stuff for countdown.
	var startTimer:FlxTimer;
	var perfectMode:Bool = false;

	var luaWiggles:Array<WiggleEffect> = [];

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	var keys = [false, false, false, false];

	var songStarted = false;

	var debugNum:Int = 0;

	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var nps:Int = 0;
	var maxNPS:Int = 0;

	var endingSong:Bool = false;

	var hits:Array<Float> = [];
	var offsetTest:Float = 0;

	var timeShown = 0;
	var currentTimingShown:FlxText = null;

//for holdsss
	var upHold:Bool = false;
	var downHold:Bool = false;
	var rightHold:Bool = false;
	var leftHold:Bool = false;

	var mashing:Int = 0;
	var mashViolations:Int = 0;

	var etternaModeScore:Int = 0;

	var fastCarCanDrive:Bool = true;

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;
	var fuckingAnimationPlaying = false;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	var startedMoving:Bool = false;

	var danced:Bool = false;

	var dadishere = true;//uwu

//for the intoxicate deactivation
	var olddadx:Float;
	var olddady:Float;
	var oldarrowx:Float;
	var oldbfx:Float;
	var oldgfx:Float;
	var oldgfy:Float;
	var oldbfy:Float;
	var oldarrowy:Float;

//hallo bg
	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;
	var sectionman:Int = 0;

	var curLight:Int = 0;

	// API stuff

	public function addObject(object:FlxBasic)
	{
		add(object);
	}

	public function removeObject(object:FlxBasic)
	{
		remove(object);
	}

	override public function create()
	{

		FlxG.mouse.visible = false;
		instance = this;
		MusicBeatState.songEnded = false;

		saveLoad();

		if (fpsCap > 290)
			(cast(Lib.current.getChildAt(0), Main)).setFPSCap(800);

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		if (!isStoryMode)
		{
			sicks = 0;
			bads = 0;
			shits = 0;
			goods = 0;
		}
		misses = 0;

		highestCombo = 0;
		repPresses = 0;
		repReleases = 0;
		inResults = false;

		PlayStateChangeables.useDownscroll = downscroll;
		PlayStateChangeables.safeFrames = frames;
		PlayStateChangeables.scrollSpeed = scrollSpeed;
		PlayStateChangeables.botPlay = botplay;
		PlayStateChangeables.Optimize = optimize;

		// pre lowercasing the song name (create)
		var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();
		switch (songLowercase)
		{
			case 'dad-battle':
				songLowercase = 'dadbattle';
			case 'philly-nice':
				songLowercase = 'philly';
		}
		switch (SONG.song.toLowerCase()){
			case 'intoxicate' | 'guns' | 'disco':
				cool = true;
		}

		removedVideo = false;

		#if windows
		executeModchart = FileSystem.exists(Paths.lua(songLowercase + "/modchart"));
		if (executeModchart)
			PlayStateChangeables.Optimize = false;
		#end
		#if !cpp
		executeModchart = false; // FORCE disable for non cpp targets
		#end
		#if sys
		if (FileSystem.exists(Paths.lua(songLowercase + '/modchart')))
			hasLua = true;
		#end

		trace('Mod chart: ' + executeModchart + " - " + Paths.lua(songLowercase + "/modchart"));

		#if windows
		// Making difficulty text for Discord Rich Presence.
		storyDifficultyText = CoolUtil.difficultyFromInt(storyDifficulty);
		if (storyDifficulty == 0)
			isEasy = true;

		iconRPC = SONG.player2;

		// To avoid having duplicate images in Discord assets
		switch (iconRPC)
		{
			case 'senpai-angry':
				iconRPC = 'senpai';
			case 'monster-christmas':
				iconRPC = 'monster';
			case 'mom-car':
				iconRPC = 'mom';
		}

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: Week " + storyWeek;
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;

		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"\nAcc: "
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camHUDNOTES = new FlxCamera();
		camHUDNOTES.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camHUDNOTES);

		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial', 'tutorial');

		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();
		var sploosh = new NoteSplash(100, 100, 0);
		sploosh.alpha = 0.6;

		grpNoteSplashes.add(sploosh);

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		if (SONG.eventObjects == null)
			{
				SONG.eventObjects = [new Song.Event("Init BPM",0,SONG.bpm,"BPM Change")];
			}
	

		TimingStruct.clearTimings();

		var convertedStuff:Array<Song.Event> = [];

		var currentIndex = 0;
		for (i in SONG.eventObjects)
		{
			var name = Reflect.field(i,"name");
			var type = Reflect.field(i,"type");
			var pos = Reflect.field(i,"position");
			var value = Reflect.field(i,"value");

			if (type == "BPM Change")
			{
				var beat:Float = pos;

				var endBeat:Float = Math.POSITIVE_INFINITY;

				TimingStruct.addTiming(beat,value,endBeat, 0); // offset in this case = start time since we don't have a offset
				
				if (currentIndex != 0)
				{
					var data = TimingStruct.AllTimings[currentIndex - 1];
					data.endBeat = beat;
					data.length = (data.endBeat - data.startBeat) / (data.bpm / 60);
					TimingStruct.AllTimings[currentIndex].startTime = data.startTime + data.length;
				}

				currentIndex++;
			}
			convertedStuff.push(new Song.Event(name,pos,value,type));
		}

		SONG.eventObjects = convertedStuff;

		trace('INFORMATION ABOUT WHAT U PLAYIN WIT:\nFRAMES: ' + PlayStateChangeables.safeFrames + '\nZONE: ' + Conductor.safeZoneOffset + '\nTS: '
			+ Conductor.timeScale + '\nBotPlay : ' + PlayStateChangeables.botPlay);

		// dialogue shit
		switch (songLowercase)
		{
			case 'senpai':
				dialogue = CoolUtil.coolTextFile(Paths.txt('data/senpai/senpaiDialogue'));
			case 'roses':
				dialogue = CoolUtil.coolTextFile(Paths.txt('data/roses/rosesDialogue'));
			case 'thorns':
				dialogue = CoolUtil.coolTextFile(Paths.txt('data/thorns/thornsDialogue'));
		}

		// defaults if no stage was found in chart
		var stageCheck:String = 'stage';

		if (SONG.stage != null)
			stageCheck = SONG.stage;

		var shitSong = SONG.song.toLowerCase();

		if (!PlayStateChangeables.Optimize)
		{
			switch (shitSong)
			{
				case 'senpai':
					{
						curStage = 'school';

						var bgSky = new FlxSprite().loadGraphic(Paths.image('weeb/weebSky', 'week6'));
						bgSky.scrollFactor.set(0.1, 0.1);
						add(bgSky);

						var repositionShit = -200;

						var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('weeb/weebSchool', 'week6'));
						bgSchool.scrollFactor.set(0.6, 0.90);
						add(bgSchool);

						var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('weeb/weebStreet', 'week6'));
						bgStreet.scrollFactor.set(0.95, 0.95);
						add(bgStreet);

						var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.image('weeb/weebTreesBack', 'week6'));
						fgTrees.scrollFactor.set(0.9, 0.9);
						add(fgTrees);

						var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
						var treetex = Paths.getPackerAtlas('weeb/weebTrees', 'week6');
						bgTrees.frames = treetex;
						bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
						bgTrees.animation.play('treeLoop');
						bgTrees.scrollFactor.set(0.85, 0.85);
						add(bgTrees);

						var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
						treeLeaves.frames = Paths.getSparrowAtlas('weeb/petals', 'week6');
						treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
						treeLeaves.animation.play('leaves');
						treeLeaves.scrollFactor.set(0.85, 0.85);
						add(treeLeaves);

						var widShit = Std.int(bgSky.width * 6);

						bgSky.setGraphicSize(widShit);
						bgSchool.setGraphicSize(widShit);
						bgStreet.setGraphicSize(widShit);
						bgTrees.setGraphicSize(Std.int(widShit * 1.4));
						fgTrees.setGraphicSize(Std.int(widShit * 0.8));
						treeLeaves.setGraphicSize(widShit);

						fgTrees.updateHitbox();
						bgSky.updateHitbox();
						bgSchool.updateHitbox();
						bgStreet.updateHitbox();
						bgTrees.updateHitbox();
						treeLeaves.updateHitbox();

						bgGirls = new BackgroundGirls(-100, 190);
						bgGirls.scrollFactor.set(0.9, 0.9);

						if (songLowercase == 'roses')
						{
							if (distractions)
							{
								bgGirls.getScared();
							}
						}

						bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
						bgGirls.updateHitbox();
						if (distractions)
						{
							add(bgGirls);
						}
					}
				case 'thorns':
					{
						curStage = 'schoolEvil';

						if (!PlayStateChangeables.Optimize)
						{
							var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
							var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);
						}

						var posX = 400;
						var posY = 200;

						var bg:FlxSprite = new FlxSprite(posX, posY);
						bg.frames = Paths.getSparrowAtlas('weeb/animatedEvilSchool', 'week6');
						bg.animation.addByPrefix('idle', 'background 2', 24);
						bg.animation.play('idle');
						bg.scrollFactor.set(0.8, 0.9);
						bg.scale.set(6, 6);
						add(bg);

					}
				case 'intoxicate' | 'intoxic8' | 'd1sc0' | 'disco':
				{
					curStage = 'darkroom';
					var posX = 500;
					var posY = 380;

					if (!PlayStateChangeables.Optimize)
					{
						var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
						var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);
					}
					var skoy:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('8bit/skoy','shared'));
					skoy.scrollFactor.set(0.9, 0.9);
					skoy.scale.set(6, 6);
					//add(skoy);
					var flot:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('8bit/crap','shared'));
					flot.scrollFactor.set(0.9, 0.9);
					flot.scale.set(6, 6);
					add(flot);
					var flor:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('8bit/floor','shared'));
					flor.scrollFactor.set(0.9, 0.9);
					flor.scale.set(6, 6);
					add(flor);
					bg = new FlxSprite(posX, posY);
					// bg.frames = fromJson(Paths.image("8bit/new_room_close", "shared"), Paths.I8json("8bit/new_room_close", "shared"));
					bg.frames = Paths.I8json(Paths.image("8bit/new_room_close", "shared"), Paths.image("8bit/new_room_close", "shared").replace('.png', '.json'));
					bg.animation.addByNames('idle', ["new_room_close 0.aseprite", "new_room_close 1.aseprite", "new_room_close 2.aseprite", "new_room_close 3.aseprite", "new_room_close 4.aseprite", "new_room_close 5.aseprite", "new_room_close 6.aseprite", "new_room_close 7.aseprite", "new_room_close 8.aseprite", "new_room_close 9.aseprite", "new_room_close 10.aseprite", "new_room_close 11.aseprite", "new_room_close 12.aseprite", "new_room_close 13.aseprite", "new_room_close 14.aseprite", "new_room_close 15.aseprite", "new_room_close 16.aseprite", "new_room_close 17.aseprite", "new_room_close 18.aseprite", "new_room_close 19.aseprite", "new_room_close 20.aseprite", "new_room_close 21.aseprite", "new_room_close 22.aseprite", 'new_room_close 23.aseprite', "new_room_close 24.aseprite", "new_room_close 25.aseprite", "new_room_close 26.aseprite", "new_room_close 27.aseprite"], 24);
					bg.animation.play('idle');//shortcut ass
					bg.scrollFactor.set(0.9, 0.9);
					bg.scale.set(6, 6);
					add(bg);
					sky = new FlxSprite(posX, posY);
					sky.frames = Paths.getSparrowAtlas('8bit/sky', 'shared');
					sky.animation.addByPrefix('idle', 'SKY', 24);
					sky.animation.play('idle');
					sky.scrollFactor.set(0.9, 0.9);
					sky.scale.set(6, 6);
					bg2 = new FlxSprite(posX, posY);
					bg2.frames = Paths.getSparrowAtlas('8bit/room_open', 'shared');
					bg2.animation.addByPrefix('idle', 'room open', 24);
					bg2.animation.play('idle');
					bg2.scrollFactor.set(0.9, 0.9);
					bg2.scale.set(6, 6);

					things = new FlxSprite(posX, posY);
					// things.frames = fromJson(Paths.image("8bit/new_room_close_Arcade", "shared"), Paths.I8json("8bit/new_room_close_Arcade", "shared"));
					things.frames = Paths.I8json(Paths.image("8bit/new_room_close_Arcade", "shared"), Paths.image("8bit/new_room_close_Arcade", "shared").replace('.png', '.json'));
					things.animation.addByNames("idle", ["new_room_close_Arcade 0.aseprite", "new_room_close_Arcade 1.aseprite", "new_room_close_Arcade 2.aseprite", "new_room_close_Arcade 3.aseprite", "new_room_close_Arcade 4.aseprite", "new_room_close_Arcade 5.aseprite", "new_room_close_Arcade 6.aseprite", "new_room_close_Arcade 7.aseprite", "new_room_close_Arcade 8.aseprite", "new_room_close_Arcade 9.aseprite", "new_room_close_Arcade 10.aseprite", "new_room_close_Arcade 11.aseprite", "new_room_close_Arcade 12.aseprite", "new_room_close_Arcade 13.aseprite", "new_room_close_Arcade 14.aseprite", "new_room_close_Arcade 15.aseprite", "new_room_close_Arcade 16.aseprite", "new_room_close_Arcade 17.aseprite", "new_room_close_Arcade 18.aseprite", "new_room_close_Arcade 19.aseprite", "new_room_close_Arcade 20.aseprite", "new_room_close_Arcade 21.aseprite", "new_room_close_Arcade 22.aseprite", 'new_room_close_Arcade 23.aseprite', "new_room_close_Arcade 24.aseprite", "new_room_close_Arcade 25.aseprite", "new_room_close_Arcade 26.aseprite", "new_room_close_Arcade 27.aseprite"], 24);
					things.animation.play("idle");
					things.scale.set(6, 6);
					things.scrollFactor.set(0.9,0.9);
					
					defaultCamZoom = 0.5;
				}
				case 'guns':
				{
					curStage = 'void';
					var posX = 500;
					var posY = 380;

					if (!PlayStateChangeables.Optimize)
					{
						var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
						var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);
					}
					var skoy:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('8bit/skoy','shared'));
					skoy.scrollFactor.set(0.9, 0.9);
					skoy.scale.set(6, 6);
					add(skoy);
					flot = new FlxSprite(posX, posY).loadGraphic(Paths.image('8bit/crap','shared'));
					flot.scrollFactor.set(0.9, 0.9);
					flot.scale.set(6, 6);
					add(flot);
					defaultCamZoom = 0.6;
					var wee:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('8bit/weeeeeeee','shared'));
					wee.scrollFactor.set(0.9, 0.9);
					wee.scale.set(6, 6);
					add(wee);
					flor1 = new FlxSprite(posX, posY).loadGraphic(Paths.image('8bit/land','shared'));
					flor1.scrollFactor.set(0.9, 0.9);
					flor1.scale.set(6, 6);
					add(flor1);
					flor2 = new FlxSprite(posX, posY).loadGraphic(Paths.image('8bit/land2','shared'));
					flor2.scrollFactor.set(0.9, 0.9);
					flor2.scale.set(6, 6);
					flor2.alpha = 0;
					add(flor2);
					flor3 = new FlxSprite(posX, posY).loadGraphic(Paths.image('8bit/land5','shared'));
					flor3.scrollFactor.set(0.9, 0.9);
					flor3.scale.set(6, 6);
					flor3.alpha = 0;
					add(flor3);
					defaultCamZoom = 0.4;
				}
				case 'saloon':
				{
					var posX = 500;
					var posY = 380;
					var bg:FlxSprite = new FlxSprite(posX,posY).loadGraphic(Paths.image('8bit/barbg'));
					bg.scale.set(6,6);
					bg.antialiasing = false;
					bg.scrollFactor.set(0.9,0.9);
					add(bg);
					var flufash:FlxSprite = new FlxSprite(posX,posY).loadGraphic(Paths.image('8bit/ash'));
					flufash.scale.set(6,6);
					flufash.antialiasing = false;
					flufash.scrollFactor.set(0.9,0.9);
					add(flufash);
					zack = new FlxSprite(posX,posY).loadGraphic(Paths.image('8bit/cap'));
					zack.scale.set(6,6);
					zack.antialiasing = false;
					zack.scrollFactor.set(0.8,0.8);
					curStage = 'bar';
					defaultCamZoom = 0.7;
				}
				default:
					{
						if (!cool){
							defaultCamZoom = 0.9;
							curStage = 'stage';
							var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
							if(antialiasing)
								{
									bg.antialiasing = true;
								}
							bg.scrollFactor.set(0.9, 0.9);
							bg.active = false;
							add(bg);

							var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
							stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
							stageFront.updateHitbox();
							if(antialiasing)
							{
								stageFront.antialiasing = true;
							}
							stageFront.scrollFactor.set(0.9, 0.9);
							stageFront.active = false;
							add(stageFront);

							var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
							stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
							stageCurtains.updateHitbox();
							if(antialiasing)
							{
								stageCurtains.antialiasing = true;
							}
							stageCurtains.scrollFactor.set(1.3, 1.3);
							stageCurtains.active = false;

							add(stageCurtains);
						}
					}
			}
		}
		defaultCamZoom += 0.3;
		// defaults if no gf was found in chart
		var gfCheck:String = 'gf';

		if (SONG.gfVersion == null)
		{
			switch (storyWeek)
			{
				case 4:
					gfCheck = 'gf-car';
				case 5:
					gfCheck = 'gf-christmas';
				case 6:
					gfCheck = 'gf-pixel';
			}
		}
		else
		{
			gfCheck = SONG.gfVersion;
		}

		var curGf:String = '';
		switch (gfCheck)
		{
			case 'gf-car':
				curGf = 'gf-car';
			case 'gf-christmas':
				curGf = 'gf-christmas';
			case 'gf-pixel':
				curGf = 'gf-pixel';
			default:
				if (cool){
					curGf = 'gf-pixel';
				}
				else{
					curGf = 'gf';
				}
		}

		gf = new Character(400, 130, curGf);
		gf.scrollFactor.set(0.95, 0.95);

		dad = new Character(100, 100, SONG.player2);
		if (SONG.song.toLowerCase() == 'disco'){
			virusMan = new Character(100,100,'virus');
		}

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		switch (SONG.player2)
		{
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				camPos.x += 600;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}

			case "spooky":
				dad.y += 200;
			case "monster":
				dad.y += 100;
			case 'monster-christmas':
				dad.y += 130;
			case 'dad':
				camPos.x += 400;
			case 'pico':
				camPos.x += 600;
				dad.y += 300;
			case 'parents-christmas':
				dad.x -= 500;
			case 'senpai':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'senpai-angry':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'virus':
				dad.x += 100;
				dad.y += 420;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'virus-mad':
				dad.x += 100;
				dad.y += 420;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'bit':
				dad.x += 100;
				dad.y += 350;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
				if (SONG.song.toLowerCase() == 'disco'){
					virusMan.setPosition(200,520);
				}
			case 'spirit':
				if (distractions)
				{
					if (!PlayStateChangeables.Optimize)
					{
						var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
						add(evilTrail);
					}
				}

				dad.x -= 150;
				dad.y += 100;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
		}

		boyfriend = new Boyfriend(770, 450, SONG.player1);

		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'limo':
				boyfriend.y -= 220;
				boyfriend.x += 260;
				if (distractions)
				{
					resetFastCar();
					add(fastCar);
				}

			case 'mall':
				boyfriend.x += 200;

			case 'mallEvil':
				boyfriend.x += 320;
				dad.y -= 80;
			case 'school':
				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'darkroom':
				boyfriend.x += 350;
				boyfriend.y += 250;
				gf.x += 250;
				gf.y += 300;
			case 'void':
				dad.y += 100;
				boyfriend.x += 460;
				boyfriend.y += 300;
				gf.x += 370;
				gf.y += 250;
			case 'schoolEvil':
				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
		}

		if (!PlayStateChangeables.Optimize)
		{
			add(gf);

			// Shitty layering but whatev it works LOL
			if (curStage == 'limo')
				add(limo);
			add(dad);
			add(boyfriend);
			if (curStage == 'darkroom')
				add(things);
			if (curStage == 'bar')
				add(zack);
		}

		if (loadRep)
		{
			FlxG.watch.addQuick('rep rpesses', repPresses);
			FlxG.watch.addQuick('rep releases', repReleases);

			PlayStateChangeables.useDownscroll = rep.replay.isDownscroll;
			PlayStateChangeables.safeFrames = rep.replay.sf;
			PlayStateChangeables.botPlay = true;
		}

		trace('uh ' + PlayStateChangeables.safeFrames);

		trace("SF CALC: " + Math.floor((PlayStateChangeables.safeFrames / 60) * 1000));

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		if (PlayStateChangeables.useDownscroll)
			strumLine.y = FlxG.height - 165;

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		add(grpNoteSplashes);
//shortcut #3
		playerStrums = new FlxTypedGroup<FlxSprite>();
		cpuStrums = new FlxTypedGroup<FlxSprite>();

		generateStaticArrows(0);
		generateStaticArrows(1);

		if (SONG.song == null)
			trace('song is null???');
		else
			trace('song looks gucci');

		generateSong(SONG.song);

		trace('generated');

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.14);

		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		if (songPosition) // I dont wanna talk about this code :(
		{
			songPosBG = new FlxSprite(0, 10).loadGraphic(Paths.image('healthBar'));
			if (PlayStateChangeables.useDownscroll)
				songPosBG.y = FlxG.height * 0.9 + 45;
			songPosBG.screenCenter(X);
			songPosBG.scrollFactor.set();
			add(songPosBG);

			songPosBar = new FlxBar(songPosBG.x + 4, songPosBG.y + 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
				'songPositionBar', 0, 90000);
			songPosBar.scrollFactor.set();
			songPosBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);
			add(songPosBar);

			songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - (SONG.song.length * 5), songPosBG.y, 0, SONG.song, 16);
			if (PlayStateChangeables.useDownscroll)
				songName.y -= 3;
			songName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			songName.scrollFactor.set();
			add(songName);
			songName.cameras = [camHUD];
		}

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
		if (PlayStateChangeables.useDownscroll)
			healthBarBG.y = 50;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();

		//For healthbar for each character.
		switch (dad.curCharacter){
			case 'virus':
				color1 = FlxColor.fromRGB(0, 255, 81);
			case 'bit':
				color1 = 0xFF00E7FF;
			default:
				color1 = FlxColor.RED;
		}

		switch (boyfriend.curCharacter){
			case 'bf-pixel':
				color2 = FlxColor.fromRGB(0,200,255);
			case 'bit':
				color2 = 0xFF00E7FF;
			default:
				color2 = FlxColor.BLUE;
		}

		healthBar.createFilledBar(color1, color2);
		// healthBar
		add(healthBar);

		// Add Kade Engine watermark
		kadeEngineWatermark = new FlxText(4, healthBarBG.y
			+ 50, 0,
			SONG.song
			+ " - "
			+ CoolUtil.difficultyFromInt(storyDifficulty)
			+ (Main.watermarks ? " | KE " + MainMenuState.kadeEngineVer : " | FUNKIN-VIRUS "), 16);
		kadeEngineWatermark.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		kadeEngineWatermark.scrollFactor.set();
		add(kadeEngineWatermark);

		if (PlayStateChangeables.useDownscroll)
			kadeEngineWatermark.y = FlxG.height * 0.9 + 45;

		scoreTxt = new FlxText(FlxG.width / 2 - 235, healthBarBG.y + 50, 0, "", 20);

		scoreTxt.screenCenter(X);

		originalX = scoreTxt.x;

		scoreTxt.scrollFactor.set();

		scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		add(scoreTxt);

		replayTxt = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (PlayStateChangeables.useDownscroll ? 100 : -100), 0, "REPLAY",
			20);
		replayTxt.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		replayTxt.borderSize = 4;
		replayTxt.borderQuality = 2;
		replayTxt.scrollFactor.set();
		if (loadRep)
		{
			add(replayTxt);
		}
		// Literally copy-paste of the above, fu
		botPlayState = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (PlayStateChangeables.useDownscroll ? 100 : -100), 0,
			"BOTPLAY", 20);
		botPlayState.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botPlayState.scrollFactor.set();
		botPlayState.borderSize = 4;
		botPlayState.borderQuality = 2;
		if (PlayStateChangeables.botPlay && !loadRep)
			add(botPlayState);

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);
		iconP1.y -= 30;

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);
		iconP2.y -= 30;

		strumLineNotes.cameras = [camHUDNOTES];
		grpNoteSplashes.cameras = [camHUDNOTES];
		notes.cameras = [camHUDNOTES];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		doof.cameras = [camHUD];
		if (songPosition)
		{
			songPosBG.cameras = [camHUD];
			songPosBar.cameras = [camHUD];
		}
		kadeEngineWatermark.cameras = [camHUD];
		if (loadRep)
			replayTxt.cameras = [camHUD];

		#if (android || ios)
			mcontrols = new Mobilecontrols();
			switch (mcontrols.mode)
			{
				case VIRTUALPAD_RIGHT | VIRTUALPAD_LEFT | VIRTUALPAD_CUSTOM:
					controls.setVirtualPad(mcontrols._virtualPad, FULL, NONE);
				case HITBOX:
					controls.setHitBox(mcontrols._hitbox);
				default:
			}
			trackedinputs = controls.trackedinputs;
			controls.trackedinputs = [];

			mcontrols.cameras = [camHUD];

			mcontrols.alpha = 0;

			add(mcontrols);
		#end

		startingSong = true;

		trace('starting');

		if (isStoryMode)
		{
			switch (StringTools.replace(curSong, " ", "-").toLowerCase())
			{
				case 'senpai':
					schoolIntro(doof);
				case 'roses':
					FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(doof);
				case 'thorns':
					schoolIntro(doof);
				default:
					startCountdown();
			}
		}
		else
		{
			startCountdown();
		}
		#if desktop
		if (!loadRep)
			rep = new Replay("na");

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, releaseInput);
		#end

		changeScroll();

		super.create();
	}

	function saveLoad(){
		downscroll = FlxG.save.data.downscroll;
		frames = FlxG.save.data.frames;
		scrollSpeed = FlxG.save.data.scrollSpeed;
		botplay = FlxG.save.data.botplay;
		optimize = FlxG.save.data.optimize;
		antialiasing = FlxG.save.data.antialiasing;
		distractions = FlxG.save.data.distractions;
		songPosition = FlxG.save.data.songPosition;
		ghost = FlxG.save.data.ghost;
		offset = FlxG.save.data.offset;
		resetButton = FlxG.save.data.resetButton;
		cpuStrumsA = FlxG.save.data.cpuStrums;
		scoreScreen = FlxG.save.data.scoreScreen;
		accuracyMod = FlxG.save.data.accuracyMod;
		changedHit = FlxG.save.data.changedHit;
		missSounds = FlxG.save.data.missSounds;
		camzoom = FlxG.save.data.camzoom;
		fpsCap = FlxG.save.data.fpsCap;

	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();

		if (StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase() == 'roses'
			|| StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase() == 'thorns')
		{
			remove(black);

			if (StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase() == 'thorns')
			{
				add(red);
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;

					if (StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase() == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	function startCountdown():Void
	{
		inCutscene = false;
		#if (android || ios)
		new FlxTimer().start(0.1, function(tmr:FlxTimer)
		{
			mcontrols.alpha += 0.1;
			if (mcontrols.alpha != 0.7){
				tmr.reset(0.1);
			}
			else{
				trace('aweseom.');
			}
		});
		#end
		appearStaticArrows();

		if (startTime != 0)
		{
			var toBeRemoved = [];
			for(i in 0...unspawnNotes.length)
			{
				var dunceNote:Note = unspawnNotes[i];

				if (dunceNote.strumTime - startTime <= 0)
					toBeRemoved.push(dunceNote);
				else if (dunceNote.strumTime - startTime < 3500)
				{
					notes.add(dunceNote);

					if (dunceNote.mustPress)
						dunceNote.y = (playerStrums.members[Math.floor(Math.abs(dunceNote.noteData))].y
							+ 0.45 * (startTime - dunceNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
								2)) - dunceNote.noteYOff;
					else
						dunceNote.y = (strumLineNotes.members[Math.floor(Math.abs(dunceNote.noteData))].y
							+ 0.45 * (startTime - dunceNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
								2)) - dunceNote.noteYOff;
					toBeRemoved.push(dunceNote);
				}
			}

			for(i in toBeRemoved)
				unspawnNotes.remove(i);
		}

		#if windows
		// pre lowercasing the song name (startCountdown)
		var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();
		switch (songLowercase)
		{
			case 'dad-battle':
				songLowercase = 'dadbattle';
			case 'philly-nice':
				songLowercase = 'philly';
		}
		if (executeModchart)
		{
			luaModchart = ModchartState.createModchartState();
			luaModchart.executeState('start', [songLowercase]);
		}
		#end

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			dad.dance();
			iconP1.setGraphicSize(Std.int(iconP1.width + 30));
			iconP1.updateHitbox();
			gf.dance();
			boyfriend.playAnim('idle');

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('schoolEvil', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			for (value in introAssets.keys())
			{
				if (value == curStage)
				{
					trace(value + " - " + curStage);
					introAlts = introAssets.get(value);
					if (curStage.contains('school') || curStage == 'darkroom')
						altSuffix = '-pixel';
				}
			}

			switch (swagCounter)

			{
				case 0:
					FlxG.sound.play(Paths.sound('3','shared'), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('2','shared'), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('1','shared'), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('singlego','shared'), 0.6);
				case 4:
			}

			swagCounter += 1;
		}, 5);
	}

	private function getKey(charCode:Int):String
	{
		for (key => value in FlxKey.fromStringMap)
		{
			if (charCode == value)
				return key;
		}
		return null;
	}

	#if desktop
	private function releaseInput(evt:KeyboardEvent):Void // handles releases
	#else
	private function releaseMobile(evt:Int):Void
	#end
	{
		@:privateAccess
		#if desktop
		var key = FlxKey.toStringMap.get(Keyboard.__convertKeyCode(evt.keyCode));
		#else
		var key = evt;
		#end

		var binds:Array<String> = [
			FlxG.save.data.leftBind,
			FlxG.save.data.downBind,
			FlxG.save.data.upBind,
			FlxG.save.data.rightBind
		];

		var data = -1;

		#if desktop
		switch (evt.keyCode) // arrow keys
		{
			case 37:
				data = 0;
			case 40:
				data = 1;
			case 38:
				data = 2;
			case 39:
				data = 3;
		}
		#else
		data = evt;
		#end

		#if desktop
		for (i in 0...binds.length) // binds
		{
			if (binds[i].toLowerCase() == key.toLowerCase())
				data = i;
		}
		#end

		if (data == -1)
			return;

		keys[data] = false;
	}

	#if desktop
	private function handleInput(evt:KeyboardEvent):Void
	#else
	private function handleMobile(evt:Int):Void
	#end
	{ // this actually handles press inputs

		if (PlayStateChangeables.botPlay || loadRep || paused)
			return;

		// first convert it from openfl to a flixel key code
		// then use FlxKey to get the key's name based off of the FlxKey dictionary
		// this makes it work for special characters

		@:privateAccess
		#if desktop
		var key = FlxKey.toStringMap.get(Keyboard.__convertKeyCode(evt.keyCode));
		#else
		var key = evt;
		#end

		var binds:Array<String> = [
			FlxG.save.data.leftBind,
			FlxG.save.data.downBind,
			FlxG.save.data.upBind,
			FlxG.save.data.rightBind
		];

		var data = -1;

		#if desktop
		switch (evt.keyCode) // arrow keys
		{
			case 37:
				data = 0;
			case 40:
				data = 1;
			case 38:
				data = 2;
			case 39:
				data = 3;
		}
		#else
		data = evt;
		#end

		#if desktop
		for (i in 0...binds.length) // binds
		{
			if (binds[i].toLowerCase() == key.toLowerCase())
				data = i;
		}
		#end

		if (data == -1)
			return;

		if (keys[data])
			return;

		keys[data] = true;

		var ana = new Ana(Conductor.songPosition, null, false, "miss", data);

		var dataNotes = [];
		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && daNote.noteData == data)
				dataNotes.push(daNote);
		}); // Collect notes that can be hit

		dataNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime)); // sort by the earliest note

		if (dataNotes.length != 0)
		{
			var coolNote = null;

			for (i in dataNotes)
				if (!i.isSustainNote)
				{
					coolNote = i;
					break;
				}

			if (coolNote == null) // Note is null, which means it's probably a sustain note. Update will handle this (HOPEFULLY???)
			{
				return;
			}

			if (dataNotes.length > 1) // stacked notes or really close ones
			{
				for (i in 0...dataNotes.length)
				{
					if (i == 0) // skip the first note
						continue;

					var note = dataNotes[i];

					if (!note.isSustainNote && (note.strumTime - coolNote.strumTime) < 2)
					{
						trace('found a stacked/really close note ' + (note.strumTime - coolNote.strumTime));
						// just fuckin remove it since it's a stacked note and shouldn't be there
						note.kill();
						notes.remove(note, true);
						note.destroy();
					}
				}
			}

			goodNoteHit(coolNote);
			var noteDiff:Float = -(coolNote.strumTime - Conductor.songPosition);
			ana.hit = true;
			ana.hitJudge = Ratings.CalculateRating(noteDiff, Math.floor((PlayStateChangeables.safeFrames / 60) * 1000));
			ana.nearestNote = [coolNote.strumTime, coolNote.noteData, coolNote.sustainLength];
		}
		else if (!ghost && songStarted)
		{
			noteMiss(data, null);
			ana.hit = false;
			ana.hitJudge = "shit";
			ana.nearestNote = [];
			health -= 0.10;
		}
	}

	function startSong():Void
	{
		startingSong = false;
		songStarted = true;
		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
		{
			#if sys
			if (!isStoryMode && isSM)
			{
				trace("Loading " + pathToSm + "/" + sm.header.MUSIC);
				var bytes = File.getBytes(pathToSm + "/" + sm.header.MUSIC);
				var sound = new Sound();
				sound.loadCompressedDataFromByteArray(bytes.getData(), bytes.length);
				FlxG.sound.playMusic(sound);
			}
			else
				FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
			#else
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
			#end
		}

		FlxG.sound.music.onComplete = endSong;
		vocals.play();

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		if (songPosition)
		{
			remove(songPosBG);
			remove(songPosBar);
			remove(songName);

			songPosBG = new FlxSprite(0, 10).loadGraphic(Paths.image('healthBar'));
			if (PlayStateChangeables.useDownscroll)
				songPosBG.y = FlxG.height * 0.9 + 45;
			songPosBG.screenCenter(X);
			songPosBG.scrollFactor.set();
			add(songPosBG);

			songPosBar = new FlxBar(songPosBG.x
				+ 4, songPosBG.y
				+ 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
				'songPositionBar', 0, songLength
				- 1000);
			songPosBar.numDivisions = 1000;
			songPosBar.scrollFactor.set();
			songPosBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);
			add(songPosBar);

			var songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - (SONG.song.length * 5), songPosBG.y, 0, SONG.song, 16);
			if (PlayStateChangeables.useDownscroll)
				songName.y -= 3;
			songName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			songName.scrollFactor.set();
			add(songName);

			songPosBG.cameras = [camHUD];
			songPosBar.cameras = [camHUD];
			songName.cameras = [camHUD];
		}

		// Song check real quick
		switch (curSong)
		{
			case 'Bopeebo' | 'Philly Nice' | 'Blammed' | 'Cocoa' | 'Eggnog':
				allowedToHeadbang = true;
			default:
				allowedToHeadbang = false;
		}

		if (useVideo)
			GlobalVideo.get().resume();

		#if windows
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"\nAcc: "
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end

		FlxG.sound.music.time = startTime;
		vocals.time = startTime;
		Conductor.songPosition = startTime;
		startTime = 0;

		for(i in 0...unspawnNotes.length)
			if (unspawnNotes[i].strumTime < startTime)
				unspawnNotes.remove(unspawnNotes[i]);
	}

	//var noteTypeID:Int = 0;

	public function generateSong(dataPath:String):Void
	{

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		#if sys
		if (SONG.needsVoices && !isSM)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();
		#else
		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();
		#end

		trace('loaded vocals');

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		// Per song offset check
		#if windows
		// pre lowercasing the song name (generateSong)
		var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();
		switch (songLowercase)
		{
			case 'dad-battle':
				songLowercase = 'dadbattle';
			case 'philly-nice':
				songLowercase = 'philly';
		}

		var songPath = 'assets/data/' + songLowercase + '/';
		
		#if sys
		if (isSM && !isStoryMode)
			songPath = pathToSm;
		#end

		for (file in sys.FileSystem.readDirectory(songPath))
		{
			var path = haxe.io.Path.join([songPath, file]);
			if (!sys.FileSystem.isDirectory(path))
			{
				if (path.endsWith('.offset'))
				{
					trace('Found offset file: ' + path);
					songOffset = Std.parseFloat(file.substring(0, file.indexOf('.off')));
					break;
				}
				else
				{
					trace('Offset file not found. Creating one @: ' + songPath);
					sys.io.File.saveContent(songPath + songOffset + '.offset', '');
				}
			}
		}
		#end
		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped


		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0] + offset + songOffset;
				if (daStrumTime < 0)
					daStrumTime = 0;
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note;
				switch (noteTypeID){
					case 1:
						swagNote = new Note(daStrumTime, daNoteData, oldNote, false, false, "coins");
					default:
						swagNote = new Note(daStrumTime, daNoteData, oldNote);
				}

				if (!gottaHitNote && PlayStateChangeables.Optimize)
					continue;

				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				if (susLength > 0)
					swagNote.isParent = true;

				var type = 0;

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
					{
						sustainNote.x += FlxG.width / 2; // general offset
					}

					sustainNote.parent = swagNote;
					swagNote.children.push(sustainNote);
					sustainNote.spotInLine = type;
					type++;
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
			}
			daBeats += 1;
		}

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		//return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
		return unspawnShit(Obj1, Obj2);
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			babyArrow = new FlxSprite(0, strumLine.y);

			// defaults if no noteStyle was found in chart
			var noteTypeCheck:String = 'normal';

			if (PlayStateChangeables.Optimize && player == 0)
				continue;

			if (SONG.noteStyle == null)
			{
				if (FlxG.save.data.noteSkin)
					noteTypeCheck = 'pixel';
				else
					noteTypeCheck = "normal";
			}
			else
			{
				noteTypeCheck = SONG.noteStyle;
			}

			switch (noteTypeCheck)
			{
				case 'pixel':
					babyArrow.loadGraphic(Paths.image('8bit/arrows-pixels'), true, 17, 17);
					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purplel', [4]);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					switch (Math.abs(i))
					{//shortcut #1
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.add('static', [2]);
							babyArrow.animation.add('pressed', [6, 10], 12, false);
							babyArrow.animation.add('confirm', [14, 18], 12, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.add('static', [3]);
							babyArrow.animation.add('pressed', [7, 11], 12, false);
							babyArrow.animation.add('confirm', [15, 19], 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.add('static', [1]);
							babyArrow.animation.add('pressed', [5, 9], 12, false);
							babyArrow.animation.add('confirm', [13, 17], 24, false);
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.add('static', [0]);
							babyArrow.animation.add('pressed', [4, 8], 12, false);
							babyArrow.animation.add('confirm', [12, 16], 24, false);
					}

				default:
					babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');
					for (j in 0...4)
					{
						babyArrow.animation.addByPrefix(dataColor[j], 'arrow' + dataSuffix[j]);	
					}

					var lowerDir:String = dataSuffix[i].toLowerCase();

					babyArrow.animation.addByPrefix('static', 'arrow' + dataSuffix[i]);
					babyArrow.animation.addByPrefix('pressed', lowerDir + ' press', 24, false);
					babyArrow.animation.addByPrefix('confirm', lowerDir + ' confirm', 24, false);

					babyArrow.x += Note.swagWidth * i;

					if(antialiasing)
						{
							babyArrow.antialiasing = true;
						}
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			babyArrow.alpha = 0;
			if (!isStoryMode)
			{
				babyArrow.y -= 10;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			babyArrow.ID = i;

			switch (player)
			{
				case 0:
					cpuStrums.add(babyArrow);
				case 1:
					playerStrums.add(babyArrow);
			}

			babyArrow.animation.play('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * player);

			if (PlayStateChangeables.Optimize)
				babyArrow.x -= 275;

			cpuStrums.forEach(function(spr:FlxSprite)
			{
				spr.centerOffsets(); // CPU arrows start out slightly off-center
			});

			strumLineNotes.add(babyArrow);
		}
	}

	private function appearStaticArrows():Void
	{
		strumLineNotes.forEach(function(babyArrow:FlxSprite)
		{
			if (isStoryMode)
				babyArrow.alpha = 1;
		});
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			#if windows
			DiscordClient.changePresence("PAUSED on "
				+ SONG.song
				+ " ("
				+ storyDifficultyText
				+ ") "
				+ Ratings.GenerateLetterRank(accuracy),
				"Acc: "
				+ HelperFunctions.truncateFloat(accuracy, 2)
				+ "% | Score: "
				+ songScore
				+ " | Misses: "
				+ misses, iconRPC);
			#end
			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			#if windows
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText
					+ " "
					+ SONG.song
					+ " ("
					+ storyDifficultyText
					+ ") "
					+ Ratings.GenerateLetterRank(accuracy),
					"\nAcc: "
					+ HelperFunctions.truncateFloat(accuracy, 2)
					+ "% | Score: "
					+ songScore
					+ " | Misses: "
					+ misses, iconRPC, true,
					songLength
					- Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy), iconRPC);
			}
			#end
		}

		super.closeSubState();
	}

	function resyncVocals():Void
	{
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();

		#if windows
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"\nAcc: "
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end
	}

	var isNormal = true;
	var isWinning = false;
	var isLosing = false;
	var iconp1Anim = SONG.player1;
	var iconp2Anim = SONG.player2;

	override public function update(elapsed:Float)
	{
		#if !debug
		perfectMode = false;
		#end

		if (updateFrame == 4)
			{
				TimingStruct.clearTimings();
	
					var currentIndex = 0;
					for (i in SONG.eventObjects)
					{
						if (i.type == "BPM Change")
						{
							var beat:Float = i.position;
	
							var endBeat:Float = Math.POSITIVE_INFINITY;
	
							TimingStruct.addTiming(beat,i.value,endBeat, 0); // offset in this case = start time since we don't have a offset
							
							if (currentIndex != 0)
							{
								var data = TimingStruct.AllTimings[currentIndex - 1];
								data.endBeat = beat;
								data.length = (data.endBeat - data.startBeat) / (data.bpm / 60);
								TimingStruct.AllTimings[currentIndex].startTime = data.startTime + data.length;
							}
	
							currentIndex++;
						}
					}
					updateFrame++;
			}
			else if (updateFrame != 5)
				updateFrame++;
	

			var timingSeg = TimingStruct.getTimingAtTimestamp(Conductor.songPosition);
	
			if (timingSeg != null)
			{
	
				var timingSegBpm = timingSeg.bpm;
	
				if (timingSegBpm != Conductor.bpm)
				{
					trace("BPM CHANGE to " + timingSegBpm);
					Conductor.changeBPM(timingSegBpm, false);
				}
	
			}

		var newScroll = PlayStateChangeables.scrollSpeed;

		for(i in SONG.eventObjects)
		{
			switch(i.type)
			{
				case "Scroll Speed Change":
					if (i.position < curDecimalBeat)
						newScroll = i.value;
			}
		}

		PlayStateChangeables.scrollSpeed = newScroll;
	
		if (PlayStateChangeables.botPlay && FlxG.keys.justPressed.ONE){
			camHUD.visible = !camHUD.visible;
			camHUDNOTES.visible = !camHUDNOTES.visible;
		}

		if (useVideo && GlobalVideo.get() != null && !stopUpdate)
		{
			if (GlobalVideo.get().ended && !removedVideo)
			{
				remove(videoSprite);
				FlxG.stage.window.onFocusOut.remove(focusOut);
				FlxG.stage.window.onFocusIn.remove(focusIn);
				removedVideo = true;
			}
		}

		#if windows
		if (executeModchart && luaModchart != null && songStarted)
		{
			luaModchart.setVar('songPos', Conductor.songPosition);
			luaModchart.setVar('hudZoom', camHUD.zoom);
			luaModchart.setVar('cameraZoom', FlxG.camera.zoom);
			luaModchart.executeState('update', [elapsed]);

			for (i in luaWiggles)
			{
				trace('wiggle le gaming');
				i.update(elapsed);
			}

			if (hasLua){
				FlxG.camera.angle = luaModchart.getVar('cameraAngle', 'float');
				camHUD.angle = luaModchart.getVar('camHudAngle', 'float');
			}
			//shortcut #4

			if (luaModchart.getVar("showOnlyStrums", 'bool'))
			{
				healthBarBG.visible = false;
				kadeEngineWatermark.visible = false;
				healthBar.visible = false;
				iconP1.visible = false;
				iconP2.visible = false;
				scoreTxt.visible = false;
			}
			else
			{
				healthBarBG.visible = true;
				kadeEngineWatermark.visible = true;
				healthBar.visible = true;
				iconP1.visible = true;
				iconP2.visible = true;
				scoreTxt.visible = true;
			}

			var p1 = luaModchart.getVar("strumLine1Visible", 'bool');
			var p2 = luaModchart.getVar("strumLine2Visible", 'bool');

			for (i in 0...4)
			{
				strumLineNotes.members[i].visible = p1;
				if (i <= playerStrums.length)
					playerStrums.members[i].visible = p2;
			}
		}
		#end

		// reverse iterate to remove oldest notes first and not invalidate the iteration
		// stop iteration as soon as a note is not removed
		// all notes should be kept in the correct order and this is optimal, safe to do every frame/update
		{
			var balls = notesHitArray.length - 1;
			while (balls >= 0)
			{
				var cock:Date = notesHitArray[balls];
				if (cock != null && cock.getTime() + 1000 < Date.now().getTime())
					notesHitArray.remove(cock);
				else
					balls = 0;
				balls--;
			}
			nps = notesHitArray.length;
			if (nps > maxNPS)
				maxNPS = nps;
		}

		switch (curStage)
		{
			case 'philly':
				if (trainMoving && !PlayStateChangeables.Optimize)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
		}

		if (FlxG.save.data.lessUpdate)
			super.update(elapsed/2);
		else
			super.update(elapsed);
			
		if (bg != null && things != null) {
			if (bg.animation.finished)
				bg.animation.play("idle");
			if (things.animation.finished)
				things.animation.play("idle");
		}
		
		//check system for Mobilecontrols 
		#if android
		if (mcontrols != null) {
			/*switch (mcontrols.mode) {
				case VIRTUALPAD_CUSTOM | VIRTUALPAD_LEFT | VIRTUALPAD_RIGHT:
					if (mcontrols._virtualPad.buttonLeft.justReleased)
						releaseMobile(0);
					if (mcontrols._virtualPad.buttonDown.justReleased)
						releaseMobile(1);
					if (mcontrols._virtualPad.buttonUp.justReleased)
						releaseMobile(2);
					if (mcontrols._virtualPad.buttonRight.justReleased)
						releaseMobile(3);
				case HITBOX:
					if (mcontrols._hitbox.buttonLeft.justReleased)
						releaseMobile(0);
					if (mcontrols._hitbox.buttonDown.justReleased)
						releaseMobile(1);
					if (mcontrols._hitbox.buttonUp.justReleased)
						releaseMobile(2);
					if (mcontrols._hitbox.buttonRight.justReleased)
						releaseMobile(3);
				default:
			}*/
			if (controls.LEFT)
				handleMobile(0);
			if (controls.DOWN)
				handleMobile(1);
			if (controls.UP)
				handleMobile(2);
			if (controls.RIGHT)
				handleMobile(3);
			
			if (controls.LEFT_R)
				releaseMobile(0);
			if (controls.DOWN_R)
				releaseMobile(1);
			if (controls.UP_R)
				releaseMobile(2);
			if (controls.RIGHT_R)
				releaseMobile(3);
		}
		#end

		if (PlayState.SONG.song.toLowerCase() == 'disco' && PlayState.misses == 0 && MusicBeatState.songEnded && !FlxG.save.data.BluSpy && !MusicBeatState.dontSpam)
			medalPop('Blue Spy');

		if (PlayState.misses > 100 && MusicBeatState.songEnded && !FlxG.save.data.TOUHOU && !MusicBeatState.dontSpam)
			medalPop('TOUHOU Bit');

		if (!FlxG.save.data.ECHO && !MusicBeatState.dontSpam && MusicBeatState.songEnded && PlayState.SONG.song.toLowerCase() == 'alterbyte')
			medalPop('ECHO');

		if (!FlxG.save.data.Firewall && !MusicBeatState.dontSpam && MusicBeatState.songEnded && PlayState.misses == 0 && PlayState.SONG.song.toLowerCase() == 'intoxicate')
			medalPop('Firewall');

		if (!FlxG.save.data.TWTMF && !MusicBeatState.dontSpam && PlayState.misses == 0 && MusicBeatState.songEnded && PlayState.SONG.song.toLowerCase() == '4th song')
			medalPop('TWTMF');

		scoreTxt.text = Ratings.CalculateRanking(songScore, songScoreDef, nps, maxNPS, accuracy);

		var lengthInPx = scoreTxt.textField.length * scoreTxt.frameHeight; // bad way but does more or less a better job

		scoreTxt.x = (originalX - (lengthInPx / 2)) + 335;

		if ((controls.PAUSE #if android || FlxG.android.justPressed.BACK #end) && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			// 1 / 100 chance for Gitaroo Man easter egg
			if (FlxG.random.bool(1))
			{
				trace('GITAROO MAN EASTER EGG');
				FlxG.switchState(new GitarooPause());
			}
			else
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}

		if (FlxG.keys.justPressed.SEVEN)
		{
			if (useVideo)
			{
				GlobalVideo.get().stop();
				remove(videoSprite);
				#if sys
				FlxG.stage.window.onFocusOut.remove(focusOut);
				FlxG.stage.window.onFocusIn.remove(focusIn);
				#end
				removedVideo = true;
			}
			cannotDie = true;
			#if windows
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
			FlxG.switchState(new ChartingState());
			#if desktop
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(iconP1.width, 150, 0.09 / (120 / 60))));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(iconP2.width, 150, 0.09 / (120 / 60))));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2)
			health = 2;

		if (healthBar.percent < 20 && !isLosing)
			changeMood(false);
		else
			changeMood(false,true);
		

		if (healthBar.percent > 80 && !isWinning)
			changeMood(true);
		else
			changeMood(false,true);
		

		#if debug
		if (FlxG.keys.justPressed.SIX)
		{
			if (useVideo)
			{
				GlobalVideo.get().stop();
				remove(videoSprite);
				FlxG.stage.window.onFocusOut.remove(focusOut);
				FlxG.stage.window.onFocusIn.remove(focusIn);
				removedVideo = true;
			}

			FlxG.switchState(new AnimationDebug(SONG.player2));
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			#if windows
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}

		if (FlxG.keys.justPressed.ZERO)
		{
			FlxG.switchState(new AnimationDebug(SONG.player1));
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			#if windows
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}
		
		if(FlxG.keys.justPressed.TWO) { //Go 10 seconds into the future, credit: Shadow Mario#9396
			trace('why tf use this');
			if (!usedTimeTravel && Conductor.songPosition + 10000 < FlxG.sound.music.length) 
			{
				usedTimeTravel = true;
				FlxG.sound.music.pause();
				vocals.pause();
				Conductor.songPosition += 10000;
				notes.forEachAlive(function(daNote:Note)
				{
					if(daNote.strumTime - 500 < Conductor.songPosition) {
						daNote.active = false;
						daNote.visible = false;

					
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				});
				for (i in 0...unspawnNotes.length) {
					var daNote:Note = unspawnNotes[0];
					if(daNote.strumTime - 500 >= Conductor.songPosition) {
						break;
					}
					unspawnNotes.splice(unspawnNotes.indexOf(daNote), 1);
				}

				FlxG.sound.music.time = Conductor.songPosition;
				FlxG.sound.music.play();

				vocals.time = Conductor.songPosition;
				vocals.play();
				new FlxTimer().start(0.5, function(tmr:FlxTimer)
					{
						usedTimeTravel = false;
					});
			}
		}
		#end

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			Conductor.songPosition += FlxG.elapsed * 1000;
			songPositionBar = Conductor.songPosition;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
				}
			}

		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			// Make sure Girlfriend cheers only for certain songs
			if (allowedToHeadbang)
			{
				// Don't animate GF if something else is already animating her (eg. train passing)
				if (gf.animation.curAnim.name == 'danceLeft'
					|| gf.animation.curAnim.name == 'danceRight'
					|| gf.animation.curAnim.name == 'idle')
				{
					// Per song treatment since some songs will only have the 'Hey' at certain times
					switch (curSong)
					{
						case 'Philly Nice':
							{
								// General duration of the song
								if (curBeat < 250)
								{
									// Beats to skip or to stop GF from cheering
									if (curBeat != 184 && curBeat != 216)
									{
										if (curBeat % 16 == 8)
										{
											// Just a garantee that it'll trigger just once
											if (!triggeredAlready)
											{
												gf.playAnim('cheer');
												triggeredAlready = true;
											}
										}
										else
											triggeredAlready = false;
									}
								}
							}
						case 'Bopeebo':
							{
								// Where it starts || where it ends
								if (curBeat > 5 && curBeat < 130)
								{
									if (curBeat % 8 == 7)
									{
										if (!triggeredAlready)
										{
											gf.playAnim('cheer');
											triggeredAlready = true;
										}
									}
									else
										triggeredAlready = false;
								}
							}
						case 'Blammed':
							{
								if (curBeat > 30 && curBeat < 190)
								{
									if (curBeat < 90 || curBeat > 128)
									{
										if (curBeat % 4 == 2)
										{
											if (!triggeredAlready)
											{
												gf.playAnim('cheer');
												triggeredAlready = true;
											}
										}
										else
											triggeredAlready = false;
									}
								}
							}
						case 'Cocoa':
							{
								if (curBeat < 170)
								{
									if (curBeat < 65 || curBeat > 130 && curBeat < 145)
									{
										if (curBeat % 16 == 15)
										{
											if (!triggeredAlready)
											{
												gf.playAnim('cheer');
												triggeredAlready = true;
											}
										}
										else
											triggeredAlready = false;
									}
								}
							}
						case 'Eggnog':
							{
								if (curBeat > 10 && curBeat != 111 && curBeat < 220)
								{
									if (curBeat % 8 == 7)
									{
										if (!triggeredAlready)
										{
											gf.playAnim('cheer');
											triggeredAlready = true;
										}
									}
									else
										triggeredAlready = false;
								}
							}
					}
				}
			}

			#if windows
			if (luaModchart != null)
				luaModchart.setVar("mustHit", PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			#end

			if ((camFollow.x != dad.getMidpoint().x + 150 && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection) || (SONG.forceDad && !SONG.forceBf && SONG.forceMiddle))
			{
				var offsetX = 0;
				var offsetY = 0;
				#if windows
				if (luaModchart != null)
				{
					offsetX = luaModchart.getVar("followXOffset", "float");
					offsetY = luaModchart.getVar("followYOffset", "float");
				}
				#end
				camFollow.setPosition(dad.getMidpoint().x + 150 + offsetX, dad.getMidpoint().y - 100 + offsetY);
				#if windows
				if (luaModchart != null)
					luaModchart.executeState('playerTwoTurn', []);
				#end

				switch (dad.curCharacter)
				{
					case 'virus' | 'error' | 'bit' | 'fake'://probably most cavemanish way to do shit but ehhh who cares.
						switch (dad.animation.curAnim.name){
							case 'singDOWN':
								camFollow.x = dad.getMidpoint().x - 100;
								camFollow.y = dad.getMidpoint().y - 400;
							case 'singUP':
								camFollow.x = dad.getMidpoint().x - 100;
								camFollow.y = dad.getMidpoint().y - 460;
							case 'singRIGHT':
								camFollow.x = dad.getMidpoint().x - 70;
								camFollow.y = dad.getMidpoint().y - 430;
							case 'singLEFT':
								camFollow.x = dad.getMidpoint().x - 130;
								camFollow.y = dad.getMidpoint().y - 430;
							default:
								camFollow.y = dad.getMidpoint().y - 430;
								camFollow.x = dad.getMidpoint().x - 100;
						}
					case 'virus-mad':
						switch (dad.animation.curAnim.name){
							case 'singRIGHT':
								camFollow.y = dad.getMidpoint().y - 1050;
								camFollow.x = dad.getMidpoint().x - 390;
							case 'singLEFT':
								camFollow.y = dad.getMidpoint().y - 1050;
								camFollow.x = dad.getMidpoint().x - 450;
							case 'singDOWN':
								camFollow.y = dad.getMidpoint().y - 1020;
								camFollow.x = dad.getMidpoint().x - 420;
							case 'singUP':
								camFollow.y = dad.getMidpoint().y - 1080;
								camFollow.x = dad.getMidpoint().x - 420;
							default:
								camFollow.y = dad.getMidpoint().y - 1050;
								camFollow.x = dad.getMidpoint().x - 420;
						}
				}
			}

			if ((PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && camFollow.x != boyfriend.getMidpoint().x - 100) || (SONG.forceBf && !SONG.forceDad && !SONG.forceMiddle))
			{
				var offsetX = 0;
				var offsetY = 0;
				#if windows
				if (luaModchart != null)
				{
					offsetX = luaModchart.getVar("followXOffset", "float");
					offsetY = luaModchart.getVar("followYOffset", "float");
				}
				#end
				camFollow.setPosition(boyfriend.getMidpoint().x - 100 + offsetX, boyfriend.getMidpoint().y - 100 + offsetY);

				#if windows
				if (luaModchart != null)
					luaModchart.executeState('playerOneTurn', []);
				#end

				switch (curStage)
				{
					case 'darkroom' | 'void':
						switch (boyfriend.animation.curAnim.name){
							case 'singRIGHT':
								camFollow.x = boyfriend.getMidpoint().x - 435;
								camFollow.y = boyfriend.getMidpoint().y - 370;
							case 'singLEFT':
								camFollow.x = boyfriend.getMidpoint().x - 465;
								camFollow.y = boyfriend.getMidpoint().y - 370;
							case 'singDOWN':
								camFollow.x = boyfriend.getMidpoint().x - 460;
								camFollow.y = boyfriend.getMidpoint().y - 345;
							case 'singUP':
								camFollow.x = boyfriend.getMidpoint().x - 460;
								camFollow.y = boyfriend.getMidpoint().y - 405;
							default:
								camFollow.x = boyfriend.getMidpoint().x - 460;
								camFollow.y = boyfriend.getMidpoint().y - 370;
						}
					case 'schoolEvil':
						camFollow.x = boyfriend.getMidpoint().x - 200;
						camFollow.y = boyfriend.getMidpoint().y - 200;
				}
			}
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
			camHUDNOTES.zoom = FlxMath.lerp(1, camHUDNOTES.zoom, 0.95);
		}

		FlxG.watch.addQuick("curBPM", Conductor.bpm);
		FlxG.watch.addQuick("Closest Note", (unspawnNotes.length != 0 ? unspawnNotes[0].strumTime - Conductor.songPosition : "No note"));

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		if (curSong == 'Fresh')
		{
			switch (curBeat)
			{
				case 16:
					camZooming = true;
					gfSpeed = 2;
				case 48:
					gfSpeed = 1;
				case 80:
					gfSpeed = 2;
				case 112:
					gfSpeed = 1;
				case 163:
			}
		}

		if (curSong == 'Bopeebo')
		{
			switch (curBeat)
			{
				case 128, 129, 130:
					vocals.volume = 0;
			}
		}

		if (health <= 0 && !cannotDie)
		{
			if (!usedTimeTravel) 
			{
				boyfriend.stunned = true;

				persistentUpdate = false;
				persistentDraw = false;
				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();
				MusicBeatState.deaths += 1;

				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

				#if windows
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("GAME OVER -- "
					+ SONG.song
					+ " ("
					+ storyDifficultyText
					+ ") "
					+ Ratings.GenerateLetterRank(accuracy),
					"\nAcc: "
					+ HelperFunctions.truncateFloat(accuracy, 2)
					+ "% | Score: "
					+ songScore
					+ " | Misses: "
					+ misses, iconRPC);
				#end
			}
			else
				health = 1;
		}
		if (!inCutscene && resetButton)
		{
			if (FlxG.keys.justPressed.R)
			{
				boyfriend.stunned = true;

				persistentUpdate = false;
				persistentDraw = false;
				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();

				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

				#if windows
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("GAME OVER -- "
					+ SONG.song
					+ " ("
					+ storyDifficultyText
					+ ") "
					+ Ratings.GenerateLetterRank(accuracy),
					"\nAcc: "
					+ HelperFunctions.truncateFloat(accuracy, 2)
					+ "% | Score: "
					+ songScore
					+ " | Misses: "
					+ misses, iconRPC);
				#end
			}
		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 3500)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];

			notes.forEachAlive(function(daNote:Note)
			{
				// instead of doing stupid y > FlxG.height
				// we be men and actually calculate the time :)
				if (daNote.tooLate)
				{
					daNote.active = false;
					daNote.visible = false;
				}
				else
				{
					daNote.visible = true;
					daNote.active = true;
				}

				if (!daNote.modifiedByLua)
				{
					if (PlayStateChangeables.useDownscroll)
					{
						if (daNote.mustPress)
							daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y
								+ 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
									2)) - daNote.noteYOff;
						else
							daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
								+ 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
									2)) - daNote.noteYOff;
						if (daNote.isSustainNote)
						{
							// Remember = minus makes notes go up, plus makes them go down
							if (daNote.animation.curAnim.name.endsWith('end') && daNote.prevNote != null)
								daNote.y += daNote.prevNote.height;
							else
								daNote.y += daNote.height / 2;

							// If not in botplay, only clip sustain notes when properly hit, botplay gets to clip it everytime
							if (!PlayStateChangeables.botPlay)
							{
								if ((!daNote.mustPress || daNote.wasGoodHit || daNote.prevNote.wasGoodHit && !daNote.canBeHit)
									&& daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= (strumLine.y + Note.swagWidth / 2))
								{
									// Clip to strumline
									var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
									swagRect.height = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
										+ Note.swagWidth / 2
										- daNote.y) / daNote.scale.y;
									swagRect.y = daNote.frameHeight - swagRect.height;

									daNote.clipRect = swagRect;
								}
							}
							else
							{
								var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
								swagRect.height = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
									+ Note.swagWidth / 2
									- daNote.y) / daNote.scale.y;
								swagRect.y = daNote.frameHeight - swagRect.height;

								daNote.clipRect = swagRect;
							}
						}
					}
					else
					{
						if (daNote.mustPress)
							daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y
								- 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
									2)) + daNote.noteYOff;
						else
							daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
								- 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
									2)) + daNote.noteYOff;
						if (daNote.isSustainNote)
						{
							daNote.y -= daNote.height / 2;

							if (!PlayStateChangeables.botPlay)
							{
								if ((!daNote.mustPress || daNote.wasGoodHit || daNote.prevNote.wasGoodHit && !daNote.canBeHit)
									&& daNote.y + daNote.offset.y * daNote.scale.y <= (strumLine.y + Note.swagWidth / 2))
								{
									// Clip to strumline
									var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
									swagRect.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
										+ Note.swagWidth / 2
										- daNote.y) / daNote.scale.y;
									swagRect.height -= swagRect.y;

									daNote.clipRect = swagRect;
								}
							}
							else
							{
								var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
								swagRect.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
									+ Note.swagWidth / 2
									- daNote.y) / daNote.scale.y;
								swagRect.height -= swagRect.y;

								daNote.clipRect = swagRect;
							}
						}
					}
				}

				if (!daNote.mustPress && daNote.wasGoodHit)
				{
					if (SONG.song != 'Tutorial')
						camZooming = true;

					var altAnim:String = "";

					if (SONG.notes[Math.floor(curStep / 16)] != null)
					{
						if (SONG.notes[Math.floor(curStep / 16)].altAnim)
							altAnim = '-alt';
					}
					
					// Accessing the animation name directly to play it
					var singData:Int = Std.int(Math.abs(daNote.noteData));
					if (!fuckingAnimationPlaying)
						dad.playAnim('sing' + dataSuffix[singData] + altAnim, true);
					if (cpuStrumsA)
					{
						cpuStrums.forEach(function(spr:FlxSprite)
						{
							if (Math.abs(daNote.noteData) == spr.ID)
							{
								spr.animation.play('confirm', true);
							}
							if (spr.animation.curAnim.name == 'confirm' && !cool)
							{
								spr.centerOffsets();
								spr.offset.x -= 13;
								spr.offset.y -= 13;
							}
							else
								spr.centerOffsets();
						});
					}

					#if windows
					if (luaModchart != null)
						luaModchart.executeState('playerTwoSing', [Math.abs(daNote.noteData), Conductor.songPosition]);
					#end

					dad.holdTimer = 0;

					if (SONG.needsVoices)
						vocals.volume = 1;

					daNote.active = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}

				if (daNote.mustPress && !daNote.modifiedByLua)
				{
					daNote.visible = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].visible;
					daNote.x = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].x;
					if (!daNote.isSustainNote)
						daNote.modAngle = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].angle;
					if (daNote.sustainActive)
						daNote.alpha = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].alpha;
					daNote.modAngle = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].angle;
				}
				else if (!daNote.wasGoodHit && !daNote.modifiedByLua)
				{
					daNote.visible = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].visible;
					daNote.x = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].x;
					if (!daNote.isSustainNote)
						daNote.modAngle = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].angle;
					if (daNote.sustainActive)
						daNote.alpha = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].alpha;
					daNote.modAngle = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].angle;
				}

				if (daNote.isSustainNote)
				{
					daNote.x += daNote.width / 2 + 20;
					if (cool)
						daNote.x -= 11;
				}

				// WIP interpolation shit? Need to fix the pause issue

				if ((daNote.mustPress && daNote.tooLate && !PlayStateChangeables.useDownscroll || daNote.mustPress && daNote.tooLate
					&& PlayStateChangeables.useDownscroll)
					&& daNote.mustPress)
				{
					if (daNote.isSustainNote && daNote.wasGoodHit)
						{
							daNote.kill();
							notes.remove(daNote, true);
						}
						else
						{
							if (loadRep && daNote.isSustainNote)
							{
								// im tired and lazy this sucks I know i'm dumb
								if (findByTime(daNote.strumTime) != null)
									totalNotesHit += 1;
								else
								{
									if (!daNote.isSustainNote)
										health -= 0.10;
									vocals.volume = 0;
									if (theFunne && !daNote.isSustainNote)
										noteMiss(daNote.noteData, daNote);
									if (daNote.isParent)
									{
										health -= 0.20; // give a health punishment for failing a LN
										trace("hold fell over at the start");
										for (i in daNote.children)
										{
											i.alpha = 0.3;
											i.sustainActive = false;
										}
									}
									else
									{
										if (!daNote.wasGoodHit
											&& daNote.isSustainNote
											&& daNote.sustainActive
											&& daNote.spotInLine != daNote.parent.children.length)
										{
											health -= 0.20; // give a health punishment for failing a LN
											trace("hold fell over at " + daNote.spotInLine);
											for (i in daNote.parent.children)
											{
												i.alpha = 0.3;
												i.sustainActive = false;
											}
											if (daNote.parent.wasGoodHit)
												misses++;
											updateAccuracy();
										}
									}
								}
							}
							else
							{
								if (!daNote.isSustainNote)
									health -= 0.10;
								vocals.volume = 0;
								if (theFunne && !daNote.isSustainNote)
									noteMiss(daNote.noteData, daNote);

								if (daNote.isParent)
								{
									health -= 0.20; // give a health punishment for failing a LN
									trace("hold fell over at the start");
									for (i in daNote.children)
									{
										i.alpha = 0.3;
										i.sustainActive = false;
										trace(i.alpha);
									}
								}
								else
								{
									if (!daNote.wasGoodHit
										&& daNote.isSustainNote
										&& daNote.sustainActive
										&& daNote.spotInLine != daNote.parent.children.length)
									{
										health -= 0.20; // give a health punishment for failing a LN
										trace("hold fell over at " + daNote.spotInLine);
										for (i in daNote.parent.children)
										{
											i.alpha = 0.3;
											i.sustainActive = false;
											trace(i.alpha);
										}
										if (daNote.parent.wasGoodHit)
											misses++;
										updateAccuracy();
									}
								}
							}
						}

						daNote.visible = false;
						daNote.kill();
						notes.remove(daNote, true);
					}
			});
		}

		if (cpuStrums != null)
		{
			cpuStrums.forEach(function(spr:FlxSprite)
			{
				if (spr.animation.finished)
				{
					spr.animation.play('static');
					spr.centerOffsets();
				}
			});
		}

		if (!inCutscene && songStarted)
			keyShit();

		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end

		// yes this is bad
		// but i'm doing it to update misses and accuracy
		#if windows
		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"Acc: "
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC, true,
			songLength
			- Conductor.songPosition);
		#end
	}
	
	function changeMood(winning:Bool, ?normal:Bool = false){
		if (winning && !isWinning && !normal){
			iconp1Anim = boyfriend.curCharacter + "-win";
			iconp2Anim = dad.curCharacter + "-lose";
			isWinning = true;
			isLosing = false;
		}
		if (!winning && !isLosing && !normal){
			iconp1Anim = boyfriend.curCharacter + "-lose";
			iconp2Anim = dad.curCharacter + "-win";
			isWinning = false;
			isLosing = true;
		}
		if (normal){
			isLosing = false;
			isWinning = false;
			iconp2Anim = dad.curCharacter;
			iconp1Anim = boyfriend.curCharacter;
		}
	}

	function endSong():Void
	{
		#if (android || ios)
		//aaa
		new FlxTimer().start(0.1, function(tmr:FlxTimer)
		{
			mcontrols.alpha -= 0.1;
			if (mcontrols.alpha != 0){
				tmr.reset(0.1);
			}
			else{
				trace('aweseom.');
			}
		});
		#end
		/*if (FlxG.save.data.storyBeated){
			MusicBeatState.songEnded = true;
			MusicBeatState.endedSongs += 1;
			if (MusicBeatState.endedSongs == 5)
				MusicBeatState.storyCompleted = true;
		}*/
		#if desktop
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
		#end
		if (useVideo)
		{
			GlobalVideo.get().stop();
			FlxG.stage.window.onFocusOut.remove(focusOut);
			FlxG.stage.window.onFocusIn.remove(focusIn);
			PlayState.instance.remove(PlayState.instance.videoSprite);
		}

		if (isStoryMode)
			campaignMisses = misses;
		#if desktop
		if (!loadRep)
			rep.SaveReplay(saveNotes, saveJudge, replayAna);
		#end
		else
		{
			PlayStateChangeables.botPlay = false;
			PlayStateChangeables.scrollSpeed = 1;
			PlayStateChangeables.useDownscroll = false;
		}

		if (fpsCap > 290)
			(cast(Lib.current.getChildAt(0), Main)).setFPSCap(290);

		#if windows
		if (luaModchart != null)
		{
			luaModchart.die();
			luaModchart = null;
		}
		#end

		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		FlxG.sound.music.pause();
		vocals.pause();
		if (SONG.validScore)
		{
			// adjusting the highscore song name to be compatible
			// would read original scores if we didn't change packages
			var songHighscore = StringTools.replace(PlayState.SONG.song, " ", "-");
			switch (songHighscore)
			{
				case 'Dad-Battle':
					songHighscore = 'Dadbattle';
				case 'Philly-Nice':
					songHighscore = 'Philly';
			}

			#if !switch
			/*Highscore.saveScore(songHighscore, Math.round(songScore), storyDifficulty);
			Highscore.saveCombo(songHighscore, Ratings.GenerateLetterRank(accuracy), storyDifficulty);*/
			#end
			if ((FlxG.save.data.discoScore == 0 || FlxG.save.data.discoScore < songScore) && SONG.song.toLowerCase() == "disco"){
				FlxG.save.data.discoScore = songScore;
				if (FlxGameJolt._initialized){
					FlxGameJolt.addScore("" + FlxG.save.data.discoScore + "points", FlxG.save.data.discoScore, 657398, false, "", "" + FlxG.save.data.user);
					KeyJolt.setData(3, Std.string(FlxG.save.data.discoScore), true);
				}
			}
			if ((FlxG.save.data.intoxicateScore == 0 || FlxG.save.data.intoxicateScore < songScore) && SONG.song.toLowerCase() == "intoxicate"){
				FlxG.save.data.intoxicateScore = songScore;
				if (FlxGameJolt._initialized){
					FlxGameJolt.addScore("" + FlxG.save.data.intoxicateScore + "points", FlxG.save.data.intoxicateScore, 654903, false, "", "" + FlxG.save.data.user);
					KeyJolt.setData(4, Std.string(FlxG.save.data.intoxicateScore), true);
				}
			}
			if (isStoryMode){
				switch (SONG.song.toLowerCase()){
					case "disco":
						FlxG.save.data.discoDone = true;
						if (FlxGameJolt._initialized)
							KeyJolt.setData(1, "true", true);
					case "intoxicate":
						FlxG.save.data.intoxicateDone = true;
						if(FlxGameJolt._initialized)
							KeyJolt.setData(2, "true", true);
				}
				if (FlxG.save.data.discoDone && FlxG.save.data.intoxicateDone && SONG.song.toLowerCase() == "intoxicate"){
					if (FlxGameJolt._initialized)
						KeyJolt.setData(0, "true", true);
					switch (storyDifficulty){
						case 0:
							FlxG.save.data.storyBeatedEz = true;
							FlxG.save.data.storyBeated = true;
						case 1:
							FlxG.save.data.storyBeatedNom = true;
							FlxG.save.data.storyBeated = true;
						case 2:
							FlxG.save.data.storyBeatedHard = true;
							FlxG.save.data.storyBeated = true;
						//case 0 | 1 | 2:
							
					}
				}
			}
		}

		if (offsetTesting)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			offsetTesting = false;
			LoadingState.loadAndSwitchState(new OptionsMenu());
			offset = Std.int(offsetTest);
		}
		else
		{
			if (isStoryMode)
			{
				campaignScore += Math.round(songScore);

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					transIn = FlxTransitionableState.defaultTransIn;
					transOut = FlxTransitionableState.defaultTransOut;

					paused = true;

					FlxG.sound.music.stop();
					vocals.stop();
					if (scoreScreen)
					{
						openSubState(new ResultsScreen());
						new FlxTimer().start(1, function(tmr:FlxTimer)
							{
								inResults = true;
							});
					}
					else
					{
						FlxG.sound.playMusic(Paths.music('freakyMenu'));
						Conductor.changeBPM(102);
						FlxG.switchState(new MainMenuState());
					}

					#if windows
					if (luaModchart != null)
					{
						luaModchart.die();
						luaModchart = null;
					}
					#end

					if (SONG.validScore)
					{
						#if newgrounds
						NGio.unlockMedal(60961);
						#end
						Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
					}

					//StoryMenuState.unlockNextWeek(storyWeek);
				}
				else
				{
					// adjusting the song name to be compatible
					var songFormat = StringTools.replace(PlayState.storyPlaylist[0], " ", "-");
					switch (songFormat)
					{
						case 'Dad-Battle':
							songFormat = 'Dadbattle';
						case 'Philly-Nice':
							songFormat = 'Philly';
					}

					var poop:String = Highscore.formatSong(songFormat, storyDifficulty);

					trace('LOADING NEXT SONG');
					trace(poop);

					if (StringTools.replace(PlayState.storyPlaylist[0], " ", "-").toLowerCase() == 'eggnog')
					{
						var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
							-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
						blackShit.scrollFactor.set();
						add(blackShit);
						camHUD.visible = false;

						FlxG.sound.play(Paths.sound('Lights_Shut_off'));
					}

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					prevCamFollow = camFollow;

					PlayState.SONG = Song.loadFromJson(poop, PlayState.storyPlaylist[0]);
					FlxG.sound.music.stop();

					LoadingState.loadAndSwitchState(new PlayState());
				}
			}
			else
			{
				trace('WENT BACK TO FREEPLAY??');

				paused = true;

				FlxG.sound.music.stop();
				vocals.stop();

				if (scoreScreen) 
				{
					openSubState(new ResultsScreen());
					new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							inResults = true;
						});
				}
				else
					FlxG.switchState(new NewFreeplay());
			}
		}
	}

	private function popUpScore(daNote:Note):Void
	{
		var noteDiff:Float = -(daNote.strumTime - Conductor.songPosition);
		var wife:Float = EtternaFunctions.wife3(-noteDiff, Conductor.timeScale);
		vocals.volume = 1;
		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		coolText.y -= 350;
		coolText.cameras = [camHUD];

		var rating:FlxSprite = new FlxSprite();
		var score:Float = 350;

		if (accuracyMod == 1)
			totalNotesHit += wife;

		var daRating = daNote.rating;

		switch (daRating)
		{
			case 'shit':
				score = -300;
				combo = 0;
				misses++;
				health -= 0.06;
				ss = false;
				shits++;
				if (accuracyMod == 0)
					totalNotesHit -= 1;
			case 'bad':
				daRating = 'bad';
				score = 0;
				health -= 0.03;
				ss = false;
				bads++;
				if (accuracyMod == 0)
					totalNotesHit += 0.50;
			case 'good':
				daRating = 'good';
				score = 200;
				ss = false;
				goods++;
				if (accuracyMod == 0)
					totalNotesHit += 0.75;
			case 'sick':
				if (health < 2)
					health += 0.04;
				if (accuracyMod == 0)
					totalNotesHit += 1;
				sicks++;
				var recycledNote = grpNoteSplashes.recycle(NoteSplash);
				if (PlayStateChangeables.useDownscroll){
					switch (daNote.noteData){
						case 1:
							recycledNote.setupNoteSplash(daNote.x + 40,strumLine.y + 40, 1);
							//Note.swagWidth * 2;
						case 2:
							recycledNote.setupNoteSplash(daNote.x + 40, strumLine.y + 40, 2);
						case 3:
							recycledNote.setupNoteSplash(daNote.x + 40, strumLine.y + 40, 3);
						case 0:
							recycledNote.setupNoteSplash(daNote.x + 40, strumLine.y + 40, 0);
						default:
							recycledNote.setupNoteSplash(daNote.x + 40, strumLine.y + 40, 0);
					}//shortcut #2
				}else{
					switch (daNote.noteData){
						case 1:
							recycledNote.setupNoteSplash(daNote.x + 40,strumLine.y + 60, 1);
							//Note.swagWidth * 2;
						case 2:
							recycledNote.setupNoteSplash(daNote.x + 40, strumLine.y + 60, 2);
						case 3:
							recycledNote.setupNoteSplash(daNote.x + 40, strumLine.y + 60, 3);
						case 0:
							recycledNote.setupNoteSplash(daNote.x + 40, strumLine.y + 60, 0);
						default:
							recycledNote.setupNoteSplash(daNote.x + 60, strumLine.y + 60, 0);
					}//shortcut #2
				}
				grpNoteSplashes.add(recycledNote);
		}

		if (daRating != 'shit' || daRating != 'bad')
		{
			songScore += Math.round(score);
			songScoreDef += Math.round(ConvertScore.convertScore(noteDiff));

			/* if (combo > 60)
					daRating = 'sick';
				else if (combo > 12)
					daRating = 'good'
				else if (combo > 4)
					daRating = 'bad';
			 */

			var pixelShitPart1:String = "";
			var pixelShitPart2:String = '';

			if (curStage.startsWith('school') || curStage == 'darkroom')
			{
				pixelShitPart1 = 'weeb/pixelUI';
				pixelShitPart2 = '-pixel';
			}

			rating.loadGraphic(Paths.image('8bit/' + daRating + '-pixel', 'shared'));
			rating.screenCenter();
			rating.y -= 50;
			rating.x = coolText.x - 125;

			if (changedHit)
			{
				rating.x = FlxG.save.data.changedHitX;
				rating.y = FlxG.save.data.changedHitY;
			}
			rating.acceleration.y = 550;
			rating.velocity.y -= FlxG.random.int(140, 175);
			rating.velocity.x -= FlxG.random.int(0, 10);

			var msTiming = HelperFunctions.truncateFloat(noteDiff, 3);
			if (PlayStateChangeables.botPlay && !loadRep)
				msTiming = 0;

			if (loadRep)
				msTiming = HelperFunctions.truncateFloat(findByTime(daNote.strumTime)[3], 3);

			if (currentTimingShown != null)
				remove(currentTimingShown);

			currentTimingShown = new FlxText(0, 0, 0, "0ms");
			timeShown = 0;
			switch (daRating)
			{
				case 'shit' | 'bad':
					currentTimingShown.color = FlxColor.RED;
				case 'good':
					currentTimingShown.color = FlxColor.GREEN;
				case 'sick':
					currentTimingShown.color = FlxColor.CYAN;
			}
			currentTimingShown.borderStyle = OUTLINE;
			currentTimingShown.borderSize = 1;
			currentTimingShown.borderColor = FlxColor.BLACK;
			currentTimingShown.text = msTiming + "ms";
			currentTimingShown.size = 20;

			if (msTiming >= 0.03 && offsetTesting)
			{
				// Remove Outliers
				hits.shift();
				hits.shift();
				hits.shift();
				hits.pop();
				hits.pop();
				hits.pop();
				hits.push(msTiming);

				var total = 0.0;

				for (i in hits)
					total += i;

				offsetTest = HelperFunctions.truncateFloat(total / hits.length, 2);
			}

			if (currentTimingShown.alpha != 1)
				currentTimingShown.alpha = 1;

			if (!PlayStateChangeables.botPlay || loadRep)
				add(currentTimingShown);

			var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image('weeb/pixelUI/combo-pixel', 'week6'));
			comboSpr.screenCenter();
			comboSpr.x = rating.x;
			comboSpr.y = rating.y + 100;
			comboSpr.acceleration.y = 600;
			comboSpr.velocity.y -= 150;

			currentTimingShown.screenCenter();
			currentTimingShown.x = comboSpr.x + 100;
			currentTimingShown.y = rating.y + 100;
			currentTimingShown.acceleration.y = 600;
			currentTimingShown.velocity.y -= 150;

			comboSpr.velocity.x += FlxG.random.int(1, 10);
			currentTimingShown.velocity.x += comboSpr.velocity.x;
			if (!PlayStateChangeables.botPlay || loadRep){
				add(rating);
				if (combo > 10)
					add(comboSpr);
			}


			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));


			currentTimingShown.updateHitbox();
			comboSpr.updateHitbox();
			rating.updateHitbox();

			currentTimingShown.cameras = [camHUD];
			comboSpr.cameras = [camHUD];
			rating.cameras = [camHUD];

			var seperatedScore:Array<Int> = [];

			var comboSplit:Array<String> = (combo + "").split('');

			if (combo > highestCombo)
				highestCombo = combo;

			// make sure we have 3 digits to display (looks weird otherwise lol)
			if (comboSplit.length == 1)
			{
				seperatedScore.push(0);
				seperatedScore.push(0);
			}
			else if (comboSplit.length == 2)
				seperatedScore.push(0);

			for (i in 0...comboSplit.length)
			{
				var str:String = comboSplit[i];
				seperatedScore.push(Std.parseInt(str));
			}

			var daLoop:Int = 0;
			for (i in seperatedScore)
			{
				var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image('weeb/pixelUI/num' + Std.int(i) + '-pixel', 'week6'));
				numScore.screenCenter();
				numScore.x = rating.x + (43 * daLoop) - 50;
				numScore.y = rating.y + 100;
				numScore.cameras = [camHUD];


				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));

				numScore.updateHitbox();

				numScore.acceleration.y = FlxG.random.int(200, 300);
				numScore.velocity.y -= FlxG.random.int(140, 160);
				numScore.velocity.x = FlxG.random.float(-5, 5);

				add(numScore);

				FlxTween.tween(numScore, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						numScore.destroy();
					},
					startDelay: Conductor.crochet * 0.002
				});

				daLoop++;
			}

			coolText.text = Std.string(seperatedScore);

			FlxTween.tween(rating, {alpha: 0}, 0.2, {
				startDelay: Conductor.crochet * 0.001,
				onUpdate: function(tween:FlxTween)
				{
					if (currentTimingShown != null)
						currentTimingShown.alpha -= 0.02;
					timeShown++;
				}
			});

			FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					coolText.destroy();
					comboSpr.destroy();
					if (currentTimingShown != null && timeShown >= 20)
					{
						remove(currentTimingShown);
						currentTimingShown = null;
					}
					rating.destroy();
				},
				startDelay: Conductor.crochet * 0.001
			});

			curSection += 1;
		}
	}

	public function NearlyEquals(value1:Float, value2:Float, unimportantDifference:Float = 10):Bool
	{
		return Math.abs(FlxMath.roundDecimal(value1, 1) - FlxMath.roundDecimal(value2, 1)) < unimportantDifference;
	}

	// THIS FUNCTION JUST FUCKS WIT HELD NOTES AND BOTPLAY/REPLAY (also gamepad shit)

	private function keyShit():Void // I've invested in emma stocks
	{
		// control arrays, order L D R U
		var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
		var pressArray:Array<Bool> = [controls.LEFT_P, controls.DOWN_P, controls.UP_P, controls.RIGHT_P];
		var releaseArray:Array<Bool> = [controls.LEFT_R, controls.DOWN_R, controls.UP_R, controls.RIGHT_R];
		#if windows
		if (luaModchart != null)
		{
			if (controls.LEFT_P)
			{
				luaModchart.executeState('keyPressed', ["left"]);
			};
			if (controls.DOWN_P)
			{
				luaModchart.executeState('keyPressed', ["down"]);
			};
			if (controls.UP_P)
			{
				luaModchart.executeState('keyPressed', ["up"]);
			};
			if (controls.RIGHT_P)
			{
				luaModchart.executeState('keyPressed', ["right"]);
			};
		};
		#end

		// Prevent player input if botplay is on
		if (PlayStateChangeables.botPlay)
		{
			holdArray = [false, false, false, false];
			pressArray = [false, false, false, false];
			releaseArray = [false, false, false, false];
		}

		var anas:Array<Ana> = [null, null, null, null];

		for (i in 0...pressArray.length)
			if (pressArray[i])
				anas[i] = new Ana(Conductor.songPosition, null, false, "miss", i);

		// HOLDS, check for sustain notes
		if (holdArray.contains(true) && generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData] && daNote.sustainActive)
				{
					trace(daNote.sustainActive);
					goodNoteHit(daNote);
				}
			});
		}

		if ((KeyBinds.gamepad && !FlxG.keys.justPressed.ANY))
		{
			// PRESSES, check for note hits
			if (pressArray.contains(true) && generatedMusic)
			{
				boyfriend.holdTimer = 0;

				var possibleNotes:Array<Note> = []; // notes that can be hit
				var directionList:Array<Int> = []; // directions that can be hit
				var dumbNotes:Array<Note> = []; // notes to kill later
				var directionsAccounted:Array<Bool> = [false, false, false, false]; // we don't want to do judgments for more than one presses

				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !directionsAccounted[daNote.noteData])
					{
						if (directionList.contains(daNote.noteData))
						{
							directionsAccounted[daNote.noteData] = true;
							for (coolNote in possibleNotes)
							{
								if (coolNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - coolNote.strumTime) < 10)
								{ // if it's the same note twice at < 10ms distance, just delete it
									// EXCEPT u cant delete it in this loop cuz it fucks with the collection lol
									dumbNotes.push(daNote);
									break;
								}
								else if (coolNote.noteData == daNote.noteData && daNote.strumTime < coolNote.strumTime)
								{ // if daNote is earlier than existing note (coolNote), replace
									possibleNotes.remove(coolNote);
									possibleNotes.push(daNote);
									break;
								}
							}
						}
						else
						{
							directionsAccounted[daNote.noteData] = true;
							possibleNotes.push(daNote);
							directionList.push(daNote.noteData);
						}
					}
				});

				for (note in dumbNotes)
				{
					FlxG.log.add("killing dumb ass note at " + note.strumTime);
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}

				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

				var hit = [false,false,false,false];

				if (perfectMode)
					goodNoteHit(possibleNotes[0]);
				else if (possibleNotes.length > 0)
				{
					if (!ghost)
					{
						for (shit in 0...pressArray.length)
						{ // if a direction is hit that shouldn't be
							if (pressArray[shit] && !directionList.contains(shit))
								noteMiss(shit, null);
						}
					}
					for (coolNote in possibleNotes)
					{
						if (pressArray[coolNote.noteData] && !hit[coolNote.noteData])
						{
							if (mashViolations != 0)
								mashViolations--;
							hit[coolNote.noteData] = true;
							scoreTxt.color = FlxColor.WHITE;
							var noteDiff:Float = -(coolNote.strumTime - Conductor.songPosition);
							anas[coolNote.noteData].hit = true;
							anas[coolNote.noteData].hitJudge = Ratings.CalculateRating(noteDiff, Math.floor((PlayStateChangeables.safeFrames / 60) * 1000));
							anas[coolNote.noteData].nearestNote = [coolNote.strumTime, coolNote.noteData, coolNote.sustainLength];
							goodNoteHit(coolNote);
						}
					}
				};
				
				if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || PlayStateChangeables.botPlay))
				{
					if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss') && boyfriend.animation.curAnim.curFrame >= 10)
						boyfriend.playAnim('idle');
				}
				else if (!ghost)
				{
					for (shit in 0...pressArray.length)
						if (pressArray[shit])
							noteMiss(shit, null);
				}
			}
			#if desktop
			if (!loadRep)
				for (i in anas)
					if (i != null)
						replayAna.anaArray.push(i); // put em all there.
			#end
		}
		notes.forEachAlive(function(daNote:Note)
		{
			if (PlayStateChangeables.useDownscroll && daNote.y > strumLine.y || !PlayStateChangeables.useDownscroll && daNote.y < strumLine.y)
			{
				// Force good note hit regardless if it's too late to hit it or not as a fail safe
				if (PlayStateChangeables.botPlay && daNote.canBeHit && daNote.mustPress || PlayStateChangeables.botPlay && daNote.tooLate && daNote.mustPress)
				{
					if (loadRep)
					{
						var n = findByTime(daNote.strumTime);
						trace(n);
						if (n != null)
						{
							goodNoteHit(daNote);
							boyfriend.holdTimer = daNote.sustainLength;
						}
					}
					else
					{
						goodNoteHit(daNote);
						boyfriend.holdTimer = daNote.sustainLength;
					}
				}
			}
		});

		if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || PlayStateChangeables.botPlay))
		{
			if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss') && boyfriend.animation.curAnim.curFrame >= 10)
				boyfriend.playAnim('idle');
		}

		playerStrums.forEach(function(spr:FlxSprite)
		{
			if (keys[spr.ID] && spr.animation.curAnim.name != 'confirm')
				spr.animation.play('pressed');
			if (!keys[spr.ID])
				spr.animation.play('static');

			if (spr.animation.curAnim.name == 'confirm' && !cool)
			{
				spr.centerOffsets();
				spr.offset.x -= 13;
				spr.offset.y -= 13;
			}
			else
				spr.centerOffsets();
		});
	}

	public function findByTime(time:Float):Array<Dynamic>
	{
		for (i in rep.replay.songNotes)
		{
			if (i[0] == time)
				return i;
		}
		return null;
	}

	public function findByTimeIndex(time:Float):Int
	{
		for (i in 0...rep.replay.songNotes.length)
		{
			if (rep.replay.songNotes[i][0] == time)
				return i;
		}
		return -1;
	}

	public function focusOut()
	{
		if (paused)
			return;
		persistentUpdate = false;
		persistentDraw = true;
		paused = true;

		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.pause();
			vocals.pause();
		}

		openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
	}

	public function focusIn()
	{
		// nada
	}

	public function backgroundVideo(source:String) // for background videos
	{
		#if desktop
		useVideo = true;

		FlxG.stage.window.onFocusOut.add(focusOut);
		FlxG.stage.window.onFocusIn.add(focusIn);

		var ourSource:String = "assets/videos/daWeirdVid/dontDelete.webm";
		WebmPlayer.SKIP_STEP_LIMIT = 90;
		var str1:String = "WEBM SHIT";
		webmHandler = new WebmHandler();
		webmHandler.source(ourSource);
		webmHandler.makePlayer();
		webmHandler.webm.name = str1;

		GlobalVideo.setWebm(webmHandler);

		GlobalVideo.get().source(source);
		GlobalVideo.get().clearPause();
		if (GlobalVideo.isWebm)
		{
			GlobalVideo.get().updatePlayer();
		}
		GlobalVideo.get().show();

		if (GlobalVideo.isWebm)
		{
			GlobalVideo.get().restart();
		}
		else
		{
			GlobalVideo.get().play();
		}

		var data = webmHandler.webm.bitmapData;

		videoSprite = new FlxSprite(-470, -30).loadGraphic(data);

		videoSprite.setGraphicSize(Std.int(videoSprite.width * 1.2));

		remove(gf);
		remove(boyfriend);
		remove(dad);
		add(videoSprite);
		add(gf);
		add(boyfriend);
		add(dad);

		trace('poggers');

		if (!songStarted)
			webmHandler.pause();
		else
			webmHandler.resume();
		#end
	}

	function noteMiss(direction:Int = 1, daNote:Note):Void
	{
		if (!boyfriend.stunned)
		{
			if (combo > 5 && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;
			misses++;

			if (daNote != null)
			{
				#if desktop
				if (!loadRep)
				{
					saveNotes.push([
						daNote.strumTime,
						0,
						direction,
						166 * Math.floor((PlayState.rep.replay.sf / 60) * 1000) / 166
					]);
					saveJudge.push("miss");
				}
				#end
			}
			#if desktop
			else if (!loadRep)
			{
				saveNotes.push([
					Conductor.songPosition,
					0,
					direction,
					166 * Math.floor((PlayState.rep.replay.sf / 60) * 1000) / 166
				]);
				saveJudge.push("miss");
			}
			#end
			

			if (accuracyMod == 1)
				totalNotesHit -= 1;

			if (daNote != null)
			{
				if (!daNote.isSustainNote)
					songScore -= 10;
			}
			else
				songScore -= 10;
			
			if(missSounds)
				{
					FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
				}

			boyfriend.playAnim('sing' + dataSuffix[direction] + 'miss', true);

			#if windows
			if (luaModchart != null)
				luaModchart.executeState('playerOneMiss', [direction, Conductor.songPosition]);
			#end

			updateAccuracy();
		}
	}

	function updateAccuracy()
	{
		totalPlayed += 1;
		accuracy = Math.max(0, totalNotesHit / totalPlayed * 100);
		accuracyDefault = Math.max(0, totalNotesHitDefault / totalPlayed * 100);
	}

	function getKeyPresses(note:Note):Int
	{
		var possibleNotes:Array<Note> = []; // copypasted but you already know that

		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate)
			{
				possibleNotes.push(daNote);
				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
			}
		});
		if (possibleNotes.length == 1)
			return possibleNotes.length + 1;
		return possibleNotes.length;
	}

	function noteCheck(controlArray:Array<Bool>, note:Note):Void // sorry lol
	{
		var noteDiff:Float = -(note.strumTime - Conductor.songPosition);

		note.rating = Ratings.CalculateRating(noteDiff, Math.floor((PlayStateChangeables.safeFrames / 60) * 1000));

		if (controlArray[note.noteData])
		{
			goodNoteHit(note, (mashing > getKeyPresses(note)));
		}
	}

	function goodNoteHit(note:Note, resetMashViolation = true):Void
	{
		if (mashing != 0)
			mashing = 0;

		var noteDiff:Float = -(note.strumTime - Conductor.songPosition);

		if (loadRep)
		{
			noteDiff = findByTime(note.strumTime)[3];
			note.rating = rep.replay.songJudgements[findByTimeIndex(note.strumTime)];
		}
		else
			note.rating = Ratings.CalculateRating(noteDiff);

		if (note.rating == "miss")
			return;

		// add newest note to front of notesHitArray
		// the oldest notes are at the end and are removed first
		if (!note.isSustainNote)
			notesHitArray.unshift(Date.now());

		if (!resetMashViolation && mashViolations >= 1)
			mashViolations--;

		if (mashViolations < 0)
			mashViolations = 0;

		if (!note.wasGoodHit)
		{
			if (!note.isSustainNote)
			{
				popUpScore(note);
				combo += 1;
			}
			else
				totalNotesHit += 1;

			switch (note.noteData)
			{
				case 2:
					boyfriend.playAnim('singUP', true);
				case 3:
					boyfriend.playAnim('singRIGHT', true);
				case 1:
					boyfriend.playAnim('singDOWN', true);
				case 0:
					boyfriend.playAnim('singLEFT', true);
			}

			#if windows
			if (luaModchart != null)
				luaModchart.executeState('playerOneSing', [note.noteData, Conductor.songPosition]);
			#end
			#if desktop
			if (!loadRep && note.mustPress)
			{
				var array = [note.strumTime, note.sustainLength, note.noteData, noteDiff];
				if (note.isSustainNote)
					array[1] = -1;
				saveNotes.push(array);
				saveJudge.push(note.rating);
			}
			#end

			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (Math.abs(note.noteData) == spr.ID)
				{
					spr.animation.play('confirm', true);
				}
			});

			note.kill();
			notes.remove(note, true);
			note.destroy();

			updateAccuracy();
		}
	}

	function resetFastCar():Void
	{
		if (distractions)
		{
			fastCar.x = -12600;
			fastCar.y = FlxG.random.int(140, 250);
			fastCar.velocity.x = 0;
			fastCarCanDrive = true;
		}
	}

	function fastCarDrive()
	{
		if (distractions)
		{
			FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

			fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
			fastCarCanDrive = false;
			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				resetFastCar();
			});
		}
	}

	function trainStart():Void
	{
		if (distractions)
		{
			trainMoving = true;
			if (!trainSound.playing)
				trainSound.play(true);
		}
	}

	function updateTrainPos():Void
	{
		if (distractions)
		{
			if (trainSound.time >= 4700)
			{
				startedMoving = true;
				gf.playAnim('hairBlow');
			}

			if (startedMoving)
			{
				phillyTrain.x -= 400;

				if (phillyTrain.x < -2000 && !trainFinishing)
				{
					phillyTrain.x = -1150;
					trainCars -= 1;

					if (trainCars <= 0)
						trainFinishing = true;
				}

				if (phillyTrain.x < -4000 && trainFinishing)
					trainReset();
			}
		}
	}

	function trainReset():Void
	{
		if (distractions)
		{
			gf.playAnim('hairFall');
			phillyTrain.x = FlxG.width + 200;
			trainMoving = false;
			// trainSound.stop();
			// trainSound.time = 0;
			trainCars = 8;
			trainFinishing = false;
			startedMoving = false;
		}
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		halloweenBG.animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		boyfriend.playAnim('scared', true);
		gf.playAnim('scared', true);
	}
	
	override function stepHit()
	{
		super.stepHit();

		if (dadishere){
			olddadx = dad.x;
			olddady = dad.y;
			oldarrowx = babyArrow.x;
			oldarrowy = babyArrow.y;
			oldbfy = boyfriend.y;
			oldbfx = boyfriend.x;
			oldgfy = gf.y;
			oldgfx = gf.x;
			dadishere = false;
		}

		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}

		if (dad.animation.curAnim.name == 'singLEFT' || dad.animation.curAnim.name == 'singRIGHT' || dad.animation.curAnim.name == 'singUP' || dad.animation.curAnim.name == 'singDOWN'){
			if (!morecrap){
				defaultCamZoom -= 0.3;
				morecrap = true;
			}
		}

		#if windows
		if (executeModchart && luaModchart != null)
		{
			luaModchart.setVar('curStep', curStep);
			luaModchart.executeState('stepHit', [curStep]);
		}
		#end
//shortcut #5
		var shit:Int = FlxG.random.int(-900, 700);
		var crap:Int = FlxG.random.int(-500, 400);
		var songLowercase = SONG.song.toLowerCase();
		switch (curStage){
			case 'void':
				floatyBitch();
			case 'darkroom':
				switch (songLowercase){
					case "disco":
						switch (curStep){
							case 350:
								warnAss();
							case 380:
								if (!FlxG.save.data.downscroll)
									changeScroll(2);
								else
									changeScroll(1);
							case 481:
								warnAss();
							case 511:
								if (!FlxG.save.data.downscroll)
									changeScroll(1);
								else
									changeScroll(2);
							//case 608:
								//warnAss();
							case 638:
								remove(dad);
								dad = new Character(100,100, "fake");
								dad.x += 100;
								dad.y += 350;
								add(dad);//shortcut #8
								dad.playAnim("tremble",true);
								SONG.forceDad = true;
								fuckingAnimationPlaying = true;
							case 639:
								dad.playAnim("tremble",true);
								defaultCamZoom += 0.3;
							case 640 | 642 | 648 | 654 | 656 | 667 | 669 | 671:
								bg.visible = false;
								things.visible = false;
							case 641 | 643 | 649 | 655 | 657 | 668 | 670:
								bg.visible = true;
								things.visible = true;
							case 657:
								bg.visible = false;
								things.visible = false;
							case 660:
								bg.visible = true;
								things.visible = true;
							case 642:
								warnAss();
							case 672:
								defaultCamZoom -= 0.3;
								bg.visible = true;
								things.visible = true;
								fuckingAnimationPlaying = false;
								SONG.forceDad = false;
								if (!FlxG.save.data.downscroll)
									changeScroll(2);
								else
									changeScroll(1);
							case 784:
								SONG.forceDad = true;
							case 800:
								SONG.forceDad = false;
							case 769:
								warnAss();
							case 799:
								if (!FlxG.save.data.downscroll)
									changeScroll(1);
								else
									changeScroll(2);
							case 802:
								warnAss();
							case 832:
								if (!FlxG.save.data.downscroll)
									changeScroll(2);
								else
									changeScroll(1);
							case 833:
								warnAss();
							case 863:
								if (!FlxG.save.data.downscroll)
									changeScroll(1);
								else
									changeScroll(2);
							case 848:
								warnAss();
							case 878:
								if (!FlxG.save.data.downscroll)
									changeScroll(2);
								else
									changeScroll(1);
							case 865:
								warnAss();
							case 895:
								if (!FlxG.save.data.downscroll)
									changeScroll(1);
								else
									changeScroll(2);
							case 882:
								warnAss();
							case 912:
								if (!FlxG.save.data.downscroll)
									changeScroll(2);
								else
									changeScroll(1);
							case 890 | 892 | 894 | 896:
								warnAss();
							case 926:
								if (!FlxG.save.data.downscroll)
									changeScroll(1);
								else
									changeScroll(2);
							case 891 | 893 | 895:
								warnAss();
							case 920:
								if (!FlxG.save.data.downscroll)
									changeScroll(2);
								else
									changeScroll(1);
							case 928:
								dad.playAnim("tremble",true);
								fuckingAnimationPlaying = true;
							case 929:
								dad.playAnim("fall",true);
								FlxTween.tween(boyfriend, {alpha: 0}, 3.2, { ease: FlxEase.quadOut });
								FlxTween.tween(gf, {alpha: 0}, 3.2, { ease: FlxEase.quadOut });
								FlxTween.tween(bg, {alpha: 0}, 3.2, { ease: FlxEase.quadOut });
								FlxTween.tween(things, {alpha: 0}, 3.2, { ease: FlxEase.quadOut });
							case 979://shortcut #9
								dad.playAnim("virus",true);
								dad.lock = true;
						}
						if ((curStep > 638  && curStep < 673) || (curStep > 784 && curStep < 800)){
							if (dad.curCharacter == "fake")
								dad.playAnim("tremble",true);
						}
						if (dad.animation.curAnim.name == "fall" && dad.animation.curAnim.finished)
							fallenCrap = true;
						if (dad.animation.curAnim.name == "virus" && dad.animation.curAnim.finished){//shortcut#10
							// FlxG.camera.fade(FlxColor.BLACK, 2.0, false);
							var blackt = new FlxSprite(-1000, -1000).makeGraphic(FlxG.width + 2000, FlxG.height + 2000, FlxColor.BLACK);
							blackt.alpha = 0;
							add(blackt);
							FlxTween.num(0, 1, 2, {}, (val)->{
								blackt.alpha = val;
							});
							virusCrap = true;
						}
						if (fallenCrap && curStep > 928 && curStep < 978)
							dad.playAnim("stuck",true);
						if (virusCrap)
							dad.playAnim("virus-idle",true);
					case 'intoxicate':
									if (curStep > 1408 && curStep < 1422){
										playerStrums.forEach(function(spr:FlxSprite){
										spr.x += shit;
										spr.y += crap;
									});
								}
								if (curStep == 1423){
									playerStrums.forEach(function (spr:FlxSprite){
										spr.x -= shit;
										spr.y -= crap;
									});
								}
								switch (curStep){
									case 1023:
										//PlayStateChangeables.scrollSpeed += 0.3;
										SONG.speed += 0.3;
										remove(dad);
										dad = new Character(olddadx, olddady, 'virus-mad');
										add(dad);
									case 1025:
										defaultCamZoom += 0.3;
										SONG.forceDad = true;
									case 1153:
										defaultCamZoom -= 0.3;
										SONG.forceDad = false;
									case 1281:
										FlxTween.color(boyfriend, 3, FlxColor.fromRGB(196, 200, 207), FlxColor.fromRGB(0, 200, 255));
										FlxTween.color(gf, 3, FlxColor.fromRGB(196, 200, 207), FlxColor.fromRGB(252, 3, 90));
										defaultCamZoom += 0.2;
									case 1408:
										dadishere = false;
										remove(dad);
										dad = new Character(olddadx, olddady, 'error');
										add(dad);
										defaultCamZoom += 0.3;
										new FlxTimer().start(0.1, function(tmr:FlxTimer){
											bg.alpha -= 0.1;
											things.alpha = bg.alpha;
											if (bg.alpha != 0){
												tmr.reset();
											}
											else{
											remove(bg);
											}
										});
										FlxG.camera.shake(0.01, 3.1);
									case 1442:
										FlxG.camera.fade(FlxColor.BLACK,0.4,false);
										new FlxTimer().start(0.4, function(tmr:FlxTimer){
											remove(dad);
											remove(boyfriend);
											remove(gf);
										});
									case 1462:
										//PlayStateChangeables.scrollSpeed -= 1;
										SONG.speed -= 1;
										gf = new Character (oldgfx + 180, oldgfy, 'gf-box');
										dad = new Character(200, 400, 'bit');
										boyfriend = new Boyfriend(oldbfx, oldbfy, 'bf-pixel');
										add(sky);
										add(bg2);
										add(dad);
										add(gf);
										add(boyfriend);
										FlxG.camera.fade(FlxColor.BLACK,0.4,true);
										dad.alpha = 1;

										var posX = 500;
										var posY = 380;

										things2 = new FlxSprite(posX, posY).loadGraphic(Paths.image('8bit/things','shared'));
										things2.scale.set(6, 6);
										things2.scrollFactor.set(0.9,0.9);
										add(things2);
										defaultCamZoom -= 0.5;
								}
				}
		}

		if ((dad.animation.curAnim.name == 'singDOWN' || dad.animation.curAnim.name == 'singRIGHT' || dad.animation.curAnim.name == 'singLEFT' || dad.animation.curAnim.name == 'singUP') && FlxG.save.data.bruh){
			FlxG.sound.play(Paths.sound('bruh','shared'));
		}
		if ((boyfriend.animation.curAnim.name == 'singDOWN' || boyfriend.animation.curAnim.name == 'singRIGHT' || boyfriend.animation.curAnim.name == 'singLEFT' || boyfriend.animation.curAnim.name == 'singUP') && FlxG.save.data.vineboom){
			FlxG.sound.play(Paths.sound('vineboom','shared'));
		}
	}

	override function beatHit()
	{
		super.beatHit();
		if (curStage == 'darkroom' && SONG.song.toLowerCase() == 'intoxicate'){
			if (curStep > 898 && curStep < 1408){
				bg.alpha = 1;
				camHUD.zoom += 0.006;
				camHUDNOTES.zoom += 0.006;
				FlxG.camera.zoom += 0.009;
				if (curBeat % 4 == 0){
					trace('BOOM!');
					camHUD.shake(0.005, 0.1);
					camHUDNOTES.shake(0.005,0.1);
					FlxG.camera.shake(0.005, 0.1);
					bg.alpha = 0;
					if (dad.alpha > 0.7){
						dad.alpha -= 0.05;
					}
				}
			}
		}
		if (curStage == 'void' && curBeat % 4 == 0 && curBeat > 2){
			changeflor(FlxG.random.int(1,3));
		}

		/*if (generatedMusic)
		{
			changeScroll();
		}*/

		#if windows
		if (executeModchart && luaModchart != null)
		{
			luaModchart.setVar('curBeat', curBeat);
			luaModchart.executeState('beatHit', [curBeat]);
		}
		#end

		if (curSong == 'Tutorial' && dad.curCharacter == 'gf')
		{
			if (curBeat % 2 == 1 && dad.animOffsets.exists('danceLeft'))
				dad.playAnim('danceLeft');
			if (curBeat % 2 == 0 && dad.animOffsets.exists('danceRight'))
				dad.playAnim('danceRight');
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{

			// Dad doesnt interupt his own notes
			if ((SONG.notes[Math.floor(curStep / 16)].mustHitSection || !dad.animation.curAnim.name.startsWith("sing")) && dad.curCharacter != 'gf')
				if (curBeat % idleBeat == 0 || dad.curCharacter == "spooky")
					dad.dance(idleToBeat);
		}
		wiggleShit.update(Conductor.crochet);

		if (camzoom)
		{
			// HARDCODING FOR MILF ZOOMS!
			if (curSong.toLowerCase() == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35)
			{
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
			}

			if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
			{
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
				camHUDNOTES.zoom += 0.03;
			}
		}

		if (curBeat % 1 == 0){
			//why not?
			iconP1.animation.play(iconp1Anim, true);
			iconP2.animation.play(iconp2Anim, true);
			iconP1.setGraphicSize(Std.int(iconP1.width + 30));
			iconP2.setGraphicSize(Std.int(iconP2.width + 30));

			iconP1.updateHitbox();
			iconP2.updateHitbox();
		}

		if (curBeat % gfSpeed == 0)
		{
			gf.dance();
		}

		if (!boyfriend.animation.curAnim.name.startsWith("sing") && curBeat % idleBeat == 0 && !fuckingAnimationPlaying)
		{
			boyfriend.playAnim('idle', idleToBeat);
		}

		if (curBeat % 8 == 7 && curSong == 'Bopeebo')
		{
			boyfriend.playAnim('hey', true);
		}

		if (curBeat % 16 == 15 && SONG.song == 'Tutorial' && dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
		{
			boyfriend.playAnim('hey', true);
			dad.playAnim('cheer', true);
		}

		switch (curStage)
		{
			case 'school':
				if (distractions)
				{
					bgGirls.dance();
				}

			case 'mall':
				if (distractions)
				{
					upperBoppers.animation.play('bop', true);
					bottomBoppers.animation.play('bop', true);
					santa.animation.play('idle', true);
				}

			case 'limo':
				if (distractions)
				{
					grpLimoDancers.forEach(function(dancer:BackgroundDancer)
					{
						dancer.dance();
					});

					if (FlxG.random.bool(10) && fastCarCanDrive)
						fastCarDrive();
				}
			case "philly":
				if (distractions)
				{
					if (!trainMoving)
						trainCooldown += 1;

					if (curBeat % 4 == 0)
					{
						phillyCityLights.forEach(function(light:FlxSprite)
						{
							light.visible = false;
						});

						curLight = FlxG.random.int(0, phillyCityLights.length - 1);

						phillyCityLights.members[curLight].visible = true;
					}
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					if (distractions)
					{
						trainCooldown = FlxG.random.int(-4, 0);
						trainStart();
					}
				}
		}

		if (isHalloween && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			if (distractions)
			{
				lightningStrikeShit();
			}
		}
	}

	function changeflor(cring:Int){
		switch (cring){
			case 1:
				flor2.alpha = 0;
				flor3.alpha = 0;
				flor1.alpha = 1;
			case 2:
				flor2.alpha = 1;
				flor3.alpha = 0;
				flor1.alpha = 0;
			case 3:
				flor2.alpha = 0;
				flor3.alpha = 1;
				flor1.alpha = 0;
		}
	}

	function floatyBitch(){
		if (flot.y == 380)
			FlxTween.linearMotion(flot, 500, 380, 500, 600, 2, true);
		if (flot.y == 600)
			FlxTween.linearMotion(flot, 500, 600, 500, 380, 2, true);
	}

	function warnAss(?down:Bool = false){
		var warn = new FlxSprite();
		warn.frames = Paths.getSparrowAtlas("8bit/warning","shared");
		warn.animation.addByPrefix("idle", "WARNING loop",24,true);
		warn.animation.addByPrefix("end", "WARNING end",24,false);
		warn.animation.play("idle", false);
		warn.scale.set(6,6);
		warn.screenCenter(X);
		if (down)
			warn.y = FlxG.height - 200;
		else
			warn.y = FlxG.height - 500;
		add(warn);
		var curShit = curStep + 30;
		var assBull = false;
		new FlxTimer().start(0.01, function(tmr:FlxTimer){
			if (curShit == curStep){
				assBull = true;
				warn.animation.play("end", true);
				new FlxTimer().start(0.6, function(tmddr:FlxTimer){
					remove(warn);
				});
				
			}
			if (!assBull)
				tmr.reset(0.01);
		});
	}

	function changeScroll(?scrollVer:Int = -2):Void{
		if (scrollVer != -2)
			trace('CHANGED SCROLL TO ID $scrollVer');
		
		if (scrollVer > 4){
			trace("invalid scroll version");
			return;
		}
		
		switch (scrollVer){
			default:
				trace('lol lmao xd');
			case -1: //Down-Up Scroll (TO DOWN)
				/*if (PlayStateChangeables.useDownscroll){
					strumLine.y = FlxG.height + 82.5;
					if (songPosition)
						songPosBG.y = 10;
					healthBarBG.y = FlxG.height * 0.9;
					if (FlxG.save.data.watermark)
						kadeEngineWatermark.y = healthBarBG.y;
					songName.y += 3;
					if (FlxG.save.data.botplay)
						botPlayState.y = 100;
					notes.sort(FlxSort.byY, FlxSort.DESCENDING);
				}*/

				PlayStateChangeables.useDownscroll = true;
			case 0: //Down-Up Scroll (TO UP)
				/*if (PlayStateChangeables.useDownscroll){
					strumLine.y = FlxG.height + 82.5;
					if (songPosition)
						songPosBG.y = 10;
					healthBarBG.y = FlxG.height * 0.9;
					if (FlxG.save.data.watermark)
						kadeEngineWatermark.y = healthBarBG.y;
					songName.y += 3;
					if (FlxG.save.data.botplay)
						botPlayState.y = 100;
					notes.sort(FlxSort.byY, FlxSort.ASCENDING);
				}*/

				PlayStateChangeables.useDownscroll = false;
			case 1: //UpScroll
				var duration = 0.25;
				var ease = FlxEase.quadOut;

				PlayStateChangeables.useDownscroll = false;

				playerStrums.forEach(o -> {
					FlxTween.tween(o, {y: 50}, duration, { ease: ease });
				});

				cpuStrums.forEach(o -> {
					FlxTween.tween(o, {y: 50}, duration, { ease: ease });
				});

				
				FlxTween.tween(strumLine, {y: 10}, duration, { ease: ease });
				if (songPosition)
				{
					FlxTween.tween(songPosBG, {y: 10}, duration, { ease: ease });
					FlxTween.tween(songName, {y: 10}, duration, { ease: ease });
				}
				FlxTween.tween(healthBarBG, {y: FlxG.height * 0.9}, duration, { ease: ease });
				
				if (FlxG.save.data.watermark)
					FlxTween.tween(kadeEngineWatermark, {y: FlxG.height * 0.9 + 50}, duration, { ease: ease });
				
				if (loadRep)
					FlxTween.tween(replayTxt, {y: FlxG.height * 0.9 + -100}, duration, { ease: ease });
				
				if (PlayStateChangeables.botPlay && !loadRep)
					FlxTween.tween(botPlayState, {y: FlxG.height * 0.9 + -100}, duration, { ease: ease });
				
				FlxTween.tween(iconP1, {y: FlxG.height * 0.9 - (iconP1.height / 2)}, duration, { ease: ease });
				FlxTween.tween(iconP2, {y: FlxG.height * 0.9 - (iconP2.height / 2)}, duration, { ease: ease });
				FlxTween.tween(healthBar, {y: FlxG.height * 0.9 + 4}, duration, { ease: ease });
			case 2: //DownScroll
				var duration = 0.25;
				var ease = FlxEase.quadOut;

				PlayStateChangeables.useDownscroll = true;
				playerStrums.forEach(o -> {
					FlxTween.tween(o, {y: FlxG.height - 165}, duration, { ease: ease });
				});

				cpuStrums.forEach(o -> {
					FlxTween.tween(o, {y: FlxG.height - 165}, duration, { ease: ease });
				});

				
				FlxTween.tween(strumLine, {y: FlxG.height - 165}, duration, { ease: ease });
				if (songPosition)
				{
					FlxTween.tween(songPosBG, {y: FlxG.height * 0.9 + 45}, duration, { ease: ease });
					FlxTween.tween(songName, {y: songPosBG.y - 3}, duration, { ease: ease });
				}
				FlxTween.tween(healthBarBG, {y: 50}, duration, { ease: ease });
				if (FlxG.save.data.watermark)
					FlxTween.tween(kadeEngineWatermark, {y: FlxG.height * 0.9 + 45}, duration, { ease: ease });
				if (loadRep)
					FlxTween.tween(replayTxt, {y: 50 + 100}, duration, { ease: ease });
				if (PlayStateChangeables.botPlay && !loadRep)
					FlxTween.tween(botPlayState, {y: 50 + 100}, duration, { ease: ease });
				FlxTween.tween(iconP1, {y: 50 - (iconP1.height / 2)}, duration, { ease: ease });
				FlxTween.tween(iconP2, {y: 50 - (iconP2.height / 2)}, duration, { ease: ease });
				FlxTween.tween(healthBar, {y: 50 + 4}, duration, { ease: ease });
			case 3: //SideScroll (Left2Right)
				
			case 4: //SideScroll (Right2Left);
				
		}
	}

	function unspawnShit(Obj1:Note, Obj2:Note):Int{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	public static function fromJson(Source:FlxGraphicAsset, Description:String):Null<Dynamic> {
		var graphic:FlxGraphic = FlxG.bitmap.add(Source);
		if (graphic == null)
			return null;

		// No need to parse data again
		var frames:FlxAtlasFrames = FlxAtlasFrames.findFrame(graphic);
		if (frames != null)
			return frames;

		if (graphic == null || Description == null)
			return null;

		frames = new FlxAtlasFrames(graphic);

		if (Assets.exists(Description))
			Description = Assets.getText(Description);

		var json = Json.parse(Description);
		var framelist = Reflect.fields(json.frames);

		for (framename in framelist)
		{
			var frame = Reflect.field(json.frames, framename);
			// trace(frame);
			var rect = FlxRect.get(frame.frame.x, frame.frame.y, frame.frame.w, frame.frame.h);
			// var duration:Int = frame.duration; // 100 = 10fps???

			frames.addAtlasFrame(rect, FlxPoint.get(rect.width, rect.height), FlxPoint.get(), framename);
		}

		return frames;
	}
	
	public static function fromI8Array(array:Array<{Source:FlxGraphicAsset, Description:String}>):FlxAtlasFrames {
		var i8frames:Array<FlxAtlasFrames> = [];
		for (i8 in array)
			i8frames.push(fromJson(i8.Source, i8.Description));

		var parent = i8frames[0];
		i8frames.shift();

		for (frames in i8frames)
			for (frame in frames.frames)
				parent.pushFrame(frame);

		return parent;
	}
}
