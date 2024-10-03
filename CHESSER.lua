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
	},
	["LastNotativeMove"] = {
		[1] = "",
		[2] = ""
	},
	["WinTypes"] = {

	}
}

function PieceToString(n)
	local str = tostring(n)
	local addon = "0"
	if #str > 1 then addon = "" end
	return addon..str
end

function SplitLayout(layout)
	if not layout then layout = identities["Layouts"]["Basic"] end

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

function BoardAngle(side, layout)
	local splitted = SplitLayout(layout)
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

function Split(str, operator, dofunc)
	if not (dofunc == nil or dofunc) then
		return str
	else
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
end

function LoadLayout(layout, flip)
	if not flip then flip = 1 end
	for pos, piece in pairs(Split(BoardAngle(flip, layout), "-")) do
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
		local notation, board = table.unpack(data[1]), table.unpack(data[2])
		local area, destination = nil, nil

		return area, destination
	elseif func == 2 then -- given area destination
		local area, destination, castling, board = table.unpack(data[1]), table.unpack(data[2])
		local notation = nil

		return notation
	else
		return warn("Encode or Decode?")
	end
end

function PossibleMoves_Piece(pos, tab, castling) -- WIP
	local destable = {}
	local function getBoard(ftab, spl)
		if not ftab then ftab = ConjoinBoard(tab) end
		return Split(BoardAngle(math.floor((tonumber(Split(ftab, "-")[pos]) - 1) / 6) + 1, ftab), "-", spl)
	end
	
	local npos = pos + 8 * (7 - 2 * math.floor((pos - 1) / 8)) + 1
	local function MoveInDirection(data, ss)
		local nss = ss
		if not data then data = {0, 0} end
		if not ss then ss = npos end
		for i, cid in ipairs(data) do
			nss = nss + (15 * cid - 7 * i * cid)
		end;return(tonumber(getBoard()[ss])), nss, ss, data
	end

	local function Insert(n, d)
		if n then table.insert(destable, d[3]) end
	end

	local piece = MoveInDirection()[1]
	local turn = math.floor((piece - 1) / 6)
	local npiece = piece - 6 * turn

	local function NotPhasing(square)
		local nphasing = true
		local data = square[4]
		if square[1] == 1 or square[1] == 3 or square[1] == 6 then
			local fullsquare = 0
			if data[1] ~= 0 then 
				fullsquare = 1 
			else 
				fullsquare = 2 
			end
			local max = math.abs(data[1] + data[2])
			for i = 1, max do
				local cdata = data
				cdata[fullsquare] = (i * data[fullsquare]) / max
				nphasing = not nphasing or MoveInDirection(cdata, square[2])[1] ~= 0
			end
		elseif square[1] == 3 or square[1] == 4 then
			local max = math.abs(data[1])
			for i = 1, max do
				local cdata = data
				for j = 1, 2 do
					cdata[j] = (i * data[j]) / max
				end
				nphasing = not nphasing or MoveInDirection(cdata, square[2])[1] ~= 0
			end
		end
		return nphasing
	end

	local function CEBS(square) --SquareIsOnBoardAndEmptyOrCapture if backwards and some stuff removed
		return (0 < square[2] and square[2] <= 64) and ((6 * turn + 1 <= square[1] and square[1] <= 6 * (turn + 1)) or square[1] == 0)
	end

	local function absfunc(v)
		return function(c)
			return math.abs(v - 8 * math.floor((v - 1) / 8))
		end
	end

	if npiece == 1 then
		local function CanEnPassent(side)
			if math.abs(MoveInDirection({0, 0})[1] - MoveInDirection({0, 2 * turn - 3})[1]) == 6 and not npos / 8 - (2 - side) == math.floor(npos / 8) then
				local square = CodeMoves({{identities.LastNotativeMove[turn + 1]}, {getBoard(ConjoinBoard(identities["Board"]))}}, 1)[1]
				return 6 * 8 < square and square <= 7 * 8
			end
		end

		local advance1 = MoveInDirection({1, 0})
		Insert(NotPhasing(advance1), advance1)

		local advance2 = MoveInDirection({2, 0})
		Insert(NotPhasing(advance2) and 8 < npos and npos <= 16, advance2)

		local attackleft = MoveInDirection({1, -1})
		Insert(attackleft[1] ~= 0 or CanEnPassent(1), attackleft)

		local attackright = MoveInDirection({1, 1})
		Insert(attackright[1] ~= 0 or CanEnPassent(2), attackright)
	elseif npiece == 2 then
		for i = 1, 8 do
			local function quirkyfunc(v)
				local getabs = absfunc(v)
				return (getabs(1) - getabs(3) - getabs(5) + getabs(7)) / 2 - 1
			end

			local square = MoveInDirection({quirkyfunc(i + 2), quirkyfunc(i)})
			if CEBS(square) then
				local willbechecked = false
				--check if will be checked if moved here
				Insert(not willbechecked, square)
			end
		end
	elseif npiece == 3 then

	elseif npiece == 4 then

	elseif npiece == 5 then
		local function quirkyfunc(v)
			local getabs = absfunc(v)
			return (getabs(1) - getabs(2) - getabs(3) - getabs(4) + getabs(5) + getabs(6) + getabs(7) + getabs(8) - 2 * getabs(9)) / 2 + 1
		end
		local squares = {}
		for i = 1, 8 do
			local csquare = MoveInDirection({quirkyfunc(i + 1), quirkyfunc(i - 1)})
			Insert(CEBS(csquare), csquare)
		end
	elseif npiece == 6 then
		local squares = {}
		for i = 0, 27 do
			local m = i - 6 * math.floor(i / 6) + 1
	
		end
	end

	local movestable = {}
	for _, des in destable do
		table.insert(movestable, CodeMoves({npos, des}, {getBoard(), castling}))
	end
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

function Move(board, castling, turn, move)
	return CheckMovePossibility_ACT(board, castling, turn, move, function(b, c, t, m) -- So basically: IF possible DO this
		local Area, Destination = CodeMoves({{m}, {b}}, 1)
		local SplitString = Split(b, "-")
		local AreaPiece = tonumber(SplitString[Area])

		if (Destination + (t - 1) * (9 - Destination)) > (56 + (t - 1) * (Destination - 56)) and AreaPiece == 6 * (t - 1) + 1 then
			AreaPiece = EvaluatePosition(1, true)[2][1]
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

print(PlayOut({"e4", "e5", "Nf3"}))

function DrawGame()
	return ({["-1"] = true, ["1"] = false})[tostring(math.abs(3 * identities["Evaluation"] - 2 * identities["ourColor"] * identities["Evaluation"]) / 3 * identities["Evaluation"] - 2 * identities["ourColor"] * identities["Evaluation"])] 
end

function HandleGameEndingEvents()
	local winner
end

function EvaluatePosition(lookahead, returnvalues) -- WIP (chess bot)
	local evaluation = 0
	local recommendations = {} 
	--recommendations[1] should be what to promote to if promotion is recommended.
	--This will also be between numbers 3 and 6 if White or 9 and 12 if Black.

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
