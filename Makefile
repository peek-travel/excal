CFLAGS = -O3 -Wall

ERLANG_PATH = $(shell erl -eval 'io:format("~s", [lists:concat([code:root_dir(), "/erts-", erlang:system_info(version), "/include"])])' -s init stop -noshell)
CFLAGS += -I$(ERLANG_PATH)

ifneq ($(OS),Windows_NT)
	CFLAGS += -fPIC

	ifeq ($(shell uname),Darwin)
		LDFLAGS += -dynamiclib -undefined dynamic_lookup
	endif
endif

SOURCE_FILES = src/recurrence/iterator.c
LIBRARY_DIRECTORY = priv/recurrence
LIBRARY = $(LIBRARY_DIRECTORY)/iterator.so

all: $(SOURCE_FILES) $(LIBRARY)

$(LIBRARY): $(LIBRARY_DIRECTORY)
	$(CC) $(CFLAGS) -shared -o $(LIBRARY) $(SOURCE_FILES) -lical $(LDFLAGS)

$(LIBRARY_DIRECTORY):
	mkdir -p priv/recurrence

clean:
	rm  -r "priv/recurrence/iterator.so"
