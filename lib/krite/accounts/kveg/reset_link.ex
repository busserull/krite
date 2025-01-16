defmodule Krite.Accounts.Kveg.ResetLink do
  @moduledoc """
  Generate and remember password reset link handles for Kveg.

  Create URL-safe reset link handles using `create_handle/1`
  with the relevant Kveg `id`.

  This Kveg `id` can then be retrieved using `get_kveg_id/1`
  until the handle expires.

  Handles expire after `expire_time_minutes` minutes, which
  is the argument given when `start_link/1` is called with
  this module.

  To delete a handle before it expries, use `delete_handle/1`.
  """

  use GenServer

  @doc """
  Start a `Krite.Accounts.Kveg.ResetLink`, registering it under
  its own module name.

  Password reset link handles kept by this module will expire
  after `expire_time_minutes` minutes.
  """
  def start_link(expire_time_minutes) do
    GenServer.start_link(__MODULE__, expire_time_minutes, name: __MODULE__)
  end

  @doc """
  Create a new password reset link handle for `kveg_id`.
  """
  def create_handle(kveg_id) do
    GenServer.call(__MODULE__, {:create, random_handle(), kveg_id})
  end

  @doc """
  Get the Kveg `id` connected to an existing and unexpired `handle`.
  """
  def get_kveg_id(handle) do
    GenServer.call(__MODULE__, {:get, handle})
  end

  @doc """
  Delete a `handle`, invalidating it for further Kveg `id` lookup.
  """
  def delete_handle(handle) do
    GenServer.call(__MODULE__, {:delete, handle})
  end

  @doc false
  def init(expire_time_minutes) do
    timeout = expire_time_minutes * 1000 * 60
    {:ok, {timeout, %{}}}
  end

  @doc false
  def handle_call({:create, handle, kveg_id}, _from, {timeout, store}) do
    new_store =
      store
      |> Enum.reject(fn {_, id} -> id == kveg_id end)
      |> Map.new()
      |> Map.put(handle, kveg_id)

    :timer.send_after(timeout, {:delete, handle})

    {:reply, handle, {timeout, new_store}}
  end

  @doc false
  def handle_call({:get, handle}, _from, {timeout, store}) do
    {:reply, Map.get(store, handle), {timeout, store}}
  end

  @doc false
  def handle_call({:delete, handle}, _from, {timeout, store}) do
    {:reply, :ok, {timeout, Map.delete(store, handle)}}
  end

  @doc false
  def handle_info({:delete, handle}, {timeout, store}) do
    {:noreply, {timeout, Map.delete(store, handle)}}
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
