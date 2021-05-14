defmodule Board do
  @derive [Poison.Encoder]
  defstruct [:players, :spaces, :turn]
end

defmodule Players do
  @derive [Poison.Encoder]
  defstruct [:card, :tokens]
end

defmodule Preplayer do
  @derive [Poison.Encoder]
  defstruct [:card]
end

defmodule Santorini.ReadWr do
  @moduledoc false

  def read_io() do
    #IO.inspect returns to stdout, this is for debugging purposes only
    IO.read(:stdio, :line)
    #|> IO.inspect
  end 
  
  def input() do
    arr = read_io()
    if arr === :eof do
      exit(:normal)
    end

    cond do
      String.length(arr) <= 46 ->
        case Poison.decode(arr, as: [%Preplayer{}]) do
          {:ok, body} -> p = body
            %Board{
              players: [
                %Players{
                  card: Enum.at(p, 0),
                  tokens: nil
                },
                %Players{
                  card: Enum.at(p, 1),
                  tokens: nil
                } 
              ],
              spaces: [
                [0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0]
              ],
              turn: -1
            }
          {:error, reason, _} -> IO.puts(reason)
        end
      String.length(arr) > 46 and String.first(arr) == "[" ->
        case Poison.decode(arr) do
          {:ok, body} -> p = body
            %Board{
              players: [
                %Players{
                  card: Enum.at(p, 0)["card"],
                  tokens: nil
                },
                %Players{
                  card: Enum.at(p, 1)["card"],
                  tokens: Enum.at(p, 1)["tokens"]
                } 
              ],
              spaces: [
                [0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0]
              ],
              turn: -1
            }
          {:error, reason, _} -> IO.puts(reason)
        end
      true -> 
        case Poison.decode(arr, as: %Board{players: [%Players{}]}) do
          {:ok, body} -> body
          {:error, reason, _} -> IO.puts(reason)
        end
    end
  end

  def input(str) do
    cond do
      String.length(str) <= 46 ->
        case Poison.decode(str, as: [%Preplayer{}]) do
          {:ok, body} -> p = body
            %Board{
              players: [
                %Players{
                  card: Enum.at(p, 0),
                  tokens: nil
                },
                %Players{
                  card: Enum.at(p, 1),
                  tokens: nil
                } 
              ],
              spaces: [
                [0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0]
              ],
              turn: -1
            }
          {:error, reason, _} -> IO.puts(reason)
        end
      String.length(str) > 46 and String.first(str) == "[" ->
        case Poison.decode(str) do
          {:ok, body} -> p = body
            %Board{
              players: [
                %Players{
                  card: Enum.at(p, 0)["card"],
                  tokens: nil
                },
                %Players{
                  card: Enum.at(p, 1)["card"],
                  tokens: Enum.at(p, 1)["tokens"]
                } 
              ],
              spaces: [
                [0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0]
              ],
              turn: -1
            }
          {:error, reason, _} -> IO.puts(reason)
        end
      true -> 
        case Poison.decode(str, as: %Board{players: [%Players{}]}) do
          {:ok, body} -> body
          {:error, reason, _} -> IO.puts(reason)
        end
    end
  end

  def output(players, spaces, turn) do
    Poison.encode!(%{"players" => players, "spaces" => spaces, "turn" => turn})
  end

  def output(players) do 
    Poison.encode!(players)
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
