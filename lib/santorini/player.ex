#defmodule Win do
#  alias Santorini.Player, as: Play
#  alias Santorini.ReadWr, as: Json
#
#  defmacro win?(board, player) do
#    quote do: unquote(Play.winning_move(board, Play.possible_moves(board, player))) != []
#  end
#end
#
defmodule Santorini.Player do
  @moduledoc false
  #  import Win
  alias Santorini.ReadWr, as: Json

  # xc & yc = current coordinates
  # xn & yn = new coordinates
  def move(board, {xc, yc}, {xn, yn}) do
    p1 = player1(board)
    p2 = player2(board)
  
    
    p1 = Enum.map(p1, fn 
      coord when coord == [xc, yc] -> [xn, yn]
      coord -> coord
    end)

    p2 = Enum.map(p2, fn 
      coord when coord == [xc, yc] -> [xn, yn]
      coord -> coord
    end)

    players = [p2, p1]

    %Board{
      players: players,
      spaces: board.spaces,
      turn: board.turn + 1
    }
  end

  # take a random move from a list of new moves
  def move(board, cur, new) do
    n = Enum.random(new)
    move(board, List.to_tuple(cur), List.to_tuple(n))
  end

  def build(board, {x, y}) do
    lvl = get_level(board.spaces, {x, y})
    row = List.replace_at(Enum.at(board.spaces, x-1), y-1, lvl+1)
    s = List.replace_at(board.spaces, x-1, row)

    %Board{
      players: board.players,
      spaces: s,
      turn: board.turn
    } 
  end

  # make the first move
  # don't move more than two spaces from the first guy
  def first_movep1(board) do
    co1 = Enum.random(1..5)
    co2 = Enum.random(1..5)
    co3 = Enum.random((Enum.map(bound(co1-2)..(bound(co1+2)), fn x -> x end) -- [co1, co2]))
    co4 = Enum.random((Enum.map(bound(co1-2)..(bound(co1+2)), fn x -> x end) -- [co1, co2]))
    players = [
        [co1, co2],
        [co3, co4]
    ]

    %Board{
      players: players,
      spaces: board.spaces,
      turn: board.turn + 1
    }
  end

  # make the first move for p2
  # don't move more than two spaces from the first guy or the first player
  # (guy in this context is the first worker p2 puts down)
  def first_movep2(board) do
    p1 = board.players
    co1 = Enum.at((for i <- p1, j <- i, do: bound(j + 1)), 0)
    co2 = Enum.at((for i <- p1, j <- i, do: bound(j - 3)), 0)
    co3 = Enum.random((Enum.map(bound(co1-2)..(bound(co1+2)), fn x -> x end) -- [co1, co2]))
    co4 = Enum.random((Enum.map(bound(co1-2)..(bound(co1+2)), fn x -> x end) -- [co1, co2]))
    players = [
      p1,
      [
        [co1, co2],
        [co3, co4]
      ]
    ]

    %Board{
      players: players, 
      spaces: board.spaces, 
      turn: board.turn + 1
    }
  end

  def win?(board, player) do
    m = possible_moves(board, player)
    winning_move(board, m) != []
  end

  def won?(board) do
    players = Enum.flat_map(board.players, fn x -> x end)
    lvls = for i <- players, do: get_level(board.spaces, List.to_tuple(i))
    IO.inspect(:stderr, lvls, [])
    Enum.any?(lvls, fn x -> x == 3 end)
  end

  # player has the position of two workers, eg. [[2,3],[4,4]]
  def pick_move(board, player) do
    cond do
      player == [[],[]] -> 
        if player1(board) == [[],[]] do
          first_movep1(board)
        else
          first_movep2(board)
        end
      win?(board, Enum.fetch!(player, 0)) -> 
        m = possible_moves(board, Enum.fetch!(player, 0))
        move(board, Enum.fetch!(player, 0), winning_move(board, m))
      win?(board, Enum.fetch!(player, 1)) ->
        m = possible_moves(board, Enum.fetch!(player, 1))
        move(board, Enum.fetch!(player, 1), winning_move(board, m))
      true -> r = Enum.fetch!(player, 0)
        move(board, r, possible_moves(board, r))
    end
  end

  def pick_build(board, player) do
    builds = possible_builds(board, List.to_tuple(Enum.fetch!(player, 0)))
    build(board, List.to_tuple(Enum.random(builds)))
  end

  def rand_guy do
    Enum.random([0, 1])
  end

  # set bounds for moves between 0-5 for the board size
  def bound(n) do
    case n do
      x when x < 1 -> 1
      x when x > 5 -> 5
      _ -> n
    end
  end

  def player1(board) do
    if board.players == nil do
      [[],[]]
    else
      case Enum.fetch(Json.players(board), 0) do
        {:ok, pos} -> pos
        {:error, _} -> [[],[]]
      end
    end
  end

  # control flow - don't call this function until the first player has definitely moved :D  
  def player2(board) do
    case Enum.fetch(Json.players(board), 1) do
      {:ok, pos} -> pos
      {:error, _} -> [player1(board),[]]
    end
  end

  # spaces: current spaces on the board
  # {x, y}: current position of guy for whom we are enumerating spaces
  def possible_moves(board, {x, y}) do
    # my level
    level = get_level(board.spaces, {x, y})
    d = delta({x, y})
    players = Enum.flat_map(board.players, fn x -> x end)

    # check levels are not higher than one above -- will also remove out of bounds squares, because their level is nil
    moves = Enum.reject(d, fn [i, j] -> get_level(board.spaces, {i, j}) > level+1 end)
    # check levels are not == 4
    moves = Enum.reject(moves, fn [i, j] -> get_level(board.spaces, {i, j}) == 4 end) 
    # remove spaces another player is already on
    moves = moves -- players
    moves
  end

  def possible_moves(board, coord) do
    possible_moves(board, List.to_tuple(coord))
  end

  def possible_builds(board, {x, y}) do
    d = delta({x, y})
    players = Enum.flat_map(board.players, fn x -> x end)
    # check levels are not == 4
    moves = Enum.reject(d, fn [i, j] -> get_level(board.spaces, {i, j}) === 4 end)
    # remove spaces another player is on
    moves = moves -- players
    moves
  end

  def winning_move(board, moves) do
    Enum.filter(moves, fn [i, j] -> get_level(board.spaces, {i, j}) == 3 end)
  end

  def delta({x, y}) do
    s = for i <- [-1, 0, 1], j <- [-1, 0, 1], do: [i, j]
    s = Enum.reject(s, fn z -> z == [0, 0] end)
    Enum.map(s, fn [i, j] -> [bound(i+x), bound(j+y)] end)
  end

  def get_level(spaces, {x, y}) do
    if (x > 5 or y > 5 or x < 1 or y < 1) do
      nil 
    else
      # flatt coords start at 1 and not 0
      Enum.at(spaces, x-1)
      |>Enum.at(y-1)
    end

  end
end
