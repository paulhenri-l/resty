defmodule Resty.Resource.Base do
  alias Resty.Associations

  @moduledoc """
  This module is used to create **resource struct** that you'll then be able to
  use with `Resty.Repo` and `Resty.Resource`.

  ## Using the module

  `Resty.Resource.Base` is here to help you create resource structs. The
  resource struct and its module holds informations about how to query the API
  such as the *site*, *headers*, *path*, *auth* etc...

  This module (`Resty.Resource.Base`) defines a lot of macros to configure
  these options. You'll be able to call them right after calling
  `use Resty.Resource.Base`.

  ```
  defmodule MyResource do
    use Resty.Resource.Base

    set_site "site.tld"
    set_resource_path "/posts"

    define_attributes [:name]
  end
  ```

  ### Primary key

  By default resty resources have a primary key attriubute that defaults to
  `:id`. If you want to use another field as the primary key you can set it
  thanks to the `set_primary_key/1` macro.

  ### Attributes

  Unlike *ActiveResource* Resty will need you to define which attributes
  should be allowed on the resource.

  They are defined thanks to the `define_attributes/1` macro. The attributes does not
  support type casting, types are taken as they come from the configured
  `Resty.Serializer`.

  ## Using the resource

  Once you have a resource you can use it with `Resty.Repo` and `Resty.Resource`
  in order to query the API or get informations about retrieved resources.

  ```
  MyResource |> Resty.Repo.all!()
  ```
  """

  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__)
      @before_compile unquote(__MODULE__)

      @default_headers Resty.default_headers()

      Module.register_attribute(__MODULE__, :attributes, accumulate: true)
      Module.register_attribute(__MODULE__, :headers, accumulate: true)
      Module.register_attribute(__MODULE__, :associations, accumulate: true)
      Module.register_attribute(__MODULE__, :association_attributes, accumulate: true)
      Module.register_attribute(__MODULE__, :known_association_attributes, accumulate: true)
      Module.put_attribute(__MODULE__, :site, Resty.default_site())
      Module.put_attribute(__MODULE__, :resource_path, "")
      Module.put_attribute(__MODULE__, :primary_key, :id)
      Module.put_attribute(__MODULE__, :include_root, false)
      Module.put_attribute(__MODULE__, :extension, "")
      Module.put_attribute(__MODULE__, :connection, Resty.default_connection())
      Module.put_attribute(__MODULE__, :connection_params, [])
      Module.put_attribute(__MODULE__, :auth, Resty.default_auth())
      Module.put_attribute(__MODULE__, :auth_params, [])
      Module.put_attribute(__MODULE__, :serializer, Resty.default_serializer())
      Module.put_attribute(__MODULE__, :serializer_params, [])
    end
  end

  @doc """
  Define the given attributes on the resource struct.
  """
  defmacro define_attributes(attributes) when is_list(attributes) do
    quote do
      for new_attribute <- unquote(attributes) do
        Module.put_attribute(__MODULE__, :attributes, new_attribute)
      end
    end
  end

  @doc """
  Set the `Resty.Connection` implementation that should be used to query this
  resource.
  """
  defmacro set_connection(connection, params \\ []) do
    quote do
      @connection unquote(connection)
      @connection_params unquote(params)
    end
  end

  @doc """
  Set the `Resty.Serializer` implementation that should be used to serialize
  and deserialize this resource.
  """
  defmacro set_serializer(serializer, params \\ []) do
    quote do
      @serializer unquote(serializer)
      @serializer_params unquote(params)
    end
  end

  @doc """
  Add a site to the resource
  """
  defmacro set_site(site) do
    quote(do: @site(unquote(site)))
  end

  @doc """
  Add a path to the resource
  """
  defmacro set_resource_path(path) do
    quote(do: @resource_path(unquote(path)))
  end

  @doc """
  Sets the resource primary key. By default it is `:id`.
  """
  defmacro set_primary_key(name) do
    quote(do: @primary_key(unquote(name)))
  end

  @doc """
  Sets the resource extension. The extension will be added in the URL.
  """
  defmacro set_extension(extension) do
    quote(do: @extension(unquote(extension)))
  end

  @doc """
  Set the `Resty.Auth` implementation that should be used to query this resource.
  """
  defmacro with_auth(auth, params \\ []) do
    quote do
      @auth unquote(auth)
      @auth_params unquote(params)
    end
  end

  @doc """
  Include the given root when serializing the resource
  """
  defmacro include_root(value) do
    quote(do: @include_root(unquote(value)))
  end

  @doc """
  Add an header to the request sent from this resource
  """
  defmacro add_header(name, value) when is_atom(name) do
    quote(do: @headers({unquote(name), unquote(value)}))
  end

  @doc """
  This will replace the default headers (`Resty.default_headers/0`) used by
  this resource.
  """
  defmacro set_headers(new_headers) do
    quote(do: @default_headers(unquote(new_headers)))
  end

  @doc """
  Declare a new belongs_to association.

  ## Arguments

  - `resource`: The resource module to which this association should resolve
  - `attribute_name`: Under which key should the resolved association be set?
  - `foreign_key`: What is the foreign_key of the association (in this resource)?
  - `eager_load`: Should this association be eagerly loaded? this parameter
  is useful in order to break circular dependencies or if you plan on using
  collection functions such as `Resty.Repo.all/1`.

  ## Usage

  ```elixir
  defmodule User do
    use Resty.Resource.Base

    set_site "https://jsonplaceholder.typicode.com"
    set_resource_path "/users"
    define_attributes [:name, :email]
  end

  defmodule Post do
    use Resty.Resource.Base

    set_site "https://jsonplaceholder.typicode.com"
    set_resource_path "/posts"
    define_attributes [:title, :body, :userId]

    belongs_to User, :user, :userId
  end

  {:ok, post} = Post |> Resty.Repo.find(1)

  IO.inspect(post.user) # %User{id: 1, email: "Sincere@april.biz", name: "Leanne Graham"}
  ```

  ## When is the association loaded?

  The belongs to association is automatically loaded when the resource is
  fetched from the server.

  Beware! This is highly **ineficient** if you are using the `Resty.Repo.all/1`
  function (or any other function that relies on it).
  """
  defmacro belongs_to(resource, attribute_name, foreign_key, eager_load \\ true) do
    quote do
      @attributes unquote(foreign_key)
      @association_attributes {unquote(attribute_name), %Associations.NotLoaded{}}
      @associations %Associations.BelongsTo{
        eager_load: unquote(eager_load),
        related: unquote(resource),
        attribute: unquote(attribute_name),
        foreign_key: unquote(foreign_key)
      }
    end
  end

  @doc """
  Declare a new has_one association.

  ## Arguments

  - `resource`: The resource module to which this association should resolve
  - `attribute_name`: Under which key should the resolved association be set?
  - `foreign_key`: What is the foreign_key of the association (on the other resource)?
    it should be `:author_id` if the resource url is (/authors/:author_id/address)
  - `eager_load`: Should this association be eagerly loaded? this parameter
  is useful in order to break circular dependencies or if you plan on using
  collection functions such as `Resty.Repo.all/1`.

  ## Usage

  ```elixir
  defmodule Company do
    use Resty.Resource.Base

    set_site "https://jsonplaceholder.typicode.com"
    set_resource_path "/users/:user_id/company"
    define_attributes [:name]
  end

  defmodule User do
    use Resty.Resource.Base

    set_site "https://jsonplaceholder.typicode.com"
    set_resource_path "/users"
    define_attributes [:name, :email]

    has_one Company, :company, :userId
  end

  {:ok, user} = User |> Resty.Repo.find(1)

  IO.inspect(user.company.name) # Romaguera-Crona
  ```

  ## When is the association loaded?

  The has_one association is automatically loaded when the resource is
  fetched from the server.

  Beware! This is highly **ineficient** if you are using the `Resty.Repo.all/1`
  function (or any other function that relies on it).
  """
  defmacro has_one(resource, attribute_name, foreign_key, eager_load \\ true) do
    quote do
      @known_association_attributes unquote(attribute_name)
      @association_attributes {unquote(attribute_name), %Associations.NotLoaded{}}
      @associations %Associations.HasOne{
        eager_load: unquote(eager_load),
        related: unquote(resource),
        attribute: unquote(attribute_name),
        foreign_key: unquote(foreign_key)
      }
    end
  end

  @doc """
  Declare a new has_many association.

  ## Arguments

  - `resource`: The resource module to which this association should resolve
  - `attribute_name`: Under which key should the resolved association be set?
  - `foreign_key`: What is the foreign_key of the association (on the other resource)?
    it should be `:post_id` if the resource url is (/posts/:post_id/comments)
  - `eager_load`: Should this association be eagerly loaded? this parameter
  is useful in order to break circular dependencies or if you plan on using
  collection functions such as `Resty.Repo.all/1`.

  ## Usage

  ```elixir
  defmodule Comment do
    use Resty.Resource.Base

    set_site "https://jsonplaceholder.typicode.com"
    set_resource_path "/posts/:post_id/comments"
    define_attributes [:postId, :body]
  end

  defmodule Post do
    use Resty.Resource.Base

    set_site "https://jsonplaceholder.typicode.com"
    set_resource_path "/posts"
    define_attributes [:title, :body]

    has_many Comment, :comments, :postId
  end

  {:ok, post} = Post |> Resty.Repo.find(1)

  IO.inspect(user.post.comments) # [%Comment{name: "id labore ex et quam laborum""} | _]
  ```

  ## When is the association loaded?

  The has_many association is automatically loaded when the resource is
  fetched from the server.

  Beware! This is highly **ineficient** if you are using the `Resty.Repo.all/1`
  function (or any other function that relies on it).
  """
  defmacro has_many(resource, attribute_name, foreign_key, eager_load \\ true) do
    quote do
      @known_association_attributes unquote(attribute_name)
      @association_attributes {unquote(attribute_name), %Associations.NotLoaded{}}
      @associations %Associations.HasMany{
        eager_load: unquote(eager_load),
        related: unquote(resource),
        attribute: unquote(attribute_name),
        foreign_key: unquote(foreign_key)
      }
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      @raw_attributes [@primary_key] ++ @attributes

      @known_attributes @raw_attributes ++ @known_association_attributes

      defstruct @raw_attributes ++ @association_attributes ++ [__persisted__: false]

      @doc false
      def site, do: @site

      @doc false
      def primary_key, do: @primary_key

      @doc false
      def resource_path, do: @resource_path

      @doc false
      def raw_attributes, do: @raw_attributes

      @doc false
      def known_attributes, do: @known_attributes

      @doc false
      def serializer, do: {@serializer, @serializer_params}

      @doc false
      def include_root, do: @include_root

      @doc false
      def extension, do: @extension

      @doc false
      def headers, do: Keyword.merge(@default_headers, @headers)

      @doc false
      def connection, do: {@connection, @connection_params}

      @doc false
      def auth, do: {@auth, @auth_params}

      @doc false
      def associations, do: @associations

      @doc """
      Create a new resource with the given attributes.
      """
      def build(attributes \\ []) do
        Resty.Resource.Builder.build(__MODULE__, attributes)
      end
    end
  end
end
