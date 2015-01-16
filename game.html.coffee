# Copyright (c) 2013, 2014, 2015 Michele Bini

# A game featuring a Vaquita, the smallest, most endagered marine cetacean

# This program is available under the terms of the MIT License

version = "0.2.522"

htmlcup <. require 'htmlcup'

htmlcup[x] = htmlcup.compileTag x for x in [ "svg", "rect", "g", "ellipse", "polygon", "line", "image", "defs", "linearGradient", "stop", "use" ]

title = "Vilma, the happy Vaquita - The Moon is sinking!"

fs = require 'fs'

datauri = (t,x)-> "data:#{t};base64,#{new Buffer(fs.readFileSync(x)).toString("base64")}"
datauripng = (x)-> datauri "image/png", x
dataurijpeg = (x)-> datauri "image/jpeg", x
datauriicon = (x)-> datauri "image/x-icon", x

icon = datauriicon "vaquita.ico"
pixyvaquita = datauripng "vilma.png"

frames =
  _: pixyvaquita
  twist_l: datauripng "vilma_twist_l.png"
  twist_r: datauripng "vilma_twist_r.png"
  happybubble0: datauripng "Happy-oxygen-bubble.png"
  grumpybubble0: datauripng "Grumpy-bubble.png"
  evilbubble0: datauripng "Evil-bubble.png"
  stilla0: datauripng "Stilla-the-starfish.png"
  # cuteluterror: datauripng 'cutelu-terror-v3.png'
  seafloor: dataurijpeg "seafloor.png"
  fontglyphs: datauripng "SimonettaFontRender.png"

gameName = "#{title} v#{version}"

htmlcup.jsFile = (f)-> @script type:"text/javascript", (fs.readFileSync(f).toString())

gameAreaSize = [ 240, 360 ]

genPage = ->
 htmlcup.printHtml "<!DOCTYPE html>\n"
 htmlcup.html lang:"en", manifest:"game.appcache", style:"height:100%", ->
  @head ->
    @meta charset:"utf-8"
    @meta name:"viewport", content:"width=480, user-scalable=no"
    @meta name:"apple-mobile-web-app-capable", content:"yes"
    @meta name:"mobile-web-app-capable", content:"yes"
    # Improve support: http://www.html5rocks.com/en/mobile/fullscreen/
    # Homescreen installed webapp on Android Chrome has weird name! (Web App)
    @link rel:"shortcut icon", href:icon
    @title title
  @body style:"margin:0;border:0;padding:0;height:100%;width:100%;background:black;-webkit-font-smoothing:none", ->
    @div style:"visibility:hidden;position:absolute", ->
        @img id:"pixyvaquita", src:pixyvaquita
        @img id:"pixyvaquita_twist_l", src:frames.twist_l
        @img id:"pixyvaquita_twist_r", src:frames.twist_r
        @img id:"happybubble0", src:frames.happybubble0
        @img id:"grumpybubble0", src:frames.grumpybubble0
        @img id:"evilbubble0", src:frames.evilbubble0
        @img id:"stilla0", src:frames.stilla0
        # @img id:"cuteluterror", src:frames.cuteluterror
        @img id:"seafloor", src:frames.seafloor
        @img id:"fontglyphs", src:frames.fontglyphs
    @div style:"display:table;width:100%;max-width:100%;height:100%;margin:0;border:0;padding:0", ->
     @div style:"display:table-cell;vertical-align:middle;width:100%;margin:0;border:0;padding:0;text-align:center", ->
      @div style:"position:relative;display:inline-block",  width:"#{gameAreaSize[0]*2}", height:"#{gameAreaSize[1]*2}", ->
        @canvas width:"#{gameAreaSize[0]*2}", height:"#{gameAreaSize[1]*2}"
        @header style:"position:absolute;top:0;left:0;font-size:14px;width:100%;color:black", ->
          @span gameName
          @span " - "
          @a target:"_blank", href:"../index.html", "Save Vaqitas"
          @div style:"text-align:right", id:"fps"
    gameObjects = null
    @script type:"text/javascript", "gameObjects=#{JSON.stringify(gameObjects)};"
    @script type:"text/javascript", "__hasProp = {}.hasOwnProperty; __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };"
    @jsFile "jaws/jaws-min.js"
    # @jsFile "jaws-assets-named.js"
    @coffeeScript -> do ->

      # reportErrors = (x)->
      #   try
      #     x()
      #   catch error
      #     try
      #       alert error.toString()
      #     catch error2
      #       alert error

      screen_x1 = 120
      screen_y1 = 180
      sqrt   <. Math
      sin    <. Math
      cos    <. Math
      tan    <. Math
      pow    <. Math
      atan   <. Math
      atan2  <. Math
      round  <. Math
      pi = atan2 0, -1
      pi_h = atan2 1, 0
      pi_h_i = 1.0 / pi_h
      
      sqr = (x)-> x * x
      cube = (x)-> x * x * x
      sharpener = (p)-> p2 = p - 1; (x)-> (pow(p, x)-1)/p2
      sharpen = sharpener 86

      jaws.onload = ->
        class Demo
          keyCodes: { left: leftKey, right: rightKey, up: upKey, down: downKey, space: spaceKey } = jaws.keyCodes
          Sprite: Sprite = class extends jaws.Sprite
            # caller needs to set lr for flip center
            constructor: ->
              super
                image: @image
                x: 0
                y: 0
                scale: 2
            draw: ->
              @flipped = @lr >= 0
              @x = (screen_x1 + @px + @lr) * 2
              @y = (screen_y1 + @py - @tb) * 2
              super()
            cr: 4
            sqrt: Math.sqrt
            collide: (o)@>
              { px, py, cr } = o
              opx = o.px; opy = o.py; ocr = o.cr
              dx = px - opx
              dy = py - opy
              dc = cr + ocr
              if (qd = dx * dx + dy * dy) <= dc * dc
                @bumpedInto?(o, qd, dx, dy)
                o.bumpedInto?(@, qd, -dx, -dy)
                # if true
                #   @lr = - @lr
                #   o.lr = - o.lr
                #   @px = opx
                #   @py = opy
                #   return
                # @py = py - 1
                # return
                # { sqrt } = @
                # if false
                #   py = opy
                #   px = opx - dc
                # else
                #   d = sqrt d
                #   if d < 0.1
                #     dy = -1
                #     d = dx * dx + dy * dy
                #     d = sqrt d
                #   d = 3 * dc / sqrt(d)
                #   py = opy + dy * d
                #   px = opx + dx * d
                # @px = px | 0
                # @py = py | 0
                
          Bubble: Bubble = Sprite
          HappyBubble: HappyBubble = class extends Bubble
            image: happybubble0
            constructor: ->
              @lr = 4
              @tb = 4
              super()
            draw: ->
              @py--
              super()
            oxygen: 10
            score: 5
            bumpedInto: (o, qd, dx, dy)@>
              return if @dead
              # if dx * dx * 2 > qd
              @dead = true
          GrumpyBubble: GrumpyBubble = class extends Bubble
            image: grumpybubble0
            constructor: ->
              @lr = 7
              @tb = 7
              @cr = 8
              @life = 60
              super()
            draw: (collisions, game)->
              if game?.slowedBubbles
                @py -= 2
              else
                @py -= 3
              super()
            bumpedInto: (o, qd, dx, dy)@>
              return if @dead
              # if dx * dx * 2 > qd
              # @dead = true
              ovy = o.vy
              o.py -= 3 + (ovy > 0 then @life -= ovy; ovy * 2 else 0)
              @dead = true unless @life > 0
          EvilBubble: EvilBubble = class extends Bubble
            image: evilbubble0
            constructor: ->
              @lr = 15
              @tb = 15
              @cr = 8
              @vy_ = -7
              @life = 2200
              super()
            draw: (collisions, game)->
              l = 0
              if game.slowedBubbles
                @py -= 3
              else
                @py += @vy_
              if (life = @life) < 2200
                l = 2200 - @life
                # l -= 1100
                # l = -l if l < 0
                # l = (l / 20)|0
                l = 2200 - l if l > 1100
                l /= 55
                @vy_ = - 8 - l
              super()
            bumpedInto: (o, qd, dx, dy)@>
              return if @dead
              # if dx * dx * 2 > qd
              # @dead = true
              ovx = o.vx
              ovy = o.vy
              @life -= ovx * ovx + ovy * ovy
              @life -= 10
              o.px = @px
              o.py = @py + @vy_
              @dead = true unless @life > 0
          slowBubbles: @>
            return if @slowedBubbles
            @slowedBubbles = true
          quitSlowBubbles: @>
            return unless @slowedBubbles
            @slowedBubbles = false
          Stilla: Stilla = class extends Bubble
            image: stilla0
            Bubble: @Bubble
            constructor: ->
              @lr = 16
              @tb = 20
              @patience = 490
              super()
            # Math: Math
            sqrt: Math.sqrt
            pow: Math.pow
            sin: Math.sin
            draw: (collisions, game)->
              { px, py, lr } = @
              (spin = @spin) then
                { pow, sin } = @
                d = pow(px * px + py * py, 0.42)
                r = 5 / (d + 1)
                if r < 1
                  ir = 1
                else
                  d = sin(d / 8000)
                  d = d * d * 8000
                  ir = sqrt(1 - r * r) * pow(d, 0.01)
                @px = px * ir + py * (r * spin)
                @py = py * ir - px * (r * spin)
                (d = px * px + py * py) > 40000 then
                  @spin = null
                  if @patience < 0
                    @dead = 1
                    # @patience += 10
                  # @spinFrame =
                else !(d >= 0) then
                  @px = 0
                  @py = 1
                  # throw "ir #{ir}" # TODO: maybe report this error?
              else
                closest = null
                closestDist = null
                consider = (v)->
                  return unless v?
                  dx = px - v.px
                  dy = py - v.py
                  d = dx * dx + dy * dy
                  if !closest? or d < closestDist
                    return unless d >= 0
                    closest = v
                    closestDist = d
                    game.quitSlowBubbles()
                vilma <. game
                consider vilma
                if game.vaquitas?
                  consider v for v in game.vaquitas
                slowBubbles = false
                if closest?
                  if closestDist < 7000
                    slowBubbles = true
                    if closestDist < 4000
                      @patience--
                      if @patience < 0 or (closestDist < 1000 and closest is vilma)
                        dx = px - closest.px
                        @spin = (lr > 0 then +1 else -1) # Start spinning
                        @patience -= 100
                      else
                        dx = px - closest.px
                        dy = py - closest.py
                        # fpx = @fpx += dx / 100
                        # fpy = @fpy += dy / 100
                        # @px = fpx | 0
                        # @py = fpy | 0
                        @px += (dx > +2 then +1 else dx < -2 then -1 else 0)
                        @py += (dy > +2 then +1 else dy < -2 then -1 else 0)
                        # @px += 1
                    
                # @px += 1
                if slowBubbles
                  game.slowBubbles()
                else
                  game.quitSlowBubbles()
                @lr = -lr if px * lr > 0
              super()
            goodnight: (game)@> game.quitSlowBubbles()
            bumpedInto: (o)@>
              o.dead = true
          oxygenation: oxygenation =
            create: @> oxygen: 0.7;  __proto__: @
            addFrom: (o)@>
              (o = o.oxygen)? then
                oxygen <. @
                oxygen += o * 0.001
                if oxygen > 1.0
                  oxygen = 1.0
                @oxygen = oxygen
            consume: @>
              @oxygen *= 0.99999
          Vaquita: Vaquita = class extends Sprite
            twist: [ pixyvaquita_twist_l, pixyvaquita_twist_r ]
            constructor: ->
              @lr = 16
              @tb = 16
              @oxygen = oxygenation.create()
              super()
            draw: ->
                  @oxygen.consume()
                  if @vx < 0
                    @lr = - 18
                  else if @vx > 0
                    @lr = 18
                  super()
            bumpedInto: (x)@> @oxygen.addFrom(x)
          AiVaquita: AiVaquita = class extends Vaquita
            constructor: ->
              @image = pixyvaquita
              @time = 0
              super()
            beat_lr: 0
            draw: ->
                  vx = @vx + Math.floor(Math.random()*5) - 2
                  vy = @vy + Math.floor(Math.random()*3) - 1
                  x = @px
                  y = @py
                  rx = 0.5 * x / screen_x1
                  ry = 0.5 * y / screen_y1
                  if (s = vx * vx + vy * vy * 2) > 6
                    vx = Math.round(vx * 0.8 - rx)
                    vy = Math.round(vy * 0.8 - ry)
                  @px += @vx = vx
                  @py += @vy = vy
                  if (@time++ % 3) is 0
                    if @image isnt pixyvaquita
                      @image = pixyvaquita
                    else if vx * vx + vy * vy > 2
                      @image = @twist[ @beat_lr++ & 1 ]
                  super()
          Vilma: Vilma = class extends Vaquita
            constructor: (@game)->
              @image = pixyvaquita
              @time = 0
              super()
              @fpx = @px ? 0
              @fpy = @py ? 0
              @touch = @game.touchInput
              @auto_to = 40
              @score = 0
            beat_lr: 0
            move: ->
              touch <. @

              # { tx, ty } = touch
              # itx = (tx >= 2 then 2 else tx <= -2 then -2 else 0)
              # ity = (ty >= 2 then 2 else ty <= -2 then -2 else 0)
              # touch.tx = tx * 0.9 - itx
              # touch.ty = ty * 0.9 - ity
              # itx = - itx / 2
              # ity = - ity / 2

              itx = touch.ax * 0.088
              ity = touch.ay * 0.088
              
              ax = (if jaws.pressed[leftKey]  then -1 else 0)    +   (if jaws.pressed[rightKey]  then 1 else 0)  +  itx
              ay = (if jaws.pressed[upKey]    then -1 else 0)    +   (if jaws.pressed[downKey]   then 1 else 0)  +  ity
              if ax is 0 and ay is 0
                if @auto_to > 0 then @auto_to-- else
                  @fvx ?= @vx
                  @fvy ?= @vy
                  fvx = @fvx * 1.2 + Math.random() - 0.5
                  fvy = @fvy * 1.2 + Math.random() - 0.5
                  x = @px
                  y = @py
                  if (s = fvx * fvx + fvy * fvy * 2) > 6
                    fvx *= 0.8
                    fvy *= 0.8
                  @px = (@fpx += (@fvx = fvx))|0
                  @py = (@fpy += (@fvy = fvy))|0
                  @vx = fvx|0
                  @vy = fvy|0
                  return
                  ax = vx/10 + (Math.random() - 0.5) * 2
                  ay = vy/10 + (Math.random() - 0.5) * 2
                  return
              else
                unless @auto_to > 0
                  @fvx = null
                  @fvy = null
                @auto_to = 600

              if (aq = ax * ax + ay * ay) > 1
                aq = sqrt(aq)
                ax /= aq
                ay /= aq
                # aq = 1
              ax *= 0.618
              ay *= 0.618

              # aa = sqr(Math.sin(Math.atan2(ax, ay))) * 2
              # ax *= aa
              # ay *= aa
              
              vx = @vx
              vy = @vy
              if ax * vx < 0
                vx = 0
              else
                vx += ax
                # vx *= 0.9
              if ay * vy < 0
                vy = 0
              else
                vy += ay
                # vy * 0.9
                
              if true
                # new way to calculate drag
                anglecomponent = 0.2 + (sharpen(sqr(sin(Math.atan2(vy, vx)))))
                # anglecomponent = 1200 / anglecomponent
                antidrag = 1 - sqr( atan( (vx * vx + vy * vy * 3) *anglecomponent / 9 ) * pi_h_i )
                vx *= antidrag
                vy *= antidrag
              else
                if (vx * vx + vy * vy * 2) > 35
                  vx *= 0.8
                  vy *= 0.8
                else
                  vx *= 0.95
                  vy *= 0.95
              @px = round(@fpx += (@vx = vx))
              @py = round(@fpy += (@vy = vy))
            draw: ->
              { vx, vy } = @
              if (@time++ % 3) is 0
                if @image isnt pixyvaquita
                  @image = pixyvaquita
                else if vx * vx + (vy * vy / 4) > 1
                  @image = @twist[@beat_lr++ & 1]
              super()
            bumpedInto: (x)@>
              @oxygen.addFrom(x)
              score <. x
              @score += score if score?
          addVaquita: ->
              # n = v.cloneNode()
              # n.setAttribute "opacity", "0.5"
              # n.href.baseVal = "#_v105" if Math.random(0) > 0.5
              # n.setAttribute "transform", ""
              # sea.appendChild n
              angle = Math.random() * 6.28
              v = new AiVaquita
              v.vx = 0
              v.vy = 0
              v.px = Math.floor(Math.sin(angle) * 300)
              v.py = Math.floor(Math.cos(angle) * 300)
              # v.draw()
              # vaquita.update()
              @vaquitas.push v
          addStilla: (x, y)@>
            return if @stilla?
            v = new @Stilla
            v.px = x
            v.py = y
            @stilla = v
          addInto: (n, v, x, y)@>
              v.vx = 0
              v.vy = 0
              v.px = x
              v.py = y
              b = @[n]
              if (i = b.indexOf(null)) >= 0
                b[i] = v
              else
                b.push v
              # v.draw()
          constructor: (@vaquitas = [], @cameos = [], @stilla = null)->
          encounters:
            __proto__:
              encounter: encounter =
                add: (game, x, y)@> game.addInto('cameos', new @creature(), x, y)
                vy: 0
              random: Math.random
              log: Math.log
              exp: Math.exp
              pow: Math.pow
              poissonSample: (m)@>
                { exp, random } = @
                pgen = (m)->
                    x = 0
                    p = exp(-m)
                    s = p
                    u = random()
                    while u > s
                        x++
                        p = p * m / x
                        s += p
                    x
                s = 0
                while m > 50
                  s += pgen 50
                  m -= 50
                s + pgen m
              generate: (game,left,top,width,height,vx,vvy)@>
                { probability, random } = @
                depth = game.getDepth()
                genRect = (m,left,top,width,height)=>
                  c = m.p(depth) * width * height
                  # c = 0
                  c = @poissonSample(c)
                  if c is 1
                      m.add?( game, left + ((random() * width)|0), top + ((random() * height)|0) )
                  else
                    # c = 0 # if c > 1000
                    # c-- if random() > 0.15
                    while c-- > 0
                      m.add?( game, left + ((random() * width)|0), top + ((random() * height)|0) )
                      1
                if vx * vx >= width * width
                  for k,v of @catalogue
                    genRect(v, left, top, width, height)
                else for k,v of @catalogue
                  vy = vvy - v.vy
                  if vy * vy >= height * height
                    genRect(v, left, top, width, height)
                  else if vx > 0
                    if vy > 0
                      genRect(v, left, top + height - vy, width, vy)
                      genRect(v, left + width - vx, top, vx, height - vy)
                    else if vy < 0
                      genRect(v, left, top, width, -vy)
                      genRect(v, left + width - vx, top - vy, vx, height + vy)
                    else
                      genRect(v, left + width, top, vx, height)
                  else if vx < 0
                    if vy > 0
                      genRect(v, left, top + height - vy, width, vy)
                      genRect(v, left, top, -vx, height - vy)
                    else if vy < 0
                      genRect(v, left, top, width, -vy)
                      genRect(v, left, top - vy, -vx, height + vy)
                    else
                      genRect(v, left, top, -vx, height)
                  else if vy > 0
                    genRect(v, left, top + height - vy, width, vy)
                  else if vy < 0
                    genRect(v, left, top, width, -vy)
            catalogue:
              happybubble:
                  __proto__: encounter
                  p: (depth)@> 0.0001 * (1.5 - depth)
                  creature: HappyBubble
                  vy: -1
              grumpybubble:
                  __proto__: encounter
                  p: (depth)@> depth < 0.08 then 0 else (depth - 0.08) * 0.00015
                  creature: GrumpyBubble
                  vy: -3
              evilbubble:
                  __proto__: encounter
                  p: (depth)@> depth < 0.35 then 0 else (depth - 0.35) * 0.00005
                  creature: EvilBubble
                  vy: -8
              stilla:
                  __proto__: encounter
                  p: (depth)@> depth < 0.01 then 1 else (1-depth)/100000
                  add: (game, x, y)@> game.addStilla(x, y)
          touchInput:
            ax: 0
            ay: 0
            tx: 0
            ty: 0
            ongoing: { }
            __proto__:
              eval: eval
              start: (ev,el)@>
                ongoing <. @
                for t in ev.changedTouches
                  { identifier, pageX, pageY } = t
                  ongoing[identifier] =
                    px: pageX
                    py: pageY
                    ox: pageX
                    oy: pageY
              move: (ev,el)@>
                ongoing <. @
                @ .> tx
                @ .> ty
                ax = 0
                ay = 0
                
                for t in ev.changedTouches
                  { identifier, pageX, pageY } = t
                  o = ongoing[identifier]
                  dx = (pageX - o.px) * 4
                  dy = (pageY - o.py) * 4
                  dx *= 3 if dx * tx < 0
                  dy *= 3 if dy * ty < 0
                  tx += dx
                  ty += dy
                  # tx * dx > 0 then tx += dx else tx = dx * 2
                  # ty * dy > 0 then ty += dy else ty = dy * 2
                  o.px = pageX
                  o.py = pageY
                  ax += pageX - o.ox
                  ay += pageY - o.oy

                @ .< tx
                @ .< ty
                @ .< ax
                @ .< ay
              end: (ev,el)@>
                ongoing <. @
                for t in ev.changedTouches
                  identifier <. t
                  delete ongoing[identifier]
                @ax = 0
                @ay = 0
              handle: (name)->
                touchInput = @
                (event)->
                  event.preventDefault()
                  event.stopPropagation()
                  touchInput[name](event,this) catch err
                    alert err.toString()
          ColorPlane: ColorPlane = do->
            document: document
            init: @>
              color <. @
              if color and typeof color is 'string'
                e = @document.createElement "canvas"
                e.width   = @w
                e.height  = @h
                ctx = e.getContext '2d'
                @color = ctx.fillStyle = color
            frame: (t)@>
              # t.save()
              t.fillStyle = @color
              t.fillRect 0,0,1024,1024
              # t.restore()
          GenericPlane: GenericPlane =
            document: document
            init: @>
              document <. @
              e = document.createElement "canvas"
              e.width   = @w
              e.height  = @h
              @ctx = e.getContext '2d'

          ScaledImg: ScaledImg =
            document: document
            zoom: 2
            init: @>
              retroScaling = (c)->
                c.imageSmoothingEnabled = false;
                c.webkitImageSmoothingEnabled = false;
                c.mozImageSmoothingEnabled = false;
                
              zoom <. @
              { width, height } = @img
              @w = w = width * zoom
              @h = h = height * zoom
              c0 = e = @document.createElement "canvas"
              retroScaling(c0)
              e.width   = w
              e.height  = height
              ctx0 = e.getContext '2d'
              retroScaling(ctx0)
              ctx0.drawImage @img, 0, 0, width, height, 0, 0, w, height
              @canvas = e = @document.createElement "canvas"
              e.width   = w
              e.height  = h
              ctx = e.getContext '2d'
              retroScaling(ctx)
              @ctx = ctx.drawImage c0, 0, 0, w, height, 0, 0, w, h
           
          ParallaxPlane: ParallaxPlane =
            __proto__: GenericPlane
            ParallaxPlaneSuper: GenericPlane
            lower: null
            x: 0
            y: 0
            fx: 0
            fy: 0
            logzoom: 2
            frame: (t,dx,dy)@>
              { fx, fy, x, y, abslogzoom, w, h, ctx } = @
              nfx = fx + dx
              nfy = fy + dy
              nx = nfx >> abslogzoom
              ny = nfy >> abslogzoom
              if nx isnt x
                if nx >= w
                  nx -= w
                  nfx -= w << abslogzoom
                else if nx < 0
                  nx += w
                  nfx += w << abslogzoom
                @x = nx
              if ny isnt y
                if ny >= h
                  ny -= h
                  nfy -= h << abslogzoom
                else if ny < 0
                  ny += h
                  nfy += h << abslogzoom
                @y = ny
              @fx = nfx
              @fy = nfy
              @lower?.frame t, dx, dy
              canvas <. ctx
              t.drawImage canvas,  nx,      ny
              t.drawImage canvas,  nx - w,  ny
              t.drawImage canvas,  nx,      ny - h
              t.drawImage canvas,  nx - w,  ny - h
            init: (options)@>
              @abslogzoom ?= @logzoom
              (l = @lower)? then
                l.logzoom? then l.abslogzoom ?= @logzoom + l.logzoom
                l.init(options)
              @ParallaxPlaneSuper.init.call @, options
          BoundParallaxPlane: BoundParallaxPlane =
            __proto__: ParallaxPlane
            BoundParallaxPlaneProto: ParallaxPlane
            pmul: 1
            alert: alert
            init: (options)@>
              { screenw, screenh } = options
              @BoundParallaxPlaneProto.init.call @
              { logzoom, abslogzoom, w, h, pmul } = @
              @mx = ((w << abslogzoom) * pmul - screenw * 8) >> abslogzoom
              @my = ((h << abslogzoom) * pmul - screenh * 8) >> abslogzoom
              # { alert } = @; alert screenw
              if false
                @fx = (@x = @mx) << abslogzoom
                @fy = (@y = @my) << abslogzoom
              @fx = @fy = 0
              @mfy = @my << abslogzoom
            frame: (t, dx, dy)@>
              { fx, fy, x, y, abslogzoom, w, h, ctx } = @
              nfx = fx - dx
              nfy = fy - dy
              nx = nfx >> abslogzoom
              ny = nfy >> abslogzoom
              if nx isnt x
                mx <. @
                if nx >= mx
                  nx = mx
                  nfx = mx << abslogzoom
                else if nx < 0
                  nx = 0
                  nfx = 0
                @x = nx
              if ny isnt y
                 my <. @
                if ny >= my
                  ny = my
                  nfy = my << abslogzoom
                else if ny < 0
                  ny = 0
                  nfy = 0
                @y = ny
              @fx = nfx
              @fy = nfy
              # @lower?.frame t, dx >> abslogzoom, dy >> abslogzoom
              canvas <. ctx
              # @mny = 100
              t.drawImage canvas, -nx, -ny
              # t.drawImage canvas, 0, 0, w, h, -nx, -ny, w*pmul, h*pmul

          SeaFloor: SeaFloor = do->
            __proto__: BoundParallaxPlane
            SeaFloorProto: BoundParallaxPlane
            # terror: CuteluTerror =
            #   img: cuteluterror
            #   zoom: 6
            #   __proto__: ScaledImg
            # color: "#051555"
            seafloorImg: seafloor
            init: (options)@>
              seafloorImg <. @
              # @terror.init(options)
              w = seafloorImg.width
              h = seafloorImg.height
              @w = w
              @h = h
              @SeaFloorProto.init.call @, options
              # { color, w, h } = @
              # e = @document.createElement "canvas"
              # e.width   = w
              # e.height  = h
              # @ctx = ctx = e.getContext '2d'
              { ctx, w, h } = @
              ctx.drawImage seafloorImg, 0, 0
              if false
                ctx.fillStyle = "magenta"
                ctx.fillRect 0, 0, w, 1
                ctx.fillRect 0, 0, 1, h
                ctx.fillRect 0, h - 1, w, 1
                ctx.fillRect w - 1, 0, 1, h              
              
          SeamlessPlane: SeamlessPlane =
            withRect: (rx,ry,rw,rh,cb)@>
              { w, h } = @
              if (ex = rx + rw) > w
                if (ey = ry + rh) > h
                  cb  rx,  ry,  w - rx,  h - ry, 0,      0
                  cb  0,   ry,  ex - w,  h - ry, w - rx, 0
                  cb  rx,  0,   w - rx,  ey - h, 0,      h - ry
                  cb  0,   0,   ex - w,  ey - h, w - rx, h - ry
                else
                  cb rx, ry, w - rx, rh, 0,      0
                  cb 0,  ry, ex - w, rh, w - rx, 0
              else
                if (ey = ry + rh) > h
                  cb rx, ry, rw, h - ry, 0, 0
                  cb rx, 0,  rw, ey - h, 0, h - ry
                else
                  cb rx, ry, rw, rh, 0, 0
            __proto__: ParallaxPlane
            
          WaterPlane: WaterPlane = do->
            waterscapeSuper: waterscapeSuper = SeamlessPlane
            __proto__: waterscapeSuper
            random: Math.random
            sqrt: Math.sqrt
            colors: [ "cyan", "blue" ]
            randomStuff: @>
              { random, sqrt, ctx } = @
              s = sqrt(15000 / (random() * 50 + 1)) | 0
              @withRect (random() * @w | 0), (random() * @h | 0), s, s >> 2, (x,y,w,h)->
                ctx.fillRect x,y,w,h
              @
            init: (options)@>
              { lower, w, h, moltf, colors } = @
              if lower?
                lower.w ?= w
                lower.h ?= h
                lower.moltf ?= moltf >> lower.logzoom if moltf?
              @waterscapeSuper.init.call @, options
              ctx <. @
              for k,v of colors
                ctx.fillStyle = v
                colors[k] = ctx.fillStyle
              ctx.globalAlpha = 0.16
              if true
                x = 200
                while x-- > 0
                  @randomStuff()
            waterscapeSuperFrame: waterscapeSuper.frame
            frame: (t)@>
              { ctx, moltf, random } = @
              
              ctx.fillStyle = @colors[ random() * 1.2 | 0 ]
              @randomStuff() while moltf-- > 0

              t.save()
              t.globalAlpha = @alpha
              @waterscapeSuperFrame.apply @, arguments
              t.restore()
            logzoom: 0
          textRenderer: textRenderer =
            glyphs: fontglyphs
            charMap: {"0":{"w":5,"o":509},"1":{"w":3,"o":518},"2":{"w":4,"o":525},"3":{"w":4,"o":533},"4":{"w":4,"o":541},"5":{"w":4,"o":549},"6":{"w":4,"o":557},"7":{"w":3,"o":565},"8":{"w":4,"o":572},"9":{"w":4,"o":580}," ":{"w":2,"o":0},"a":{"w":4,"o":6},"b":{"w":4,"o":14},"c":{"w":4,"o":22},"d":{"w":4,"o":30},"e":{"w":4,"o":38},"f":{"w":2,"o":46},"g":{"w":4,"o":52},"h":{"w":4,"o":60},"i":{"w":2,"o":68},"j":{"w":2,"o":74},"k":{"w":4,"o":80},"l":{"w":2,"o":88},"m":{"w":6,"o":94},"n":{"w":4,"o":104},"o":{"w":4,"o":112},"p":{"w":4,"o":120},"q":{"w":4,"o":128},"r":{"w":3,"o":136},"s":{"w":3,"o":143},"t":{"w":3,"o":150},"u":{"w":4,"o":157},"v":{"w":4,"o":165},"w":{"w":5,"o":173},"x":{"w":3,"o":182},"y":{"w":4,"o":189},"z":{"w":3,"o":197},"ñ":{"w":4,"o":204},"ç":{"w":4,"o":212},"A":{"w":5,"o":220},"B":{"w":4,"o":229},"C":{"w":6,"o":237},"D":{"w":6,"o":247},"E":{"w":4,"o":257},"F":{"w":4,"o":265},"G":{"w":6,"o":273},"H":{"w":6,"o":283},"I":{"w":2,"o":293},"J":{"w":2,"o":299},"K":{"w":5,"o":305},"L":{"w":4,"o":314},"M":{"w":7,"o":322},"N":{"w":6,"o":333},"O":{"w":6,"o":343},"P":{"w":4,"o":353},"Q":{"w":6,"o":361},"R":{"w":5,"o":371},"S":{"w":4,"o":380},"T":{"w":5,"o":388},"U":{"w":6,"o":397},"V":{"w":5,"o":407},"W":{"w":7,"o":416},"X":{"w":5,"o":427},"Y":{"w":5,"o":436},"Z":{"w":5,"o":445},"!":{"w":2,"o":454},"?":{"w":3,"o":460},",":{"w":2,"o":467},".":{"w":2,"o":473},"@":{"w":6,"o":479},"/":{"w":4,"o":489},":":{"w":2,"o":497},";":{"w":2,"o":503},"á":{"w":4,"o":588},"é":{"w":4,"o":596},"í":{"w":2,"o":604},"ó":{"w":4,"o":610},"ú":{"w":4,"o":618},"à":{"w":4,"o":626},"è":{"w":4,"o":634},"ì":{"w":2,"o":642},"ò":{"w":4,"o":648},"ù":{"w":4,"o":656}}
            lineHeight: 12
            fancyDrawText: (t, x, y)@>
                { charMap, lineHeight, glyphs } = @
                scale = 2
                fancy_r <. @
                fancy_r ?= 0x209532 + x + y
                fancy = 0
                for c in t
                    p = charMap[c]
                    { w, o } = p
                    # throw o
                    
                    fancy_r = (0x2309230 ^ fancy_r * fancy_r) >> 8
                    fancy += (((fancy_r >> 1)&1) - (fancy_r & 1))
                    fancy = (fancy > +4 then +4 else fancy < -4 then -4 else fancy)
                    # throw r & 7
                    
                    @ctx.drawImage glyphs, o, 0, w + 4, lineHeight, x, (y + fancy) * scale, (w + 4) * scale, lineHeight * scale
                    x += (w + 1) * scale
                fancy_r >. @
            drawText: (t, x, y)@>
              { charMap, lineHeight, glyphs } = @
              scale = 2
              for c in t
                p = charMap[c]
                { w, o } = p
                # throw o
                @ctx.drawImage glyphs, o, 0, w + 4, lineHeight, x, y * scale, (w + 4) * scale, lineHeight * scale
                x += (w + 1) * scale
          
          narrator: do->
            first: null
            last: null
            say: (t)@>
              { last, game } = @
              game.other.narrator = @ unless game.other.narrator?
              first = null
              for c in t
                continue if c is "\n"
                c = c: c
                last = (last? then last.next = c else c)
                first ?= last
              @last = last
              @first ?= first
            Math: Math
            draw: @>
              { first, game } = @
              unless first?
                delete game.other.narrator
                return
              { charMap, glyphs, lineHeight } = @
              { radx, rady } = game
              radx2 = radx * 2
              px = -radx
              ex = radx
              dy = rady - rady / 3
              last = null
              { random } = @Math
              while first?
                # x = first.x
                unless (x = first.x)?
                    unless px > radx2 - 10
                        first.x = radx2
                    break
                p = charMap[first.c]
                isLast = x < radx2
                x -= radx
                # x -= 1 + (atan((x * x / 100) / 50) | 0)
                x -= 1 + ((x * x) >> 10)
                x += radx
                x = px if x < px
                first.x = x
                ly = last?.y
                y = first.y ?= ly ? dy
                rr = random()
                y += ((rr*(3/0.33))|0) - 1 if rr < 0.33
                ly? then
                  dd = 1 + x - px
                  # y = ly + dd
                  y = (y > ly + dd then ly + dd else y < ly - dd then ly - dd else y)
                first.y = y
                { o, w } = p
                # y = 40
                scale = 2
                @ctx.drawImage glyphs, o, 0, w + 4, lineHeight, x * scale, y * scale, (w + 4) * scale, lineHeight * scale
                px = x + w + 1
                last = first
                first = first.next
                @first = first if x <= -w              
            __proto__: textRenderer
          scoreBox:
              textRenderer: textRenderer
              score: 0
              draw: @>
                  { game, textRenderer } = @
                  textRenderer.drawText "Score: #{game.vilma.score}", 0, 10
                  textRenderer.drawText "Time: #{game.getPlayTimeText(2)}", 0, 20
                  textRenderer.drawText "Oxygen: #{game.vilma.oxygen.oxygen * 100 + 0.1 | 0}", 0, 30
                  depth = game.getDepth()
                  depth > 0.0005 then textRenderer.drawText "Depth: #{(depth * 100).toFixed(1)} m", 0, 40
                  fmtnr = (x)-> x.toFixed(3).replace("-", ".")
                  if true
                    textRenderer.drawText fmtnr(game.vilma.vx),   0,    50
                    textRenderer.drawText fmtnr(game.vilma.vy),   60,   50
                    textRenderer.drawText fmtnr(game.vilma.fpx),  150,  50
                    textRenderer.drawText fmtnr(game.vilma.fpy),  210,  50
              show: @>
                  { game } = @
                  game.other.scoreBox = @
              hide: @>
                  { game } = @
                  delete game.other.scoreBox
          waves:
            intro:  @>
              
              
            game:   @>
              
              
            score:  @>
              
              
            setup:  @>
              

          # PinkWaveletPlane: PinkWaveletPlane = do->
          #   waterscapeSuper: waterscapeSuper = SeamlessPlane
          #   __proto__: waterscapeSuper
          #   random: Math.random
          #   sqrt: Math.sqrt
          #   sprites: [ "cyan", "blue" ]
          #   wlets: null
          #   randmix: @>
          #     { random, sqrt, ctx } = @
          #     s = sqrt(15000 / (random() * 100 + 1)) | 0
          #     @withRect (random() * @w | 0), (random() * @h | 0), s, s >> 2, (x,y,w,h)->
          #       ctx.fillRect x,y,w,h
          #     @
          #   init: @>
          #     { lower, w, h, moltf, colors } = @
          #     if lower?
          #       lower.w ?= w
          #       lower.h ?= h
          #       lower.moltf ?= moltf >> lower.logzoom if moltf?
          #     @waterscapeSuper.init.call @
          #     { ctx } = @
          #     for k,v of colors
          #       ctx.fillStyle = v
          #       colors[k] = ctx.fillStyle
          #     ctx.globalAlpha = 0.06
          #     if true
          #       x = 300
          #       while x-- > 0
          #         @randomStuff()
          #   waterscapeSuperFrame: waterscapeSuper.frame
          #   frame: (t)@>
          #     { ctx, moltf, random } = @
              
          #     ctx.fillStyle = @colors[ random() * 1.2 | 0 ]
          #     @randomStuff() while moltf-- > 0

          #     { alpha } = @
          #     # t.save()
          #     t.globalAlpha = alpha if alpha?
          #     @waterscapeSuperFrame.apply @, arguments
          #     # t.restore()
          #   logzoom: 0
          seafloor: seafloorPlane = __proto__: SeaFloor
          getDepth: @>
            r = @seafloor.fy / @seafloor.mfy
            r < 0 then 0 else r
          resetDepth: @> @seafloor.fy = 0
          waterscape: waterscape = do->
            __proto__: WaterPlane
            # color: "cyan"
            # logzoom: 0
            moltf: 12
            colors: [ "#051555", "#33ddff" ]
            alpha: 0.2
            logzoom: 0
            lower:
              # __proto__: ColorPlane
              # logzoom: 2
              __proto__: WaterPlane
              # color: "blue"
              colors: [ "#000033", "#001155" ]
              alpha: 0.3
              # abslogzoom: 2
              logzoom: 2
              lower: seafloorPlane
          bluescape:
            __proto__: SeamlessPlane
            bluescapeSuper: SeamlessPlane
            lower: waterscape
            logzoom: 0
            frame: (t,sx,sy)@>
              { ctx, random, w, h } = @

              x = @x + sx
              x = (x + w) % w
              y = (y + h) % h
              @x = x
              y = @y + sy
              y += h while y < 0
              y -= h while y >= h
              @y = y
              # i = ctx.getImageData(0,0,@w,@h)

              ctx.save()
              @lower.frame ctx, sx, sy
              ctx.restore()
              # t.save()
              # t.globalCompositeOperation = 'copy'

              t.drawImage ctx.canvas, 0,0,w,h, 0,0,w*4,h*4
              
              # t.drawImage ctx.canvas, 0,0,w>>2,h>>2, 0,0,w*2,h*2

              # t.drawImage ctx.canvas, 0,0,w>>2,h>>2, 0,0,w*2,h>>2
              # t.drawImage t.canvas, 0,0,w*2,h>>2, 0,0,w*2,h*2

              # t.restore()
              # @withRect x, y, rx*2, ry*2, (x,y,w,h,ox,oy)-> t.drawImage c, x,y,w,h, ox*2,oy*2,w*2,h*2
              # t.drawImage c, 0, 0, 
              # t.fillColor = if random() > 0.5 then "#104080" else "#155590"
              # t.fillRect 0, 0, 100, 100
              # t.clearRect 0, 0, 100, 100
              # t.drawImage t, 0, 0, 100, 100, 50, 50, 100, 100
            init: (options)@>
              { w, h, lower } = @

              @w = w
              @h = h

              lower.w = (w >> 2) * 5
              lower.h = (h >> 2) * 5

              @bluescapeSuper.init.call @, options

              ctx <. @

              # ctx.fillStyle = "#0099dd"
              # ctx.fillRect 0, 0, @w, @h
              
          setup: ->
            { time, bluescape, radx, rady } = @

            @textRenderer.ctx = jaws.context
            @narrator.game = @

            bluescape.w = radx
            bluescape.h = rady
            bluescape.init( { screenw: radx * 2, screenh: rady * 2 } )

            v = new Vilma(@) # jaws.Sprite x:screen_x1*2, y:screen_y1*2, zoom:2, image:pixyvaquita
            v.px = 0
            v.py = 0
            v.vx = 0
            v.vy = 0
            @vilma = v
            
            @encounters.generate(@,-radx, -rady, radx * 2, rady * 2, radx * 2, 0)
            
            touchInput <. @
            touchInput.game = @
            x = document.body
            x.addEventListener "touchmove",   touchInput.handle('move'), true
            x.addEventListener "touchstart",  touchInput.handle('start'), true
            tend = touchInput.handle 'end'
            x.addEventListener "touchend",     tend, true
            x.addEventListener "touchleave",   tend, true
            x.addEventListener "touchcancel",  tend, true

            time.game = @
            time.tickTime = 1.0 / @fps
            time.setFutureChain([
              do->
                after: 0
                run: ->
                  @other.stayontop =
                    draw: => @resetDepth()
                  @narrator.say "Vilma, "
              do->
                after: 4
                run: -> @narrator.say "the Happy Vaquita, \n"
              do->
                after: 4
                run: -> @narrator.say "presents... \n"
              do->
                after: 4
                run: -> @narrator.say "The Moon is sinking"
              do->
                after: 4
                run: ->
                  delete @other.stayontop
                  @resetDepth()
                  @time.playTime = 0
                  @vilma.score = 0
                  @scoreBox.game = @
                  @scoreBox.show()
              
            ])

            @collisions.setup(radx, rady)
          radx: screen_x1
          rady: screen_y1
          rad: screen_x1 * screen_x1 + screen_y1 * screen_y1
          collisions:
            Array: Array
            setup: (radx, rady)@>
              # Setup the collision detection subsystem
              # Assumes:
              # - radx and rady are multiples of 8
              w = @w = (radx >> 2)
              h = @h = (rady >> 2)
              @b = new @Array(w * h)
              @o = (w >> 1) * h + (h >> 1) + 1
              @l = [ ]
            a: (o)@>
              # Add a collision subject
              # Assumes:
              # - all the corners of the object's collision area are in the viewing area
              # - the object's collision radius is <= 8
              { l, b, w } = @
              i = @o + (o.py >> 3) * @w + (o.px >> 3)
              @b[i-1] = @b[i+1] = @b[i] = o
              i -= w
              @b[i-1] = @b[i+1] = @b[i] = o
              i += w << 1
              @b[i-1] = @b[i+1] = @b[i] = o
              @l.push o
              
              # o.crad
            q: (o)@>
              # Quick collision test
              # Test collisions of object against previously added collision subjects
              # For this to work correctly:
              # - the object should have a collision radius <= 4,
              # - have a center in the viewing area
              @b[@o + (o.py >> 3) * @w + (o.px >> 3)]?.collide(o)
            # t2: (o)@>
            # Like above but for objects with a collision radius <= 8
            clear: @>
              @b = new @Array(@b.length) # Discrete board for detecting collisions
              @l = [ ] # List of collisions targets
          getPlayTimeText: (dec)@>
            { playTime } = @time
            s = playTime % 60
            playTime = (playTime / 60) | 0
            m = playTime % 60
            playTime = (playTime / 60) | 0
            m = m.toString().replace(/^[0-9]$/, ((x)-> "0" + x))
            s = s.toFixed(dec).replace(/^[0-9][.]/, ((x)-> "0" + x))            
            "#{playTime}:#{m}:#{s}".replace(/:([0-9][:.])/g, ((x, y)-> ":0" + y))
          time:
            playTime: 0
            current: 0
            advance: @>
              { current, game, tickTime } = @
              @playTime += tickTime
              (current += tickTime) > 1 then
                current -= 1
                @total++
                (future = @future)? then
                  future.after > 0 then future.after-- else
                    @future = future.next
                    future.run.apply game
              @current = current
            setFutureChain: (events)@>
              p = null
              for e in events
                p?.next = e
                p = e
              @future = events[0]
            future: null
          other: { }
          draw: @>
            { jaws, radx, rady, vilma, vaquitas, cameos, stilla, rad, collisions } = @
          
            # @addVaquita() if (!(@gameloop.ticks & 0x7f) and vaquitas.length < 1) or jaws.pressed[spaceKey]
          
            vilma.fpx += vilma.px
            vilma.fpy += vilma.py
            vilma.move()
          
            if true
              { px, py, fpx, fpy } = vilma
            
              vilma.fpx -= px
              vilma.fpy -= py
              vilma.px = 0
              vilma.py = 0
            
              px = px | 0
              py = py | 0
            
              @bluescape.frame jaws.context, -fpx, -fpy
            else
              { px, py } = vilma
                
              vilma.fpx = 0
              vilma.fpy = 0
              vilma.px = 0
              vilma.py = 0
                
              px = px | 0
              py = py | 0
                
              @bluescape.frame jaws.context, -px, -py
          
            collisions.a vilma
          
            for v in vaquitas
              x = v.px -= px
              y = v.py -= py
              v.draw()
              if (x >= -radx) and (x < radx) and (y >= -rady) and (y < rady)
                collisions.a v
          
            vilma.draw()
          
            if stilla?
              x = stilla.px -= px
              y = stilla.py -= py
              if stilla.dead or x * x + y * y > rad * 16
                stilla.goodnight(@)
                @stilla = null
              else
                stilla.draw(collisions, @)
                if (x >= -radx) and (x < radx) and (y >= -rady) and (y < rady)
                  collisions.a stilla
          
            for k,v of cameos
              continue unless v?
              x = v.px -= px
              y = v.py -= py
              if v.dead or (x < -radx) or (x >= radx) or (y < -rady) or (y >= rady)
                cameos[k] = null
              else
                v.draw(collisions, @)
                collisions.q v
          
            @encounters.generate(@,-radx, -rady, radx * 2, rady * 2, px, py)
          
            collisions.clear()
          
            # @textRenderer.fancyDrawText "Vilma, the Happy Vaquita, presents.....", 21, 65
            v.draw() for k,v of @other

            @time.advance()
              
            if (@gameloop.ticks & 0xff) is 0xff
              fps.innerHTML = "#{@gameloop.fps} fps"
          jaws: jaws
          window: window
          spaceKey: spaceKey
          fps: 24
          setupJaws: (Demo)@>
            { jaws, window, fps } = @
            if true
              jaws.init()
              jaws.setupInput();
              window.game = game = new Demo
              gameloop = new jaws.GameLoop(game, { fps })
              (game.gameloop = gameloop).start()
            # else
            # jaws.start Demo, fps:25
        Demo::setupJaws(Demo)
        
      #   gameFrame = -> reportErrors ->
      #     if (time & 0xff) is 0x00 and vaquitas.length < 4
      #       addVaquita()
      #     # s += 0.001
      #     x -= vx = pressedKeys[leftKey] - pressedKeys[rightKey]
      #     y -= pressedKeys[upKey] - pressedKeys[downKey]
      #     if vx > 0
      #       zoomX = 1
      #     else if vx < 0
      #       zoomX = -1
      #     v.setAttribute("transform", "translate(#{x}, #{y}) zoom(#{zoomX}, #{zoomY})")
      #     # transform = v.transform.baseVal.getItem(0)
      #     # transformMatrix.a = zoomX
      #     # transformMatrix.e = x
      #     # transformMatrix.f = y
      #     if (time % 3) is 0
      #       if currentFrame.baseVal is "#twistleft"
      #         currentFrame .baseVal = "#_"
      #       else if vx isnt 0
      #         currentFrame.baseVal = "#twistleft"
      #     # transformList.initialize(transform)
      #     vq.update() for vq in vaquitas
      #     time++
        
      #   # setInterval gameFrame, 40
      
    @coffeeScript -> do ->
      # window.location.reload(true)
      window.addEventListener('load', ((e)->
        if (window.applicationCache)
          window.applicationCache.addEventListener('updateready', ((e)->
              # if (window.applicationCache.status == window.applicationCache.UPDATEREADY)
                # Browser downloaded a new app cache.
                # Swap it in and reload the page to get the new hotness.
                window.applicationCache.swapCache()
                if (confirm('A new version of this site is available. Load it?'))
                  window.location.reload()
              # else
                # Manifest didn't changed. Nothing new to server.
          ), false)
      ), false)

genPage()
