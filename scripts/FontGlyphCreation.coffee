# This work code was used to create the rendered font glyphs
  
game.vaquitas.splice(0)

@view.coffeecharniaConsole.style.setProperty("opacity", 0.5)

false then document.head.appendChild do(document)@>
    el = document.createElement "link"
    el.rel = "stylesheet"
    el.href = "Simonetta.css"
    el.type = "text/css"
    el

# document.head.lastChild.src
# window.canvaz = null

canvaz = window.canvaz ?= do(document)@>
    el = document.createElement "canvas"
    el.setAttribute "style", "bottom:0;position:absolute;background:red"
    document.body.appendChild el
    el

canvaz.setAttribute "style", "bottom:0;position:absolute;background:#09f"

retroScaling = (c)->
                c.imageSmoothingEnabled = false
                c.webkitImageSmoothingEnabled = false
                c.mozImageSmoothingEnabled = false


# throw canvaz

ctx = canvaz.getContext "2d"
ctx.clearRect 0, 0, 300, 150

retroScaling ctx

fontRenderer =
    ctx: ctx
    put: (t, x, y, c)@>
        @ctx.fillStyle = c
        @ctx.fillText t, x, y
        
    colors: [ "black", "white" ]

    put_b: (t, x, y)@>
        # [ m, n ] = [ "black", "white" ]
        [ m, n ] = @colors
    
        @put t, x-1, y+0, m
        @put t, x+0, y+1, m
        @put t, x+1, y+0, m
        @put t, x+0, y-1, m

        if true
            @ctx.globalAlpha = 0.3
            @put t, x-1, y-1, m
            @put t, x+1, y-1, m
            @put t, x-1, y+1, m
            @put t, x+1, y+1, m
            @ctx.globalAlpha = 1.0

        @put t, x, y, n
        @put t, x, y, n
        @ctx.globalAlpha = 0.3
        @put t, x, y, n
        @ctx.globalAlpha = 1.0

    put_m: (t, x, y)@>
        { width } = @ctx.measureText(t)
        # @ctx.fillStyle = "blue"
        # width++
        # @ctx.globalAlpha = 0.2
        # @ctx.fillRect x, 0, width, @lineHeight
        # @ctx.globalAlpha = 1
        @put_b t, x, y
        
    chars: " abcdefghijklmnopqrstuvwxyzñçABCDEFGHIJKLMNOPQRSTUVWXYZ!?,.@/:;0123456789áéíóúàèìòù"

    measure: (c)@> @ctx.measureText(c).width
    
    fontHeight: 8
    
    document: document
    
    drawingContext: (w,h)@>
        el = @document.createElement "canvas"
        el.width = w
        el.height = h
        el.getContext '2d'
        
    id2dc: (id)@>
        c = @drawingContext(id.width, id.height)
        c.putImageData(id, 0, 0)
        c

    renderChars: @>
        fontHeight = @fontHeight
        @lineHeight = lineHeight = fontHeight + (fontHeight / 2 | 0)

        ctx.font = font = "bold #{fontHeight}px Simonetta"

        false then for x in @chars
            @put_m x, 2, 1+fontHeight
            
        tw = 0
        @charMap = { }
        for x in @chars
            cw = @measure(x)
            @charMap[x] = { w: cw, o: tw }
            tw += cw + 4
        
        @glyphs = @drawingContext ((tw+15) >> 4) << 4, lineHeight
        
        @glyphs.font = font

        cc =
            ctx: @glyphs
            __proto__: @
            
        for ch in @chars
            p = @charMap[ch]
            cc.put_m ch, p.o + 2, 1+fontHeight
        
        @ctx.drawImage @glyphs.canvas, 0, 0, 150, lineHeight, 0, 0, 300, lineHeight * 2
        
        @glyphsConv 'toImageData'
        @glyphsConv 'toDrawingContext'
        @glyphsConv 'toDataUrl'
        @glyphsConv 'fromDataUrl'
        # @drawTextSpaced @chars, 0, lineHeight * 2 # For testing
        @
    test: @>
        { lineHeight } = @
        @drawText "Vilma, the Happy Vaquita!", 30, lineHeight * 2
        
    getFont: @>
        
    
    drawTextSpaced: (t, x, y)@>
        { charmap, lineHeight } = @
        scale = 2
        g = @glyphs.canvas
        for c in t
            p = @charMap[c]
            { w, o } = p
            # throw o
            @ctx.drawImage g, o, 0, w + 4, lineHeight, x, y * scale, (w + 4) * scale, lineHeight * scale
            x += (w + 4) * scale

    drawText: (t, x, y)@>
        { charmap, lineHeight } = @
        scale = 2
        g = @glyphs.canvas
        for c in t
            p = @charMap[c]
            { w, o } = p
            # throw o
            @ctx.drawImage g, o, 0, w + 4, lineHeight, x, y * scale, (w + 4) * scale, lineHeight * scale
            x += (w + 1) * scale
    
    glyphsConv: (format)@>
        @glyphs = ((f)-> f[format]())
            toImageData: =>
                g = @glyphs
                c = g.canvas
                g.getImageData(0, 0, c.width, c.height)
            toDrawingContext:  =>
                @id2dc(@glyphs)
            toDataUrl: => @glyphs.canvas.toDataURL()
            fromDataUrl: =>
                el = @document.createElement "img"
                el.src = @glyphs
                el

fontRenderer.renderChars() # finaly
    # ctx.drawImage canvaz, 0, 0, 50, 100, 50, 100, 100, 200
    # ctx.drawImage canvaz, 0, 0, 25, 50, 25, 50, 100, 200
