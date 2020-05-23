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
    
    geishaObj = {["White"]={},["Green"]={}}

    shown = {}
    gameScored = false
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

    -- Hide decks adn shuffle
    discard.setInvisibleTo(allColor)
    deck.setInvisibleTo(allColor)
    newDeck.setInvisibleTo(allColor)
    deck.shuffle()

    --Button Label creation
    initialBL()
end

function initialBL()
    local getAllObjects = getAllObjects()

    for i,v in pairs(getAllObjects) do
        -- Disable Geisha holder interaction
        if string.sub(v.getName(),1,1) == "P" and inTable(fixedColor, v.getDescription()) then
            v.interactable = false
        end
        -- Create Action Buttons
        if string.sub(v.getName(),1,1) == "T" then
            actionButton(v)
            if v.getName() == "T1" then v.editButton({index=0, tooltip="1: Save 1"}) end
            if v.getName() == "T2" then v.editButton({index=0, tooltip="2: Discard 2"}) end
            if v.getName() == "T3" then v.editButton({index=0, tooltip="3: Give 1 Take 2"}) end
            if v.getName() == "T4" then v.editButton({index=0, tooltip="4: Give Pair Take Pair"}) end
        end
        -- Geishas
        if string.sub(v.getName(),1,1) == "P" and v.getDescription() == "Geisha" then
            -- Create lane count label
            geishaLabel(v)
            v.editButton({index = 0, font_color = lanes[v.getName()].color})
            -- Create snap points
            v.setSnapPoints({
                {position = {0,0,3}},
                {position = {0,0,3.5}},
                {position = {0,0,4}},
                {position = {0,0,4.5}},
            })
            -- Build table with snap point positions relative to world
            local snaps = {}
            for j,k in pairs(v.getSnapPoints()) do
                snaps["sp"..j] = {position=v.positionToWorld(k["position"]),filled=false}
            end
            for j,k in pairs(fixedColor) do
                if inPoly(colorPosition[k].polygon, v) then
                    geishaObj[k][v.getName()] = {object=v, points=snaps}
                end
            end
        end
        -- Create Victory Point labels
        if v.getName() == "Victory Points" then
            v.interactable = false
            vpLabel(v)
            if v.getDescription() == "Green" then
                v.editButton({index = 0, font_color = "Green"})
            end
        end
        -- Create deck counter labels
        if v.getName() == "Deck Counter" then
            v.interactable = false
            deckLabel(v)
        end
        -- Create zone snap points
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

function cardButton(obj)
    local button = {}
    button.click_function = "cardClick"
    button.height = 1000
    button.width = 800
    button.position={0,0,0}
    button.tooltip="Select: "..lanes[obj.getName()].color.." "..lanes[obj.getName()].value
    button.color={r=25/255, g=25/255, b=25/255, a=0/255}
    obj.createButton(button)
end

function cardClick(obj, playerColor)
    local zone = nil
    local zoneColor = nil
    local zoneCount = 0
    local ge = geishaObj[playerColor][obj.getName()]
    local playerName = Player[otherColors(playerColor)[1]].steam_name or "Opponent"

    for i,v in pairs(fixedColor) do
        local czone = colorPosition[v].exchangeZone.getObjects()
        if inTable(czone, obj) then
            zone = czone
            zoneColor = v
            zoneCount = #czone
        end
    end

    if playerColor == zoneColor and zoneCount > 3 then
        broadcastToColor("Let opponent claim their cards first!", playerColor, playerColor)
        goto done
    end
    if playerColor ~= zoneColor and zoneCount < 4 then
        broadcastToColor("You already claimed your cards!", playerColor, playerColor)
        goto done
    end

    for i, snap in pairs(ge.points) do
        if snap.filled == true then
        else
            geishaObj[playerColor][obj.getName()].points[i].filled = true
            obj.removeButton(0)
            obj.setLock(false)
            obj.setPositionSmooth({snap.position.x, 1.65, snap.position.z}, false, false)
            obj.setRotationSmooth(colorPosition[playerColor].rotation, false, false)
            break
        end
    end

    Wait.condition(
        function()
            updateScore();
            if playerColor == zoneColor and zoneCount == 2 and deck.getQuantity() > 0 then
                deck.deal(1, otherColors(playerColor)[1])
                Wait.time(function() sortCards(otherColors(playerColor)[1]) end, 1)
                for i,v in pairs(deckCounter) do
                    v.editButton({index = 0, label = deck.getQuantity()})
                end
                broadcastToAll(playerName .. "'s turn!", otherColors(playerColor)[1])
                playerTurn = otherColors(playerColor)[1]
            end;
        end,
        function()
            return not obj.isSmoothMoving()
        end
    )
    ::done::
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
        if deck.getQuantity() == 21 then
            broadcastToAll("No one has drawn the first item card! Click Start Game", playerColor)
            for i,v in pairs(deckCounter) do
                v.highlightOn(stringColorToRGB("Yellow"), 2)
            end
            goto done
        end
        -- if playerTurn ~= obj.getDescription() and #colorPosition[otherColors(obj.getDescription())[1]].exchangeZone.getObjects() > 1 then
        --     broadcastToAll("Complete previous action!", playerColor)
        --     colorPosition[otherColors(obj.getDescription())[1]].exchange.highlightOn(stringColorToRGB("Yellow"), 2)
        --     goto done
        -- end
        if playerTurn ~= obj.getDescription() and colorPosition[otherColors(obj.getDescription())[1]].actionCount == 0 and colorPosition[obj.getDescription()].actionCount == 0 then
            broadcastToColor("Opponent needs to perform first action!", playerColor, playerColor)
            goto done
        end
        if playerTurn ~= obj.getDescription() then
            colorPosition[otherColors(obj.getDescription())[1]].exchange.highlightOn(stringColorToRGB("Yellow"), 2)
            colorPosition[obj.getDescription()].exchange.highlightOn(stringColorToRGB("Yellow"), 2)
            broadcastToColor("Are all actions complete? Do you need to draw an item card?", playerColor, playerColor)
            goto done
        end
        if (playerColor == firstPlayer and colorPosition[playerColor].actionCount - colorPosition[otherColors(playerColor)[1]].actionCount > 0) 
        or (playerColor ~= firstPlayer and colorPosition[otherColors(playerColor)[1]].actionCount - colorPosition[playerColor].actionCount < 1) then
            broadcastToColor("You already performed an action! Opponent's turn.", playerColor, playerColor)
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

        if obj.getName() == "T1" or obj.getName() == "T2" then
            if #colorPosition[otherColors(obj.getDescription())[1]].exchangeZone.getObjects() > 1 or #colorPosition[obj.getDescription()].exchangeZone.getObjects() > 1 then
                broadcastToAll("Complete previous action!", playerColor)
                colorPosition[otherColors(obj.getDescription())[1]].exchange.highlightOn(stringColorToRGB("Yellow"), 2)
                colorPosition[obj.getDescription()].exchange.highlightOn(stringColorToRGB("Yellow"), 2)
                goto done
            end
            deck.deal(1, otherColors(playerColor)[1])
            Wait.time(function() sortCards(otherColors(playerColor)[1]) end, 1)
            for i,v in pairs(deckCounter) do
                v.editButton({index = 0, label = deck.getQuantity()})
            end
            local playerName = Player[otherColors(playerColor)[1]].steam_name or "Opponent"
            broadcastToAll(playerName .. "'s turn!", otherColors(playerColor)[1])
            playerTurn = otherColors(playerColor)[1]
        end

        local curr_rot = obj.getRotation()
        obj.setRotationSmooth({curr_rot.x,curr_rot.y,curr_rot.z+180}, false, false)
        obj.removeButton(0)

        colorPosition[obj.getDescription()].actionCount = colorPosition[obj.getDescription()].actionCount + 1
        colorPosition[obj.getDescription()].actions[obj.getName()].flipped = true

        for i,v in pairs({"secret","discard","exchange"}) do
            for j,k in pairs(colorPosition[obj.getDescription()][v.."Zone"].getObjects()) do
                if string.sub(k.getName(),1,1) == "P" then
                    k.setLock(true)
                    if v == "exchange" then
                        cardButton(k)
                    end
                end
            end
        end
        
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

function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
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
        local playerName = Player[player.color].steam_name
        broadcastToAll(playerName.."'s turn!", player.color)
    elseif deck.getQuantity() == 0 and gameScored == true then
        nextRound()
    elseif deck.getQuantity() == 0 and gameScored == false then
        broadcastToAll("Game has not been scored!", player.color, player.color)
    else
        broadcastToColor("Game already started!", player.color, player.color)
    end
end

function drawClicked(player, value, id)
    local playerName = Player[player.color].steam_name
    if deck.getQuantity() == 21 then
        broadcastToAll("No one has drawn the first item card! Click Start Game", player.color)
        for i,v in pairs(deckCounter) do
            v.highlightOn(stringColorToRGB("Yellow"), 2)
        end
        goto done
    end
    if #colorPosition[otherColors(player.color)[1]].exchangeZone.getObjects() > 1 or #colorPosition[player.color].exchangeZone.getObjects() > 1 then
        broadcastToAll("Complete previous action!", playerColor)
        colorPosition[otherColors(player.color)[1]].exchange.highlightOn(stringColorToRGB("Yellow"), 2)
        colorPosition[player.color].exchange.highlightOn(stringColorToRGB("Yellow"), 2)
        goto done
    end
    if deck.getQuantity() == 0 then
        broadcastToAll("No more cards to draw! Click Score Game", player.color)
        for i,v in pairs(deckCounter) do
            v.highlightOn(stringColorToRGB("Yellow"), 2)
        end
        goto done
    end
    if (player.color == firstPlayer and math.fmod(deck.getQuantity(),2) ~= 0) or (player.color ~= firstPlayer and math.fmod(deck.getQuantity(),2) == 0) then
        broadcastToColor("You already drew a card or it was drawn for you!", player.color, player.color)
        goto done
    end
    if (player.color == firstPlayer and colorPosition[player.color].actionCount - colorPosition[otherColors(player.color)[1]].actionCount > 0) 
    or (player.color ~= firstPlayer and colorPosition[otherColors(player.color)[1]].actionCount - colorPosition[player.color].actionCount < 1) then
        broadcastToColor("You must wait for your opponent to perform an action!", player.color, player.color)
        goto done
    end

    deck.deal(1, player.color)
    Wait.time(function() sortCards(player.color) end, 1)
    for i,v in pairs(deckCounter) do
        v.editButton({index = 0, label = deck.getQuantity()})
    end
    broadcastToAll(playerName .. "'s turn!", player.color)
    playerTurn = player.color
    ::done::
end

function updateScore()
    for color in pairs(colorPosition) do
        local lowerColor = string.lower(color)
        
        for k in pairs(lanes) do
            local count = 0
            local geisha = nil

            for i,v in pairs(getAllObjects()) do
                if inPoly(colorPosition[color].polygon, v) and v.getName() == k and v.getDescription():find("Item") then
                    local curr_pos = v.getPosition()
                    v.setRotationSmooth(colorPosition[color].rotation, false, false)
                    v.setHiddenFrom({})
                    if v.getPosition().x ~= lanes[v.getName()].x then
                        v.setPositionSmooth({lanes[v.getName()].x,curr_pos.y,curr_pos.z}, false, false)
                    end
                    count = count + 1
                elseif inPoly(colorPosition[color].polygon, v) and v.getName() == k and v.getDescription() == "Geisha" then
                    geisha = v
                end
            end
            lanes[k][lowerColor.."Count"] = count
            geisha.editButton({index=0, label=count})
        end
    end
end

function getCards()
    for i, color in pairs(fixedColor) do
        if #colorPosition[color].secretZone.getObjects() > 1 then
            for i,v in pairs(colorPosition[color].secretZone.getObjects()) do
                if string.sub(v.getName(),1,1) == "P" then
                    v.setHiddenFrom({})
                    v.setLock(false)
                    v.setPositionSmooth({lanes[v.getName()].x,1.55,colorPosition[color].discard.getPosition().z}, false, false)
                    v.setRotationSmooth(colorPosition[color].rotation, false, false)
                    Wait.condition(
                        function()
                            updateScore();
                            getScored()
                        end,
                        function()
                            return not v.isSmoothMoving()
                        end
                    )
                end
            end
        end
        
        if #colorPosition[color].discardZone.getObjects() > 1 then
            for i,v in pairs(colorPosition[color].discardZone.getObjects()) do
                if string.sub(v.getName(),1,1) == "P" then
                    v.setHiddenFrom({})
                    v.setLock(false)
                    discard.putObject(v)
                end
            end
        end
    end
end

function getScored()
    for i, color in pairs(fixedColor) do    
        local lowerColor = string.lower(color)
        local victoryPoints = 0
        local geishas = 0
        for k in pairs(lanes) do
            local holder = nil

            for i,v in pairs(getAllObjects()) do
                if inPoly(colorPosition[color].polygon, v) and v.getName() == k and v.getDescription() == color then
                    holder = v
                end
            end

            if lanes[k][lowerColor.."Count"] > lanes[k][string.lower(otherColors(color)[1]).."Count"] and lanes[k].won == false then
                lanes[k].won = true
                lanes[k].wonBy = color
            end

            if lanes[k].wonBy == color then
                victoryPoints = victoryPoints + lanes[k].value
                geishas = geishas + 1
            end

            if lanes[k].wonBy == color then
                lanes[k].token.setPositionSmooth({lanes[k].x,1.65,colorPosition[color].itemZ}, false, false)
                holder.setColorTint({r=25/255, g=25/255, b=25/255})
            end
        end

        colorPosition[color].victoryPoints = victoryPoints
        colorPosition[color].geishas = geishas

        for x,y in pairs(colorPosition[color].victoryPointG) do
            y.editButton({index = 0, label = colorPosition[color].victoryPoints})
        end
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
        if #Player[v].getHandObjects() > 0 then
            broadcastToAll("Cards still in hand!", player.color)
            goto done
        end
        if not(colorPosition[v].actionCount == 4) then
            broadcastToAll("Not all actions are complete!", player.color)
            goto done
        end
    end
    if deck.getQuantity() == 0 then
        getCards()
        gameScored = true
    end
    ::done::
end

function nextRound()
    local deckObjects = deck.getObjects()

    for i,v in pairs(fixedColor) do
        if colorPosition[v].victoryPoints > 10 then
            local playerName = Player[v].steam_name or "Opponent"
            broadcastToAll(playerName.." is the winner!", v)
            goto done
        end
        if colorPosition[v].geishas > 3 then
            local playerName = Player[v].steam_name or "Opponent"
            broadcastToAll(playerName.." is the winner!", v)
            goto done
        end
        for k in pairs(geishaObj[v]) do
            for x, y in pairs(geishaObj[v][k].points) do
                geishaObj[v][k].points[x].filled = false
            end
        end
    end
    for i,v in pairs(getAllObjects()) do
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
    gameScored = false

    nd = newDeck.takeObject()

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
    Wait.frames(updateScore, 60)
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
    or inTable(colorPosition[otherColors(playerColor)[1]].exchangeZone.getObjects(), obj)
    then
        -- broadcastToColor("You can only select from the exchange area!", playerColor, playerColor)
        broadcastToColor("You can move cards from your own hand!", playerColor, playerColor)
        obj.Drop()
        obj.setLock(true)
        Wait.time(|| obj.SetLock(false), 1)
        goto done
    -- elseif inTable(secretObjects, obj) and colorPosition[playerColor].actions["T1"].flipped == true then
    --     broadcastToColor("You already placed this item card in the secret area!", playerColor, playerColor)
    --     obj.Drop()
    --     obj.setLock(true)
    --     Wait.time(|| obj.SetLock(false), 1)
    --     goto done
    -- elseif inTable(discardObjects, obj) and colorPosition[playerColor].actions["T2"].flipped == true then
    --     broadcastToColor("You already placed this item card in the discard area!", playerColor, playerColor)
    --     obj.Drop()
    --     obj.setLock(true)
    --     Wait.time(|| obj.SetLock(false), 1)
    --     goto done
    -- elseif inTable(colorPosition[otherColors(playerColor)[1]].exchangeZone.getObjects(), obj)
    -- and ((playerColor == firstPlayer and colorPosition[playerColor].actionCount - colorPosition[otherColors(playerColor)[1]].actionCount > 0) 
    -- or (playerColor ~= firstPlayer and colorPosition[otherColors(playerColor)[1]].actionCount - colorPosition[playerColor].actionCount < 1))
    -- then
    --     broadcastToColor("Opponent needs to complete action!", playerColor, playerColor)
    --     obj.Drop()
    --     obj.setLock(true)
    --     Wait.time(|| obj.SetLock(false), 1)
    --     goto done
    end
    if inTable(handObjects, obj) then
        local problem_count = 0
        if deck.getQuantity() == 21 then
            broadcastToAll("No one has drawn the first item card! Click Start Game", playerColor)
            for i,v in pairs(deckCounter) do
                v.highlightOn(stringColorToRGB("Yellow"), 2)
            end
            problem_count = problem_count + 1
        -- elseif playerColor ~= playerTurn and #colorPosition[otherColors(playerColor)[1]].exchangeZone.getObjects() > 1 then
        --     broadcastToAll("Complete previous action!", playerColor)
        --     colorPosition[otherColors(playerColor)[1]].exchange.highlightOn(stringColorToRGB("Yellow"), 2)
        --     problem_count = problem_count + 1
        elseif playerColor ~= playerTurn and colorPosition[otherColors(playerColor)[1]].actionCount == 0 and colorPosition[playerColor].actionCount == 0 then
            broadcastToColor("Opponent needs to perform first action!", playerColor, playerColor)
            problem_count = problem_count + 1
        elseif playerColor ~= playerTurn then
            colorPosition[otherColors(playerColor)[1]].exchange.highlightOn(stringColorToRGB("Yellow"), 2)
            colorPosition[playerColor].exchange.highlightOn(stringColorToRGB("Yellow"), 2)
            broadcastToColor("Are all actions complete? Do you need to draw an item card?", playerColor, playerColor)
            problem_count = problem_count + 1
        elseif (playerColor == firstPlayer and colorPosition[playerColor].actionCount - colorPosition[otherColors(playerColor)[1]].actionCount > 0) 
        or (playerColor ~= firstPlayer and colorPosition[otherColors(playerColor)[1]].actionCount - colorPosition[playerColor].actionCount < 1) then
            broadcastToColor("You already performed an action! Opponent's turn.", playerColor, playerColor)
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
        -- Wait.time(updateScore, 1)
        Wait.frames(updateScore, 60)
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
    elseif inTable(exchangeObjects, obj) and colorPosition[playerColor].actions["T3"].flipped == true and colorPosition[playerColor].actions["T4"].flipped == true then
        broadcastToColor("You already exchanged!!", playerColor, playerColor)
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
            v.setPositionSmooth({lanes[v.getName()].x,1.5,0}, false, false)
        end
        if v.getDescription():find("Item") or v.getDescription() == "iDeck" then
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