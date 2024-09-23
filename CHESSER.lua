--CHESSER
identities = {
	["ourColor"] = 1,
	["Evaluation"] = 0,
	["Pieces"] = {
		["Names"] = {
			[1] = "Pawn", 
			[2] = "King", 
			[3] = "Queen", 
			[4] = "Bishop", 
			[5] = "Knight", 
			[6] = "Rook",
		},
		["Initials"] = {
			[1] = "",
			[2] = "K",
			[3] = "Q",
			[4] = "B",
			[5] = "N",
			[6] = "R",
		},
		["MaterialAdvantages"] = {
			[1] = 1,
			[2] = 20,
			[3] = 8,
			[4] = 3,
			[5] = 3,
			[6] = 5,
		}
	},
	["Letters"] = {
		[1] = "A",
		[2] = "B",
		[3] = "C",
		[4] = "D",
		[5] = "E",
		[6] = "F",
		[7] = "G",
		[8] = "H"
	},
	["Color"] = {
		[1] = "White",
		[2] = "Black"
	},
	["Board"] = {},
	["CurrentPlayout"] = {},
	["Layouts"] = {
		["Clear"] = "00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00",
		["Basic"] = "06-05-04-03-02-04-05-06-01-01-01-01-01-01-01-01-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-07-07-07-07-07-07-07-07-12-11-10-09-08-10-11-12"
	}
}

function PieceToString(n)
	local str = tostring(n)
	local addon = "0"
	if #str > 1 then addon = "" end
	return addon..str
end

function SplitLayout(lname)
	if not lname then lname = "Basic" end
	local layout = identities["Layouts"][lname]

	local coloums = 8
	local data = 3
	local t = coloums * data

	local returned = {}

	for i = 1, 8 do
		local b = t*i-1
		table.insert(returned, layout:sub(b-t+2,b))
	end
	return returned
end

function ConjoinBoard(splitpart)
	local str = ""
	for i, v in ipairs(splitpart) do
		str = str..v
		if i ~= #splitpart then
			str = str.."-"
		end
	end
	return str
end

function BoardAngle(side, lname)
	local splitted = SplitLayout(lname)
	local flipped = {}

	for i = 1,8 do
		local oppo
		if side == 1 then
			oppo = 9 - i + 8*math.floor(i/9)
		elseif side == 2 then
			oppo = i
		end
		
		flipped[i] = splitted[oppo]
	end
	
	return ConjoinBoard(flipped)
end

function Split(str, operator)
	local t,c = {},0
	local function add() table.insert(t, ""); c = c + 1 end
	add()
	for i = 1, #str do
		local char = str:sub(i, i)
		if char ~= operator then
			t[c] = t[c]..char
		else
			add()
		end
	end
	return t
end

function LoadLayout(lname, flip)
	if not flip then flip = 1 end
	for pos, piece in pairs(Split(BoardAngle(flip, lname), "-")) do
		local p = pos - 1
		identities["Board"][identities["Letters"][p + 1 - 8*math.floor(p/8)]..tostring(math.floor(p/8+1))] = {tostring(p - 2*math.floor(p/2)), piece}
	end
end

function PrintBoard()
	local final = ""
	for i = 1, 8 do
		local txt = ""
		for j = 1, 8 do
			txt = txt..identities["Board"][identities["Letters"][j]..tostring(i)][2].."-"
		end
		final = final.."\n"..txt:sub(1, #txt - 1)
	end
	final = final:sub(2, #final)
	return "\n"..final
end

LoadLayout() --LoadLayout("Clear") would clear the board
PrintBoard() --Prints the board state to the output

function CodeMoves(data, func) -- WIP
	if func == 1 then -- given notation
		local board, notation = table.unpack(data)
	elseif func == 2 then -- given area destination
		
	else
		return warn("Encode or Decode?")
	end
end

function PossibleMoves_Piece(pos, tab, castling) -- WIP
	local movestable = {}
	return movestable
end

function PossibleMoves(turn, board, castling)
	local moves = {}
	local split = Split(board, "-")
	
	for pos, piece in ipairs(split) do
		if 6 * turn - 6 < tonumber(piece) and tonumber(piece) < 6 * turn + 1 then
			--piece is a piece we want to figure out where we can move it
			local possible = PossibleMoves_Piece(pos, split, castling)
			for _, piecemove in ipairs(possible) do
				table.insert(moves, piecemove)
			end
		end
	end
	
	return moves
end

function CheckMovePossibility_ACT(board, castling, turn, move, action)
	local moved = false
	local moves, ncastling = PossibleMoves(turn, board, castling)
	for _, pmove in ipairs(moves) do
		if pmove == move then
			moved = true
			if action then action(board, ncastling,  turn, move) end
		end
	end
	return moved, board
end

function EvaluatePosition(lookahead, returnvalues) --  !!WARNING!! ---HARD--- !!WARNING!! WIP
	local evaluation = 0
	local recommendations = {}
	
	if lookahead > 0 then
		recommendations = {}
	else
		
	end
	
	if returnvalues then
		return evaluation, recommendations
	else
		identities["Evaluation"] = evaluation
	end
end

function CheckForInputs(data)
	if data[1] == "Draw" then
		local evaluation = identities["Evaluation"] * (1 - 2 * (identities["ourColor"] - 1))
		return ({["-1"] = true, ["1"] = false})[tostring(math.abs(evaluation) / evaluation)]
	elseif data[1] == "Promo" then
		return EvaluatePosition(1, true)[2][1]
	end
end

function Move(board, castling, turn, move)
	return CheckMovePossibility_ACT(board, castling, turn, move, function(b, c, t, m) -- So basically: IF possible DO this
		local Area, Destination = CodeMoves(1, {m})
		local SplitString = Split(b, "-")
		local AreaPiece = tonumber(SplitString[Area])
		
		if (Destination + (t - 1) * (9 - Destination)) > (56 + (t - 1) * (Destination - 56)) and AreaPiece == 6 * (t - 1) + 1 then
			AreaPiece = CheckForInputs({"Promo"})
		end
		
		SplitString[Area] = PieceToString(0)
		SplitString[Destination] = PieceToString(AreaPiece)
		
		if AreaPiece + 4 == 6 * t then
			local RookArea
			local RookDestination
			
			if Destination - Area == 2 and c[t][1] then
				RookArea, RookDestination = 56 * t - 48, 56 * t - 50
			elseif Area - Destination == 2 and c[t][2] then
				RookArea, RookDestination = 56 * t - 55, 56 * t - 52
			end
			
			SplitString[RookArea] = PieceToString(0)
			SplitString[RookDestination] = PieceToString(6 * t)
		end
	end)
end

function PlayOut(lines, dv)
	if dv == nil then dv = {} end
	for i = 1, 3 do
		if dv[i] == nil then
			dv[i] = ({1, identities["Layouts"]["Basic"], true})[i]
		end
	end
	
	local currentturn, board, castling = table.unpack(dv)
	for n, move in ipairs(lines) do
		local success, result = Move(board, castling, currentturn, move)
		if success then 
			currentturn = 3 - currentturn
			board = result
		else
			warn("Move "..tostring(n).." in your lines is not possible!")
			return false
		end
	end
	return board
end

print(PlayOut({"e4"}))
