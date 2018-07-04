# Excal
[![Build Status](https://travis-ci.com/peek-travel/excal.svg?branch=master)](https://travis-ci.org/peek-travel/excal) [![codecov](https://codecov.io/gh/peek-travel/excal/branch/master/graph/badge.svg)](https://codecov.io/gh/peek-travel/excal) [![Hex.pm Version](https://img.shields.io/hexpm/v/excal.svg?style=flat)](https://hex.pm/packages/excal) [![License](https://img.shields.io/hexpm/l/excal.svg)](LICENSE.md)

NIF bindings to [libical](https://libical.github.io/libical/) for Elixir.

This library is a **WIP**!

## Requirements

Excal requires that libical be present on your system, and that it's the very latest version. This effectively means that
you need to build it from source. I'll include instructions on how to accomplish this soon.

## Installation

The package can be installed by adding `excal` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:excal, "~> 0.1.0"}
  ]
end
```

Documentation can be found at [https://hexdocs.pm/excal](https://hexdocs.pm/excal).
