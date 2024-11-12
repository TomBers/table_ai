defmodule TableAi.Types.FindType do
  # Sample data
  def types do
    [
      "Hello",
      "4",
      "4.5",
      "2020-02-25",
      "2024-11-12 15:46:03.097746Z"
    ]
  end

  # Check if the string represents an integer
  def is_int_type(type) do
    case Integer.parse(type) do
      {_, ""} -> true
      _ -> false
    end
  end

  # Check if the string represents a float
  def is_float_type(type) do
    case Float.parse(type) do
      {_, ""} -> true
      _ -> false
    end
  end

  # Check if the string represents a date
  def is_date_type(type) do
    case Date.from_iso8601(type) do
      {:ok, _} -> true
      _ -> false
    end
  end

  # Check if the string represents a datetime
  def is_datetime_type(type) do
    case DateTime.from_iso8601(type) do
      {:ok, _, _} -> true
      _ -> false
    end
  end

  # Classify the type of each item
  def classify_type(type) do
    cond do
      is_int_type(type) -> "Integer"
      is_float_type(type) -> "Float"
      is_date_type(type) -> "Date"
      is_datetime_type(type) -> "Datetime"
      true -> "String"
    end
  end

  # Classify all items in the list
  def classify_all_types do
    types()
    |> Enum.map(&{&1, classify_type(&1)})
  end
end
