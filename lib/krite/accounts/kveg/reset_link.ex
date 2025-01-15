defmodule Krite.Accounts.Kveg.ResetLink do
  @moduledoc """
  Generate and remember password reset link handles for Kveg.

  URL-safe reset link handles are created for a Kveg by calling
  `new/1` with the Kveg `id`. This returns a password reset handle
  that can be used to retrieve the inserted `id` until the handle
  expires.

  Handles expire after `@handle_valid_time` ms.

  Retrieve Kveg `id`s by invoking `get_kveg_id/1` with a valid
  and unexpired password reset link handle.

  Handles are single use, and will become invalidated once they
  are used to retrieve a Kveg `id`.
  """

  use GenServer

  # 15 minutes
  @handle_valid_time 15 * 1000 * 60

  @doc false
  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  Create a new password reset link handle for `kveg_id`.
  """
  def new(kveg_id) do
    GenServer.call(__MODULE__, {:add, random_handle(), kveg_id})
  end

  @doc """
  Get the corresponding Kveg `id` to a `handle`, if it
  exists and has not yet expired.

  The `handle` is consumed and becomes invalidated for
  further use.
  """
  def get_kveg_id(handle) do
    GenServer.call(__MODULE__, {:get, handle})
  end

  @doc false
  def init(:ok) do
    {:ok, %{}}
  end

  @doc false
  def handle_call({:add, handle, kveg_id}, _from, state) do
    new_state =
      state
      |> Enum.reject(fn {_, id} -> id == kveg_id end)
      |> Map.new()
      |> Map.put(handle, kveg_id)

    :timer.send_after(@handle_valid_time, {:remove, handle})

    {:reply, handle, new_state}
  end

  @doc false
  def handle_call({:get, handle}, _from, state) do
    {:reply, Map.get(state, handle), Map.delete(state, handle)}
  end

  @doc false
  def handle_info({:remove, handle}, state) do
    {:noreply, Map.delete(state, handle)}
  end

  defp random_handle do
    random_handle(:crypto.strong_rand_bytes(16), "")
  end

  defp random_handle(<<>>, string), do: string

  defp random_handle(<<byte, rest::binary>>, acc) do
    hex =
      byte
      |> Integer.to_string(16)
      |> String.pad_leading(2, "0")
      |> String.downcase()

    random_handle(rest, hex <> acc)
  end
end
