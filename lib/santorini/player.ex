defmodule Santorini.Player do
  @moduledoc false
  alias Santorini.ReadWr, as: Json

  # takes a board struct, the space of the current worker, and a new place to move to
  def move(board, cur, new) do
    try do
      play1 = Enum.fetch!(Json.players(board), 0)
      play2 = Enum.fetch!(Json.players(board), 1)
    rescue
      Enum.OutOfBoundsError -> "For some reason, there aren't two players on the board!"
    end

    play1 = Enum.map(play1, fn 
      coord when coord == cur -> new
      coord -> coord
    end)

    play2 = Enum.map(play2, fn 
      coord when coord == cur -> new
      coord -> coord
    end)

    players = [play1, play2]

    %Board{
      players: players,
      spaces: board.spaces,
      turn: board.turn
    }
  end

  # If there is no first player, make the first move
  def player1(board) do
    try do
      Enum.fetch!(Json.players(board), 0)
    rescue
      co1 = Enum.random(1..5)
      co2 = Enum.random(1..5)
      co3 = Enum.random(bound(co1-2)..bound(co1+2))
      co4 = Enum.random(bound(co2-2)..bound(co2+2))
      [[co1,co2],[co3,co4]]
    end
  end

  # set bounds for moves between 0-5 for the board size
  def bound(n) do
    case n do
      x < 1 -> 1
      x > 5 -> 5
      _ -> n
    end
  end

  def player2(board) do
    try do
      play1 = Enum.fetch!(Json.players(board), 0)
      Enum.fetch!(Json.players(board), 1)
    rescue
      if !play1 do
        [[]]
      end
    end
  end

  def first_move(board) do

  end

  def possible_moves(spaces, {x, y}) do
    level = get_level(spaces, {x, y})

  end

  def possible_moves([], {x, y}) do

  end

  def get_level(spaces, {x, y}) do
    Enum.at(spaces, x)
    |>Enum.at(y)
  end
end
