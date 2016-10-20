fs = require('fs')
vdomLive = require('vdom-live')
convertBuffer = require('buffer-to-arraybuffer')

createAudioContext = ->
  if typeof window.AudioContext isnt 'undefined'
    return new window.AudioContext
  else if typeof window.webkitAudioContext isnt 'undefined'
    return new window.webkitAudioContext

  throw new Error('AudioContext not supported. :(')

context = createAudioContext()

vdomLive (renderLive) ->
  document.body.style.textAlign = 'center';
  liveDOM = renderLive (h) ->
    h 'div', {
      style: {
        display: 'inline-block'
        marginTop: '50px'
      }
    }, [
      'Hej!'
    ]

  document.body.appendChild liveDOM
