ERLANG_PATH = $(shell erl -eval 'io:format("~s", [lists:concat([code:root_dir(), "/erts-", erlang:system_info(version), "/include"])])' -s init stop -noshell)

all:
	cc -fPIC -I"$(ERLANG_PATH)" -undefined dynamic_lookup -dynamiclib -lical -o priv/recurrence/iterator.so src/recurrence/iterator.c

clean:
	rm  -r "priv/recurrence/iterator.so"
