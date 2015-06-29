_ = require 'lodash'
rp = require 'request-promise'
Q = require 'q-bluebird'
Agent = require 'socks5-https-client/lib/Agent'
EventEmitter = require('events').EventEmitter

class Telegram extends EventEmitter
  constructor: (@token) ->

  polling: (update_id) ->
    self = this
    @getUpdates
      offset: update_id
      timeout: 10
    .catch (err) ->
      console.log err.error
      Q.delay(10000).then -> self.polling(update_id)
    .then (data) ->
      _.forEach data.result, (i) ->
        Q.fcall -> self.emit 'message', i.message
        .catch (err) -> console.error err

      id = _.last(data.result)?.update_id || update_id
      self.polling(id + 1)

  start: (callback) ->
    @getMe().then (data) =>
      @me = data.result
      @emit 'connected', @me
      callback.call null, @me unless typeof callback isnt 'function'
      @polling()

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
  sendChatAction
  getUserProfilePhotos
  getUpdates
  setWebhook
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
