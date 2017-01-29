_note: this is just the sequence of steps I took. It doesn't have to be done in this order_.

1. Generate a new phoenix app.
2. Configure the database.
3. Create a simple websocket channel that echoes input and prints it to the page.
4. Follow Heroku's instructions to prepare for deployment
5. Add the [addict](https://github.com/trenpixster/addict) library and run it's generators. For simplicity's sake, skip the mailer generator. Test that registration and login works.
6. Look in the docs of Phoenix.Token. There are instructions to pass credentials along with websocket requests. This involves printing the token to the HTML page and then sending it from the client with the initial socket connect request. It also requires overriding the `connect` method in `user_socket.ex`
7. Use Phoenix.Presence to track which users are online. This involves two events which need to be handled on the client: `presence_state` (fired on initial page load) and `presence_diff`.
8. On the client, subscribe to a channel for each online user. This is the direct message channel. Make a server handler for incoming direct messages. It should authenticate the user (are they able to send this direct message?) before broadcasting to all subscribers. 
9. Generate a JSON API for a message object. You could just as easily skip this and make a websocket route instead. But I just did it for exposure to the JSON API generator. Only the index route is necessary (create/delete can be handled over websockets). Have the client request the message list over JSON for each room when its direct-message channel is opened. Create a message record in the websocket handler for the create-direct-message route.
10. Make another websocket route to delete a direct message. On the client, add onclick listeners for each message which sends this delete message. Also for each message on the client, make a listener for a delete-msg-confirm event that actually removes the msg node from the page. The server should send this event after the message is deleted.

_other notes:_

- initially, I used the [guardian](https://github.com/ueberauth/guardian) library on top of addict for JWT support. However I realized that I could get the same functionality with Phoenix' builtin token generator, so I removed it. 