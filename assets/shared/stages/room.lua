function onCreateIcon(tag, image)
     makeAnimatedLuaSprite(tag, image, 0, 0)
     addAnimationByPrefix(tag, 'neutral', 'Icon', 24, true)
     addAnimationByPrefix(tag, 'lose', 'Icon', 24, true)
     addAnimationByIndices(tag, 'neutral', 'Icon', 0, true)
     addAnimationByIndices(tag, 'lose', 'Icon', 1, true)
     playAnim(tag, 'neutral')
     setObjectCamera(tag, 'camHUD')
     setObjectOrder(tag, getObjectOrder('iconP1') + 1)
     addLuaSprite(tag, true)
end

switch = false
function onEvent(name, value1, value2)
     if name == 'Switch Health' then
          if value1 == 'true' then
              onSwitchCode(true)
              switch = true
          elseif value1 == 'false' then
              onSwitchCode(false)
              switch = false
          end
     end

     if name == 'Switch Icons' and not hideHud then
          valSwitch1 = stringSplit(value1, ', ')
          valSwitch2 = stringSplit(value2, ', ')

          onCreateIcon(valSwitch1[1], 'faky icons/icon-'..valSwitch1[2])
          onCreateIcon(valSwitch2[1], 'faky icons/icon-'..valSwitch2[2])

          setProperty(valSwitch1[1]..'.flipX', false)
          setProperty(valSwitch2[1]..'.flipX', true)

          setProperty('iconP1.visible', false)
          setProperty('iconP2.visible', false)
          setHealthBarColors(getIconColor('boyfriend'), getIconColor('dad'))
     end

     if name == 'Remove Fake Icons' then
          removeLuaSprite(valSwitch1[1], true)
          removeLuaSprite(valSwitch2[1], true)

          setProperty('iconP1.visible', true)
          setProperty('iconP2.visible', true)
          setHealthBarColors(getIconColor('dad'), getIconColor('boyfriend'))
     end

     local PlayerStrumX = {defaultPlayerStrumX0, defaultPlayerStrumX1, defaultPlayerStrumX2, defaultPlayerStrumX3}
     local OpponentStrumX = {defaultOpponentStrumX0, defaultOpponentStrumX1, defaultOpponentStrumX2, defaultOpponentStrumX3}
     local StrumNum = {0, 1, 2, 3}
     if name == 'Change Note Pos' and not middlescroll then
          for i = 1, #PlayerStrumX or #OpponentStrumX or #StrumNum do
               if value1 == 'On' then 
                    setPropertyFromGroup('opponentStrums', StrumNum[i], 'x', PlayerStrumX[i] + StrumNum[i] - 3) -- better method
                    setPropertyFromGroup('playerStrums', StrumNum[i], 'x', OpponentStrumX[i] + StrumNum[i] - 3)
               end
               if value1 == 'Off' then
                    setPropertyFromGroup('opponentStrums', StrumNum[i], 'x', OpponentStrumX[i] + StrumNum[i] - 3)
                    setPropertyFromGroup('playerStrums', StrumNum[i], 'x', PlayerStrumX[i] + StrumNum[i] - 3)
               end
          end
     end 
end

function onUpdate(elapsed)
     notetypes = {''} -- le note types lol
     health = getProperty('health') 

     if switch == true then  
          if health == 2 then
               setProperty('health', -1)
          end   
          if health <= 0.01 then
               setProperty('health', 0.01)
          end

          for i = 0, getProperty('notes.length')-1 do
               for i = 1, #notetypes do
                    if getPropertyFromGroup('notes', i, 'noteType') == notetypes[i] then
                         setPropertyFromGroup('notes', i, 'hitHealth', -0.023); --Default value is: 0.023, health gained on hit
                         setPropertyFromGroup('notes', i, 'missHealth', -0.0475); --Default value is: 0.0475, health lost on miss
                    end
               end
          end
     else
          for i = 0, getProperty('notes.length')-1 do
               for i = 1, #notetypes do
                    if getPropertyFromGroup('notes', i, 'noteType') == notetypes[i] then
                         setPropertyFromGroup('notes', i, 'hitHealth', 0.023); --Default value is: 0.023, health gained on hit
                         setPropertyFromGroup('notes', i, 'missHealth', 0.0475); --Default value is: 0.0475, health lost on miss
                    end
               end
          end
     end
end

function onUpdatePost(elapsed) 
     local iconFrame1 = getProperty('iconP1.animation.curAnim.curFrame')
     local iconFrame2 = getProperty('iconP2.animation.curAnim.curFrame')

     setProperty(valSwitch2[1]..'.scale.x', getProperty('iconP1.scale.x'))
     setProperty(valSwitch2[1]..'.scale.y', getProperty('iconP1.scale.y'))

     setProperty(valSwitch1[1]..'.scale.x', getProperty('iconP2.scale.x'))
     setProperty(valSwitch1[1]..'.scale.y', getProperty('iconP2.scale.y'))

     if iconFrame1 == 0 then
          playAnim(valSwitch2[1], 'neutral')
     else
          playAnim(valSwitch2[1], 'lose')
     end
 
     if iconFrame2 == 0 then
          playAnim(valSwitch1[1], 'neutral')
     else
          playAnim(valSwitch1[1], 'lose') 
     end
end

function getIconColor(char)
     local colorR = getProperty(char..".healthColorArray")[1]
     local colorG = getProperty(char..".healthColorArray")[2]
     local colorB = getProperty(char..".healthColorArray")[3]
     return DEC_HEX(colorR) .. DEC_HEX(colorG) .. DEC_HEX(colorB)
end
 
function DEC_HEX(IN)
     local B, K, OUT, I, D, addZero = 16, "0123456789ABCDEF", "", 0, false
     if IN == 0 then
          return "00"
     elseif IN <= 15 and IN ~= 0 then
          addZero = true
     end
     while IN > 0 do
          I = I + 1
          IN, D = math.floor(IN / B), math.mod(IN, B) + 1
          OUT = string.sub(K, D, D)..OUT
     end
     if addZero then
          OUT = "0"..OUT
     end
     return OUT
end

function round(num, dp) -- i stole this
     local mult = 10^(dp or 0);
     return math.floor(num * mult + 0.5)/mult;
end

function onSwitchCode(flip) -- worst code in human existence
     local healthRound1 = round(health, 3)
     local healthRound2 = round(health, 1)
     local healthFor = healthRound1 - healthPosRound2

     if flip == true then
          if health == 2 then
               setProperty('health', 0.01) 
          elseif healthRound1 == 1.9 + healthFor then
               setProperty('health', 0.1 + healthFor)
          elseif healthRound1 == 1.8 + healthFor then
               setProperty('health', 0.2 + healthFor)
          elseif healthRound1 == 1.7 + healthFor then
               setProperty('health', 0.3 + healthFor)
          elseif healthRound1 == 1.6 + healthFor then
               setProperty('health', 0.4 + healthFor)
          elseif healthRound1 == 1.5 + healthFor then
               setProperty('health', 0.5 + healthFor)
          elseif healthRound1 == 1.4 + healthFor then
               setProperty('health', 0.4 + healthFor)
          elseif healthRound1 == 1.3 + healthFor then
               setProperty('health', 0.5 + healthFor)
          elseif healthRound1 == 1.2 + healthFor then
               setProperty('health', 0.6 + healthFor)
          elseif healthRound1 == 1.1 + healthFor then
               setProperty('health', 0.9 + healthFor) 
          elseif healthRound1 == 1 + healthFor then
               setProperty('health', 1 + healthFor) 
          elseif healthRound1 == 0.9 + healthFor then
               setProperty('health', 1.1 + healthFor) 
          elseif healthRound1 == 0.8 + healthFor then
               setProperty('health', 1.2 + healthFor) 
          elseif healthRound1 == 0.7 + healthFor then
               setProperty('health', 1.3 + healthFor) 
          elseif healthRound1 == 0.6 + healthFor then
               setProperty('health', 1.4 + healthFor) 
          elseif healthRound1 == 0.5 + healthFor then
               setProperty('health', 1.5 + healthFor) 
          elseif healthRound1 == 0.4 + healthFor then
               setProperty('health', 1.4 + healthFor) 
          elseif healthRound1 == 0.3 + healthFor then
               setProperty('health', 1.5 + healthFor) 
          elseif healthRound1 == 0.2 + healthFor then
               setProperty('health', 1.6 + healthFor) 
          elseif healthRound1 == 0.1 + healthFor then
               setProperty('health', 1.9 + healthFor) 
          end
     else
          if health < 0.1 then
               setProperty('health', 2) 
          elseif healthRound == 0.1 + healthFor then
               setProperty('health', 1.9 + healthFor) 
          elseif healthRound == 0.2 + healthFor then
               setProperty('health', 1.8 + healthFor) 
          elseif healthRound == 0.3 + healthFor then
               setProperty('health', 1.7 + healthFor) 
          elseif healthRound == 0.4 + healthFor then
               setProperty('health', 1.6 + healthFor) 
          elseif healthRound == 0.5 + healthFor then
               setProperty('health', 1.5 + healthFor) 
          elseif healthRound == 0.6 + healthFor then
               setProperty('health', 1.4 + healthFor) 
          elseif healthRound == 0.7 + healthFor then
               setProperty('health', 1.3 + healthFor) 
          elseif healthRound == 0.8 + healthFor then
               setProperty('health', 1.2 + healthFor) 
          elseif healthRound == 0.9 + healthFor then
               setProperty('health', 1.1 + healthFor)  
          elseif healthRound == 1 + healthFor then
               setProperty('health', 1 + healthFor) 
          elseif healthRound == 1.1 + healthFor then
               setProperty('health', 0.9 + healthFor) 
          elseif healthRound == 1.2 + healthFor then
               setProperty('health', 0.8 + healthFor) 
          elseif healthRound == 1.3 + healthFor then
               setProperty('health', 0.7 + healthFor) 
          elseif healthRound == 1.4 + healthFor then
               setProperty('health', 0.6 + healthFor) 
          elseif healthRound == 1.5 + healthFor then
               setProperty('health', 0.5 + healthFor) 
          elseif healthRound == 1.6 + healthFor then
               setProperty('health', 0.4 + healthFor) 
          elseif healthRound == 1.7 + healthFor then
               setProperty('health', 0.3 + healthFor) 
          elseif healthRound == 1.8 + healthFor then
               setProperty('health', 0.2 + healthFor) 
          elseif healthRound == 1.9 + healthFor then
               setProperty('health', 0.1 + healthFor) 
          end
     end
end