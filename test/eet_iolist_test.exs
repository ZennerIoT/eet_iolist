defmodule EetIolistTest do
  use ExUnit.Case
  doctest EetIolist

  test "atoms" do
    assert test_term(:a_small_atom)
    assert test_term(nil)
    assert(:"The 👮 Department of 🏠 Homeland 🗽 Security 🚔 has issued a 🅱ruh Moment ⚠ warning 🚧 for the following districts: Ligma, Sugma, 🅱ofa, and Sugondese.")
  end

  test "integers" do
    for i <- -10..10 do
      test_term(i * 30)
    end
  end

  test "binaries" do
    for _ <- 1..10 do
      length = Enum.random(50..100)
      test_term(:crypto.strong_rand_bytes(length))
    end
    test_term("Numerous instances of 🅱ruh moments 🅱eing triggered by 👀 cringe😬 normies 🚽 have ⏰ recently 🕑 occurred across the 🌎 continental 🇺🇸United States🇺🇸. These individuals are 🅱elieved to 🅱e highly 🔫 dangerous 🔪 and should 🚫 not ❌ 🅱e approached. Citizens are instructed to remain inside and 🔒lock their 🚪doors.")
  end

  test "lists" do
    test_term([])
    test_term(~w[a list of atoms]a)
    test_term(~w[a list of binaries])

    # improper list (rare but should still work!)
    test_term([1, 2, 3 | 4])
  end

  test "maps" do
    test_term(%{})
    test_term(%{a: "b"})
  end

  test "structs" do
    test_term(DateTime.utc_now())
  end

  test "floats" do
    test_term(1.5)
  end

  test "tuples" do
    test_term({})
    test_term({:ok, 12})
    test_term({:error, "failed", :thething})
    test_term(1..1000 |> Enum.into([]) |> List.to_tuple())
  end

  def test_term(term) do
    iovec = EetIolist.term_to_iolist(term)

    assert term == :erlang.binary_to_term(:erlang.iolist_to_binary(iovec))
  end
end
