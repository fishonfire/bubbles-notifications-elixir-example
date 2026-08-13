# BubblesHexUser

To start your Phoenix server:

* Run `mix setup` to install and setup dependencies
* Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4001`](http://localhost:4001) from your browser.

## Sending notifications

Open [`/notifications`](http://localhost:4001/notifications) for app-level notifications or
[`/push/notifications/device`](http://localhost:4001/push/notifications/device) for direct device pushes.

This app can run on `localhost:4001`, while the local `bubbles_notifications` package is configured to call the
notifications API on `localhost:4000`:

```elixir
config :bubbles_notifications, base_url: "http://localhost:4000"
```

The configured base URL should point at the server that exposes:

```text
POST /api/notifications/create
POST /api/devices/:device_id/send-push
```

Ready to run in production? Please [check our deployment guides](https://phoenix.hexdocs.pm/deployment.html).

## Learn more

* Official website: https://www.phoenixframework.org/
* Guides: https://phoenix.hexdocs.pm/overview.html
* Docs: https://phoenix.hexdocs.pm
* Forum: https://elixirforum.com/c/phoenix-forum
* Source: https://github.com/phoenixframework/phoenix
