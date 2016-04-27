_ = require 'lodash'
rp = require 'request-promise'
Q = require 'q-bluebird'
Agent = require 'socks5-https-client/lib/Agent'
EventEmitter = require('events').EventEmitter

class Telegram extends EventEmitter
  constructor: (@token, {@pollTimeout = 30, @retryTimeout = 10} = {}) ->

  polling: (update_id) ->
    self = this
    @getUpdates
      offset: update_id
      timeout: self.pollTimeout
    .catch (err) ->
      self.emit 'error', err
      Q.delay(self.retryTimeout * 1000).then -> self.polling(update_id)
    .then (data) ->
      _.forEach data.result, (i) =>
        Q.fcall -> self.emit 'message', i.message
        .catch (err) => self.emit 'error', err

      maxId = _.last(data.result)?.update_id
      if maxId != undefined
        maxId += 1

      id = maxId || update_id
      self.polling(id)

  start: ->
    @getMe().then (data) =>
      @me = data.result
      @emit 'connected', @me
      @polling()
      data

methods = """
  getMe
  sendMessage
  forwardMessage
  sendPhoto
  sendAudio
  sendDocument
  sendSticker
  sendVideo
  sendLocation
  sendVenue
  sendContact
  sendChatAction
  getUserProfilePhotos
  getFile
  kickChatMember
  unbanChatMember
  answerCallbackQuery
  answerInlineQuery
  getUpdates
  setWebhook
  editMessageText
  editMessageCaption
  editMessageReplyMarkup
"""

createStub = (name) -> (options) ->
  rp.post
    url: "https://api.telegram.org/bot#{@token}/#{name}"
    form: _.mapValues options || {}, (i) ->
      if _.isObject(i) || _.isArray(i) then JSON.stringify(i) else String(i)
    agentClass: if @socksProxy then Agent else null
    agentOptions: if @socksProxy then {
        socksHost: @socksProxy.host,
        socksPort: @socksProxy.port
    } else null
  .then (x) -> JSON.parse x

for method in methods.split(/\n/)
  Telegram.prototype[method] = createStub(method)

module.exports = Telegram
