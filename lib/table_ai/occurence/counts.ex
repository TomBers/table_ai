defmodule TableAi.Occurence.Counts do
  alias TableAi.LlmInterface
  # Example questions -  calculate the amount of states that have R in them
  # How many r in the word Orange?
  def agent_reply(prompt) do
    # {:ok, steps} = LlmInterface.get(prompt, system_instruction())
    # steps = [%{"data" => "Orange", "method" => "occurence_count", "search_term" => "r"}]
    steps = [
      %{
        "method" => "group_count",
        "search_list" => [
          "Alabama",
          "Alaska",
          "Arizona",
          "Arkansas",
          "California",
          "Colorado",
          "Connecticut",
          "Delaware",
          "Florida",
          "Georgia",
          "Hawaii",
          "Idaho",
          "Illinois",
          "Indiana",
          "Iowa",
          "Kansas",
          "Kentucky",
          "Louisiana",
          "Maine",
          "Maryland",
          "Massachusetts",
          "Michigan",
          "Minnesota",
          "Mississippi",
          "Missouri",
          "Montana",
          "Nebraska",
          "Nevada",
          "New Hampshire",
          "New Jersey",
          "New Mexico",
          "New York",
          "North Carolina",
          "North Dakota",
          "Ohio",
          "Oklahoma",
          "Oregon",
          "Pennsylvania",
          "Rhode Island",
          "South Carolina",
          "South Dakota",
          "Tennessee",
          "Texas",
          "Utah",
          "Vermont"
        ],
        "search_term" => "R"
      }
    ]

    dat = hd(steps)

    case dat do
      %{"method" => "occurence_count"} ->
        occurence_count(dat["data"], dat["search_term"])

      %{"method" => "group_count"} ->
        group_count(dat["search_list"], dat["search_term"])

      _ ->
        steps
    end
  end

  def occurence_count(data, term) do
    # Insert logic to count the number of times the term appears in the data
    String.length(data) - String.length(String.replace(data, term, ""))
  end

  def group_count(data, term) do
    # Insert logic to return only the items that contain the term
    items =
      Enum.filter(data, fn x -> String.contains?(String.downcase(x), String.downcase(term)) end)

    count = Enum.count(items)

    ans = items |> Enum.join(", ")
    ans <> " (#{count})"
  end

  defp system_instruction do
    """
    You are a skilled senior data analyst. Given the user's question below, return a JSON array that specifies a list of operations to be performed on the data.
    There are 2 available operations that can be performed on the data. Unless the data is explicity stated, assume the data is a list you must create from your own knowledge.

    The available operations are:

    1. **group_count(data, search_term):**
      - **Description:** Given a list of data, returns only the items that contain the `search_term`.
      - **Parameters:**
        - `search_list` (array of strings): The list of values to search by, where possible please fill this list as completely as possible.
        - 'search_term' (string): the term the user wants to count occurences of.

    2. **occurence_count(data, search_term):**
       - **Description:** Returns the number of times the `search_term` appears in the data.
       - **Parameters:**
         - `data` (string): The data the user asked about.
         - `search_term` (string): the term the user wants to count occurences of.

    Please return a JSON array in the following format:

    ```json
    [
      {
        "method": "occurence_count",
        "data": "Orange",
        "search_term": "r"
      },
      {
        "method": "group_count",
        "data": ["Orange", "Banana", "Apple"],
        "search_term": "a"
      }
    ]```
    """
  end
end
