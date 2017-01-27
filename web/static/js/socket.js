

// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "web/static/js/app.js".

// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/my_app/endpoint.ex":
import {Socket} from "phoenix"

var token = $('meta[name=channel_token]').attr('content');
var socket = new Socket('/socket', {params: {token: token}});

$(function(){

})
socket.connect()

let channel           = socket.channel("room:lobby", {})
let chatInput         = document.querySelector("#chat-input")
let messagesContainer = document.querySelector("#messages")


chatInput.addEventListener("keypress", event => {
  if(event.keyCode === 13){
    channel.push("new_msg", {body: chatInput.value})
    chatInput.value = ""
  }
})

channel.on("new_msg", payload => {
  let messageItem = document.createElement("li");
  messageItem.innerText = `[${Date()}] ${payload.body}`
  messagesContainer.appendChild(messageItem)
})

channel.on("presence_state", payload => {
  Object.keys(payload).forEach(key => {
    var online_users = $("#online-users")
    var email = payload[key]["user"]['email']
    var user = online_users.find(`[email='${email}']`)
    if (user.length == 0) {
      online_users.append($(
        `<li email='${email}'>${email}</li>`
      ))
    }
  })
})

channel.on("presence_diff", payload => {
  window.presence_diff = payload
})

channel.join()
  .receive("ok", resp => { })
  .receive("error", resp => { console.log("Unable to join", resp) })


export default socket
