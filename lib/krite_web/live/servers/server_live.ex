defmodule KriteWeb.ServerLive do
  use KriteWeb, :live_view

  alias Krite.Servers
  alias Krite.Servers.Server

  def mount(_params, _session, socket) do
    servers = Servers.list_servers()

    form = to_form(Servers.change_server(%Server{}))

    socket =
      socket
      |> assign_servers()
      |> assign(coffees: 0, form: form)

    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _uri, socket) do
    server = Servers.get_server!(id)
    {:noreply, assign(socket, selected_server: server, page_title: "What's up #{server.name}")}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, assign(socket, :selected_server, hd(socket.assigns.servers))}
  end

  def render(assigns) do
    ~H"""
    <h1>Servers</h1>

    <div id="servers">
      <div class="sidebar">
        <div class="nav">
          <.link
            :for={server <- @servers}
            patch={~p"/servers/#{server}"}
            class={if server == @selected_server, do: "selected"}
          >
            <span class={server.status}></span>
            <%= server.name %>
          </.link>
        </div>

        <div class="coffees">
          <button phx-click="drink">
            <img src="/images/coffee.svg" />
            <%= @coffees %>
          </button>
        </div>
      </div>
      <div class="main">
        <div class="wrapper">
          <.form for={@form} phx-submit="create-server">
            <div class="field">
              <.input field={@form[:name]} placeholder="Name" autocomplete="off" />
            </div>
            <div class="field">
              <.input field={@form[:size]} placeholder="Size" autocomplete="off" />
            </div>
            <div class="field">
              <.input field={@form[:framework]} placeholder="Framework" />
            </div>

            <.button phx-disable-with="Creating">
              Create
            </.button>
          </.form>

          <.server selected={@selected_server} />
          <div class="links">
            <.link navigate={~p"/light"}>
              Adjust lights
            </.link>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("drink", _params, socket) do
    {:noreply, update(socket, :coffees, &(&1 + 1))}
  end

  def handle_event("create-server", %{"server" => server_params}, socket) do
    case Servers.create_server(server_params) do
      {:ok, server} ->
        changeset = Servers.change_server(%Server{})
        form = to_form(changeset)

        socket =
          socket
          |> assign_servers()
          |> assign(form: form, selected_server: server)

        {:noreply, socket}

      {:error, changeset} ->
        form = to_form(changeset)
        {:noreply, assign(socket, form: form)}
    end
  end

  attr :selected, Server, required: true

  defp server(assigns) do
    ~H"""
    <div class="server">
      <div class="header">
        <h2><%= @selected.name %></h2>
        <span class={@selected.status}>
          <%= @selected.status %>
        </span>
      </div>
      <div class="body">
        <div class="row">
          <span>
            <%= @selected.deploy_count %> deploys
          </span>
          <span>
            <%= @selected.size %> MiB
          </span>
          <span>
            <%= @selected.framework %>
          </span>
        </div>
        <h3>Last commit message:</h3>
        <blockquote>
          <%= @selected.last_commit_message %>
        </blockquote>
      </div>
    </div>
    """
  end

  defp assign_servers(socket) do
    servers = Servers.list_servers()
    selected_server = hd(servers)

    assign(socket, servers: servers, selected_servers: selected_server)
  end
end
