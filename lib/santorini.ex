defmodule Santorini do
  alias Santorini.ReadWr, as: Json
  
  @moduledoc """
  Documentation for `Santorini`.
  """

  @doc """
  Santorini player.
  """

  def main(_args \\ []) do
    # This is just me trying to debug with some persistent files, don't mind me
    # TODO: save state in a file just in case program crash? idk

  #  {:ok, file} = File.open "/home/mei/Documents/School/CS 6963/santorini/sample.json", [:utf8, :write]
  #  try do
  #    IO.write file, Encode.read_io()
  #  after
  #    File.close(file)
  #  end

    board = Json.input()
    turns = Json.turn(board)
    IO.puts(turns)
  end
end
