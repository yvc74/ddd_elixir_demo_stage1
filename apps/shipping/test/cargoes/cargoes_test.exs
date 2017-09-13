defmodule Shipping.Cargoes.CargoesTest do
  use ExUnit.Case

  alias Shipping.Cargoes
  alias Shipping.Cargoes.Cargo

  test "Fetch an existing Cargo" do
    cargo = Cargoes.get_cargo_by_tracking_id!("ABC123")
    assert Kernel.match?(cargo, %Cargo{})
  end

  test "Fetch a non-existing Cargo" do
    cargoes = Cargoes.get_cargo_by_tracking_id!("FOO")
    assert cargoes == nil
  end

  test "Fetch some existing Delivery History" do
    history = Cargoes.get_delivery_history_for_tracking_id("ABC123")
    assert length(history) == 3
  end

end