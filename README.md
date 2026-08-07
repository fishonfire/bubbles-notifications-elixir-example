# BubblesHexUser

To start your Phoenix server:

* Run `mix setup` to install and setup dependencies
* Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Sending notifications

Open [`/notification`](http://localhost:4000/notification) to use the notification form.

The app is currently configured to send notification requests through the local `bubbles_notifications`
package using this base URL in `config/runtime.exs`:

```elixir
config :bubbles_notifications, base_url: "http://localhost:4000"
```

The configured base URL should point at the server that exposes:

```text
POST /api/notifications/create
```

Ready to run in production? Please [check our deployment guides](https://phoenix.hexdocs.pm/deployment.html).

## Learn more

* Official website: https://www.phoenixframework.org/
* Guides: https://phoenix.hexdocs.pm/overview.html
* Docs: https://phoenix.hexdocs.pm
* Forum: https://elixirforum.com/c/phoenix-forum
* Source: https://github.com/phoenixframework/phoenix
