defmodule Fakes.TestDB do
  use Agent

  alias Fakes.Post

  @initialDB %{
    Post => %{
      :last_insterted_id => 1,
      1 => ~s({"id": 1, "name": "test"})
    }
  }

  @doc "Start the fake db"
  def start_link() do
    Agent.start_link(fn -> @initialDB end, name: __MODULE__)
  end

  @doc "Get json fron the db"
  def get(resource_module, id) do
    Agent.get(__MODULE__, &get_in(&1, [resource_module, id]))
  end

  @doc "Insert json in the db"
  def insert(resource_module, json) when is_binary(json) do
    next_id = get_next_id(resource_module)

    json =
      json
      |> Poison.decode!()
      |> Map.put("id", next_id)
      |> Poison.encode!()

    Agent.update(__MODULE__, &put_in(&1, [resource_module, next_id], json))

    json
  end

  @doc "Replace the json for an existing entry in db"
  def put(resource_module, json) do
    id = Poison.decode!(json) |> Map.get("id")

    Agent.update(__MODULE__, &put_in(&1, [resource_module, id], json))

    json
  end

  @doc "Delete the given resource's json"
  def delete(resource_module, id) do
    Agent.update(__MODULE__, fn state ->
      resources =
        state
        |> Map.get(resource_module)
        |> Map.delete(id)

      Map.put(state, resource_module, resources)
    end)
  end

  defp get_next_id(resource_module) do
    Agent.get_and_update(__MODULE__, fn state ->
      next_id =
        get_in(state, [resource_module, :last_insterted_id])
        |> Kernel.+(1)

      new_state = put_in(state, [resource_module, :last_insterted_id], next_id)

      {next_id, new_state}
    end)
  end
end
