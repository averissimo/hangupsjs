Client = require './client'
Q      = require 'q'

# callback to get promise for creds using stdin. this in turn
# means the user must fire up their browser and get the
# requested token.
creds = -> auth:Client.authStdin

client = new Client()

# set more verbose logging
client.loglevel 'debug'

# receive chat message events
client.on 'chat_message', (ev) ->
    console.log 'new chat message', ev

client.on 'querypresence', (ev) ->
    console.log 'presence', ev

sendMessage = (conv_id, now = false) ->
    setTimeout () ->
        client.sendchatmessage(conv_id, [
            [0, 'Hello World']
        ])
    , (if now then 0 else 5000)

# connect and post a message.
# the id is a conversation id.
client.connect(creds).then ->

    ids = require('../login/presence.json')

    convs = require('../login/conv_id.json')
    console.log ids
    console.log convs
    debugger

    client.getselfinfo().done (ev) ->
        myId = ev.self_entity.id.chat_id
        name = "#{ev.self_entity.properties.display_name} (#{myId})"
        console.log ''
        console.log "#########{[1..name.length].map(()->'#').join('')}#######"
        console.log "#             #{[1..name.length].map(()->' ').join('')}#"
        console.log "#   I am #{name}!!   #"
        console.log "#             #{[1..name.length].map(()->' ').join('')}#"
        console.log "################{[1..name.length].map(()->'#').join('')}"

        first = true
        for chat_id in ids[myId]
            client.querypresence(chat_id).done (r) ->
                console.log '\n\n\n'
                console.log 'r[0] ', r.presence_result[0]
                console.log '\n\n\n'

        for conv_id in convs[myId]
            sendMessage(conv_id, first)
            first = false
            client.getconversation(conv_id, new Date(), 1, true).done (args) ->
                console.log 'read state', args.conversation_state.conversation.read_state
                console.log 'events: ', args.conversation_state.event.length

    console.log('sync', client.syncrecentconversations())

.done()
