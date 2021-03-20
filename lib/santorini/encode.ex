defmodule Board do
  @derive [Poison.Encoder]
  defstruct [:players, :spaces, :turn]
end

defmodule Santorini.ReadWr do
  @moduledoc false

  def read_io() do
    IO.read(:stdio, :all)

    # IO.inspect returns to stdout, this is for debugging purposes only
    # |> String.split(" ")
    # |> IO.inspect
  end 
  
  def input() do
    arr = read_io()

    case Poison.decode(arr, as: %Board{}) do
      {:ok, body} -> body
      {:error, reason, _} -> IO.puts(reason)
    end
  end

  def input(str) do
    case Poison.decode(str, as: %Board{}) do
      {:ok, body} -> body
      {:error, reason, _} -> IO.puts(reason)
    end
  end

  def output(players, spaces, turn) do
    Poison.encode!(%{"players" => players, "spaces" => spaces, "turn" => turn})
  end

  def players(board) do
    board.players
  end

  def spaces(board) do
    board.spaces
  end

  def turn(board) do
    board.turn
  end
end
