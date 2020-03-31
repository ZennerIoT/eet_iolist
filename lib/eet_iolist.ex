defmodule EetIolist do
  # http://erlang.org/doc/apps/erts/erl_ext_dist.html

  @spec term_to_iolist(any()) :: iolist()

  def term_to_iolist(term) do
    [<< 131 >> | _term_to_iolist(term)]
  end

  # SMALL_INTEGER_EXT
  defp _term_to_iolist(int) when is_integer(int) and int >= 0 and int < 256 do
    [<< 97, int::size(8)>>]
  end

  # INTEGER_EXT
  defp _term_to_iolist(int) when is_integer(int) and int >= -2147483648 and int < 2147483648 do
    [<< 98, int::size(32)-signed >>]
  end

  # FLOAT_EXT
  # we can skip this for NEW_FLOAT_EXT

  # NEW_FLOAT_EXT
  defp _term_to_iolist(float) when is_float(float) do
    [<< 70, float::float >>]
  end

  # NEW_PORT_EXT
  # not needed rn

  # NEW_PID_EXT
  # not needed rn

  # SMALL_TUPLE_EXT
  defp _term_to_iolist(tuple) when is_tuple(tuple) and :erlang.size(tuple) < 256 do
    elements =
      tuple
      |> Tuple.to_list()
      |> Enum.map(&_term_to_iolist/1)
    header = << 104, :erlang.size(tuple) :: size(8)-unsigned >>

    [ header | elements ]
  end

  # LARGE_TUPLE_EXT
  defp _term_to_iolist(tuple) when is_tuple(tuple) and :erlang.size(tuple) >= 256 do
    elements =
      tuple
      |> Tuple.to_list()
      |> Enum.map(&_term_to_iolist/1)

    header = << 105, :erlang.size(tuple) :: size(32)-unsigned >>

    [ header | elements ]
  end

  # MAP_EXT
  defp _term_to_iolist(map) when is_map(map) do
    elements = case map do
      %struct{} ->
        map
        |> Map.drop([:__struct__])
        |> Enum.into([])
        |> Keyword.put(:__struct__, struct)

      map ->
        Enum.into(map, [])
    end

    arity = length(elements)

    encoded =
      elements
      |> Enum.map(fn {key, value} ->
        [_term_to_iolist(key), _term_to_iolist(value)]
      end)
      |> List.flatten()

    header = << 116, arity::size(32)-unsigned >>

    [ header | encoded ]
  end

  # NIL_EXT
  defp _term_to_iolist([]) do
    [<< 106 >>]
  end

  # STRING_EXT skipped because no such type exists

  # LIST_EXT
  defp _term_to_iolist(list) when is_list(list) do
    {elements, tail} = split_improper(list)

    header = << 108, length(elements)::size(32)-unsigned >>
    encoded = Enum.map(elements, &_term_to_iolist/1) |> List.flatten()
    encoded_tail = _term_to_iolist(tail)

    [header | [encoded | encoded_tail]]
  end

  # BINARY_EXT
  defp _term_to_iolist(binary) when is_binary(binary) do
    [<< 109, :erlang.byte_size(binary)::size(32)-unsigned >>, binary]
  end

  defp _term_to_iolist(bitstring) when is_bitstring(bitstring) do
    bitsize = :erlang.bit_size(bitstring)
    len = div(bitsize, 8) + 1
    bits = rem(bitsize, 8)
    header = << 77, len::size(32)-unsigned, bits::size(8) >>
    pad_bits = 8 - bits
    encoded = << bitstring::bitstring,  0 :: size(pad_bits) >>
    [header, encoded]
  end

  # SMALL_ATOM_UTF8_EXT and ATOM_UTF8_EXT
  defp _term_to_iolist(atom) when is_atom(atom) do
    binary = Atom.to_string(atom)
    size = :erlang.byte_size(binary)

    header = cond do
      size < 256 ->
        << 119, size::size(8)-unsigned >>

      size >= 256 and size < 65536 ->
        << 118, size::size(16)-unsigned >>
    end

    [header, binary]
  end

  defp _term_to_iolist(_others) do
    _term_to_iolist(nil)
  end

  defp split_improper(list, acc \\ [])
  defp split_improper(rest, acc) when not is_list(rest) do
    {Enum.reverse(acc), rest}
  end
  defp split_improper([], acc) do
    {Enum.reverse(acc), []}
  end
  defp split_improper([head | tail], acc) do
    split_improper(tail, [head | acc])
  end
end
