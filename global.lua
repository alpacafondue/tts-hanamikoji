-- Menu buttons
function showButtons(player, value, id)
    if shown.buttons == false then
       Global.UI.show("buttons")
       shown.buttons = true
       Global.UI.setAttribute("showButtons", "text", "▲")
    else
       Global.UI.hide("buttons")
       shown.buttons = false
       Global.UI.setAttribute("showButtons", "text", "▼")
    end
end

-- Showing submenus (Reset)
function showForPlayer(params)
    local panel = params.panel
    local color = params.color
    local opened = Global.UI.getAttribute(panel, "visibility")
    if opened == nil then opened = "" end
 
    if opened:find(color) then
       opened = opened:gsub("|" .. color, "")
       opened = opened:gsub(color .. "|", "")
       opened = opened:gsub(color, "")
       Global.UI.setAttribute(panel, "visibility", opened)
       if opened == "" then
          Global.UI.setAttribute(panel, "active", "false")
          shown[panel] = false
       end
    else
       if shown[panel] ~= true then
          Global.UI.setAttribute(panel, "active", "true")
          Global.UI.setAttribute(panel, "visibility", color)
          shown[panel] = true
       else
          Global.UI.setAttribute(panel, "visibility", opened .. "|" .. color)
       end
    end
end

function actionButton(obj)
    local button = {}
    button.click_function = "actionClick"
    button.height = 800
    button.width = 800
    button.position={0,0,0}
    obj.createButton(button)
end

function actionClick(obj, playerColor)
    if playerColor ~= obj.getDescription() then
        broadcastToColor("Stay on your side buddy!", playerColor, playerColor)
        goto done
    end
    if playerColor == obj.getDescription() then
        if deck.getQuantity() == 8 then
            broadcastToAll("No one has drawn the first item card! Click Start Game", playerColor)
            for i,v in pairs(deckCounter) do
                v.highlightOn(stringColorToRGB("Yellow"), 2)
            end
            goto done
        end
        if playerTurn ~= obj.getDescription() then
            broadcastToColor("You must wait for your opponent to perform an action!", playerColor, playerColor)
            goto done
        end
        if playerTurn == obj.getDescription() and #colorPosition[otherColors(obj.getDescription())[1]].exchangeZone.getObjects() > 1 then
            broadcastToAll("Complete previous action!", playerColor)
            colorPosition[otherColors(obj.getDescription())[1]].exchange.highlightOn(stringColorToRGB("Yellow"), 2)
            goto done
        end
        if obj.getName() == "T1" and #colorPosition[obj.getDescription()].secretZone.getObjects() ~= 2 then
            broadcastToColor("Action requires you to put 1 item card in the secret area!", playerColor, playerColor)
            colorPosition[obj.getDescription()].secret.highlightOn(stringColorToRGB("Yellow"), 2)
            goto done
        end
        if obj.getName() == "T2" and #colorPosition[obj.getDescription()].discardZone.getObjects() ~= 3 then
            broadcastToColor("Action requires you to put 2 item cards in the discard area!", playerColor)
            colorPosition[obj.getDescription()].discard.highlightOn(stringColorToRGB("Yellow"), 2)
            goto done
        end
        if obj.getName() == "T3" and #colorPosition[obj.getDescription()].exchangeZone.getObjects() ~= 4 then
            broadcastToColor("Action requires you to put 3 item cards in the exchange area!", playerColor, playerColor)
            colorPosition[obj.getDescription()].exchange.highlightOn(stringColorToRGB("Yellow"), 2)
            goto done
        end
        if obj.getName() == "T4" and #colorPosition[obj.getDescription()].exchangeZone.getObjects() ~= 5 then
            broadcastToColor("Action requires you to put 4 item cards in the exchange area!", playerColor, playerColor)
            colorPosition[obj.getDescription()].exchange.highlightOn(stringColorToRGB("Yellow"), 2)
            goto done
        end

        deck.deal(1, otherColors(obj.getDescription())[1])
        Wait.time(function() sortCards(otherColors(obj.getDescription())[1]) end, 1)
        for i,v in pairs(deckCounter) do
            v.editButton({index = 0, label = deck.getQuantity()})
        end
        local playerName = Player[otherColors(obj.getDescription())[1]].steam_name or "Opponent"
        broadcastToAll(playerName .. "'s turn! Resolve outstanding actions.", otherColors(obj.getDescription())[1])

        local curr_rot = obj.getRotation()
        obj.setRotationSmooth({curr_rot.x,curr_rot.y,curr_rot.z+180}, false, false)
        obj.removeButton(0)

        colorPosition[obj.getDescription()].actionCount = colorPosition[obj.getDescription()].actionCount + 1
        colorPosition[obj.getDescription()].actions[obj.getName()].flipped = true

        playerTurn = otherColors(obj.getDescription())[1]
    end
    ::done::
end

function geishaLabel(obj)
    local button = {}
    button.click_function = "nothing"
    button.height = 0
    button.width = 0
    button.label = 0
    button.font_size = 300
    button.position={0,0.5,1.5}
    obj.createButton(button)
end

function vpLabel(obj)
    local button = {}
    button.click_function = "nothing"
    button.height = 0
    button.width = 0
    button.label = 0
    button.font_size = 300
    button.font_color = "White"
    button.position={0,0.75,0}
    obj.createButton(button)
end

function deckLabel(obj)
    local button = {}
    button.click_function = "nothing"
    button.height = 0
    button.width = 0
    button.label = deck.getQuantity()
    button.font_size = 150
    button.font_color = "Grey"
    button.position={0,0.75,0}
    obj.createButton(button)
end

function sdLabel(obj)
    local button = {}
    local col = "White"
    button.label = "[b]"..obj.getName().."[/b]"

    if obj.getName() == "SECRET" then
        col = "Green"
        button.label = button.label.."\nHidden From\nOpponent\n[i]Scored Later[/i]"
    elseif obj.getName() == "DISCARD" then
        col = "Red"
        button.label = button.label.."\nHidden From\nOpponent\n[i]Not Scored[/i]"
    else
    end
    button.click_function = "nothing"
    button.height = 0
    button.width = 0
    button.font_size = 70
    button.font_color = col
    button.position={0,0.5,0}
    obj.createButton(button)
end

function exchangeLabel(obj)
    local button = {}
    button.click_function = "nothing"
    button.height = 0
    button.width = 0
    button.label = "[b]"..obj.getName().."[/b]\nShared With\nOpponent"
    button.font_size = 55
    button.font_color = "Grey"
    button.position={0,0.5,0}
    obj.createButton(button)
end

function initialBL()
    local getAllObjects = getAllObjects()
    -- Create Action buttons
    for i,v in pairs(getAllObjects) do
        if string.sub(v.getName(),1,1) == "P" and inTable(fixedColor, v.getDescription()) then
            v.interactable = false
        end
        if string.sub(v.getName(),1,1) == "T" then
            actionButton(v)
        end
        if string.sub(v.getName(),1,1) == "P" and v.getDescription() == "Geisha" then
            geishaLabel(v)
            v.editButton({index = 0, font_color = lanes[v.getName()].color})
            v.setSnapPoints({
                {position = {0,0,3}},
                {position = {0,0,3.5}},
                {position = {0,0,4}},
                {position = {0,0,4.5}},
            })
        end
        if v.getName() == "Victory Points" then
            v.interactable = false
            vpLabel(v)
            if v.getDescription() == "Green" then
                v.editButton({index = 0, font_color = "Green"})
            end
        end
        if v.getName() == "Deck Counter" then
            v.interactable = false
            deckLabel(v)
        end
        if v.getName() == "SECRET" then
            v.interactable = false
            v.setSnapPoints({{position = {0,0,0}}})
        end
        if v.getName() == "DISCARD" then
            v.interactable = false
            v.setSnapPoints({
                {position = {0.25,0,0}},
                {position = {-0.25,0,0}}
            })
        end
        if v.getName() == "EXCHANGE" then
            v.interactable = false
            v.setSnapPoints({
                {position = {0.25,0,0.25}},
                {position = {0.25,0,-0.25}},
                {position = {-0.25,0,-0.25}},
                {position = {-0.25,0,0.25}}
            })
        end
    end
end

function onLoad()
    -- Turns
    Turns.enable = false
    Turns.disable_interactations = false
    Turns.pass_turns = false
    playerTurn = "Nothing"
    firstPlayer = "Nothing"

    -- Objects
    deck = getObjectFromGUID("f56545")
    newDeck = getObjectFromGUID("1fa18d")
    deckCounter = {getObjectFromGUID("018a91"), getObjectFromGUID("28a65c")}
    discard = getObjectFromGUID("7ab66c")

    -- Variables
    lanes = {
        ["P1"] = {x = -27, value = 2, won = false, wonBy = nil, ["whiteCount"] = 0, ["greenCount"] = 0, token = getObjectFromGUID("d6ec67"), color = "Yellow"},
        ["P2"] = {x = -18, value = 2, won = false, wonBy = nil, ["whiteCount"] = 0, ["greenCount"] = 0, token = getObjectFromGUID("6b35b6"), color = "Red"},
        ["P3"] = {x = -9, value = 2, won = false, wonBy = nil, ["whiteCount"] = 0, ["greenCount"] = 0, token = getObjectFromGUID("d408d9"), color = "Purple"},
        ["P4"] = {x = 0, value = 3, won = false, wonBy = nil, ["whiteCount"] = 0, ["greenCount"] = 0, token = getObjectFromGUID("17b4d2"), color = "Blue"},
        ["P5"] = {x = 9, value = 3, won = false, wonBy = nil, ["whiteCount"] = 0, ["greenCount"] = 0, token = getObjectFromGUID("78aa39"), color = "Orange"},
        ["P6"] = {x = 18, value = 4, won = false, wonBy = nil, ["whiteCount"] = 0, ["greenCount"] = 0, token = getObjectFromGUID("0cf464"), color = "Green"},
        ["P7"] = {x = 27, value = 5, won = false, wonBy = nil, ["whiteCount"] = 0, ["greenCount"] = 0, token = getObjectFromGUID("2ead4c"), color = "Pink"},
    }

    shown = {}
    tablePolygon = {{-31.5,22.5},{31.5,22.5},{31.5,-22.5},{-31.5,-22.5}}

    -- Player Colors
    gameColors = Player.getAvailableColors()
    fixedColor = {"White","Green"}
    allColor = {"White","Green","Grey"}

    colorPosition = {
        ["White"] = {polygon = {{-31.5,-1},{31.5,-1},{31.5,-22.5},{-31.5,-22.5}},
            color = stringColorToRGB("White"), rotation = {0,180,0},
            secret = getObjectFromGUID("56587e"), secretZone = getObjectFromGUID("370bbb"),
            discard = getObjectFromGUID("9fd89c"), discardZone = getObjectFromGUID("43080c"),
            exchange = getObjectFromGUID("43f125"), exchangeZone = getObjectFromGUID("38d3ee"),
            geishas = 0, victoryPoints = 0, victoryPointG = {getObjectFromGUID("0fc514"),getObjectFromGUID("058652")}, itemZ = -4,
            actionCount = 0,
            actions = {
                ["T1"] = {object = getObjectFromGUID("1330b8"), flipped = false},
                ["T2"] = {object = getObjectFromGUID("669d04"), flipped = false},
                ["T3"] = {object = getObjectFromGUID("ae2b73"), flipped = false},
                ["T4"] = {object = getObjectFromGUID("af7a78"), flipped = false},
            },
        },
        ["Green"] = {polygon = {{-31.5,1},{31.5,1},{31.5,22.5},{-31.5,22.5}},
            color = stringColorToRGB("Green"), rotation = {0,0,0},
            secret = getObjectFromGUID("49165e"), secretZone = getObjectFromGUID("d88993"),
            discard = getObjectFromGUID("303d85"), discardZone = getObjectFromGUID("5672a0"),
            exchange = getObjectFromGUID("e2ba71"), exchangeZone = getObjectFromGUID("339b41"),
            geishas = 0, victoryPoints = 0, victoryPointG = {getObjectFromGUID("392c35"),getObjectFromGUID("38f746")}, itemZ = 4,
            actionCount = 0,
            actions = {
                ["T1"] = {object = getObjectFromGUID("1169a5"), flipped = false},
                ["T2"] = {object = getObjectFromGUID("901b37"), flipped = false},
                ["T3"] = {object = getObjectFromGUID("9c0565"), flipped = false},
                ["T4"] = {object = getObjectFromGUID("efd693"), flipped = false},
            },
        },
    }

    
    -- Deal out initial hand
    discard.setInvisibleTo(allColor)
    deck.setInvisibleTo(allColor)
    newDeck.setInvisibleTo(allColor)
    deck.shuffle()
    initialBL()
end

function inTable(tbl, item)
    for key, value in pairs(tbl) do
        if value == item then return true end
    end
    return false
end

function inPoly(poly, obj)
    local inside = false
    local p1x = poly[1][1]
    local p1y = poly[1][2]
    local x = obj.getPosition().x
    local y = obj.getPosition().z

    for i=0,#poly do

        local p2x = poly[((i)%#poly)+1][1]
        local p2y = poly[((i)%#poly)+1][2]

        if y > math.min(p1y,p2y) then
            if y <= math.max(p1y,p2y) then
                if x <= math.max(p1x,p2x) then
                    if p1y ~= p2y then
                        xinters = (y-p1y)*(p2x-p1x)/(p2y-p1y)+p1x
                    end
                    if p1x == p2x or x <= xinters then
                        inside = not inside
                    end
                end
            end
        end
        p1x,p1y = p2x,p2y	
    end
    return inside
end

function otherColors(color)
    local c = {}
    for i,v in pairs(fixedColor) do
        if v ~= color then
            table.insert(c, v)
        end
    end
    return c
end

function randomize(t)
    for i = 1, #t*2 do
        local a = math.random(#t)
        local b = math.random(#t)
        t[a],t[b] = t[b],t[a]
    end 
    return t
end

function sortCards(playerColor)
    -- Sort cards by random suit order
    local cards = {}
    local handPos = {}
    local t = {"P1","P2","P3","P4","P5","P6","P7"}
    local o = {1,2}
    
    -- Get player"s hand
    local handObjects = Player[playerColor].getHandObjects()
    local randSuit = randomize(t)
    local randOrder = randomize(o)[1]
    
    -- One table stores card names, the other position
    for j, k in pairs(handObjects) do
        table.insert(handPos, k.getPosition())
        for x, y in pairs(randSuit) do
            if y == k.getName() then
                table.insert(cards, {card=k, ind=x, dir=randOrder,name=k.getName()})
            end
        end
    end
        
    -- Reorder names while retaining original positions
    table.sort(cards, function(a, b) 
        if a.ind ~= b.ind then 
            return a.ind < b.ind 
        end
        if a.dir == 1 then
            return a.name < b.name 
        else
            return a.name > b.name
        end
    end)
    
    -- Reset position of re-ordered cards
    for i, j in pairs(cards) do
        j.card.setPosition(handPos[i])
        j.card.setDescription("Item")
    end
end

function sortCardsAll()
    for i,v in pairs(fixedColor) do
        sortCards(v)
    end
end

function sortCardsButton(player, value, id)
    sortCards(player.color)
end

function startClicked(player, value, id)
    if deck.getQuantity() == 21 then
        discard.putObject(deck.takeObject({index=1}))
        
        for i,v in pairs(fixedColor) do
            deck.deal(6, v)
        end

        firstPlayer = player.color
        playerTurn = player.color
        deck.deal(1, player.color)
        Wait.time(sortCardsAll, 1)

        for i,v in pairs(deckCounter) do
            v.editButton({index = 0, label = deck.getQuantity()})
        end
        local playerName = Player[player.color].steam_name or "Opponent"
        broadcastToAll(playerName.."'s turn!", player.color)
    else
        broadcastToColor("Additional dealing happens after actions are clicked.", player.color, player.color)
    end
end

function updateScore()
    local allObjects = getAllObjects()
    for color in pairs(colorPosition) do
        local lowerColor = string.lower(color)
        local victoryPoints = 0
        local geishas = 0
        
        for k in pairs(lanes) do
            local count = 0
            local geisha = nil

            for i,v in pairs(allObjects) do
                if inPoly(colorPosition[color].polygon, v) and v.getName() == k and v.getDescription() == "ItemOK" then
                    local curr_pos = v.getPosition()
                    v.setPositionSmooth({lanes[v.getName()].x,curr_pos.y,curr_pos.z}, false, false)
                    v.setRotationSmooth(colorPosition[color].rotation, false, false)
                    v.setHiddenFrom({})
                    count = count + 1
                elseif inPoly(colorPosition[color].polygon, v) and v.getName() == k and v.getDescription() == "Geisha" then
                    geisha = v
                elseif inPoly(colorPosition[color].polygon, v) and v.getName() == k and v.getDescription() == color then
                    holder = v
                end
            end
            lanes[k][lowerColor.."Count"] = count
            geisha.editButton({index=0, label=count})
            
            if count / lanes[k].value > 0.5 then
                victoryPoints = victoryPoints + lanes[k].value
                geishas = geishas + 1
                lanes[k].won = true
                lanes[k].wonBy = color
            end
        end

        colorPosition[color].victoryPoints = victoryPoints
        colorPosition[color].geishas = geishas
    end
end

function scoreClicked(player, value, id)
    if deck.getQuantity() > 0 then
        broadcastToAll("There are still item cards left in the deck!", player.color)
        goto done
    end
    for i,v in pairs(fixedColor) do
        if #colorPosition[v].exchangeZone.getObjects() > 1 then
            broadcastToAll("Complete previous action!", player.color)
            colorPosition[v].exchange.highlightOn(stringColorToRGB("Yellow"), 2)
            goto done
        end
    end
    if deck.getQuantity() == 0 then
        for color in pairs(colorPosition) do
            if #colorPosition[color].secretZone.getQuantity() > 1 then
                for i,v in pairs(colorPosition[color].secretZone.getObjects()) do
                    if string.sub(v.getName(),1,1) == "P" then
                        v.setHiddenFrom({})
                        v.setPosition({lanes[v.getName()].x,1.55,colorPosition[color].discard.getPosition().z})
                        v.setRotation(colorPosition[color].rotation)
                    end
                end
            end
            
            if #colorPosition[color].discardZone.getObjects() > 1 then
                for i,v in pairs(colorPosition[color].discardZone.getObjects()) do
                    if string.sub(v.getName(),1,1) == "P" then
                        v.setHiddenFrom({})
                        discard.putObject(v)
                    end
                end
            end
        end
        updateScore()
        for color in pairs(colorPosition) do    
            local allObjects = getAllObjects()
            for k in pairs(lanes) do
                local holder = nil

                for i,v in pairs(allObjects) do
                    if inPoly(colorPosition[color].polygon, v) and v.getName() == k and v.getDescription() == color then
                        holder = v
                    end
                end
                if lanes[k].wonBy == color then
                    lanes[k].token.setPositionSmooth({lanes[k].x,1.65,colorPosition[color].itemZ})
                    holder.setColorTint({r=25/255, g=25/255, b=25/255})
                end
            end

            for x,y in pairs(colorPosition[color].victoryPointG) do
                y.editButton({index = 0, label = colorPosition[color].victoryPoints})
            end
        end
        nextRound()
    end
    ::done::
end

function nextRound()
    local allObjects = getAllObjects()
    local deckObjects = deck.getObjects()
    local nd = newDeck.takeObject()

    for i,v in pairs(fixedColor) do
        if colorPosition[v].geishas > 3 or colorPosition[v].victoryPoints > 10 then
            local playerName = Player[v].steam_name or "Opponent"
            broadcastToAll(playerName.."is the winner!", v)
            goto done
        end
    end
    for i,v in pairs(allObjects) do
        if v.getDescription():find("Item") then
            discard.putObject(v)
        end
        if string.sub(v.getName(),1,1) == "T" then
            local curr_rot = v.getRotation()
            v.setRotationSmooth({curr_rot.x,curr_rot.y,0}, false, false)
            colorPosition[v.getDescription()].actionCount = 0
            colorPosition[v.getDescription()].actions[v.getName()].flipped = false
            if v.getButtons() then
                v.removeButton(0)
            end
            actionButton(v)
        end
    end
    for i,v in pairs(deck.getObjects()) do
        discard.putObject(deck.takeObject(v))
    end
    
    firstPlayer = otherColors(firstPlayer)[1]
    playerTurn = firstPlayer

    Wait.condition(
        function() 
            for i = 1,21 do
                deck.putObject(nd.takeObject())
            end;
            deck.shuffle();
            discard.putObject(deck.takeObject({index=1}));
            for i,v in pairs(fixedColor) do
                deck.deal(6, v)
            end;
            deck.deal(1, firstPlayer);
            sortCardsAll();
            for i,v in pairs(deckCounter) do
                v.editButton({index = 0, label = deck.getQuantity()})
            end;
        end,
        function() return not nd.spawning end
    )

    broadcastToAll("The battle continues!", firstPlayer)
    ::done::
end

function onObjectPickUp(playerColor, obj)
    local secretObjects = colorPosition[playerColor].secretZone.getObjects()
    local discardObjects = colorPosition[playerColor].discardZone.getObjects()
    local exchangeObjects = colorPosition[playerColor].exchangeZone.getObjects()
    local handObjects = Player[playerColor].getHandObjects()

    if inTable(Player[otherColors(playerColor)[1]].getHandObjects(), obj)
    or inTable(colorPosition[otherColors(playerColor)[1]].secretZone.getObjects(), obj)
    or inTable(colorPosition[otherColors(playerColor)[1]].discardZone.getObjects(), obj)
    then
        broadcastToColor("You can only select from the exchange area!", playerColor, playerColor)
        obj.Drop()
        obj.setLock(true)
        Wait.time(|| obj.SetLock(false), 1)
        goto done
    elseif inTable(secretObjects, obj) and colorPosition[playerColor].actions["T1"].flipped == true then
        broadcastToColor("You already placed this item card in the secret area!", playerColor, playerColor)
        obj.Drop()
        obj.setLock(true)
        Wait.time(|| obj.SetLock(false), 1)
        goto done
    elseif inTable(discardObjects, obj) and colorPosition[playerColor].actions["T2"].flipped == true then
        broadcastToColor("You already placed this item card in the discard area!", playerColor, playerColor)
        obj.Drop()
        obj.setLock(true)
        Wait.time(|| obj.SetLock(false), 1)
        goto done
    end
    if inTable(handObjects, obj) then
        local problem_count = 0
        if deck.getQuantity() == 8 then
            broadcastToAll("No one has drawn the first item card! Click Start Game", playerColor)
            for i,v in pairs(deckCounter) do
                v.highlightOn(stringColorToRGB("Yellow"), 2)
            end
            problem_count = problem_count + 1
        elseif playerColor ~= playerTurn then
            broadcastToColor("You must wait for your opponent to perform an action!", playerColor, playerColor)
            problem_count = problem_count + 1
        elseif playerColor == playerTurn and #colorPosition[otherColors(playerColor)[1]].exchangeZone.getObjects() > 1 then
            broadcastToAll("Complete previous action!", playerColor)
            colorPosition[otherColors(playerColor)[1]].exchange.highlightOn(stringColorToRGB("Yellow"), 2)
            problem_count = problem_count + 1
        end

        if problem_count > 0 then
            obj.Drop()
            obj.setLock(true)
            Wait.time(|| obj.SetLock(false), 1)
            goto done
        else

            if colorPosition[playerColor].actions["T1"].flipped == false and #secretObjects ~= 2 then
                colorPosition[playerColor].secret.highlightOn(stringColorToRGB("Yellow"), 2)
                if #secretObjects == 1 then
                    sdLabel(colorPosition[playerColor].secret)
                end
            end
            if colorPosition[playerColor].actions["T2"].flipped == false and #discardObjects ~= 3 then
                colorPosition[playerColor].discard.highlightOn(stringColorToRGB("Yellow"), 2)
                if #discardObjects == 1 then
                    sdLabel(colorPosition[playerColor].discard)
                end
            end
            if (colorPosition[playerColor].actions["T3"].flipped == false and #exchangeObjects ~= 4) 
            or (colorPosition[playerColor].actions["T4"].flipped == false and #exchangeObjects ~= 5) then
                colorPosition[playerColor].exchange.highlightOn(stringColorToRGB("Yellow"), 2)
                if #exchangeObjects == 1 then
                    exchangeLabel(colorPosition[playerColor].exchange)
                end
            end
        end
    end
    if not(inPoly(tablePolygon, obj) or inTable(colorPosition["White"].exchangeZone.getObjects(), obj) or inTable(colorPosition["Green"].exchangeZone.getObjects(), obj)) then
        obj.setHiddenFrom(otherColors(playerColor))
    end
    ::done::
end

function onObjectDrop(playerColor, obj)
    local secretObjects = colorPosition[playerColor].secretZone.getObjects()
    local discardObjects = colorPosition[playerColor].discardZone.getObjects()
    local exchangeObjects = colorPosition[playerColor].exchangeZone.getObjects()
    local handObjects = Player[playerColor].getHandObjects()
    local problem_count = 0

    for i,v in pairs({"secret","discard","exchange"}) do
        if colorPosition[playerColor][v].getButtons() then
            colorPosition[playerColor][v].removeButton(0)
        end
    end

    if not(inPoly(tablePolygon, obj) or inTable(secretObjects, obj) or inTable(discardObjects, obj) or inTable(exchangeObjects, obj) or inTable(handObjects, obj)) then
        broadcastToColor("Place item cards in your own area!", playerColor, playerColor)
        problem_count = problem_count + 1
    end

    if inPoly(tablePolygon, obj) and obj.getDescription() ~= "ItemOK" then
        broadcastToColor("Item cards can only be played from the exchange area!", playerColor, playerColor)
        problem_count = problem_count + 1
    elseif inPoly(tablePolygon, obj) then
        updateScore()
    end

    if inTable(secretObjects, obj) and #secretObjects > 2 then
        broadcastToColor("You already have 1 secret item card!", playerColor, playerColor)
        problem_count = problem_count + 1
    elseif inTable(secretObjects, obj) then
        obj.setDescription("Item")
        obj.setHiddenFrom(otherColors(playerColor))
    end

    if inTable(discardObjects, obj) and #discardObjects > 3 then
        broadcastToColor("You already have 2 discard item cards!", playerColor, playerColor)
        problem_count = problem_count + 1
    elseif inTable(discardObjects, obj) then
        obj.setDescription("Item")
        obj.setHiddenFrom(otherColors(playerColor))
    end
    
    if inTable(exchangeObjects, obj) and #exchangeObjects > 5 then
        broadcastToColor("You already have 4 exchange item cards!", playerColor, playerColor)
        problem_count = problem_count + 1
    elseif inTable(exchangeObjects, obj) then
        obj.setDescription("ItemOK")
        obj.setHiddenFrom({})
    end

    if inTable(handObjects, obj) then
        obj.setDescription("Item")
    end    

    if problem_count > 0 then
        obj.deal(1, playerColor)
    end
end

-- Open Reset
function resetClicked(player, value, id)
    showForPlayer({panel = "reset", color = player.color})
end

-- No Reset
function noResetClicked(player, value, id)
    showForPlayer({panel = "reset", color = player.color})
end

-- Yes Reset
function yesResetClicked(player, value, id)
    local allObjects = getAllObjects()
    local deckObjects = deck.getObjects()
    local nd = newDeck.takeObject()

    -- Return to original state
    for i,v in pairs(allObjects) do
        if v.getButtons() then
            v.removeButton(0)
        end
        if string.sub(v.getName(),1,1) == "P" and inTable(fixedColor, v.getDescription()) then
            v.setColorTint({r=25/255, g=25/255, b=25/255, a=0/255})
        end
        if v.getDescription() == "Winner" then
            v.setPositionSmooth({lanes[v.getName()].x,1.5,0})
        end
        if v.getDescription():find("Item") then
            discard.putObject(v)
        end
        if string.sub(v.getName(),1,1) == "T" then
            local curr_rot = v.getRotation()
            v.setRotationSmooth({curr_rot.x,curr_rot.y,0}, false, false)
        end
    end

    for i,v in pairs(deckObjects) do
        discard.putObject(deck.takeObject(v))
    end


    Wait.condition(
        function() 
            for i = 1,21 do
                deck.putObject(nd.takeObject())
            end;
            onLoad();
            showForPlayer({panel = "reset", color = player.color});
        end,
        function() return not nd.spawning end
    )
end