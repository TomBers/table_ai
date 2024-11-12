defmodule TableAi.DataFix.SystemInstructions do
  def fix_dates do
    """
    You are a skilled senior data analyst. Given the list of misformatted dates, can you return dates accoring to the iso8601 standard?
    Example - ["2020-02-25 - on a thursday", "2020-02-25"] -> ["2020-02-25", "2020-02-25"]


    Please return a JSON array in the following format:

    ```json
    [
     "2020-02-25",
     "2020-02-25"
    ]```
    """
  end
end
