defmodule KriteWeb.SearchLive.Flights do
  def search_by_airport(airport) do
    Process.sleep(4000)

    list_flights()
    |> Enum.filter(&(&1.origin == airport || &1.destination == airport))
  end

  def list_flights do
    [
      %{
        number: "450",
        origin: "DEN",
        destination: "ORD",
        departure_time: time_from_now(days: 1, hours: 1),
        arrival_time: time_from_now(days: 1, hours: 3)
      },
      %{
        number: "450",
        origin: "DEN",
        destination: "ORD",
        departure_time: time_from_now(days: 2, hours: 2),
        arrival_time: time_from_now(days: 2, hours: 4)
      },
      %{
        number: "450",
        origin: "DEN",
        destination: "ORD",
        departure_time: time_from_now(days: 3, hours: 1),
        arrival_time: time_from_now(days: 3, hours: 3)
      },
      %{
        number: "450",
        origin: "DEN",
        destination: "ORD",
        departure_time: time_from_now(days: 4, hours: 2),
        arrival_time: time_from_now(days: 4, hours: 4)
      },
      %{
        number: "860",
        origin: "DFW",
        destination: "ORD",
        departure_time: time_from_now(days: 1, hours: 1),
        arrival_time: time_from_now(days: 1, hours: 3)
      },
      %{
        number: "860",
        origin: "DFW",
        destination: "ORD",
        departure_time: time_from_now(days: 2, hours: 2),
        arrival_time: time_from_now(days: 2, hours: 4)
      },
      %{
        number: "860",
        origin: "DFW",
        destination: "ORD",
        departure_time: time_from_now(days: 3, hours: 1),
        arrival_time: time_from_now(days: 3, hours: 3)
      },
      %{
        number: "740",
        origin: "DAB",
        destination: "DEN",
        departure_time: time_from_now(days: 1, hours: 2),
        arrival_time: time_from_now(days: 1, hours: 5)
      },
      %{
        number: "740",
        origin: "DAB",
        destination: "DEN",
        departure_time: time_from_now(days: 2, hours: 1),
        arrival_time: time_from_now(days: 2, hours: 4)
      },
      %{
        number: "740",
        origin: "DAB",
        destination: "DEN",
        departure_time: time_from_now(days: 3, hours: 2),
        arrival_time: time_from_now(days: 3, hours: 5)
      }
    ]
  end

  defp time_from_now([days: _, hours: _] = options) do
    Timex.local() |> Timex.shift(options) |> Timex.format!("%b %d at %H:%M", :strftime)
  end
end
