_ = require 'lodash'
Telegram = require '..'

tg = new Telegram(process.env.TELEGRAM_BOT_TOKEN)
#tg.socksProxy = { host: "127.0.0.1", port: "36000" }

sessions = {}

map =
  help: (msg) ->
    msg.reply
      text: """
        /1a2b - start a 1A2B game (https://en.wikipedia.org/wiki/Bulls_and_Cows)
        /cancel - cancel any ongoing games
        /help - about this bot
      """

  cancel: (msg) ->
    if sessions[msg.chat.id]
      delete sessions[msg.chat.id]
      msg.reply
        text: "No more games then ;)"
    else
      msg.reply
        text: "No games were running ;("

  "1a2b": (msg) ->
    randomNumber = _.shuffle([0..9]).slice(0, 4).join("")
    sessions[msg.chat.id] = (msg) ->
      text = String(msg.text).trim()
      if text == randomNumber
        delete sessions[msg.chat.id]

        name = if msg.from.username then "#{msg.from.username}" else msg.from.first_name
        msg.reply
          text: "Congratulations, #{name}! The answer is #{randomNumber}. Start a new game by sending /1a2b."
      else if text?.length == 4 && text.match(/^[0-9]{4}$/)
        if text.match(/([0-9]).*\1/)
          msg.reply
            text: "No duplicate numbers - try again!"
            reply_markup:
              force_reply: true
        else
          a = b = 0
          for i in [0..3]
            for j in [0..3]
              if text[i] == randomNumber[j]
                if i == j then a++ else b++
          msg.reply
            text: "#{text}: #{a}A#{b}B"
            reply_markup:
              force_reply: true

    msg.reply
      text: "A new random 4-digital number has been generated! Reply to me the number you guess ┏ (゜ω゜)=☞"
      reply_markup:
        force_reply: true

tg.on 'message', (msg) ->
  console.log "#{msg.date} #{msg.from.username || msg.from.first_name}: #{msg.text}"
  text = String(msg.text).trim()
  msg.reply = (options) ->
    tg.sendMessage _.defaults options,
      reply_to_message_id: @message_id
      chat_id: @chat.id

  cmd = String(text.match(/^\/([a-zA-Z0-9]*)(@gaussbot)?/i)?[1]).toLowerCase()
  return map[cmd](msg) if cmd && map[cmd]

  sessions[msg.chat.id](msg) if sessions[msg.chat.id]

tg.start()
