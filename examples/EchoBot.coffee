Telegram = require '..'

tg = new Telegram(process.env.TELEGRAM_BOT_TOKEN)
tg.on 'message', (msg) ->
  return unless msg.text
  tg.sendMessage
    text: msg.text
    reply_to_message_id: msg.message_id
    chat_id: msg.chat.id

tg.start (me) ->
	console.log "#{me.first_name} running!"