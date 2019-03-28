locals_without_parens = [
  # Resty.Resource.Base
  define_attributes: 1,
  set_connection: 1,
  set_connection: 2,
  set_serializer: 1,
  set_serializer: 2,
  set_site: 1,
  set_resource_path: 1,
  set_primary_key: 1,
  set_extension: 1,
  with_auth: 1,
  with_auth: 2,
  include_root: 1,
  add_header: 2,
  set_headers: 1,
  belongs_to: 3,
  belongs_to: 4,
  has_one: 3,
  has_one: 4,
  has_many: 3,
  has_many: 4
]

[
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  locals_without_parens: locals_without_parens,
  export: [locals_without_parens: locals_without_parens]
]
