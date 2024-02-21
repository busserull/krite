defmodule KriteWeb.ServerLive do
  use KriteWeb, :live_view

  alias Krite.Servers
  alias Krite.Servers.Server

  def mount(_params, _session, socket) do
    servers = Servers.list_servers()
    socket = assign(socket, servers: servers, coffees: 0)

    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _uri, socket) do
    server = Servers.get_server!(id)
    {:noreply, assign(socket, selected_server: server, page_title: "What's up #{server.name}")}
  end

  def handle_params(_params, _uri, socket) do
    socket =
      if socket.assigns.live_action == :new do
        changeset = Servers.change_server(%Server{})

        assign(socket, selected_server: nil, form: to_form(changeset))
      else
        assign(socket, selected_servers: hd(socket.assigns.servers))
      end

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Servers</h1>

    <div id="servers">
      <div class="sidebar">
        <div class="nav">
          <.link patch={~p"/servers/new"} class="add">
            Add New Server
          </.link>

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
          <.form :if={@live_action == :new} for={@form} phx-submit="create-server">
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

            <.link class="cancel" patch={~p"/servers"}>
              Cancel
            </.link>
          </.form>

          <.server :if={@live_action != :new} selected={@selected_server} />
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
          |> assign(servers: Servers.list_servers())
          |> push_patch(to: ~p"/servers/#{server.id}")

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
end
