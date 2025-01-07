defmodule TableAi.Structs.NLPQuery do
  defstruct df: nil,
            headers: [],
            steps: [],
            errors: [],
            file_path: nil,
            user_query: nil,
            file_name: nil

  def reset_query(query, user_query) do
    %TableAi.Structs.NLPQuery{
      file_path: query.file_path,
      file_name: query.file_name,
      user_query: user_query
    }
  end

  # def add_error(query, errors) do
  #   %{query | errors: errors}
  # end
end
