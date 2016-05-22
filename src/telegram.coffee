_ = require 'lodash'
rp = require 'request-promise'
Q = require 'q-bluebird'
fs = require 'fs'
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
        .catch (err) -> self.emit 'error', err

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
  getChat
  leaveChat
  getChatAdministrators
  getChatMember
  getChatMembersCount
"""

createStub = (name) -> (options) ->
  formData = _.mapValues options || {}, (i) ->
    if i instanceof fs.ReadStream
      i
    else if _.isObject(i) and i.value and _.isObject(i.options)
      i
    else if _.isObject(i) || _.isArray(i)
      JSON.stringify(i)
    else
      String(i)
  formData = null if _.isEmpty(formData)
  rp.post
    url: "https://api.telegram.org/bot#{@token}/#{name}"
    formData: formData
    agentClass: if @socksProxy then Agent else null
    agentOptions: if @socksProxy then {
        socksHost: @socksProxy.host,
        socksPort: @socksProxy.port
    } else null
  .then (x) -> JSON.parse x

for method in methods.split(/\n/)
  Telegram.prototype[method] = createStub(method)

module.exports = Telegram
