defmodule TableAi.OccurenceTest do
  use ExUnit.Case

  alias TableAi.Occurence.Counts

  test "occurence_count" do
    data = "Orangee"
    term = "r"
    assert Counts.occurence_count(data, term) == 1
    assert Counts.occurence_count(data, "e") == 2
  end

  test "group_count" do
    data = ["Orange", "Banana", "Apple"]
    term = "n"
    assert Counts.group_count(data, term) == "Orange, Banana (2)"
  end
end
