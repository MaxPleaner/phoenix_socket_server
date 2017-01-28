

// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "web/static/js/app.js".

// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/my_app/endpoint.ex":
import {Socket} from "phoenix"

function init() {

  chatInput.on("keypress", event => {
    if(event.keyCode === 13){
      channel.push("global_msg", {body: chatInput.value})
      chatInput.value = ""
    }
  })

  channel.on("global_msg", payload => {
    let messageItem = document.createElement("li");
    messageItem.innerText = `[${Date()}] ${payload.body}`
    messagesContainer.appendChild(messageItem)
  })

  window.attachUser = function(email) {
    var user = onlineUsers.find(`[email='${email}']`)
    if (user.length == 0) {
      var usernode = $(
        `<li class='usernode' email='${email}'>
          <a href="#">${email}</a>
        </li>`
      )
      onlineUsers.append(usernode)
      usernode.on("click", usernodeOnClick)
      attachDirectMessageBox(email)
    }
  }
 
  window.usernodeOnClick = function(e) {
    var usernode = $(e.currentTarget)
    var email = usernode.attr("email")
    var directMessageBox = directMessages.find(`[email='${email}']`)
    var wasHidden = directMessageBox.hasClass("hidden")
    directMessages.find(".direct-msg-box").addClass("hidden")
    onlineUsers.find(".selected").removeClass("selected")
    if (wasHidden) {
      directMessageBox.removeClass("hidden")
      usernode.addClass("selected")
    }
  }

  window.attachDirectMessageBox = function(toUserEmail) {
    var roomName = `direct_msg-${[currentUserEmail, toUserEmail].sort().join("-")}`
    var directMessageBox = $(`
      <div class="hidden direct-msg-box hidden" email='${toUserEmail}' room='${roomName}'>
        <ul class='direct-msg-list'>
        </ul>
        <input class='send-direct-message' type='text' placeholder='send-direct-message'
      </div>
    `)
    directMessages.append(directMessageBox)
    addIncomingDirectMessageListener(toUserEmail, roomName)
    addOutgoingDirectMessageListener(directMessageBox)
  }

  window.removeDirectMessageBox = function(email) {
    var directMessageBox = directMessages.find(`[email='${email}']`)
    directMessageBox.remove(true, true)
    removeIncomingDirectMessageListener(email)
  }

  window.addOutgoingDirectMessageListener = function(directMessageBox) {
    var input = directMessageBox.find(".send-direct-message")
    var email = directMessageBox.attr("email")
    input.on("keypress", event => {
      var el = $(event.currentTarget)
      if(event.keyCode === 13){
        channel.push('direct_msg', {email: email, body: el.val()})
        el.val("")
      }
    })
  }

  window.addIncomingDirectMessageListener = function(toUserEmail, roomName) {
    channel.on( roomName, payload => {
      var msg = payload.body
      console.log(`${msg} from ${roomName}`)
    })
  }
  
  window.removeIncomingDirectMessageListener = function(email) {
    var roomName = `direct_msg-${[currentUserEmail, email].sort().join("-")}`
    channel.off(roomName)
  }

  window.removeUser = function(email) {
    onlineUsers.find(`[email='${email}']`).remove()
    removeDirectMessageBox(email)
  }

  channel.on("presence_state", payload => {
    Object.keys(payload).forEach(key => {
      var user = payload[key]['metas'][0]
      var email = user['email']
      attachUser(email)
    })
  })

  channel.on("presence_diff", payload => {
    window.payload = payload
    Object.keys(payload["joins"]).forEach(key => {
      payload["joins"][key]["metas"].forEach(meta => {
        attachUser(meta["email"])
      })
    })
    Object.keys(payload["leaves"]).forEach(key => {
      payload["leaves"][key]["metas"].forEach(meta => {
        removeUser(meta["email"])
      })
    })  
  })

  channel.join()
    .receive("ok", resp => { console.log("connected to channel") })
    .receive("error", resp => { console.log("Unable to join", resp) })
}


let token = document.querySelector('meta[name=channel_token]').getAttribute('content');
let socket = new Socket('/socket', {params: {token: token}});
window.socket = socket
window.token = token

$(function(){
  window.auth = $("#page-authenticated") 
  if (auth.length > 0) {
    window.chatInput         = $("#chat-input")
    window.messagesContainer = $("#messages")
    window.directMessages    = $("#direct-messages")
    window.onlineUsers       = $("#online-users")

    window.channel           = socket.channel("room:lobby", {})

    window.currentUserEmail = auth.attr("current-user-email")
    socket.connect()
    init()
  }
})

export default socket
