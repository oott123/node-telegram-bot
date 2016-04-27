telegram-bot
============

[![npm version](https://badge.fury.io/js/telegram-bot.svg)](http://badge.fury.io/js/telegram-bot)

Create your own Telegram bot in minutes with [the official Bot API][api]!

Quick Start
-----------

An echo bot in 9 lines: (CoffeeScript)

```coffeescript
Telegram = require 'telegram-bot'

tg = new Telegram(process.env.TELEGRAM_BOT_TOKEN)
tg.on 'message', (msg) ->
  return unless msg.text
  tg.sendMessage
    text: msg.text
    reply_to_message_id: msg.message_id
    chat_id: msg.chat.id

tg.start()
```

or 11 lines (JavaScript):

```javascript
var Telegram = require('telegram-bot');
var tg = new Telegram(process.env.TELEGRAM_BOT_TOKEN);

tg.on('message', function(msg) {
  if (!msg.text) return;
  tg.sendMessage({
    text: msg.text,
    reply_to_message_id: msg.message_id,
    chat_id: msg.chat.id
  });
});

tg.start();
```

For more examples, checkout the `examples` folder!

API Reference
-------------
All methods in the official Bot API can be called directly on the `Telegram` object. For a complete list of available methods, check it out [here][manual].

 [api]: https://core.telegram.org/bots
 [manual]: https://core.telegram.org/bots/api

Todo
----
* [ ] better logging
* [ ] add more examples utilizing multimedia messages
