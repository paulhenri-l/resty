defmodule Fakes.TestDB do
  use Agent

  alias Fakes.Post

  @initialDB %{
    Post => %{
      :last_insterted_id => 1,
      1 => Post.build(id: 1, name: "test")
    }
  }

  def start_link() do
    Agent.start_link(fn -> @initialDB end, name: __MODULE__)
  end

  def get(resource_module, id) do
    case Agent.get(__MODULE__, &get_in(&1, [resource_module, id])) do
      nil -> raise "#{resource_module} #{id} not found"
      result -> result
    end
  end

  def put(resource_module, resource) do
    next_id = get_next_id(resource_module)
    resource = %{resource | id: next_id}

    Agent.update(__MODULE__, &put_in(&1, [resource_module, next_id], resource))

    resource
  end

  def update(resource_module, resource) do
    Agent.update(__MODULE__, &put_in(&1, [resource_module, resource.id], resource))
    resource
  end

  def get_next_id(resource_module) do
    next_id =
      Agent.get_and_update(__MODULE__, fn state ->
        next_id =
          get_in(state, [resource_module, :last_insterted_id])
          |> Kernel.+(1)

        new_state = put_in(state, [resource_module, :last_insterted_id], next_id)

        {next_id, new_state}
      end)

    case next_id do
      nil -> raise "#{resource_module} not found"
      next_id -> next_id
    end
  end
end
