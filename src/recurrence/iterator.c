#include <stdio.h>
#include <string.h>
#include "libical/ical.h"
#include "erl_nif.h"

typedef struct
{
  icalrecur_iterator *iterator;
} IteratorResource;

ErlNifResourceType *EXCAL_RECUR_ITERATOR_RES_TYPE;

void recurrence_iterator_free(ErlNifEnv *env, void *res)
{
  icalrecur_iterator *iterator = ((IteratorResource *)res)->iterator;
  icalrecur_iterator_free(iterator);
}

int load(ErlNifEnv *env, void **priv_data, ERL_NIF_TERM load_info)
{
  int flags = ERL_NIF_RT_CREATE | ERL_NIF_RT_TAKEOVER;
  EXCAL_RECUR_ITERATOR_RES_TYPE = enif_open_resource_type(env, NULL, "IteratorResource", recurrence_iterator_free, flags, NULL);

  return 0;
}

int upgrade(ErlNifEnv *env, void **priv_data, void **old_priv_data, ERL_NIF_TERM load_info)
{
  return 0;
}

static ERL_NIF_TERM
icaltime_to_erl_datetime(ErlNifEnv *env, struct icaltimetype datetime)
{
  return enif_make_tuple2(
      env,
      enif_make_tuple3(
          env,
          enif_make_int(env, datetime.year),
          enif_make_int(env, datetime.month),
          enif_make_int(env, datetime.day)),
      enif_make_tuple3(
          env,
          enif_make_int(env, datetime.hour),
          enif_make_int(env, datetime.minute),
          enif_make_int(env, datetime.second)));
}

static ERL_NIF_TERM
icaltime_to_erl_date(ErlNifEnv *env, struct icaltimetype date)
{
  return enif_make_tuple3(
      env,
      enif_make_int(env, date.year),
      enif_make_int(env, date.month),
      enif_make_int(env, date.day));
}

static ERL_NIF_TERM
make_error_tuple(ErlNifEnv *env, const char *error)
{
  return enif_make_tuple2(env, enif_make_atom(env, "error"), enif_make_atom(env, error));
}

static ERL_NIF_TERM
make_ok_tuple(ErlNifEnv *env, ERL_NIF_TERM output)
{
  return enif_make_tuple2(env, enif_make_atom(env, "ok"), output);
}

static ERL_NIF_TERM
make_nil(ErlNifEnv *env)
{
  return enif_make_atom(env, "nil");
}

int get_iterator(ErlNifEnv *env, ERL_NIF_TERM arg, icalrecur_iterator **iterator)
{
  // read arg as iterator resource
  IteratorResource *iterator_resource;
  if (!enif_get_resource(env, arg, EXCAL_RECUR_ITERATOR_RES_TYPE, (void **)&iterator_resource))
  {
    return 0;
  }

  // get the ical iterator from the resource struct
  (*iterator) = iterator_resource->iterator;

  return 1;
}

int get_string_from_binary(ErlNifEnv *env, ERL_NIF_TERM arg, char **output)
{
  // read arg as binary
  ErlNifBinary binary;
  if (!enif_inspect_iolist_as_binary(env, arg, &binary))
  {
    // argument was not a binary
    return 0;
  }

  // copy binary to local string
  (*output) = strndup((char *)binary.data, binary.size);

  return 1;
}

static ERL_NIF_TERM
recurrence_iterator_new(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
  char *rrule_string;
  if (argc < 1 || !get_string_from_binary(env, argv[0], &rrule_string))
  {
    return enif_make_badarg(env);
  }

  char *dtstart_string;
  if (argc < 2 || !get_string_from_binary(env, argv[1], &dtstart_string))
  {
    return enif_make_badarg(env);
  }

  // make the start time struct from the dtstart string
  // TODO: timezones?
  struct icaltimetype dtstart = icaltime_from_string(dtstart_string);
  if (icaltime_is_null_time(dtstart))
  {
    return make_error_tuple(env, "invalid_dtstart");
  }

  // make the recurrence struct from the rrule string
  icalerror_set_errno(ICAL_NO_ERROR); // reset error first
  struct icalrecurrencetype recur = icalrecurrencetype_from_string(rrule_string);
  if (icalerrno == ICAL_MALFORMEDDATA_ERROR || icalerrno == ICAL_NEWFAILED_ERROR)
  {
    return make_error_tuple(env, "invalid_rrule");
  }

  // initialize the iterator
  icalrecur_iterator *iterator = icalrecur_iterator_new(recur, dtstart);
  if (iterator == 0)
  {
    // not sure if this is even possible
    return make_error_tuple(env, "bad_iterator");
  }

  // wrap the iterator in a resource struct
  IteratorResource *iterator_resource = enif_alloc_resource(EXCAL_RECUR_ITERATOR_RES_TYPE, sizeof(IteratorResource));
  iterator_resource->iterator = iterator;

  // convert to erlang resource term and release to erlang memory management
  ERL_NIF_TERM iterator_term = enif_make_resource(env, iterator_resource);
  enif_release_resource(iterator_resource);

  // return {:ok, iterator}
  return make_ok_tuple(env, iterator_term);
}

static ERL_NIF_TERM
recurrence_iterator_set_start(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
  // get iterator arg
  icalrecur_iterator *iterator;
  if (argc < 1 || !get_iterator(env, argv[0], &iterator))
  {
    return enif_make_badarg(env);
  }

  // get start string arg
  char *start_string;
  if (argc < 2 || !get_string_from_binary(env, argv[1], &start_string))
  {
    return enif_make_badarg(env);
  }

  // build start from start_string
  // TODO: timezones?
  struct icaltimetype start = icaltime_from_string(start_string);
  if (icaltime_is_null_time(start))
  {
    return make_error_tuple(env, "invalid_start");
  }

  // set iterator start
  if (icalrecur_iterator_set_start(iterator, start))
  {
    // return :ok
    return enif_make_atom(env, "ok");
  }
  else
  {
    // you can't set start on rules that use COUNT
    // return {:error, :invalid_start}
    return make_error_tuple(env, "start_invalid_for_rule");
  }
}

static ERL_NIF_TERM
recurrence_iterator_next(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
  // get iterator arg
  icalrecur_iterator *iterator;
  if (argc < 1 || !get_iterator(env, argv[0], &iterator))
  {
    return enif_make_badarg(env);
  }

  // get next occurrence
  icaltimetype occurrence = icalrecur_iterator_next(iterator);

  // make response, either nil, a date, or a datetime
  ERL_NIF_TERM occurrence_term;
  if (icaltime_is_null_time(occurrence))
  {
    occurrence_term = make_nil(env);
  }
  else if (occurrence.is_date)
  {
    occurrence_term = icaltime_to_erl_date(env, occurrence);
  }
  else
  {
    occurrence_term = icaltime_to_erl_datetime(env, occurrence);
  }

  // return occurrence
  return occurrence_term;
}

static ErlNifFunc nif_funcs[] = {
    {"new", 2, recurrence_iterator_new},
    {"set_start", 2, recurrence_iterator_set_start},
    {"next", 1, recurrence_iterator_next}};

ERL_NIF_INIT(Elixir.Excal.Interface.Recurrence.Iterator, nif_funcs, &load, NULL, &upgrade, NULL)
