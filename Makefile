$(shell mkdir -p priv/recurrence)

CFLAGS = -O3 -Wall

ERLANG_PATH = $(shell erl -eval 'io:format("~s", [lists:concat([code:root_dir(), "/erts-", erlang:system_info(version), "/include"])])' -s init stop -noshell)
CFLAGS += -I$(ERLANG_PATH)

ifneq ($(OS),Windows_NT)
	CFLAGS += -fPIC

	ifeq ($(shell uname),Darwin)
		LDFLAGS += -dynamiclib -undefined dynamic_lookup
	endif
endif

all:
	$(CC) $(CFLAGS) -shared -o priv/recurrence/iterator.so src/recurrence/iterator.c -lical $(LDFLAGS)

clean:
	rm  -r "priv/recurrence/iterator.so"
