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

    players = [p1, p2]

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

  # make the first move
  # don't move more than two spaces from the first guy
  def first_movep1(board) do
    co1 = Enum.random(1..5)
    co2 = Enum.random(1..5)
    co3 = Enum.random((bound(co1-2)..bound(co1+2) -- [co1, co2]))
    co4 = Enum.random((bound(co1-2)..bound(co1+2) -- [co1, co2]))
    players = [
      [
        [co1, co2],
        [co3, co4]
      ],
      [[],[]]
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
    p1 = player1(board)
    co1 = Enum.random(for i <- p1, j <- i, do: bound(j + 1))
    co2 = Enum.random(for i <- p1, j <- i, do: bound(j - 1))
    co3 = Enum.random((bound(co1-2)..bound(co1+2) -- [co1, co2]))
    co4 = Enum.random((bound(co1-2)..bound(co1+2) -- [co1, co2]))
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

  def pick_move(board) do
    p1 = player1(board)
    p2 = player2(board)

    cond do
      p1 == [[],[]] -> first_movep1(board)
      win?(board, Enum.fetch!(p1, 0)) -> 
        m = possible_moves(board, Enum.fetch!(p1, 0))
        move(board, Enum.fetch!(p1, 0), winning_move(board, m))
      win?(board, Enum.fetch!(p1, 1)) ->
        m = possible_moves(board, Enum.fetch!(p1, 1))
        move(board, Enum.fetch!(p1, 1), winning_move(board, m))
      true -> _ = possible_moves(board, {0, 0})
    end

    cond do
      p2 == [[],[]] -> first_movep2(board)
      win?(board, Enum.fetch!(p2, 0)) -> 
        m = possible_moves(board, Enum.fetch!(p2, 0))
        move(board, Enum.fetch!(p2, 0), winning_move(board, m))
      win?(board, Enum.fetch!(p2, 1)) ->
        m = possible_moves(board, Enum.fetch!(p2, 1))
        move(board, Enum.fetch!(p1, 1), winning_move(board, m))
      true -> r = Enum.fetch(p2, rand_guy())
        move(board, r, possible_moves(board, r))
    end

    # make the first move if no move has been made (first or second player)
    # case {player1(board),win?(board, Enum.fetch(player1(board),1))}  do
    #   {[[],[]], _} -> first_movep1(board)
    #   {x, true} -> 
    #     m = possible_moves(board, Enum.fetch!(x, 0))
    #     move(board, Enum.fetch!(x, 0), winning_move(board, m))
    #   {x, true} ->
    #     m = possible_moves(board, Enum.fetch!(x, 1))
    #     move(board, Enum.fetch!(x, 1), winning_move(board, m))
    #   # don't do anything with the first worker if he can't win
    #   _ -> _ = possible_moves(board, {0, 0}) 
    # end

    # case {player2(board),win?(board, Enum.fetch(player1(board),1))}  do
    #   {[[],[]], _} -> first_movep2(board)
    #   {x, true} -> 
    #     m = possible_moves(board, Enum.fetch!(x, 0))
    #     move(board, Enum.fetch!(x, 0), winning_move(board, m))
    #   {x, true} ->
    #     m = possible_moves(board, Enum.fetch!(x, 1))
    #     move(board, Enum.fetch!(x, 1), winning_move(board, m))
    #   # don't do anything with the first worker if he can't win
    #   {x, _} -> 
    #     r = Enum.fetch!(x, rand_guy())
    #     move(board, r, possible_moves(board, r))
    # end
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
    case Enum.fetch(Json.players(board), 0) do
      {:ok, pos} -> pos
      {:error, _} -> [[],[]]
    end
  end

  # control flow - don't call this function until the first player has definitely moved :D  
  def player2(board) do
    case Enum.fetch(Json.players(board), 1) do
      {:ok, pos} -> pos
      {:error, _} -> [[],[]]
    end
  end

  # spaces: current spaces on the board
  # {x, y}: current position of guy for whom we are enumerating spaces
  def possible_moves(board, {x, y}) do
    # my level
    level = get_level(board.spaces, {x, y})
    d = delta({x, y})
    players = Enum.flat_map(board.players, fn x -> x end)

    # check levels are not == 4
    moves = Enum.reject(d, fn [i, j] -> get_level(board.spaces, {i, j}) == 4 end) 
    # check levels are not higher than one above -- will also remove out of bounds squares, because their level is nil
    moves = Enum.reject(moves, fn [i, j] -> get_level(board.spaces, {i, j}) > level+1 end)
    # remove spaces another player is already on
    moves = moves -- players
    moves
  end

  def possible_moves(board, coord) do
    possible_moves(board, List.to_tuple(coord))
  end

  def winning_move(board, moves) do
    Enum.filter(moves, fn [i, j] -> get_level(board.spaces, {i, j}) == 3 end)
  end

  def delta({x, y}) do
    s = for i <- [-1, 0, 1], j <- [-1, 0, 1], do: [i, j]
    s = Enum.reject(s, fn z -> z == [0, 0] end)
    Enum.map(s, fn [i, j] -> [i+x, j+y] end)
  end

  def get_level(spaces, {x, y}) do
    # flatt coords start at 1 and not 0
    Enum.at(spaces, x-1)
    |>Enum.at(y-1)
  end
end
