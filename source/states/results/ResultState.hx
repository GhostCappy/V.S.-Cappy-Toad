package states.results;


import backend.Highscore;
import flixel.addons.transition.FlxTransitionableState;
import substates.StickerSubState;
import funkin.FunkinTools;
import funkin.Scoring;
import backend.PsychCamera;
import backend.animation.FlxAtlasSprite;
import shaders.LeftMaskShader;
import flixel.FlxSprite;

import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;

import flixel.math.FlxRect;
import flixel.text.FlxBitmapText;

import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;

import flixel.tweens.FlxTween;
import flixel.addons.display.FlxBackdrop;

import flixel.util.FlxGradient;
import flixel.util.FlxTimer;
using funkin.FunkinTools;

/**
 * The state for the results screen after a song or week is finished.
 */
//@:nullSafety
class ResultState extends MusicBeatSubstate
{
  final params:ResultsStateParams;

  final rank:ScoringRank;
  final songName:FlxBitmapText;
  final difficulty:FlxBitmapText;
  final clearPercentSmall:ClearPercentCounter;

  final maskShaderSongName:LeftMaskShader = new LeftMaskShader();
  final maskShaderDifficulty:LeftMaskShader = new LeftMaskShader();

  final resultsAnim:FlxSprite;
  final ratingsPopin:FlxSprite;
  final scorePopin:FlxSprite;

  final bgFlash:FlxSprite;

  final highscoreNew:FlxSprite;
  final score:ResultScore;

  var bfPerfect:Null<FlxAtlasSprite> = null;
  var heartsPerfect:Null<FlxAtlasSprite> = null;
  var bfExcellent:Null<FlxAtlasSprite> = null;
  var bfGreat:Null<FlxAtlasSprite> = null;
  var gfGreat:Null<FlxAtlasSprite> = null;
  var bfGood:Null<FlxSprite> = null;
  var gfGood:Null<FlxSprite> = null;
  var bfShit:Null<FlxAtlasSprite> = null;

  var rankBg:FlxSprite;
  final cameraBG:PsychCamera;
  final cameraScroll:PsychCamera;
  final cameraEverything:PsychCamera;
  final cameraOverlay:PsychCamera;
	var resultingAccuracy:Float;


  public function new(params:ResultsStateParams)
  {
    super();

    this.params = params;

    resultingAccuracy = Math.min(1,params.scoreData.accPoints/params.scoreData.totalNotesHit); 
    if(params.scoreData.totalNotesHit == 0) resultingAccuracy = 0;

    rank = Scoring.calculateRankFromData(params.scoreData.score,resultingAccuracy,params.scoreData.missed == 0) ?? SHIT;

    cameraBG = new PsychCamera( 0, 0, FlxG.width, FlxG.height);
    cameraScroll = new PsychCamera(0, 0, FlxG.width, FlxG.height);
    cameraEverything = new PsychCamera(0, 0, FlxG.width, FlxG.height);
    cameraOverlay = new PsychCamera(0, 0, FlxG.width, FlxG.height);
    // We build a lot of this stuff in the constructor, then place it in create().
    // This prevents having to do `null` checks everywhere.

    var fontLetters:String = "AaBbCcDdEeFfGgHhiIJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz:1234567890";
    songName = new FlxBitmapText(FlxBitmapFont.fromMonospace(Paths.image("resultScreen/tardlingSpritesheet"), fontLetters, FlxPoint.get(49, 62)));
    songName.text = params.title;
    songName.letterSpacing = -15; //!!!
    songName.angle = -4.4;
    //songName.zIndex = 1000;
    var difColor = PlayState.storyDifficultyColor;
    var fractal = difColor.redFloat*0.33;
    difColor.greenFloat = Math.max(difColor.greenFloat,fractal);

    difficulty = new FlxBitmapText(FlxBitmapFont.fromMonospace(Paths.image("resultScreen/tardlingSpritesheet"), fontLetters, FlxPoint.get(49, 62)));
    difficulty.text = Difficulty.list[PlayState.storyDifficulty].toUpperCase();
    difficulty.color = difColor;
    difficulty.letterSpacing = -11; //!!!
    difficulty.angle = -4.4;
    //difficulty.zIndex = 1000;

    clearPercentSmall = new ClearPercentCounter(FlxG.width / 2 + 300, FlxG.height / 2 - 100, 100, true);
    //clearPercentSmall.zIndex = 1000;
    clearPercentSmall.visible = false;

    bgFlash = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, [0xFFFFF1A6, 0xFFFFF1BE], 90);

    resultsAnim = FunkinTools.createSparrow(-200, -10, "resultScreen/results");

    ratingsPopin = FunkinTools.createSparrow(-135, 135, "resultScreen/ratingsPopin");

    scorePopin = FunkinTools.createSparrow(-180, 515, "resultScreen/scorePopin");

    highscoreNew = new FlxSprite(44, 557);

    score = new ResultScore(35, 305, 10, params.scoreData.score);

    rankBg = new FlxSprite(0, 0);
  }

  override function create():Void
  {
    if (FlxG.sound.music != null) FlxG.sound.music.stop();

    // We need multiple cameras so we can put one at an angle.
    cameraScroll.angle = -3.8;

    cameraBG.bgColor = FlxColor.MAGENTA;
    cameraScroll.bgColor = FlxColor.TRANSPARENT;
    cameraEverything.bgColor = FlxColor.TRANSPARENT;
    cameraOverlay.bgColor = FlxColor.TRANSPARENT;

    FlxG.cameras.add(cameraBG, false);
    FlxG.cameras.add(cameraScroll, false);
    FlxG.cameras.add(cameraEverything, false);
    FlxG.cameras.add(cameraOverlay, false);

    FlxG.cameras.setDefaultDrawTarget(cameraEverything, true);
    this.camera = cameraEverything;

    // Reset the camera zoom on the results screen.
    FlxG.camera.zoom = 1.0;

    var bg:FlxSprite = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, [0xFFFECC5C, 0xFFFDC05C], 90);
    bg.scrollFactor.set();
    //bg.zIndex = 10;
    bg.cameras = [cameraBG];
    add(bg);

    bgFlash.scrollFactor.set();
    bgFlash.visible = false;
    //bgFlash.zIndex = 20;
    // bgFlash.cameras = [cameraBG];
    add(bgFlash);

    // The sound system which falls into place behind the score text. Plays every time!
    var soundSystem:FlxSprite = FunkinTools.createSparrow(-15, -180, 'resultScreen/soundSystem');
    soundSystem.animation.addByPrefix("idle", "sound system", 24, false);
    soundSystem.visible = false;
    new FlxTimer().start(8 / 24, _ -> {
      soundSystem.animation.play("idle");
      soundSystem.visible = true;
    });
    //soundSystem.zIndex = 1100;
    

    switch (rank)
    {
      case PERFECT | PERFECT_GOLD:
        heartsPerfect = new FlxAtlasSprite(1342, 370, Paths.getSharedPath("images/resultScreen/results-bf/resultsPERFECT/hearts"));
        heartsPerfect.visible = false;
        //heartsPerfect.zIndex = 501;
        add(heartsPerfect);

        heartsPerfect.anim.onComplete.add(() -> {
          if (heartsPerfect != null)
          {
            // bfPerfect.anim.curFrame = 137;
            heartsPerfect.anim.curFrame = 43;
            heartsPerfect.anim.play(); // unpauses this anim, since it's on PlayOnce!
          }
        });

        bfPerfect = new FlxAtlasSprite(1342, 370, Paths.getSharedPath("images/resultScreen/results-bf/resultsPERFECT"));
        bfPerfect.visible = false;
        //bfPerfect.zIndex = 500;
        add(bfPerfect);

        bfPerfect.anim.onComplete.add(() -> {
          if (bfPerfect != null)
          {
            // bfPerfect.anim.curFrame = 137;
            bfPerfect.anim.curFrame = 137;
            bfPerfect.anim.play(); // unpauses this anim, since it's on PlayOnce!
          }
        });

      case EXCELLENT:
        bfExcellent = new FlxAtlasSprite(1329, 429, Paths.getSharedPath("images/resultScreen/results-bf/resultsEXCELLENT"));
        bfExcellent.visible = false;
        //bfExcellent.zIndex = 500;
        add(bfExcellent);

        bfExcellent.anim.onComplete.add(() -> {
          if (bfExcellent != null)
          {
            bfExcellent.anim.curFrame = 28;
            bfExcellent.anim.play(); // unpauses this anim, since it's on PlayOnce!
          }
        });

      case GREAT:
        gfGreat = new FlxAtlasSprite(802, 331, Paths.getSharedPath("images/resultScreen/results-bf/resultsGREAT/gf"));
        gfGreat.visible = false;
        //gfGreat.zIndex = 499;
        add(gfGreat);

        gfGreat.scale.set(0.93, 0.93);

        gfGreat.anim.onComplete.add(() -> {
          if (gfGreat != null)
          {
            gfGreat.anim.curFrame = 9;
            gfGreat.anim.play(); // unpauses this anim, since it's on PlayOnce!
          }
        });

        bfGreat = new FlxAtlasSprite(929, 363, Paths.getSharedPath("images/resultScreen/results-bf/resultsGREAT/bf"));
        bfGreat.visible = false;
        //bfGreat.zIndex = 500;
        add(bfGreat);

        bfGreat.scale.set(0.93, 0.93);

        bfGreat.anim.onComplete.add(() -> {
          if (bfGreat != null)
          {
            bfGreat.anim.curFrame = 15;
            bfGreat.anim.play(); // unpauses this anim, since it's on PlayOnce!
          }
        });

      case GOOD:
        gfGood = FunkinTools.createSparrow(625, 325,'resultScreen/results-bf/resultsGOOD/resultGirlfriendGOOD');
        gfGood.animation.addByPrefix("clap", "Girlfriend Good Anim", 24, false);
        gfGood.visible = false;
        //gfGood.zIndex = 500;
        gfGood.animation.finishCallback = _ -> {
          if (gfGood != null)
          {
            gfGood.animation.play('clap', true, false, 9);
          }
        };
        add(gfGood);

        bfGood = FunkinTools.createSparrow(640, -200, 'resultScreen/results-bf/resultsGOOD/resultBoyfriendGOOD');
        bfGood.animation.addByPrefix("fall", "Boyfriend Good Anim0", 24, false);
        bfGood.visible = false;
        //bfGood.zIndex = 501;
        bfGood.animation.finishCallback = function(_) {
          if (bfGood != null)
          {
            bfGood.animation.play('fall', true, false, 14);
          }
        };
        add(bfGood);

      case SHIT:
        bfShit = new FlxAtlasSprite(0, 20, Paths.getSharedPath("images/resultScreen/results-bf/resultsSHIT"));
        bfShit.visible = false;
        //bfShit.zIndex = 500;
        add(bfShit);
        bfShit.anim.onComplete.add(() -> {
          if (bfShit != null)
          {
            bfShit.playAnimation('Loop Start');
          }
        });
    }

    add(difficulty);

    add(songName);

    var angleRad = songName.angle * Math.PI / 180;
    speedOfTween.x = -1.0 * Math.cos(angleRad);
    speedOfTween.y = -1.0 * Math.sin(angleRad);

    timerThenSongName(1.0, false);
    //TODOtt
    //songName.shader = maskShaderSongName;
    //difficulty.shader = maskShaderDifficulty;

    //maskShaderSongName.swagMaskX = difficulty.x - 15;
    //maskShaderDifficulty.swagMaskX = difficulty.x - 15;

    var blackTopBar:FlxSprite = new FlxSprite().loadGraphic(Paths.image("resultScreen/topBarBlack"));
    blackTopBar.y = -blackTopBar.height;
    FlxTween.tween(blackTopBar, {y: 0}, 7 / 24, {ease: FlxEase.quartOut, startDelay: 3 / 24});
    //blackTopBar.zIndex = 1010;
    add(blackTopBar);
    add(clearPercentSmall);
    add(soundSystem);

    resultsAnim.animation.addByPrefix("result", "results instance 1", 24, false);
    resultsAnim.visible = false;
    //resultsAnim.zIndex = 1200;
    add(resultsAnim);
    new FlxTimer().start(6 / 24, _ -> {
      resultsAnim.visible = true;
      resultsAnim.animation.play("result");
    });

    ratingsPopin.animation.addByPrefix("idle", "Categories", 24, false);
    ratingsPopin.visible = false;
    //ratingsPopin.zIndex = 1200;
    add(ratingsPopin);
    new FlxTimer().start(21 / 24, _ -> {
      ratingsPopin.visible = true;
      ratingsPopin.animation.play("idle");
    });

    scorePopin.animation.addByPrefix("score", "tally score", 24, false);
    scorePopin.visible = false;
    //scorePopin.zIndex = 1200;
    add(scorePopin);
    new FlxTimer().start(36 / 24, _ -> {
      scorePopin.visible = true;
      scorePopin.animation.play("score");
      scorePopin.animation.finishCallback = anim -> {};
    });

    new FlxTimer().start(37 / 24, _ -> {
      score.visible = true;
      score.animateNumbers();
      startRankTallySequence();
    });

    new FlxTimer().start(rank.getBFDelay(), _ -> {
      afterRankTallySequence();
    });

    new FlxTimer().start(rank.getFlashDelay(), _ -> {
      displayRankText();
    });

    highscoreNew.frames = Paths.getSparrowAtlas("resultScreen/highscoreNew");
    highscoreNew.animation.addByPrefix("new", "highscoreAnim0", 24, false);
    highscoreNew.visible = false;
    // highscoreNew.setGraphicSize(Std.int(highscoreNew.width * 0.8));
    highscoreNew.updateHitbox();
    //highscoreNew.zIndex = 1200;
    add(highscoreNew);

    new FlxTimer().start(rank.getHighscoreDelay(), _ -> {
      if (params.isNewHighscore ?? false)
      {
        highscoreNew.visible = true;
        highscoreNew.animation.play("new");
        highscoreNew.animation.finishCallback = _ -> highscoreNew.animation.play("new", true, false, 16);
      }
      else
      {
        highscoreNew.visible = false;
      }
    });

    var hStuf:Int = 50;

    var ratingGrp:FlxTypedGroup<TallyCounter> = new FlxTypedGroup<TallyCounter>();
    //ratingGrp.zIndex = 1200;
    add(ratingGrp);

    /**
     * NOTE: We display how many notes were HIT, not how many notes there were in total.
     *
     */
    var totalHit:TallyCounter = new TallyCounter(375, hStuf * 3, params.scoreData.totalNotesHit);
    ratingGrp.add(totalHit);

    var maxCombo:TallyCounter = new TallyCounter(375, hStuf * 4, params.scoreData.maxCombo);
    ratingGrp.add(maxCombo);

    hStuf += 2;
    var extraYOffset:Float = 7;

    hStuf += 2;

    var tallySick:TallyCounter = new TallyCounter(230, (hStuf * 5) + extraYOffset, params.scoreData.sick, 0xFF89E59E);
    ratingGrp.add(tallySick);

    var tallyGood:TallyCounter = new TallyCounter(210, (hStuf * 6) + extraYOffset, params.scoreData.good, 0xFF89C9E5);
    ratingGrp.add(tallyGood);

    var tallyBad:TallyCounter = new TallyCounter(190, (hStuf * 7) + extraYOffset, params.scoreData.bad, 0xFFE6CF8A);
    ratingGrp.add(tallyBad);

    var tallyShit:TallyCounter = new TallyCounter(220, (hStuf * 8) + extraYOffset, params.scoreData.shit, 0xFFE68C8A);
    ratingGrp.add(tallyShit);

    var tallyMissed:TallyCounter = new TallyCounter(260, (hStuf * 9) + extraYOffset, params.scoreData.missed, 0xFFC68AE6);
    ratingGrp.add(tallyMissed);

    score.visible = false;
    //score.zIndex = 1200;
    add(score);

    for (ind => rating in ratingGrp.members)
    {
      rating.visible = false;
      new FlxTimer().start((0.3 * ind) + 1.20, _ -> {
        rating.visible = true;
        FlxTween.tween(rating, {curNumber: rating.neededNumber}, 0.5, {ease: FlxEase.quartOut});
      });
    }
    //TODO monitor this. New feature?
    // if (params.isNewHighscore ?? false)
    // {
    //   highscoreNew.visible = true;
    //   highscoreNew.animation.play("new");
    //   //FlxTween.tween(highscoreNew, {y: highscoreNew.y + 10}, 0.8, {ease: FlxEase.quartOut});
    // }
    // else
    // {
    //   highscoreNew.visible = false;
    // }

    new FlxTimer().start(rank.getMusicDelay(), _ -> {
      var rankMusicPath = rank.getMusicPath();
      if (rank.hasMusicIntro())
      {
        FlxG.sound.play(Paths.music(rankMusicPath + '/' + rankMusicPath + '-intro'),1,false,null,true,() -> {
          FlxG.sound.playMusic(Paths.music(rankMusicPath),1,rank.shouldMusicLoop());
        });
        // Play the intro music.
      }
      else
      {
        FlxG.sound.playMusic(Paths.music(rankMusicPath),1,rank.shouldMusicLoop());
      }
    });

    rankBg.makeSolidColor(FlxG.width, FlxG.height, 0xFF000000);
    rankBg.cameras = [cameraOverlay];
    //rankBg.zIndex = 99999;
    

    rankBg.alpha = 0;

    //refresh();
    // forEachOfType(FlxSprite,s ->{
    //   s.antialiasing = ClientPrefs.data.antialiasing;
    // }); // quick n dirty way to apply anit-aliasing to everything
    super.create();
  }

  var rankTallyTimer:Null<FlxTimer> = null;
  var clearPercentTarget:Int = 100;
  var clearPercentLerp:Int = 0;

  function startRankTallySequence():Void
  {
    bgFlash.visible = true;
    FlxTween.tween(bgFlash, {alpha: 0}, 5 / 24);
    var clearPercentFloat = resultingAccuracy* 100;
    clearPercentTarget = Math.floor(clearPercentFloat);
    // Prevent off-by-one errors.

    clearPercentLerp = Std.int(Math.max(0, clearPercentTarget - 36));

    trace('Clear percent target: ' + clearPercentFloat + ', round: ' + clearPercentTarget);

    var clearPercentCounter:ClearPercentCounter = new ClearPercentCounter(FlxG.width / 2 + 190, FlxG.height / 2 - 70, clearPercentLerp);
    FlxTween.tween(clearPercentCounter, {curNumber: clearPercentTarget}, 58 / 24,
      {
        ease: FlxEase.quartOut,
        onUpdate: _ -> {
          // Only play the tick sound if the number increased.
          if (clearPercentLerp != clearPercentCounter.curNumber)
          {
            clearPercentLerp = clearPercentCounter.curNumber;
            FlxG.sound.play(Paths.sound('scrollMenu'));
          }
        },
        onComplete: _ -> {
          // Play confirm sound.
          FlxG.sound.play(Paths.sound('confirmMenu'));

          // Just to be sure that the lerp didn't mess things up.
          clearPercentCounter.curNumber = clearPercentTarget;

          clearPercentCounter.flash(true);
          new FlxTimer().start(0.4, _ -> {
            clearPercentCounter.flash(false);
          });

          // displayRankText();

          // previously 2.0 seconds
          new FlxTimer().start(0.25, _ -> {
            FlxTween.tween(clearPercentCounter, {alpha: 0}, 0.5,
              {
                startDelay: 0.5,
                ease: FlxEase.quartOut,
                onComplete: _ -> {
                  remove(clearPercentCounter);
                }
              });

            // afterRankTallySequence();
          });
        }
      });
    //clearPercentCounter.zIndex = 450;
    add(clearPercentCounter);

    if (ratingsPopin == null)
    {
      trace("Could not build ratingsPopin!");
    }
    else
    {
      // ratingsPopin.animation.play("idle");
      // ratingsPopin.visible = true;

      ratingsPopin.animation.finishCallback = anim -> {
        // scorePopin.animation.play("score");

        // scorePopin.visible = true;

        if (params.isNewHighscore ?? false)
        {
          highscoreNew.visible = true;
          highscoreNew.animation.play("new");
        }
        else
        {
          highscoreNew.visible = false;
        }
      };
    }

    //refresh();
  }

  function displayRankText():Void
  {
    bgFlash.visible = true;
    bgFlash.alpha = 1;
    FlxTween.tween(bgFlash, {alpha: 0}, 14 / 24);

    var rankTextVert:FlxBackdrop = new FlxBackdrop(Paths.image(rank.getVerTextAsset()), Y, 0, 30);
    rankTextVert.x = FlxG.width - 44;
    rankTextVert.y = 100;
    //rankTextVert.zIndex = 990;
    add(rankTextVert);

    FlxFlicker.flicker(rankTextVert, 2 / 24 * 3, 2 / 24, true);

    // Scrolling.
    new FlxTimer().start(30 / 24, _ -> {
      rankTextVert.velocity.y = -80;
    });

    for (i in 0...12)
    {
      var rankTextBack:FlxBackdrop = new FlxBackdrop(Paths.image(rank.getHorTextAsset()), X, 10, 0);
      rankTextBack.x = FlxG.width / 2 - 320;
      rankTextBack.y = 50 + (135 * i / 2) + 10;
      // rankTextBack.angle = -3.8;
      //rankTextBack.zIndex = 100;
      rankTextBack.cameras = [cameraScroll];
      add(rankTextBack);

      // Scrolling.
      rankTextBack.velocity.x = (i % 2 == 0) ? -7.0 : 7.0;
    }

    //refresh();
  }

  function afterRankTallySequence():Void
  {
    showSmallClearPercent();

    switch (rank)
    {
      case PERFECT | PERFECT_GOLD:
        if (bfPerfect == null)
        {
          trace("Could not build PERFECT animation!");
        }
        else
        {
          bfPerfect.visible = true;
          bfPerfect.playAnimation('');
        }
        new FlxTimer().start(106 / 24, _ -> {
          if (heartsPerfect == null)
          {
            trace("Could not build heartsPerfect animation!");
          }
          else
          {
            heartsPerfect.visible = true;
            heartsPerfect.playAnimation('');
          }
        });
      case EXCELLENT:
        if (bfExcellent == null)
        {
          trace("Could not build EXCELLENT animation!");
        }
        else
        {
          bfExcellent.visible = true;
          bfExcellent.playAnimation('');
        }
      case GREAT:
        if (bfGreat == null)
        {
          trace("Could not build GREAT animation!");
        }
        else
        {
          bfGreat.visible = true;
          bfGreat.playAnimation('');
        }

        new FlxTimer().start(6 / 24, _ -> {
          if (gfGreat == null)
          {
            trace("Could not build GREAT animation for gf!");
          }
          else
          {
            gfGreat.visible = true;
            gfGreat.playAnimation('');
          }
        });
      case SHIT:
        if (bfShit == null)
        {
          trace("Could not build SHIT animation!");
        }
        else
        {
          bfShit.visible = true;
          bfShit.playAnimation('Intro');
        }
      case GOOD:
        if (bfGood == null)
        {
          trace("Could not build GOOD animation!");
        }
        else
        {
          bfGood.animation.play('fall');
          bfGood.visible = true;
          new FlxTimer().start((1 / 24) * 22, _ -> {
            // plays about 22 frames (at 24fps timing) after bf spawns in
            if (gfGood != null)
            {
              gfGood.animation.play('clap', true);
              gfGood.visible = true;
            }
            else
            {
              trace("Could not build GOOD animation!");
            }
          });
        }
      default:
    }
  }

  function timerThenSongName(timerLength:Float = 3.0, autoScroll:Bool = true):Void
  {
    movingSongStuff = false;

    difficulty.x = 555;

    var diffYTween:Float = 122;

    difficulty.y = -difficulty.height;
    FlxTween.tween(difficulty, {y: diffYTween}, 0.5, {ease: FlxEase.expoOut, startDelay: 0.8});

    if (clearPercentSmall != null)
    {
      clearPercentSmall.x = (difficulty.x + difficulty.width) + 50;
      clearPercentSmall.y = -clearPercentSmall.height;
      FlxTween.tween(clearPercentSmall, {y: 122 - 5}, 0.5, {ease: FlxEase.expoOut, startDelay: 0.85});
    }

    songName.y = -songName.height;
    var fuckedupnumber = (10) * (songName.text.length / 15);
    FlxTween.tween(songName, {y: diffYTween - 25 - fuckedupnumber}, 0.5, {ease: FlxEase.expoOut, startDelay: 0.9});
    songName.x = clearPercentSmall.x + 94;

    new FlxTimer().start(timerLength, _ -> {
      var tempSpeed = FlxPoint.get(speedOfTween.x, speedOfTween.y);

      speedOfTween.set(0, 0);
      FlxTween.tween(speedOfTween, {x: tempSpeed.x, y: tempSpeed.y}, 0.7, {ease: FlxEase.quadIn});

      movingSongStuff = (autoScroll);
    });
  }

  function showSmallClearPercent():Void
  {
    if (clearPercentSmall != null)
    {
      
      clearPercentSmall.visible = true;
      clearPercentSmall.flash(true);
      new FlxTimer().start(0.4, _ -> {
        clearPercentSmall.flash(false);
      });

      clearPercentSmall.curNumber = clearPercentTarget;
      //clearPercentSmall.zIndex = 1000;
      //refresh();
    }

    new FlxTimer().start(2.5, _ -> {
      movingSongStuff = true;
    });
  }

  var movingSongStuff:Bool = false;
  var speedOfTween:FlxPoint = FlxPoint.get(-1, 1);

  override function draw():Void
  {
    super.draw();

    songName.clipRect = FlxRect.get(Math.max(0, 520 - songName.x), 0, FlxG.width, songName.height);

    // PROBABLY SHOULD FIX MEMORY FREE OR WHATEVER THE PUT() FUNCTION DOES !!!! FEELS LIKE IT STUTTERS!!!

    // if (songName != null && songName.frame != null)
    // maskShaderSongName.frameUV = songName.frame.uv;
  }

  override function update(elapsed:Float):Void
  {
    // if(FlxG.keys.justPressed.R){
    //   FlxG.switchState(() -> new funkin.play.ResultState(
    //   {
    //     storyMode: false,
    //     title: "Cum Song Erect by Kawai Sprite",
    //     songId: "cum",
    //     difficultyId: "nightmare",
    //     isNewHighscore: true,
    //     scoreData:
    //       {
    //         score: 1_234_567,
    //         tallies:
    //           {
    //             sick: 200,
    //             good: 0,
    //             bad: 0,
    //             shit: 0,
    //             missed: 0,
    //             combo: 0,
    //             maxCombo: 69,
    //             totalNotesHit: 200,
    //             totalNotes: 200 // 0,
    //           }
    //       },
    //   }));
    // }

    // if(heartsPerfect != null){
    // if (FlxG.keys.justPressed.I)
    // {
    //   heartsPerfect.y -= 1;
    //   trace(heartsPerfect.x, heartsPerfect.y);
    // }
    // if (FlxG.keys.justPressed.J)
    // {
    //   heartsPerfect.x -= 1;
    //   trace(heartsPerfect.x, heartsPerfect.y);
    // }
    // if (FlxG.keys.justPressed.L)
    // {
    //   heartsPerfect.x += 1;
    //   trace(heartsPerfect.x, heartsPerfect.y);
    // }
    // if (FlxG.keys.justPressed.K)
    // {
    //   heartsPerfect.y += 1;
    //   trace(heartsPerfect.x, heartsPerfect.y);
    // }
    // }

    // if(bfGreat != null){
    // if (FlxG.keys.justPressed.W)
    // {
    //   bfGreat.y -= 1;
    //   trace(bfGreat.x, bfGreat.y);
    // }
    // if (FlxG.keys.justPressed.A)
    // {
    //   bfGreat.x -= 1;
    //   trace(bfGreat.x, bfGreat.y);
    // }
    // if (FlxG.keys.justPressed.D)
    // {
    //   bfGreat.x += 1;
    //   trace(bfGreat.x, bfGreat.y);
    // }
    // if (FlxG.keys.justPressed.S)
    // {
    //   bfGreat.y += 1;
    //   trace(bfGreat.x, bfGreat.y);
    // }
    // }

    maskShaderSongName.swagSprX = songName.x;
    maskShaderDifficulty.swagSprX = difficulty.x;

    if (movingSongStuff)
    {
      songName.x += speedOfTween.x;
      difficulty.x += speedOfTween.x;
      clearPercentSmall.x += speedOfTween.x;
      songName.y += speedOfTween.y;
      difficulty.y += speedOfTween.y;
      clearPercentSmall.y += speedOfTween.y;

      if (songName.x + songName.width < 100)
      {
        timerThenSongName();
      }
    }

    if (FlxG.keys.justPressed.RIGHT) speedOfTween.x += 0.1;

    if (FlxG.keys.justPressed.LEFT)
    {
      speedOfTween.x -= 0.1;
    }

    if (controls.PAUSE)
    {
      if (FlxG.sound.music != null)
      {
        FlxTween.tween(FlxG.sound.music, {volume: 0}, 0.5);
        FlxTween.tween(FlxG.sound.music, {pitch: 3}, 0.1,
          {
            onComplete: _ -> {
              FlxTween.tween(FlxG.sound.music, {pitch: 0.5}, 0.4);
            }
          });
      }
      if (params.storyMode)
      {
        openSubState(new StickerSubState(null, (sticker) -> new StoryMenuState(sticker)));
      }
      else
      {
        var rigged:Bool = true;

        if (rank > params.prevScoreRank) // if (rigged)
        {
          trace('THE RANK IS Higher.....');
          add(rankBg);
          FlxTween.tween(rankBg, {alpha: 1}, 0.5,
            {
              ease: FlxEase.expoOut,
              onComplete: function(_) {
                FlxTransitionableState.skipNextTransOut = true;
                FlxG.switchState(() -> states.freeplay.FreeplayState.build(
                  {
                    {
                      fromResults:
                        {
                          oldRank: params.prevScoreRank,
                          newRank: rank,
                          songId: params.songId,
                          difficultyId: params.difficultyId,
                          playRankAnim: true
                        }
                    }
                  }));
              }
            });
        }
        else
        {
          trace('rank is lower...... and/or equal');
          openSubState(new StickerSubState(null, (sticker) -> states.freeplay.FreeplayState.build(
            {
              {
                fromResults:
                  {
                    oldRank: null,
                    playRankAnim: false,
                    newRank: rank,
                    songId: params.songId,
                    difficultyId: params.difficultyId
                  }
              }
            }, sticker)));
        }
      }
    }

    super.update(elapsed);
  }
}

typedef ResultsStateParams =
{
  /**
   * True if results are for a level, false if results are for a single song.
   */
  var storyMode:Bool;

  /**
   * Either "Song Name by Artist Name" or "Week Name"
   */
  var title:String;

  var songId:String;

  /**
   * Whether the displayed score is a new highscore
   */
  var ?isNewHighscore:Bool;

  /**
   * The difficulty ID of the song/week we just played.
   * @default Normal
   */
  var ?difficultyId:String;

  /**
   * The score, accuracy, and judgements.
   */
  var scoreData:SaveScoreData;
  /**
   * Previous
   */
  var prevScoreRank:ScoringRank;
};

typedef SaveScoreData =
{
  /**
   * The score achieved.
   */
  var score:Int;
  var accPoints:Float; // Hit points. Divide by all notes to get accuracy

  var sick:Int;
  var good:Int;
  var bad:Int;
  var shit:Int;
  var missed:Int;
  var combo:Int;
  var maxCombo:Int;
  var totalNotesHit:Int;
  var totalNotes:Int;
}