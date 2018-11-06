defmodule Resty.Resource.Path do
  # add specs.
  def to(module) when is_atom(module) do
    "#{module.site()}/#{module.resource_path()}"
  end

  def to(%{} = resource) do
    to(resource.__module__, resource)
  end

  def to(module, %{} = resource) do
    id = Map.get(resource, module.id_column())
    to(module, id)
  end

  def to(module, id) do
    "#{to(module)}/#{id}"
  end
end
