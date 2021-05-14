defmodule Santorini do
  alias Santorini.ReadWr, as: Json
  alias Santorini.Apollo, as: Apollo
  alias Santorini.Artemis, as: Artemis
  alias Santorini.Atlas, as: Atlas
  alias Santorini.Demeter, as: Demeter
  alias Santorini.Hephastus, as: Hephastus
  alias Santorini.Minotaur, as: Minotaur
  alias Santorini.Pan, as: Pan
  alias Santorini.Prometheus, as: Prometheus

  @moduledoc """
  Documentation for `Santorini`.
  """

  @doc """
  Santorini player.
  """

  def main(_args \\ []) do
    board = Json.input()

    myplayer = board.players |>Enum.at(0)

    case myplayer.card do
      "Artemis" -> 
        if (board.turn == -1) do
          b = Artemis.pick_move(board, [[],[]])
          move1_output(b)
        else 
          b = Artemis.pick_move(board, myplayer)
          b = if (not Artemis.won?(b)) do
            myplayer = Artemis.myplayer(b)
            b = Artemis.pick_move(b, myplayer)
            myplayer = Artemis.myplayer(b)
            Artemis.pick_build(b, myplayer)
          else
            b
          end

          j = Json.output(b)
          IO.puts(j)
        end
      "Apollo" ->
        if (board.turn == -1) do
          b = Apollo.pick_move(board, [[],[]])
          move1_output(b)
        else 
          b = Apollo.pick_move(board, myplayer)
          b = if (not Apollo.won?(b)) do
            myplayer = Apollo.myplayer(b)
            Apollo.pick_build(b, myplayer)
          else
            b
          end

          j = Json.output(b)
          IO.puts(j)
        end
      "Atlas" ->
        if (board.turn == -1) do
          b = Atlas.pick_move(board, [[],[]])
          move1_output(b)
        else 
          b = Atlas.pick_move(board, myplayer)
          b = if (not Atlas.won?(b)) do
            myplayer = Atlas.myplayer(b)
            Atlas.pick_build(b, myplayer)
          else
            b
          end

          j = Json.output(b)
          IO.puts(j)
        end
      "Demeter" ->
        if (board.turn == -1) do
          b = Demeter.pick_move(board, [[],[]])
          move1_output(b)
        else 
          b = Demeter.pick_move(board, myplayer)
          b = if (not Demeter.won?(b)) do
            myplayer = Demeter.myplayer(b)
            {builded, bord} = Demeter.pick_build(b, myplayer)
            {_, bord} = Demeter.pick_build(bord, myplayer, builded)
            bord
          else
            b
          end

          j = Json.output(b)
          IO.puts(j)
        end
      "Hephestus" ->
        if (board.turn == -1) do
          b = Hephastus.pick_move(board, [[],[]])
          move1_output(b)
        else 
          b = Hephastus.pick_move(board, myplayer)
          b = if (not Hephastus.won?(b)) do
            myplayer = Hephastus.myplayer(b)
            {builded, bord} = Hephastus.pick_build(b, myplayer)
            {_, bord} = Hephastus.pick_build(bord, builded)
            bord
          else
            b
          end

          j = Json.output(b)
          IO.puts(j)
        end
      "Minotaur" ->
        if (board.turn == -1) do
          b = Minotaur.pick_move(board, [[],[]])
          move1_output(b)
        else 
          b = Minotaur.pick_move(board, myplayer)
          b = if (not Minotaur.won?(b)) do
            myplayer = Minotaur.myplayer(b)
            Minotaur.pick_build(b, myplayer)
          else
            b
          end

          j = Json.output(b)
          IO.puts(j)
        end
      "Pan" ->
        if (board.turn == -1) do
          b = Pan.pick_move(board, [[],[]])
          move1_output(b)
        else 
          b = Pan.pick_move(board, myplayer)
          b = if (not Pan.won?(b)) do
            myplayer = Pan.myplayer(b)
            Pan.pick_build(b, myplayer)
          else
            b
          end

          j = Json.output(b)
          IO.puts(j)
        end
      "Prometheus" ->
        if (board.turn == -1) do
          b = Prometheus.pick_move(board, [[],[]])
          move1_output(b)
        else 
          b = Prometheus.pick_build(board, myplayer)
          b = Prometheus.pick_constrained(b, myplayer)
          b = if (not Prometheus.won?(b)) do
            myplayer = Prometheus.myplayer(b)
            Prometheus.pick_build(b, myplayer)
          else
            b
          end

          j = Json.output(b)
          IO.puts(j)
        end
      _ -> IO.puts("Uh oh! Didn't get a god for some reason?")
    end 

    main()
  end

  def move1_output(board) do
    j = Json.output(board.players)
    IO.puts(j)
  end
end
