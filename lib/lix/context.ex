defmodule Lix.Context do
  @state Process

  def make_handle() do
    handle_id = @state.get(:__handle_id_counter, 0) + 1
    @state.put(:__handle_id_counter, handle_id)
    handle_id
  end

  def set(handle_id, value) do
    @state.put(handle_id, value)
  end

  def get(handle_id) do
    @state.get(handle_id)
  end

  def update(handle_id, updater) do
    new_value =
      handle_id
      |> @state.get()
      |> updater.()

    @state.put(handle_id, new_value)
    new_value
  end

  def subscribe(from_handle_id, from_tag, listener) do
    # Output tag should exit
    true = from_tag in get(from_handle_id).module.out_tags()

    case listener do
      {target_handler_id, function_name} when is_integer(target_handler_id) ->
        handler = __MODULE__.get(target_handler_id)

        # Handler function should exist, and take the handle and value as arguments.
        true = {function_name, 2} in handler.module.__info__(:functions)

      _ ->
        nil
    end

    key = {:listeners, from_handle_id, from_tag}
    listeners = @state.get(key, %{})

    # Add listeners backwards in order to handle broadcasts in connection-order
    listeners =
      Map.update(listeners, from_tag, [listener], &(&1 ++ [listener]))

    @state.put(key, listeners)
  end

  def broadcast(from_handle_id, tag, value) do
    key = {:listeners, from_handle_id, tag}

    if tag_listeners = @state.get(key) do
      for listener <- Map.get(tag_listeners, tag, []) do
        case listener do
          {target_handler_id, function_name} when is_integer(target_handler_id) ->
            handler = __MODULE__.get(target_handler_id)
            false = is_nil(handler)
            apply(handler.module, function_name, [target_handler_id, value])

          function ->
            function.(value)
        end
      end
    end
  end
end
