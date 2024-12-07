defmodule TableAiWeb.OccuranceLive do
  use TableAiWeb, :live_view
  import TableAiWeb.CoreComponents
  alias TableAi.Occurence.Counts

  @impl true
  def mount(_params, _session, socket) do
    # Initialize the message list and set an empty input value
    socket = assign(socket, messages: [], current_input: "")
    {:ok, socket}
  end

  @impl true
  def handle_event("update_input", %{"message" => message}, socket) do
    # This event updates the current input as the user types
    {:noreply, assign(socket, :current_input, message)}
  end

  @impl true
  def handle_event("send_message", %{"message" => message}, socket) do
    # Basic validation: ensure message is not empty.
    message = String.trim(message)

    if message == "" do
      # If empty, do nothing or show an error if desired
      {:noreply, socket}
    else
      # Append user's message to the list
      updated_messages = socket.assigns.messages ++ [{message, :user}]

      # Optionally, simulate an agent reply
      reply = Counts.agent_reply(message)
      # IO.inspect(reply, label: "Reply")
      updated_messages = updated_messages ++ [{reply, :agent}]

      # Reset current_input so the textbox clears
      {:noreply, assign(socket, messages: updated_messages, current_input: "")}
    end
  end
end
