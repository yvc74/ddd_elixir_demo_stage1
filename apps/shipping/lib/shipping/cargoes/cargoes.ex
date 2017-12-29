defmodule Shipping.Cargoes do
  @moduledoc """
  The boundary for the Cargoes Aggregate.
  Responsiblities:
  o Get and update Cargo data.
  o Create a DeliveryHistory based on a list of HandlingEvent's

  """

  import Ecto.Query, warn: false
  alias Shipping
  alias Shipping.Repo
  alias Shipping.Cargoes.{Cargo, DeliveryHistory}
  alias Shipping.HandlingEvents.HandlingEvent

  @doc """
  Gets a cargo by its tracking id.

  Raises `Ecto.NoResultsError` if the Cargo does not exist.

  ## Examples

      iex> get_cargo_by_tracking_id!(123)
      %Cargo{}

      iex> get_cargo_by_tracking_id!(456)
      ** (Ecto.NoResultsError)

  """
  def get_cargo_by_tracking_id!(tracking_id), do: Repo.get_by_tracking_id!(Cargo, tracking_id)

  @doc """
  Updates a cargo.

  ## Examples

      iex> update_cargo(cargo, %{field: new_value})
      {:ok, %Cargo{}}

      iex> update_cargo(cargo, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_cargo(%Cargo{} = cargo, attrs) do
    cargo
    |> Cargo.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking cargo changes.

  ## Examples

      iex> change_cargo(cargo)
      %Ecto.Changeset{source: %Cargo{}}

  """
  def change_cargo(%Cargo{} = cargo) do
    Cargo.changeset(cargo, %{})
  end

  @doc """
  Create a DeliveryHistory: a representation of the Cargo's current status. The values
  in a DeliveryHistory are determined by applying each of the Cargo's handling events,
  in turn, against the DeliveryHistory.
  """
  def create_delivery_history(handling_events) do
    delivery_history = %DeliveryHistory{}
    update_delivery_history(handling_events, delivery_history)
  end

  defp update_delivery_history([%HandlingEvent{
                          type: type} | handling_events],
                        %DeliveryHistory{
                          transportation_status: trans_status} = delivery_history) do
      new_trans_status = Shipping.next_trans_status(type, trans_status)
      update_delivery_history(handling_events,
                      %{delivery_history | :transportation_status => new_trans_status})
  end
  defp update_delivery_history([], delivery_history) do
    delivery_history
  end

end
