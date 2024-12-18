

# NOTE: This file is generated by m4! Make sure you're editing the .m4 version,
# not the generated version!

FFMPEG_VERSION_MAJOR=7
FFMPEG_VERSION_MINREV=1
FFMPEG_VERSION=$(FFMPEG_VERSION_MAJOR).$(FFMPEG_VERSION_MINREV)
LIBAVJS_VERSION_SUFFIX=
LIBAVJS_VERSION_BASE=6.4
LIBAVJS_VERSION=$(LIBAVJS_VERSION_BASE).$(FFMPEG_VERSION)$(LIBAVJS_VERSION_SUFFIX)
LIBAVJS_VERSION_SHORT=$(LIBAVJS_VERSION_BASE).$(FFMPEG_VERSION_MAJOR)
EMCC=emcc
MINIFIER=node_modules/.bin/terser
OPTFLAGS=-Oz
EMFTFLAGS=-Lbuild/inst/base/lib -lemfiberthreads
THRFLAGS=-pthread $(EMFTFLAGS)
ES6FLAGS=-sEXPORT_ES6=1 -sUSE_ES6_IMPORT_META=1
EFLAGS=\
	`tools/memory-init-file-emcc.sh` \
	--pre-js pre.js \
	--post-js build/post.js --extern-post-js extern-post.js \
	-s "EXPORT_NAME='LibAVFactory'" \
	-s "EXPORTED_FUNCTIONS=@build/exports.json" \
	-s "EXPORTED_RUNTIME_METHODS=['ccall', 'cwrap', 'PThread']" \
	-s MODULARIZE=1 \
	-s STACK_SIZE=1048576 \
	-s ASYNCIFY \
	-s "ASYNCIFY_IMPORTS=['libavjs_wait_reader']" \
	-s INITIAL_MEMORY=25165824 \
	-s ALLOW_MEMORY_GROWTH=1

# For debugging:
#EFLAGS+=\
#	-s ASSERTIONS=2 \
#	-s STACK_OVERFLOW_CHECK=2 \
#	-s MALLOC=emmalloc-memvalidate \
#	-s SAFE_HEAP=1

all: build-default

include mk/*.mk


build-%: \
	dist/libav-$(LIBAVJS_VERSION)-%.js \
	dist/libav-%.js \
	dist/libav-$(LIBAVJS_VERSION)-%.mjs \
	dist/libav-%.mjs \
	dist/libav-$(LIBAVJS_VERSION)-%.dbg.js \
	dist/libav-%.dbg.js \
	dist/libav-$(LIBAVJS_VERSION)-%.dbg.mjs \
	dist/libav-%.dbg.mjs \
	dist/libav-$(LIBAVJS_VERSION)-%.asm.js \
	dist/libav-$(LIBAVJS_VERSION)-%.asm.mjs \
	dist/libav-$(LIBAVJS_VERSION)-%.dbg.asm.js \
	dist/libav-$(LIBAVJS_VERSION)-%.dbg.asm.mjs \
	dist/libav-$(LIBAVJS_VERSION)-%.wasm.js \
	dist/libav-$(LIBAVJS_VERSION)-%.wasm.mjs \
	dist/libav-$(LIBAVJS_VERSION)-%.dbg.wasm.js \
	dist/libav-$(LIBAVJS_VERSION)-%.dbg.wasm.mjs \
	dist/libav-$(LIBAVJS_VERSION)-%.thr.js \
	dist/libav-$(LIBAVJS_VERSION)-%.thr.mjs \
	dist/libav-$(LIBAVJS_VERSION)-%.dbg.thr.js \
	dist/libav-$(LIBAVJS_VERSION)-%.dbg.thr.mjs \
	dist/libav.types.d.ts
	true

# Generic rule for frontend builds
# Use: febuildrule(debug infix, target extension, minifier)



dist/libav-$(LIBAVJS_VERSION)-%.js: build/libav-$(LIBAVJS_VERSION).js \
	dist/libav-$(LIBAVJS_VERSION)-%.wasm.js \
	node_modules/.bin/terser
	mkdir -p dist
	sed "s/@CONFIG/$(*)/g ; s/@DBG//g" < $< | $(MINIFIER) > $(@)

dist/libav-%.js: dist/libav-$(LIBAVJS_VERSION)-%.js
	cp $(<) $(@)


dist/libav-$(LIBAVJS_VERSION)-%.mjs: build/libav-$(LIBAVJS_VERSION).mjs \
	dist/libav-$(LIBAVJS_VERSION)-%.wasm.mjs \
	node_modules/.bin/terser
	mkdir -p dist
	sed "s/@CONFIG/$(*)/g ; s/@DBG//g" < $< | $(MINIFIER) > $(@)

dist/libav-%.mjs: dist/libav-$(LIBAVJS_VERSION)-%.mjs
	cp $(<) $(@)


dist/libav-$(LIBAVJS_VERSION)-%.dbg.js: build/libav-$(LIBAVJS_VERSION).js \
	dist/libav-$(LIBAVJS_VERSION)-%.dbg.wasm.js \
	node_modules/.bin/terser
	mkdir -p dist
	sed "s/@CONFIG/$(*)/g ; s/@DBG/.dbg/g" < $< | cat > $(@)

dist/libav-%.dbg.js: dist/libav-$(LIBAVJS_VERSION)-%.dbg.js
	cp $(<) $(@)


dist/libav-$(LIBAVJS_VERSION)-%.dbg.mjs: build/libav-$(LIBAVJS_VERSION).mjs \
	dist/libav-$(LIBAVJS_VERSION)-%.dbg.wasm.mjs \
	node_modules/.bin/terser
	mkdir -p dist
	sed "s/@CONFIG/$(*)/g ; s/@DBG/.dbg/g" < $< | cat > $(@)

dist/libav-%.dbg.mjs: dist/libav-$(LIBAVJS_VERSION)-%.dbg.mjs
	cp $(<) $(@)


dist/libav.types.d.ts: build/libav.types.d.ts
	mkdir -p dist
	cp $< $@

# Link rule that checks for a library's existence before linking it
# Use: linkfflib(library name, target inst name)


# General build rule for any target
# Use: buildrule(target file name, debug infix, target inst name, extra link flags, target file suffix)


# asm.js version

dist/libav-$(LIBAVJS_VERSION)-%.asm.js: build/ffmpeg-$(FFMPEG_VERSION)/build-base-%/libavformat/libavformat.a \
	build/exports.json pre.js build/post.js extern-post.js bindings.c
	mkdir -p $(@).d
	$(EMCC) $(OPTFLAGS) $(EFLAGS) \
		-Ibuild/ffmpeg-$(FFMPEG_VERSION) -Ibuild/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*) \
		`test ! -e configs/configs/$(*)/link-flags.txt || cat configs/configs/$(*)/link-flags.txt` \
		bindings.c \
		`grep LIBAVJS_WITH_CLI configs/configs/$(*)/link-flags.txt > /dev/null 2>&1 && echo ' \
		build/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/fftools/*.o \
		-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavdevice -lavdevice \
		'` \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavutil/libavutil.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavutil -lavutil \
	'` \
 \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavformat/libavformat.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavformat -lavformat \
	'` \
 \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavcodec/libavcodec.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavcodec -lavcodec \
	'` \
 \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavfilter/libavfilter.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavfilter -lavfilter \
	'` \
 \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libswresample/libswresample.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libswresample -lswresample \
	'` \
 \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libswscale/libswscale.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libswscale -lswscale \
	'` \
 \
		`test ! -e configs/configs/$(*)/libs.txt || sed 's/@TARGET/base/' configs/configs/$(*)/libs.txt` \
		$(EMFTFLAGS) -s WASM=0 \
		-o $(@).d/libav-$(LIBAVJS_VERSION)-$(*).asm.js
	if [ -e $(@).d/libav-$(LIBAVJS_VERSION)-$(*).asm.wasm.map ] ; then \
		./tools/adjust-sourcemap.js $(@).d/libav-$(LIBAVJS_VERSION)-$(*).asm.wasm.map \
			ffmpeg $(FFMPEG_VERSION) \
			libvpx $(LIBVPX_VERSION) \
			libaom $(LIBAOM_VERSION); \
	fi || ( rm -f $(@) ; false )
	sed " \
		s/^\/\/.*include:.*// ; \
		s/@VER/$(LIBAVJS_VERSION)/g ; \
		s/@VARIANT/$(*)/g ; \
		s/@TARGET/asm/g ; \
		s/@DBG//g ; \
		s/@JS/js/g \
	" $(@).d/libav-$(LIBAVJS_VERSION)-$(*).asm.js | tools/license-header.sh configs/configs/$(*)/license.js > $(@)
	rm -f $(@).d/libav-$(LIBAVJS_VERSION)-$(*).asm.js
	-chmod a-x $(@).d/*.wasm
	-mv $(@).d/* dist/
	rmdir $(@).d


dist/libav-$(LIBAVJS_VERSION)-%.asm.mjs: build/ffmpeg-$(FFMPEG_VERSION)/build-base-%/libavformat/libavformat.a \
	build/exports.json pre.js build/post.js extern-post.js bindings.c
	mkdir -p $(@).d
	$(EMCC) $(OPTFLAGS) $(EFLAGS) \
		-Ibuild/ffmpeg-$(FFMPEG_VERSION) -Ibuild/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*) \
		`test ! -e configs/configs/$(*)/link-flags.txt || cat configs/configs/$(*)/link-flags.txt` \
		bindings.c \
		`grep LIBAVJS_WITH_CLI configs/configs/$(*)/link-flags.txt > /dev/null 2>&1 && echo ' \
		build/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/fftools/*.o \
		-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavdevice -lavdevice \
		'` \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavutil/libavutil.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavutil -lavutil \
	'` \
 \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavformat/libavformat.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavformat -lavformat \
	'` \
 \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavcodec/libavcodec.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavcodec -lavcodec \
	'` \
 \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavfilter/libavfilter.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavfilter -lavfilter \
	'` \
 \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libswresample/libswresample.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libswresample -lswresample \
	'` \
 \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libswscale/libswscale.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libswscale -lswscale \
	'` \
 \
		`test ! -e configs/configs/$(*)/libs.txt || sed 's/@TARGET/base/' configs/configs/$(*)/libs.txt` \
		$(EMFTFLAGS) $(ES6FLAGS) -s WASM=0 \
		-o $(@).d/libav-$(LIBAVJS_VERSION)-$(*).asm.mjs
	if [ -e $(@).d/libav-$(LIBAVJS_VERSION)-$(*).asm.wasm.map ] ; then \
		./tools/adjust-sourcemap.js $(@).d/libav-$(LIBAVJS_VERSION)-$(*).asm.wasm.map \
			ffmpeg $(FFMPEG_VERSION) \
			libvpx $(LIBVPX_VERSION) \
			libaom $(LIBAOM_VERSION); \
	fi || ( rm -f $(@) ; false )
	sed " \
		s/^\/\/.*include:.*// ; \
		s/@VER/$(LIBAVJS_VERSION)/g ; \
		s/@VARIANT/$(*)/g ; \
		s/@TARGET/asm/g ; \
		s/@DBG//g ; \
		s/@JS/mjs/g \
	" $(@).d/libav-$(LIBAVJS_VERSION)-$(*).asm.mjs | tools/license-header.sh configs/configs/$(*)/license.js > $(@)
	rm -f $(@).d/libav-$(LIBAVJS_VERSION)-$(*).asm.mjs
	-chmod a-x $(@).d/*.wasm
	-mv $(@).d/* dist/
	rmdir $(@).d


dist/libav-$(LIBAVJS_VERSION)-%.dbg.asm.js: build/ffmpeg-$(FFMPEG_VERSION)/build-base-%/libavformat/libavformat.a \
	build/exports.json pre.js build/post.js extern-post.js bindings.c
	mkdir -p $(@).d
	$(EMCC) $(OPTFLAGS) $(EFLAGS) \
		-Ibuild/ffmpeg-$(FFMPEG_VERSION) -Ibuild/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*) \
		`test ! -e configs/configs/$(*)/link-flags.txt || cat configs/configs/$(*)/link-flags.txt` \
		bindings.c \
		`grep LIBAVJS_WITH_CLI configs/configs/$(*)/link-flags.txt > /dev/null 2>&1 && echo ' \
		build/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/fftools/*.o \
		-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavdevice -lavdevice \
		'` \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavutil/libavutil.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavutil -lavutil \
	'` \
 \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavformat/libavformat.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavformat -lavformat \
	'` \
 \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavcodec/libavcodec.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavcodec -lavcodec \
	'` \
 \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavfilter/libavfilter.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavfilter -lavfilter \
	'` \
 \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libswresample/libswresample.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libswresample -lswresample \
	'` \
 \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libswscale/libswscale.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libswscale -lswscale \
	'` \
 \
		`test ! -e configs/configs/$(*)/libs.txt || sed 's/@TARGET/base/' configs/configs/$(*)/libs.txt` \
		$(EMFTFLAGS) -g2 -s WASM=0 \
		-o $(@).d/libav-$(LIBAVJS_VERSION)-$(*).dbg.asm.js
	if [ -e $(@).d/libav-$(LIBAVJS_VERSION)-$(*).dbg.asm.wasm.map ] ; then \
		./tools/adjust-sourcemap.js $(@).d/libav-$(LIBAVJS_VERSION)-$(*).dbg.asm.wasm.map \
			ffmpeg $(FFMPEG_VERSION) \
			libvpx $(LIBVPX_VERSION) \
			libaom $(LIBAOM_VERSION); \
	fi || ( rm -f $(@) ; false )
	sed " \
		s/^\/\/.*include:.*// ; \
		s/@VER/$(LIBAVJS_VERSION)/g ; \
		s/@VARIANT/$(*)/g ; \
		s/@TARGET/asm/g ; \
		s/@DBG/dbg./g ; \
		s/@JS/js/g \
	" $(@).d/libav-$(LIBAVJS_VERSION)-$(*).dbg.asm.js | tools/license-header.sh configs/configs/$(*)/license.js > $(@)
	rm -f $(@).d/libav-$(LIBAVJS_VERSION)-$(*).dbg.asm.js
	-chmod a-x $(@).d/*.wasm
	-mv $(@).d/* dist/
	rmdir $(@).d


dist/libav-$(LIBAVJS_VERSION)-%.dbg.asm.mjs: build/ffmpeg-$(FFMPEG_VERSION)/build-base-%/libavformat/libavformat.a \
	build/exports.json pre.js build/post.js extern-post.js bindings.c
	mkdir -p $(@).d
	$(EMCC) $(OPTFLAGS) $(EFLAGS) \
		-Ibuild/ffmpeg-$(FFMPEG_VERSION) -Ibuild/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*) \
		`test ! -e configs/configs/$(*)/link-flags.txt || cat configs/configs/$(*)/link-flags.txt` \
		bindings.c \
		`grep LIBAVJS_WITH_CLI configs/configs/$(*)/link-flags.txt > /dev/null 2>&1 && echo ' \
		build/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/fftools/*.o \
		-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavdevice -lavdevice \
		'` \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavutil/libavutil.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavutil -lavutil \
	'` \
 \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavformat/libavformat.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavformat -lavformat \
	'` \
 \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavcodec/libavcodec.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavcodec -lavcodec \
	'` \
 \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavfilter/libavfilter.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavfilter -lavfilter \
	'` \
 \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libswresample/libswresample.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libswresample -lswresample \
	'` \
 \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libswscale/libswscale.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libswscale -lswscale \
	'` \
 \
		`test ! -e configs/configs/$(*)/libs.txt || sed 's/@TARGET/base/' configs/configs/$(*)/libs.txt` \
		$(EMFTFLAGS) -g2 $(ES6FLAGS) -s WASM=0 \
		-o $(@).d/libav-$(LIBAVJS_VERSION)-$(*).dbg.asm.mjs
	if [ -e $(@).d/libav-$(LIBAVJS_VERSION)-$(*).dbg.asm.wasm.map ] ; then \
		./tools/adjust-sourcemap.js $(@).d/libav-$(LIBAVJS_VERSION)-$(*).dbg.asm.wasm.map \
			ffmpeg $(FFMPEG_VERSION) \
			libvpx $(LIBVPX_VERSION) \
			libaom $(LIBAOM_VERSION); \
	fi || ( rm -f $(@) ; false )
	sed " \
		s/^\/\/.*include:.*// ; \
		s/@VER/$(LIBAVJS_VERSION)/g ; \
		s/@VARIANT/$(*)/g ; \
		s/@TARGET/asm/g ; \
		s/@DBG/dbg./g ; \
		s/@JS/mjs/g \
	" $(@).d/libav-$(LIBAVJS_VERSION)-$(*).dbg.asm.mjs | tools/license-header.sh configs/configs/$(*)/license.js > $(@)
	rm -f $(@).d/libav-$(LIBAVJS_VERSION)-$(*).dbg.asm.mjs
	-chmod a-x $(@).d/*.wasm
	-mv $(@).d/* dist/
	rmdir $(@).d

# wasm version with no added features

dist/libav-$(LIBAVJS_VERSION)-%.wasm.js: build/ffmpeg-$(FFMPEG_VERSION)/build-base-%/libavformat/libavformat.a \
	build/exports.json pre.js build/post.js extern-post.js bindings.c
	mkdir -p $(@).d
	$(EMCC) $(OPTFLAGS) $(EFLAGS) \
		-Ibuild/ffmpeg-$(FFMPEG_VERSION) -Ibuild/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*) \
		`test ! -e configs/configs/$(*)/link-flags.txt || cat configs/configs/$(*)/link-flags.txt` \
		bindings.c \
		`grep LIBAVJS_WITH_CLI configs/configs/$(*)/link-flags.txt > /dev/null 2>&1 && echo ' \
		build/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/fftools/*.o \
		-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavdevice -lavdevice \
		'` \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavutil/libavutil.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavutil -lavutil \
	'` \
 \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavformat/libavformat.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavformat -lavformat \
	'` \
 \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavcodec/libavcodec.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavcodec -lavcodec \
	'` \
 \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavfilter/libavfilter.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavfilter -lavfilter \
	'` \
 \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libswresample/libswresample.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libswresample -lswresample \
	'` \
 \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libswscale/libswscale.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libswscale -lswscale \
	'` \
 \
		`test ! -e configs/configs/$(*)/libs.txt || sed 's/@TARGET/base/' configs/configs/$(*)/libs.txt` \
		$(EMFTFLAGS) \
		-o $(@).d/libav-$(LIBAVJS_VERSION)-$(*).wasm.js
	if [ -e $(@).d/libav-$(LIBAVJS_VERSION)-$(*).wasm.wasm.map ] ; then \
		./tools/adjust-sourcemap.js $(@).d/libav-$(LIBAVJS_VERSION)-$(*).wasm.wasm.map \
			ffmpeg $(FFMPEG_VERSION) \
			libvpx $(LIBVPX_VERSION) \
			libaom $(LIBAOM_VERSION); \
	fi || ( rm -f $(@) ; false )
	sed " \
		s/^\/\/.*include:.*// ; \
		s/@VER/$(LIBAVJS_VERSION)/g ; \
		s/@VARIANT/$(*)/g ; \
		s/@TARGET/wasm/g ; \
		s/@DBG//g ; \
		s/@JS/js/g \
	" $(@).d/libav-$(LIBAVJS_VERSION)-$(*).wasm.js | tools/license-header.sh configs/configs/$(*)/license.js > $(@)
	rm -f $(@).d/libav-$(LIBAVJS_VERSION)-$(*).wasm.js
	-chmod a-x $(@).d/*.wasm
	-mv $(@).d/* dist/
	rmdir $(@).d


dist/libav-$(LIBAVJS_VERSION)-%.wasm.mjs: build/ffmpeg-$(FFMPEG_VERSION)/build-base-%/libavformat/libavformat.a \
	build/exports.json pre.js build/post.js extern-post.js bindings.c
	mkdir -p $(@).d
	$(EMCC) $(OPTFLAGS) $(EFLAGS) \
		-Ibuild/ffmpeg-$(FFMPEG_VERSION) -Ibuild/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*) \
		`test ! -e configs/configs/$(*)/link-flags.txt || cat configs/configs/$(*)/link-flags.txt` \
		bindings.c \
		`grep LIBAVJS_WITH_CLI configs/configs/$(*)/link-flags.txt > /dev/null 2>&1 && echo ' \
		build/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/fftools/*.o \
		-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavdevice -lavdevice \
		'` \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavutil/libavutil.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavutil -lavutil \
	'` \
 \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavformat/libavformat.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavformat -lavformat \
	'` \
 \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavcodec/libavcodec.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavcodec -lavcodec \
	'` \
 \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavfilter/libavfilter.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavfilter -lavfilter \
	'` \
 \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libswresample/libswresample.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libswresample -lswresample \
	'` \
 \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libswscale/libswscale.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libswscale -lswscale \
	'` \
 \
		`test ! -e configs/configs/$(*)/libs.txt || sed 's/@TARGET/base/' configs/configs/$(*)/libs.txt` \
		$(EMFTFLAGS) $(ES6FLAGS) \
		-o $(@).d/libav-$(LIBAVJS_VERSION)-$(*).wasm.mjs
	if [ -e $(@).d/libav-$(LIBAVJS_VERSION)-$(*).wasm.wasm.map ] ; then \
		./tools/adjust-sourcemap.js $(@).d/libav-$(LIBAVJS_VERSION)-$(*).wasm.wasm.map \
			ffmpeg $(FFMPEG_VERSION) \
			libvpx $(LIBVPX_VERSION) \
			libaom $(LIBAOM_VERSION); \
	fi || ( rm -f $(@) ; false )
	sed " \
		s/^\/\/.*include:.*// ; \
		s/@VER/$(LIBAVJS_VERSION)/g ; \
		s/@VARIANT/$(*)/g ; \
		s/@TARGET/wasm/g ; \
		s/@DBG//g ; \
		s/@JS/mjs/g \
	" $(@).d/libav-$(LIBAVJS_VERSION)-$(*).wasm.mjs | tools/license-header.sh configs/configs/$(*)/license.js > $(@)
	rm -f $(@).d/libav-$(LIBAVJS_VERSION)-$(*).wasm.mjs
	-chmod a-x $(@).d/*.wasm
	-mv $(@).d/* dist/
	rmdir $(@).d


dist/libav-$(LIBAVJS_VERSION)-%.dbg.wasm.js: build/ffmpeg-$(FFMPEG_VERSION)/build-base-%/libavformat/libavformat.a \
	build/exports.json pre.js build/post.js extern-post.js bindings.c
	mkdir -p $(@).d
	$(EMCC) $(OPTFLAGS) $(EFLAGS) \
		-Ibuild/ffmpeg-$(FFMPEG_VERSION) -Ibuild/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*) \
		`test ! -e configs/configs/$(*)/link-flags.txt || cat configs/configs/$(*)/link-flags.txt` \
		bindings.c \
		`grep LIBAVJS_WITH_CLI configs/configs/$(*)/link-flags.txt > /dev/null 2>&1 && echo ' \
		build/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/fftools/*.o \
		-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavdevice -lavdevice \
		'` \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavutil/libavutil.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavutil -lavutil \
	'` \
 \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavformat/libavformat.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavformat -lavformat \
	'` \
 \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavcodec/libavcodec.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavcodec -lavcodec \
	'` \
 \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavfilter/libavfilter.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavfilter -lavfilter \
	'` \
 \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libswresample/libswresample.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libswresample -lswresample \
	'` \
 \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libswscale/libswscale.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libswscale -lswscale \
	'` \
 \
		`test ! -e configs/configs/$(*)/libs.txt || sed 's/@TARGET/base/' configs/configs/$(*)/libs.txt` \
		$(EMFTFLAGS) -gsource-map \
		-o $(@).d/libav-$(LIBAVJS_VERSION)-$(*).dbg.wasm.js
	if [ -e $(@).d/libav-$(LIBAVJS_VERSION)-$(*).dbg.wasm.wasm.map ] ; then \
		./tools/adjust-sourcemap.js $(@).d/libav-$(LIBAVJS_VERSION)-$(*).dbg.wasm.wasm.map \
			ffmpeg $(FFMPEG_VERSION) \
			libvpx $(LIBVPX_VERSION) \
			libaom $(LIBAOM_VERSION); \
	fi || ( rm -f $(@) ; false )
	sed " \
		s/^\/\/.*include:.*// ; \
		s/@VER/$(LIBAVJS_VERSION)/g ; \
		s/@VARIANT/$(*)/g ; \
		s/@TARGET/wasm/g ; \
		s/@DBG/dbg./g ; \
		s/@JS/js/g \
	" $(@).d/libav-$(LIBAVJS_VERSION)-$(*).dbg.wasm.js | tools/license-header.sh configs/configs/$(*)/license.js > $(@)
	rm -f $(@).d/libav-$(LIBAVJS_VERSION)-$(*).dbg.wasm.js
	-chmod a-x $(@).d/*.wasm
	-mv $(@).d/* dist/
	rmdir $(@).d


dist/libav-$(LIBAVJS_VERSION)-%.dbg.wasm.mjs: build/ffmpeg-$(FFMPEG_VERSION)/build-base-%/libavformat/libavformat.a \
	build/exports.json pre.js build/post.js extern-post.js bindings.c
	mkdir -p $(@).d
	$(EMCC) $(OPTFLAGS) $(EFLAGS) \
		-Ibuild/ffmpeg-$(FFMPEG_VERSION) -Ibuild/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*) \
		`test ! -e configs/configs/$(*)/link-flags.txt || cat configs/configs/$(*)/link-flags.txt` \
		bindings.c \
		`grep LIBAVJS_WITH_CLI configs/configs/$(*)/link-flags.txt > /dev/null 2>&1 && echo ' \
		build/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/fftools/*.o \
		-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavdevice -lavdevice \
		'` \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavutil/libavutil.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavutil -lavutil \
	'` \
 \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavformat/libavformat.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavformat -lavformat \
	'` \
 \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavcodec/libavcodec.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavcodec -lavcodec \
	'` \
 \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavfilter/libavfilter.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libavfilter -lavfilter \
	'` \
 \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libswresample/libswresample.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libswresample -lswresample \
	'` \
 \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libswscale/libswscale.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-base-$(*)/libswscale -lswscale \
	'` \
 \
		`test ! -e configs/configs/$(*)/libs.txt || sed 's/@TARGET/base/' configs/configs/$(*)/libs.txt` \
		$(EMFTFLAGS) -gsource-map $(ES6FLAGS) \
		-o $(@).d/libav-$(LIBAVJS_VERSION)-$(*).dbg.wasm.mjs
	if [ -e $(@).d/libav-$(LIBAVJS_VERSION)-$(*).dbg.wasm.wasm.map ] ; then \
		./tools/adjust-sourcemap.js $(@).d/libav-$(LIBAVJS_VERSION)-$(*).dbg.wasm.wasm.map \
			ffmpeg $(FFMPEG_VERSION) \
			libvpx $(LIBVPX_VERSION) \
			libaom $(LIBAOM_VERSION); \
	fi || ( rm -f $(@) ; false )
	sed " \
		s/^\/\/.*include:.*// ; \
		s/@VER/$(LIBAVJS_VERSION)/g ; \
		s/@VARIANT/$(*)/g ; \
		s/@TARGET/wasm/g ; \
		s/@DBG/dbg./g ; \
		s/@JS/mjs/g \
	" $(@).d/libav-$(LIBAVJS_VERSION)-$(*).dbg.wasm.mjs | tools/license-header.sh configs/configs/$(*)/license.js > $(@)
	rm -f $(@).d/libav-$(LIBAVJS_VERSION)-$(*).dbg.wasm.mjs
	-chmod a-x $(@).d/*.wasm
	-mv $(@).d/* dist/
	rmdir $(@).d

# wasm + threads

dist/libav-$(LIBAVJS_VERSION)-%.thr.js: build/ffmpeg-$(FFMPEG_VERSION)/build-thr-%/libavformat/libavformat.a \
	build/exports.json pre.js build/post.js extern-post.js bindings.c
	mkdir -p $(@).d
	$(EMCC) $(OPTFLAGS) $(EFLAGS) \
		-Ibuild/ffmpeg-$(FFMPEG_VERSION) -Ibuild/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*) \
		`test ! -e configs/configs/$(*)/link-flags.txt || cat configs/configs/$(*)/link-flags.txt` \
		bindings.c \
		`grep LIBAVJS_WITH_CLI configs/configs/$(*)/link-flags.txt > /dev/null 2>&1 && echo ' \
		build/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*)/fftools/*.o \
		-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*)/libavdevice -lavdevice \
		'` \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*)/libavutil/libavutil.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*)/libavutil -lavutil \
	'` \
 \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*)/libavformat/libavformat.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*)/libavformat -lavformat \
	'` \
 \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*)/libavcodec/libavcodec.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*)/libavcodec -lavcodec \
	'` \
 \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*)/libavfilter/libavfilter.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*)/libavfilter -lavfilter \
	'` \
 \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*)/libswresample/libswresample.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*)/libswresample -lswresample \
	'` \
 \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*)/libswscale/libswscale.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*)/libswscale -lswscale \
	'` \
 \
		`test ! -e configs/configs/$(*)/libs.txt || sed 's/@TARGET/thr/' configs/configs/$(*)/libs.txt` \
		$(THRFLAGS) -sPTHREAD_POOL_SIZE=navigator.hardwareConcurrency \
		-o $(@).d/libav-$(LIBAVJS_VERSION)-$(*).thr.js
	if [ -e $(@).d/libav-$(LIBAVJS_VERSION)-$(*).thr.wasm.map ] ; then \
		./tools/adjust-sourcemap.js $(@).d/libav-$(LIBAVJS_VERSION)-$(*).thr.wasm.map \
			ffmpeg $(FFMPEG_VERSION) \
			libvpx $(LIBVPX_VERSION) \
			libaom $(LIBAOM_VERSION); \
	fi || ( rm -f $(@) ; false )
	sed " \
		s/^\/\/.*include:.*// ; \
		s/@VER/$(LIBAVJS_VERSION)/g ; \
		s/@VARIANT/$(*)/g ; \
		s/@TARGET/thr/g ; \
		s/@DBG//g ; \
		s/@JS/js/g \
	" $(@).d/libav-$(LIBAVJS_VERSION)-$(*).thr.js | tools/license-header.sh configs/configs/$(*)/license.js > $(@)
	rm -f $(@).d/libav-$(LIBAVJS_VERSION)-$(*).thr.js
	-chmod a-x $(@).d/*.wasm
	-mv $(@).d/* dist/
	rmdir $(@).d


dist/libav-$(LIBAVJS_VERSION)-%.thr.mjs: build/ffmpeg-$(FFMPEG_VERSION)/build-thr-%/libavformat/libavformat.a \
	build/exports.json pre.js build/post.js extern-post.js bindings.c
	mkdir -p $(@).d
	$(EMCC) $(OPTFLAGS) $(EFLAGS) \
		-Ibuild/ffmpeg-$(FFMPEG_VERSION) -Ibuild/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*) \
		`test ! -e configs/configs/$(*)/link-flags.txt || cat configs/configs/$(*)/link-flags.txt` \
		bindings.c \
		`grep LIBAVJS_WITH_CLI configs/configs/$(*)/link-flags.txt > /dev/null 2>&1 && echo ' \
		build/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*)/fftools/*.o \
		-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*)/libavdevice -lavdevice \
		'` \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*)/libavutil/libavutil.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*)/libavutil -lavutil \
	'` \
 \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*)/libavformat/libavformat.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*)/libavformat -lavformat \
	'` \
 \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*)/libavcodec/libavcodec.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*)/libavcodec -lavcodec \
	'` \
 \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*)/libavfilter/libavfilter.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*)/libavfilter -lavfilter \
	'` \
 \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*)/libswresample/libswresample.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*)/libswresample -lswresample \
	'` \
 \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*)/libswscale/libswscale.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*)/libswscale -lswscale \
	'` \
 \
		`test ! -e configs/configs/$(*)/libs.txt || sed 's/@TARGET/thr/' configs/configs/$(*)/libs.txt` \
		$(ES6FLAGS) $(THRFLAGS) -sPTHREAD_POOL_SIZE=navigator.hardwareConcurrency \
		-o $(@).d/libav-$(LIBAVJS_VERSION)-$(*).thr.mjs
	if [ -e $(@).d/libav-$(LIBAVJS_VERSION)-$(*).thr.wasm.map ] ; then \
		./tools/adjust-sourcemap.js $(@).d/libav-$(LIBAVJS_VERSION)-$(*).thr.wasm.map \
			ffmpeg $(FFMPEG_VERSION) \
			libvpx $(LIBVPX_VERSION) \
			libaom $(LIBAOM_VERSION); \
	fi || ( rm -f $(@) ; false )
	sed " \
		s/^\/\/.*include:.*// ; \
		s/@VER/$(LIBAVJS_VERSION)/g ; \
		s/@VARIANT/$(*)/g ; \
		s/@TARGET/thr/g ; \
		s/@DBG//g ; \
		s/@JS/mjs/g \
	" $(@).d/libav-$(LIBAVJS_VERSION)-$(*).thr.mjs | tools/license-header.sh configs/configs/$(*)/license.js > $(@)
	rm -f $(@).d/libav-$(LIBAVJS_VERSION)-$(*).thr.mjs
	-chmod a-x $(@).d/*.wasm
	-mv $(@).d/* dist/
	rmdir $(@).d


dist/libav-$(LIBAVJS_VERSION)-%.dbg.thr.js: build/ffmpeg-$(FFMPEG_VERSION)/build-thr-%/libavformat/libavformat.a \
	build/exports.json pre.js build/post.js extern-post.js bindings.c
	mkdir -p $(@).d
	$(EMCC) $(OPTFLAGS) $(EFLAGS) \
		-Ibuild/ffmpeg-$(FFMPEG_VERSION) -Ibuild/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*) \
		`test ! -e configs/configs/$(*)/link-flags.txt || cat configs/configs/$(*)/link-flags.txt` \
		bindings.c \
		`grep LIBAVJS_WITH_CLI configs/configs/$(*)/link-flags.txt > /dev/null 2>&1 && echo ' \
		build/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*)/fftools/*.o \
		-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*)/libavdevice -lavdevice \
		'` \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*)/libavutil/libavutil.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*)/libavutil -lavutil \
	'` \
 \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*)/libavformat/libavformat.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*)/libavformat -lavformat \
	'` \
 \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*)/libavcodec/libavcodec.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*)/libavcodec -lavcodec \
	'` \
 \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*)/libavfilter/libavfilter.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*)/libavfilter -lavfilter \
	'` \
 \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*)/libswresample/libswresample.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*)/libswresample -lswresample \
	'` \
 \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*)/libswscale/libswscale.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*)/libswscale -lswscale \
	'` \
 \
		`test ! -e configs/configs/$(*)/libs.txt || sed 's/@TARGET/thr/' configs/configs/$(*)/libs.txt` \
		-gsource-map $(THRFLAGS) -sPTHREAD_POOL_SIZE=navigator.hardwareConcurrency \
		-o $(@).d/libav-$(LIBAVJS_VERSION)-$(*).dbg.thr.js
	if [ -e $(@).d/libav-$(LIBAVJS_VERSION)-$(*).dbg.thr.wasm.map ] ; then \
		./tools/adjust-sourcemap.js $(@).d/libav-$(LIBAVJS_VERSION)-$(*).dbg.thr.wasm.map \
			ffmpeg $(FFMPEG_VERSION) \
			libvpx $(LIBVPX_VERSION) \
			libaom $(LIBAOM_VERSION); \
	fi || ( rm -f $(@) ; false )
	sed " \
		s/^\/\/.*include:.*// ; \
		s/@VER/$(LIBAVJS_VERSION)/g ; \
		s/@VARIANT/$(*)/g ; \
		s/@TARGET/thr/g ; \
		s/@DBG/dbg./g ; \
		s/@JS/js/g \
	" $(@).d/libav-$(LIBAVJS_VERSION)-$(*).dbg.thr.js | tools/license-header.sh configs/configs/$(*)/license.js > $(@)
	rm -f $(@).d/libav-$(LIBAVJS_VERSION)-$(*).dbg.thr.js
	-chmod a-x $(@).d/*.wasm
	-mv $(@).d/* dist/
	rmdir $(@).d


dist/libav-$(LIBAVJS_VERSION)-%.dbg.thr.mjs: build/ffmpeg-$(FFMPEG_VERSION)/build-thr-%/libavformat/libavformat.a \
	build/exports.json pre.js build/post.js extern-post.js bindings.c
	mkdir -p $(@).d
	$(EMCC) $(OPTFLAGS) $(EFLAGS) \
		-Ibuild/ffmpeg-$(FFMPEG_VERSION) -Ibuild/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*) \
		`test ! -e configs/configs/$(*)/link-flags.txt || cat configs/configs/$(*)/link-flags.txt` \
		bindings.c \
		`grep LIBAVJS_WITH_CLI configs/configs/$(*)/link-flags.txt > /dev/null 2>&1 && echo ' \
		build/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*)/fftools/*.o \
		-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*)/libavdevice -lavdevice \
		'` \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*)/libavutil/libavutil.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*)/libavutil -lavutil \
	'` \
 \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*)/libavformat/libavformat.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*)/libavformat -lavformat \
	'` \
 \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*)/libavcodec/libavcodec.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*)/libavcodec -lavcodec \
	'` \
 \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*)/libavfilter/libavfilter.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*)/libavfilter -lavfilter \
	'` \
 \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*)/libswresample/libswresample.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*)/libswresample -lswresample \
	'` \
 \
		 \
	`test ! -e build/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*)/libswscale/libswscale.a || echo ' \
	-Lbuild/ffmpeg-$(FFMPEG_VERSION)/build-thr-$(*)/libswscale -lswscale \
	'` \
 \
		`test ! -e configs/configs/$(*)/libs.txt || sed 's/@TARGET/thr/' configs/configs/$(*)/libs.txt` \
		-gsource-map $(ES6FLAGS) $(THRFLAGS) -sPTHREAD_POOL_SIZE=navigator.hardwareConcurrency \
		-o $(@).d/libav-$(LIBAVJS_VERSION)-$(*).dbg.thr.mjs
	if [ -e $(@).d/libav-$(LIBAVJS_VERSION)-$(*).dbg.thr.wasm.map ] ; then \
		./tools/adjust-sourcemap.js $(@).d/libav-$(LIBAVJS_VERSION)-$(*).dbg.thr.wasm.map \
			ffmpeg $(FFMPEG_VERSION) \
			libvpx $(LIBVPX_VERSION) \
			libaom $(LIBAOM_VERSION); \
	fi || ( rm -f $(@) ; false )
	sed " \
		s/^\/\/.*include:.*// ; \
		s/@VER/$(LIBAVJS_VERSION)/g ; \
		s/@VARIANT/$(*)/g ; \
		s/@TARGET/thr/g ; \
		s/@DBG/dbg./g ; \
		s/@JS/mjs/g \
	" $(@).d/libav-$(LIBAVJS_VERSION)-$(*).dbg.thr.mjs | tools/license-header.sh configs/configs/$(*)/license.js > $(@)
	rm -f $(@).d/libav-$(LIBAVJS_VERSION)-$(*).dbg.thr.mjs
	-chmod a-x $(@).d/*.wasm
	-mv $(@).d/* dist/
	rmdir $(@).d


build/libav-$(LIBAVJS_VERSION).js: libav.in.js libav.types.in.d.ts post.in.js funcs.json tools/apply-funcs.js
	mkdir -p build dist
	./tools/apply-funcs.js $(LIBAVJS_VERSION)

build/libav.types.d.ts build/libav-$(LIBAVJS_VERSION).in.mjs build/exports.json build/post.js: build/libav-$(LIBAVJS_VERSION).js
	touch $@

build/libav-$(LIBAVJS_VERSION).mjs: build/libav-$(LIBAVJS_VERSION).in.mjs
	./tools/mk-es6.js ../build/libav-$(LIBAVJS_VERSION).js $< > $@

node_modules/.bin/terser:
	npm install

# Targets
build/inst/base/cflags.txt:
	mkdir -p build/inst/base
	echo -gsource-map > $@

build/inst/thr/cflags.txt:
	mkdir -p build/inst/thr
	echo -pthread -gsource-map > $@

RELEASE_VARIANTS=\
	sink

release: extract
	mkdir -p dist/release
	mkdir dist/release/libav.js-$(LIBAVJS_VERSION)
	cp -a README.md docs dist/release/libav.js-$(LIBAVJS_VERSION)/
	mkdir dist/release/libav.js-$(LIBAVJS_VERSION)/dist
	for v in $(RELEASE_VARIANTS); \
	do \
		$(MAKE) build-$$v; \
		$(MAKE) release-$$v; \
		cp dist/libav-$(LIBAVJS_VERSION)-$$v.* \
			dist/libav-$$v.* \
			dist/release/libav.js-$(LIBAVJS_VERSION)/dist; \
	done
	cp dist/libav.types.d.ts dist/release/libav.js-$(LIBAVJS_VERSION)/dist/
	mkdir dist/release/libav.js-$(LIBAVJS_VERSION)/sources
	for t in ffmpeg emfiberthreads lame libaom libogg libvorbis libvpx opus zlib; \
	do \
		$(MAKE) $$t-release; \
	done
	git archive HEAD -o dist/release/libav.js-$(LIBAVJS_VERSION)/sources/libav.js.tar
	xz dist/release/libav.js-$(LIBAVJS_VERSION)/sources/libav.js.tar
	cd dist/release && zip -r libav.js-$(LIBAVJS_VERSION).zip libav.js-$(LIBAVJS_VERSION)
	rm -rf dist/release/libav.js-$(LIBAVJS_VERSION)

release-%: dist/release/libav.js-$(LIBAVJS_VERSION)-%
	true

dist/release/libav.js-$(LIBAVJS_VERSION)-%: build-%
	mkdir -p $(@)/dist
	cp dist/libav-$(LIBAVJS_VERSION)-$(*).* \
		dist/libav-$(*).* \
		dist/libav.types.d.ts \
		$(@)/dist
	rm -f $(@)/dist/*.dbg.*
	sed 's/@VARIANT/$(*)/g ; s/@VERSION/$(LIBAVJS_VERSION)/g ; s/@VER/$(LIBAVJS_VERSION_SHORT)/g' \
		package-one-variant.json > $(@)/package.json

npm-publish:
	cd dist/release && unzip libav.js-$(LIBAVJS_VERSION).zip
	cd dist/release/libav.js-$(LIBAVJS_VERSION) && \
	  cp ../../../package.json . && \
	  rm -f dist/*.dbg.* dist/*-av1* dist/*-vp9* dist/*.asm.mjs 
	rm -rf dist/release/libav.js-$(LIBAVJS_VERSION)
	for v in $(RELEASE_VARIANTS); \
	do \
		( cd dist/release/libav.js-$(LIBAVJS_VERSION)-$$v && npm publish --access=public ) \
	done

halfclean:
	-rm -rf dist/
	-rm -f build/exports.json build/libav-$(LIBAVJS_VERSION).js build/post.js

clean: halfclean
	-rm -rf build/inst
	-rm -rf build/emfiberthreads
	-rm -rf build/opus-$(OPUS_VERSION)
	-rm -rf build/libaom-$(LIBAOM_VERSION)
	-rm -rf build/libvorbis-$(LIBVORBIS_VERSION)
	-rm -rf build/libogg-$(LIBOGG_VERSION)
	-rm -rf build/libvpx-$(LIBVPX_VERSION)
	-rm -rf build/lame-$(LAME_VERSION)
	-rm -rf build/openh264-$(OPENH264_VERSION)
	-rm -rf build/ffmpeg-$(FFMPEG_VERSION)
	-rm -rf build/zlib-$(ZLIB_VERSION)

distclean: clean
	-rm -rf build/

print-version:
	@printf '%s\n' "$(LIBAVJS_VERSION)"

.PRECIOUS: \
	build/ffmpeg-$(FFMPEG_VERSION)/build-%/libavformat/libavformat.a \
	dist/libav.types.d.ts \
	dist/libav-$(LIBAVJS_VERSION)-%.js \
	dist/libav-%.js \
	dist/libav-$(LIBAVJS_VERSION)-%.mjs \
	dist/libav-%.mjs \
	dist/libav-$(LIBAVJS_VERSION)-%.dbg.js \
	dist/libav-%.dbg.js \
	dist/libav-$(LIBAVJS_VERSION)-%.dbg.mjs \
	dist/libav-%.dbg.mjs \
	dist/libav-$(LIBAVJS_VERSION)-%.asm.js \
	dist/libav-$(LIBAVJS_VERSION)-%.asm.mjs \
	dist/libav-$(LIBAVJS_VERSION)-%.dbg.asm.js \
	dist/libav-$(LIBAVJS_VERSION)-%.dbg.asm.mjs \
	dist/libav-$(LIBAVJS_VERSION)-%.wasm.js \
	dist/libav-$(LIBAVJS_VERSION)-%.wasm.mjs \
	dist/libav-$(LIBAVJS_VERSION)-%.dbg.wasm.js \
	dist/libav-$(LIBAVJS_VERSION)-%.dbg.wasm.mjs \
	dist/libav-$(LIBAVJS_VERSION)-%.thr.js \
	dist/libav-$(LIBAVJS_VERSION)-%.thr.mjs \
	dist/libav-$(LIBAVJS_VERSION)-%.dbg.thr.js \
	dist/libav-$(LIBAVJS_VERSION)-%.dbg.thr.mjs
