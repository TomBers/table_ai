defmodule TableAi.Occurence.Counts do
  alias TableAi.LlmInterface
  # Example questions -  calculate the amount of states that have R in them
  # How many r in the word Orange?
  def example_questions do
    [
      "How many r in the word Orange?",
      "How many US states have the letter R in them?",
      "How many capital cities have a P in their name?"
    ]
  end

  def get_steps(prompt) do
    # TODO - Check max token parameter in the request
    {:ok, steps} = LlmInterface.get(prompt, system_instruction())
    steps
    # steps = [%{"data" => "Orange", "method" => "occurence_count", "search_term" => "r"}]

    # steps = [
    #   %{
    #     "search_list" => [
    #       "Alabama",
    #       "Alaska",
    #       "Arizona",
    #       "Arkansas",
    #       "California",
    #       "Colorado",
    #       "Connecticut",
    #       "Delaware",
    #       "Florida",
    #       "Georgia",
    #       "Hawaii",
    #       "Idaho",
    #       "Illinois",
    #       "Indiana",
    #       "Iowa",
    #       "Kansas",
    #       "Kentucky",
    #       "Louisiana",
    #       "Maine",
    #       "Maryland",
    #       "Massachusetts",
    #       "Michigan",
    #       "Minnesota",
    #       "Mississippi",
    #       "Missouri",
    #       "Montana",
    #       "Nebraska",
    #       "Nevada",
    #       "New Hampshire",
    #       "New Jersey",
    #       "New Mexico",
    #       "New York",
    #       "North Carolina",
    #       "North Dakota",
    #       "Ohio",
    #       "Oklahoma",
    #       "Oregon",
    #       "Pennsylvania",
    #       "Rhode Island",
    #       "South Carolina",
    #       "South Dakota",
    #       "Tennessee",
    #       "Texas",
    #       "Utah",
    #       "Vermont",
    #       "Virginia",
    #       "Washington",
    #       "West Virginia",
    #       "Wisconsin",
    #       "Wyoming"
    #     ],
    #     "method" => "group_count",
    #     "search_term" => "R"
    #   }
    # ]
  end

  def agent_reply(prompt) do
    steps = get_steps(prompt)
    dat = hd(steps)

    case dat do
      %{"method" => "occurence_count"} ->
        occurence_count(dat["search_string"], dat["search_term"])

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
    You are a skilled senior data analyst. The user will ask a question. If their question explicitly requires counting occurrences of a substring within a piece of data, or filtering a list of data by items containing a substring, then you should return a JSON array specifying the operations to be performed. Otherwise, provide a normal, direct answer to their question.

    There are 2 available operations that can be performed on the data, but you should only use them if necessary to answer the user's request. If the user asks about occurrence counting or grouping based on a search term, return a JSON array describing which operations to perform and the parameters to use. If the question is unrelated to these tasks, simply answer without returning the JSON array.

    The available operations are:

    1. **group_count(data, search_term):**
       - **Description:** Given a list of data, returns only the items that contain the `search_term`.
       - **Parameters:**
         - `search_list` (array of strings): The list of values to search by. If the user requests data not explicitly provided, reasonably assume or generate a comprehensive list.
         - `search_term` (string): The term the user wants to find in the data.

    2. **occurence_count(data, search_term):**
       - **Description:** Returns the number of times the `search_term` appears in the `search_string`.
       - **Parameters:**
         - `search_string` (string): The data the user asked about.
         - `search_term` (string): The term the user wants to count occurrences of.

    When the user asks a question that requires one of the above operations, return a JSON array in the following format:

    ```json
    [
      {
        "method": "occurence_count",
        "search_string": "Orange",
        "search_term": "r"
      },
      {
        "method": "group_count",
        "search_list": ["Orange", "Banana", "Apple"],
        "search_term": "a"
      }
    ]```
    If the user’s query does not require these operations, respond normally as an expert data analyst without returning any JSON array.
    """
  end
end
