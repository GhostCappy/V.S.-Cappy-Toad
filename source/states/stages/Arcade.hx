package states.stages;

import states.stages.objects.*;
import objects.Character;

class Arcade extends BaseStage
{
	// If you're moving your stage from PlayState to a stage file,
	// you might have to rename some variables if they're missing, for example: camZooming -> game.camZooming
	var guys:FlxSprite = new FlxSprite();
	var lights:FlxSprite = new FlxSprite();
	var dadbattleBlack:BGSprite;
	var dadbattleLight:BGSprite;

	override function create()
	{ 
		// Spawn your stage sprites here.
		// Characters are not ready yet on this function, so you can't add things above them yet.
		// Use createPost() if that's what you want to do.

		var bg:BGSprite = new BGSprite('stagebackkapiold', -600, -300, 0.9, 0.9);
		add(bg);

		guys = new FlxSprite(10, 100);
        guys.frames = Paths.getSparrowAtlas('littleguys');
        guys.animation.addByPrefix('spookyBop', 'Bottom Level Boppers', 24, true);
        guys.animation.play('spookyBop');
        guys.antialiasing = true;
        guys.scrollFactor.set(0.9, 0.9);
        guys.setGraphicSize(Std.int(guys.width * 1));
        guys.active = true;
        add(guys);

		lights = new FlxSprite(-600, -300);
        lights.frames = Paths.getSparrowAtlas('lights');
        lights.animation.addByPrefix('lightBlink', 'lightblink', 3, true);
        lights.animation.play('lightBlink');
        lights.antialiasing = true;
        lights.scrollFactor.set(0.9, 0.9);
        lights.setGraphicSize(Std.int(lights.width * 1));
        lights.active = true;
        add(lights);

		var front:BGSprite = new BGSprite('stagefrontkapiold', -650, 600, 0.9, 0.9);
		front.setGraphicSize(Std.int(front.width * 1.1));
		front.updateHitbox();
		add(front);
	}

	override function eventPushed(event:objects.Note.EventNote)
		{
			switch(event.event)
			{
				case "Spotlight":
					dadbattleBlack = new BGSprite(null, -800, -400, 0, 0);
					dadbattleBlack.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					dadbattleBlack.alpha = 0.40;
					dadbattleBlack.visible = false;
					add(dadbattleBlack);
	
					dadbattleLight = new BGSprite('spotlight', 400, -400);
					dadbattleLight.alpha = 0.375;
					dadbattleLight.blend = ADD;
					dadbattleLight.visible = false;
					add(dadbattleLight);
			}
		}

		override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
			{
				switch(eventName)
				{
					case "Spotlight":
						if(flValue1 == null) flValue1 = 0;
						var val:Int = Math.round(flValue1);
		
						switch(val)
						{
							case 1, 2, 3: //enable and target dad
								if(val == 1) //enable
								{
									dadbattleBlack.visible = true;
									dadbattleLight.visible = true;
								}
		
								var who:Character = dad;
								if(val > 2) who = boyfriend;
								//2 only targets dad
								dadbattleLight.alpha = 0;
								new FlxTimer().start(0.12, function(tmr:FlxTimer) {
									dadbattleLight.alpha = 0.375;
								});
								dadbattleLight.setPosition(who.getGraphicMidpoint().x - 50, who.y - 250);
		
							default:
								dadbattleBlack.visible = false;
								dadbattleLight.visible = false;
						}
				}
			}
			
	override function eventPushedUnique(event:objects.Note.EventNote)
	{
		// used for preloading assets used on events where its values affect what assets should be preloaded
		switch(event.event)
		{
			case "My Event":
				switch(event.value1)
				{
					// If value 1 is "blah blah", it will preload these assets:
					case 'blah blah':
						//precacheImage('myImageOne') //preloads images/myImageOne.png
						//precacheSound('mySoundOne') //preloads sounds/mySoundOne.ogg
						//precacheMusic('myMusicOne') //preloads music/myMusicOne.ogg

					// If value 1 is "coolswag", it will preload these assets:
					case 'coolswag':
						//precacheImage('myImageTwo') //preloads images/myImageTwo.png
						//precacheSound('mySoundTwo') //preloads sounds/mySoundTwo.ogg
						//precacheMusic('myMusicTwo') //preloads music/myMusicTwo.ogg
					
					// If value 1 is not "blah blah" or "coolswag", it will preload these assets:
					default:
						//precacheImage('myImageThree') //preloads images/myImageThree.png
						//precacheSound('mySoundThree') //preloads sounds/mySoundThree.ogg
						//precacheMusic('myMusicThree') //preloads music/myMusicThree.ogg
				}
		}
	}
}