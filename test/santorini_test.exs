defmodule SantoriniTest do
  use ExUnit.Case
  doctest Santorini
  alias Santorini.ReadWr, as: Json


  defp test_json() do
    # sigils for string
    ~s({"players":[[[2,3],[4,4]],[[2,5],[3,5]]],"spaces":[[0,0,0,0,2],[1,1,2,0,0],[1,0,0,3,0],[0,0,3,0,0],[0,0,0,1,4]],"turn":18})
  end

  defp test_json_nondeterm() do
    ~s({"turn":18,"spaces":[[0,0,0,0,2],[1,1,2,0,0],[1,0,0,3,0],[0,0,3,0,0],[0,0,0,1,4]],"players":[[[2,3],[4,4]],[[2,5],[3,5]]]})
  end

  defp correct() do
    %Board{
      players: [[[2, 3], [4, 4]], [[2, 5], [3, 5]]],
      spaces: [
        [0, 0, 0, 0, 2],
        [1, 1, 2, 0, 0],
        [1, 0, 0, 3, 0],
        [0, 0, 3, 0, 0],
        [0, 0, 0, 1, 4]
      ],
      turn: 18
    }
  end

  describe "read json" do
    test "decoded json returns correct struct" do
      assert Json.input(test_json()) == correct()
    end

    test "players value is correct" do
      assert Json.players(correct()) == [[[2, 3], [4, 4]], [[2, 5], [3, 5]]]
    end

    test "spaces value is correct" do
      assert Json.spaces(correct()) == [
        [0, 0, 0, 0, 2],
        [1, 1, 2, 0, 0],
        [1, 0, 0, 3, 0],
        [0, 0, 3, 0, 0],
        [0, 0, 0, 1, 4]
      ]
    end

    test "turn value is correct" do
      assert Json.turn(correct()) == 18
    end
  end

  describe "write json" do
    test "json with given values is correctly formatted" do
      # ordering not guaranteed, this test may fail... but using my eyes to see
      # if they're close enough...
      j = Json.output(correct().players, correct().spaces, correct().turn)
      assert j == test_json_nondeterm() || j == test_json() 
    end
  end

  describe "constraints on moves" do
    test "enumerate all possible moves" do
      # possible moves for the given board for the player [2, 3]
      moves = [
        [2, 2],
        [1, 3],
        [1, 2],
        [3, 2],
        [3, 3],
        [3, 4],
        [1, 4],
        [2, 4]
      ]
    end
  end
end
