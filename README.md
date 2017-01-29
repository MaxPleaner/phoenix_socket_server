# About

This is an app I built to practice / learn Phoenix and Elixir. There's very little pizazz - all the Javascript is in one 200-line file and there's hardly any CSS. But that's the way I like it. 

Basically the app authenticates you, then shows you a list of online users. You can send them direct messages, which are persisted, and messages can be deleted by the sender. Except for auth, all this is in realtime over websockets. That's the gist of it.

This is deployed to heroku: [hidden-inlet-64920.herokuapp.com](https://hidden-inlet-64920.herokuapp.com)

For a broad-level tutorial on how this site was put together, see [this writeup](./writeup.md)

# Running

To start your Phoenix app:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `npm install`
  * Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Production

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
