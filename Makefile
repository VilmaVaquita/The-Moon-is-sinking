TARGETS=game.appcache

clean:
	rm -f $(TARGETS)

all: $(TARGETS)


%.html: %.html.coffee
	(sh -c "coffee $< >$@.new" && mv $@.new $@ && touch -r $< $@) || rm -f $@

%.appcache: %.html
	sleep 1
	# touch $@
	echo >>$@

%.js: %.coffee
	coffee -bc $<

%.stripped.png: %.png
	convert -strip -colorspace sRGB $< -colorspace sRGB $@

%.pamfix.png: %.png
	(pngtopnm|pnmtopng) <$< >$@ || rm -f $@

%.pnmfix.pnm: %.png
	pngtopnm -alpha <$< >$@.alpha.png
	pngtopnm <$< >$@

%.pnmfix.png: %.pnmfix.pnm
	pnmtopng -alpha $<.alpha.png <$< >$@

# %.out.bmp: %.png
# 	pngtopnm <$< |ppmtobmp >$@ || rm -f $@
# %.png: %.in.bmp
# 	bmptoppm $< |pnmtopng >$@ || rm -f $@

# %.out.ppm: %.png
# 	pngtopnm <$< >$@ || rm -f $@
# %.png: %.in.ppm
# 	pnmtopng <$< >$@ || rm -f $@

%_8X.png: %.pnmfix.png
	convert -interpolate integer -scale 800 $< -format BMP2 $@

%_6X.png: %.pnmfix.png
	convert -interpolate integer -scale 600 $< -format BMP2 $@

%_5X.png: %.pnmfix.png
	convert -interpolate integer -scale 500 $< -format BMP2 $@

%_4X.png: %.pnmfix.png
	convert -interpolate integer -scale 400 $< -format BMP2 $@

%_3X.png: %.pnmfix.png
	convert -interpolate integer -scale 300 $< -format BMP2 $@

%_2X.png: %.pnmfix.png
	convert -interpolate integer -scale 200 $< -format BMP2 $@
