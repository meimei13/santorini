defmodule Santorini.Prometheus do
  @moduledoc false
  # xc & yc = current coordinates
  # xn & yn = new coordinates
  def move(board, {xc, yc}, {xn, yn}) do
    p1 = myplayer(board)
    
    ts = Enum.map(p1.tokens, fn
      coord when coord == [xc, yc] -> [xn, yn]
      coord -> coord
    end)

    p = %Players{
      card: p1.card,
      tokens: ts
    }

    players = [p, board.players |>Enum.at(1)]

    %Board{
      players: players,
      spaces: board.spaces,
      turn: board.turn
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
      players: [board.players|>Enum.at(1), board.players|>Enum.at(0)],
      spaces: s,
      turn: board.turn + 1
    } 
  end

  def first_move(board) do
    co1 = Enum.random(1..5)
    co2 = Enum.random(1..5)
    co3 = Enum.random((Enum.map(bound(co1-2)..(bound(co1+2)), fn x -> x end) -- [co1, co2]))
    co4 = Enum.random((Enum.map(bound(co1-2)..(bound(co1+2)), fn x -> x end) -- [co1, co2]))

    opponent = board.players|>Enum.at(1)

    token = case opponent.tokens do
      nil -> [[co1, co2],[co3, co4]]
      x -> Enum.map(x, fn
        coord when coord == [co1, co2] -> [bound(co1+1), bound(co2-1)]
        _ -> [co1, co2]  
        end)
    end

    token = [Enum.at(token, 0), [co3, co4]]
    p = myplayer(board)
    players = [
      opponent,
      %Players{
        card: p.card,
        tokens: token
      }
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
      player.tokens == [[],[]] -> first_move(board) 
      win?(board, player) -> 
        m = possible_moves(board, player)
        move(board, player, winning_move(board, m))
      true -> r = player
        move(board, r, possible_moves(board, r))
    end
  end

  def pick_constrained(board, player) do
    p = Enum.at(player.tokens, 0)
    move(board, p, possible_constrained(board, p))
  end
  
  def pick_build(board, player) do
    builds = possible_builds(board, List.to_tuple(Enum.at(player.tokens, 0)))
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

  def myplayer(board) do
    p = board.players |>Enum.at(0)
    if p.tokens == nil do
      %Players{
        card: p.card,
        tokens: [[],[]]
      }
    else
      p
    end
  end

  # spaces: current spaces on the board
  # {x, y}: current position of guy for whom we are enumerating spaces
  def possible_moves(board, {x, y}) do
    # my level
    level = get_level(board.spaces, {x, y})
    d = delta({x, y})
    p1 = myplayer(board)
    opponent = board.players|>Enum.at(1)
    players = Enum.flat_map([p1.tokens, opponent.tokens], fn x -> x end)

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

  def possible_constrained(board, {x, y}) do
    # my level
    level = get_level(board.spaces, {x, y})
    d = delta({x, y})
    p1 = myplayer(board)
    opponent = board.players|>Enum.at(1)
    players = Enum.flat_map([p1.tokens, opponent.tokens], fn x -> x end)

    # check levels are not higher than one above -- will also remove out of bounds squares, because their level is nil
    moves = Enum.reject(d, fn [i, j] -> get_level(board.spaces, {i, j}) > level end)
    # remove spaces another player is already on
    moves = moves -- players
    moves
  end
  
  def possible_builds(board, {x, y}) do
    d = delta({x, y})
    p1 = myplayer(board)
    opponent = board.players|>Enum.at(1)
    players = Enum.flat_map([p1.tokens, opponent.tokens], fn x -> x end)
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
