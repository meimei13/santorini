defmodule SantoriniTest do
  use ExUnit.Case
  doctest Santorini
  alias Santorini.ReadWr, as: Json
  alias Santorini.Player, as: Play

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

  describe "constraints on moves:" do
    test "enumerate all possible moves for [2, 3]" do
      # possible moves for the given board for the player [2, 3]
      moves = [
        [1, 2],
        [1, 3],
        [1, 4],
        [2, 2],
        [2, 4],
        [3, 2],
        [3, 3],
        [3, 4],
      ]
      assert Play.possible_moves(correct(), {2, 3}) == moves
    end

    test "enumerate all possible moves for [2, 5] guy on the end" do
      moves = [
        [1, 4],
        [2, 4],
      ]
      assert Play.possible_moves(correct(), {2, 5}) == moves
    end

    test "enumerate all possible moves for [3, 5]" do 
      moves = [
        [2, 4],
        [4, 5]
      ]
      assert Play.possible_moves(correct(), {3, 5}) == moves
    end

    test "get correct winning move(s)" do
      mv = Play.possible_moves(correct(), {2, 3}) 
      assert Play.winning_move(correct(), mv) == [[3,4]]
    end

    test "get correct level" do
      assert Play.get_level(Json.spaces(correct()), {1, 5}) == 2    
    end
  end

  describe "player positions:" do
    test "player 1 is in correct spot" do
      assert Play.player1(correct()) == [[2,3], [4,4]]
    end
    
    test "player 2 is in correct spot" do
      assert Play.player2(correct()) == [[2,5], [3,5]]
    end

    test "moving a player moves them to correct spot" do
      c = %Board{
                players: [[[3, 4], [4, 4]], [[2, 5], [3, 5]]],
                spaces: [
                  [0, 0, 0, 0, 2],
                  [1, 1, 2, 0, 0],
                  [1, 0, 0, 3, 0],
                  [0, 0, 3, 0, 0],
                  [0, 0, 0, 1, 4]
                ],
                turn: 19
              }
      assert Play.move(correct(), {2,3}, {3,4}) == c
    end
  end
end
