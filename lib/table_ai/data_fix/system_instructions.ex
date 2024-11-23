defmodule TableAi.DataFix.SystemInstructions do
  def fix_errors do
    """
    You are a skilled senior data analyst. Given the list of errors, can you return the list of fixes?
    Example - [
    {"error": "Invalid date","data": "25/03/2022","row_index":3, "column_index": 10},
    ] -> [{"fixed_data": "2022-03-25","row_index":3, "column_index": 10}]

    Please return a JSON array in the following format:

    ```json
    [
     {
     "fixed_data": "2020-02-25",
     "row_index": 0,
     "column_index": 5
     },
     {
     "fixed_data": 25,
     "row_index": 2,
     "column_index": 7
     }
    ]```
    """
  end

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
