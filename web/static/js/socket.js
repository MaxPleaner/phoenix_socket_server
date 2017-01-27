

// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "web/static/js/app.js".

// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/my_app/endpoint.ex":
import {Socket} from "phoenix"

var token = $('meta[name=channel_token]').attr('content');
var socket = new Socket('/socket', {params: {token: token}});

$(function(){
  window.online_users = $("#online-users")
  if ($("#page-authenticated")) {
    socket.connect()
  }
})

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

window.attachUser = function(phx_ref, email) {
  var user = online_users.find(`[phx_ref='${phx_ref}']`)
  if (user.length == 0) {
    var usernode = $(
      `<li phx_ref='${phx_ref}'>${email}</li>`
    )
    online_users.append(usernode)
    usernode.on("click", function(e){
      e.preventDefault()
      channel.push("direct_msg", {email: email, body: chatInput.value})
    })
  }
}

window.removeUser = function(phx_ref) {
  online_users.find(`[phx_ref='${phx_ref}']`).remove()
}

channel.on("presence_state", payload => {
  Object.keys(payload).forEach(key => {
    var user = payload[key]['metas'][0]
    var phx_ref = user['phx_ref']
    var email = user['email']
    attachUser(phx_ref, email)
  })
})

channel.on("presence_diff", payload => {
  console.log('presence diff')
  console.dir(payload)
  window.payload = payload
  Object.keys(payload["joins"]).forEach(key => {
    payload["joins"][key]["metas"].forEach(meta => {
      attachUser(meta["phx_ref"], meta["email"])
    })
  })
  Object.keys(payload["leaves"]).forEach(key => {
    payload["leaves"][key]["metas"].forEach(meta => {
      removeUser(meta["phx_ref"])
    })
  })  
})

channel.on("direct_msg", payload => {
  console.log("direct msg")
  console.dir(payload)
})

channel.join()
  .receive("ok", resp => { console.log(resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })


export default socket
