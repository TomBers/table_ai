defmodule TableAi.NlpExtract.EnumDetector do
  @moduledoc """
  Detects likely enumerations from tabular data by analyzing column values.
  """

  @type row :: [String.t()]
  @type data :: [row()]
  @type opts :: [
          sample_size: pos_integer(),
          threshold: pos_integer(),
          split_pattern: String.t(),
          case_sensitive: boolean()
        ]

  @doc """
  Detects likely enumerations in the data based on the number of unique values.

  Options:
    * `:sample_size` - Number of rows to sample (default: 100)
    * `:threshold` - Maximum number of unique values to consider as enum (default: 10)
    * `:split_pattern` - Pattern to split multiple values (default: ",")
    * `:case_sensitive` - Whether to treat values as case sensitive (default: true)

  Returns `{:ok, map}` where map contains headers and their enum values,
  or `{:error, reason}` if the data is invalid.
  """
  @spec detect_likely_enums(data(), opts()) ::
          {:ok, %{String.t() => [String.t()]}} | {:error, String.t()}
  def detect_likely_enums(data, opts \\ []) do
    case validate_data(data) do
      {:error, reason} -> {:error, reason}
      {:ok, [headers | rows]} -> {:ok, process_data(headers, rows, opts)}
    end
  end

  @spec validate_data(data()) :: {:ok, data()} | {:error, String.t()}
  defp validate_data([]) do
    {:error, "Empty data"}
  end

  defp validate_data([[] | _]) do
    {:error, "No headers found"}
  end

  defp validate_data(data) do
    {:ok, data}
  end

  @spec process_data([String.t()], [row()], opts()) :: %{String.t() => [String.t()]}
  defp process_data(headers, rows, opts) do
    sample_size = Keyword.get(opts, :sample_size, 100)
    threshold = Keyword.get(opts, :threshold, 10)
    split_pattern = Keyword.get(opts, :split_pattern, ",")
    case_sensitive = Keyword.get(opts, :case_sensitive, true)

    sample_rows = Enum.take(rows, sample_size)

    headers
    |> Enum.with_index()
    |> Enum.map(fn {header, index} ->
      values =
        sample_rows
        |> Enum.map(&Enum.at(&1, index))
        |> Enum.reject(&(is_nil(&1) or &1 == ""))
        |> process_values(split_pattern, case_sensitive)

      {header, values}
    end)
    |> Enum.reject(fn {_, enum_vals} -> MapSet.size(enum_vals) > threshold end)
    |> Map.new(fn {header, enum_vals} -> {header, MapSet.to_list(enum_vals)} end)
  end

  @spec process_values([String.t()], String.t(), boolean()) :: MapSet.t()
  defp process_values(values, split_pattern, case_sensitive) do
    values
    |> Enum.flat_map(fn value ->
      value = if case_sensitive, do: value, else: String.downcase(value)

      if String.contains?(value, split_pattern) do
        value
        |> String.split(split_pattern, trim: true)
        |> Enum.map(&String.trim/1)
      else
        [value]
      end
    end)
    |> MapSet.new()
  end
end
