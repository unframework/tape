fs = require('fs')
vdomLive = require('vdom-live')
convertBuffer = require('buffer-to-arraybuffer')

echoData = convertBuffer(fs.readFileSync __dirname + '/../echo.wav')
bassData = convertBuffer(fs.readFileSync __dirname + '/../bass.wav')
bass2Data = convertBuffer(fs.readFileSync __dirname + '/../bass2.wav')

createAudioContext = ->
  if typeof window.AudioContext isnt 'undefined'
    return new window.AudioContext
  else if typeof window.webkitAudioContext isnt 'undefined'
    return new window.webkitAudioContext

  throw new Error('AudioContext not supported. :(')

context = createAudioContext()

bassBuffer = null
bass2Buffer = null

context.decodeAudioData bassData, (buffer) ->
  bassBuffer = buffer
context.decodeAudioData bass2Data, (buffer) ->
  bass2Buffer = buffer

# echo
reverbNode = context.createConvolver()
reverbNode.connect(context.destination)
context.decodeAudioData echoData, (buffer) ->
  reverbNode.buffer = buffer

# low-pass
filter = context.createBiquadFilter()
filter.type = 'lowpass'
filter.Q.value = 52.5
filter.frequency.setValueAtTime 440, context.currentTime
filter.frequency.linearRampToValueAtTime 1760, context.currentTime + 20
filter.Q.setValueAtTime 15, context.currentTime
filter.Q.linearRampToValueAtTime(5, context.currentTime + 20)
filter.connect(reverbNode)

runSample = ->
  soundSource = context.createBufferSource()
  soundSource.buffer = if Math.random() > 0.5 then bass2Buffer else bassBuffer
  soundSource.start 0
  soundSource.connect reverbNode
  soundSource.playbackRate.setValueAtTime 1, context.currentTime
  soundSource.playbackRate.linearRampToValueAtTime 0.975 + Math.random() * 0.1, context.currentTime + 1

vdomLive (renderLive) ->
  document.body.style.textAlign = 'center';
  liveDOM = renderLive (h) ->
    h 'div', {
      style: {
        display: 'inline-block'
        marginTop: '50px'
      }
    }, [
      h 'button', { onclick: runSample }, 'Hej!'
    ]

  document.body.appendChild liveDOM
