BIN := bin

LUA := $(shell find ./src -type f -name '*.lua')
LUA_OUT := $(addprefix $(BIN)/,$(LUA))

all: elona-next

elona-next: $(BIN) $(LUA_OUT) $(BIN)/bin/love $(BIN)/elona-next

$(BIN)/%.lua: %.lua
	@mkdir -p "$(@D)"
	cp "$<" "$@"

$(BIN)/bin/love: lib/love/Makefile
	cd lib/love && \
	$(MAKE) && \
	$(MAKE) install

lib/love/Makefile:
	cd lib/love && \
	./platform/unix/automagic && \
	./configure --disable-love-physics --disable-library-enet --prefix $(PWD)/$(BIN)

$(BIN):
	mkdir -p $(BIN)/

$(BIN)/elona-next: runtime/elona-next
	cp runtime/elona-next $(BIN)/

clean:
	rm -r $(BIN)/

FORCE: ;

.PHONY: all clean
