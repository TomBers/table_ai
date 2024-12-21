defmodule TableAi.Structs.NLPQuery do
  defstruct df: nil,
            headers: [],
            steps: [],
            errors: [],
            file_path: nil,
            user_query: nil,
            file_name: nil

  # def add_error(query, errors) do
  #   %{query | errors: errors}
  # end
end
