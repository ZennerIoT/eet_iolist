# EetIolist

This library offers a single function that encodes a term into an iolist with the same protocol that 
`:erlang.term_to_binary/1` does (Erlang External Term Format), but as a flat IO list instead of a potentionally 
large binary.

This helps in processes that have a high throughput and might leak memory when generating these large binaries.

Flat IO lists (aka IO vectors) can be passed to almost all network sockets, which means they will memory-efficiently 
stream these binaries to the recipient.

Note that OTP 23 will include a function that does the same thing, this library is just needed to fill the time gap
until it is released.

Also note that PIDs, ports and refs are simply encoded as `nil`.

```elixir
iex> demo = %{foo: :atom, bar: {:ok, :tuple}, baz: ["a", "list", "of", "binaries"]}
%{bar: {:ok, :tuple}, baz: ["a", "list", "of", "binaries"], foo: :atom}
iex> encoded = EetIolist.term_to_iolist(demo)
[
  <<131>>,
  <<116, 0, 0, 0, 3>>,
  <<119, 3>>,
  "bar",
  <<104, 2>>,
  <<119, 2>>,
  "ok",
  <<119, 5>>,
  "tuple",
  <<119, 3>>,
  "baz", 
  <<108, 0, 0, 0, 4>>,
  <<109, 0, 0, 0, 1>>,
  "a",
  <<109, 0, 0, 0, 4>>,
  "list",
  <<109, 0, 0, 0, 2>>,
  "of",
  <<109, 0, 0, 0, 8>>,
  "binaries",
  "j",
  <<119, 3>>, 
  "foo",
  <<119, 4>>,
  "atom"
]
iex> encoded |> :erlang.iolist_to_binary() |> :erlang.binary_to_term()
%{bar: {:ok, :tuple}, baz: ["a", "list", "of", "binaries"], foo: :atom}
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `eet_iolist` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:eet_iolist, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/eet_iolist](https://hexdocs.pm/eet_iolist).

