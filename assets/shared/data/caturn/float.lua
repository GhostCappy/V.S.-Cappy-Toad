local timer = 0;
function onUpdate()
    doTweenY('opponentFloat', 'dad', ((math.sin(timer*2)*80)-90), 0.001, 'linear')
    doTweenY('bfFloat', 'boyfriend', ((math.sin(timer*2)*80)+180), 0.01, 'linear')
    doTweenY('gfFloat', 'gf', ((math.sin(timer*2)*80)-360), 0.5, 'linear')
    timer = timer+0.01
 end
