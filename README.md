# Excal

[![Build Status](https://travis-ci.com/peek-travel/excal.svg?branch=master)](https://travis-ci.org/peek-travel/excal)
[![codecov](https://codecov.io/gh/peek-travel/excal/branch/master/graph/badge.svg)](https://codecov.io/gh/peek-travel/excal)
[![Ebert](https://ebertapp.io/github/peek-travel/excal.svg)](https://ebertapp.io/github/peek-travel/excal)
[![Hex.pm Version](https://img.shields.io/hexpm/v/excal.svg?style=flat)](https://hex.pm/packages/excal)
[![License](https://img.shields.io/hexpm/l/excal.svg)](LICENSE.md)
[![Dependabot Status](https://api.dependabot.com/badges/status?host=github&repo=peek-travel/excal)](https://dependabot.com)
[![Inline docs](http://inch-ci.org/github/peek-travel/excal.svg)](http://inch-ci.org/github/peek-travel/excal)

NIF bindings to [libical](https://libical.github.io/libical/) for Elixir.

This library is still a **WIP**, but works well for basic calls to libical's recurrence iterators.

## Requirements

Excal requires that libical (and its development headers) be present on your system, and that it's at least version 3.0.0.

### macOS

You can easily install `libical` using [Homebrew](https://brew.sh/) on macOS:

```sh
brew install libical
```

Homebrew provides the latest version, as of this writing, which is `3.0.4`.

### linux

Use favorite package manager to install `libical` (may be named slightly differently depending on distro), or maybe `libical-dev` if you're using a Debian based distro like Ubuntu.

NOTE: Make sure you're getting at least version `3.0.0`. Anything below will prevent Excal from compiling.

### Windows

I'm not currently aware of how to get this working on Windows, but if someone wants to try and let me know how, I will add instructions to this readme.

## Installation

The package can be installed by adding `excal` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:excal, "~> 0.3.0"}
  ]
end
```

Documentation can be found at [https://hexdocs.pm/excal](https://hexdocs.pm/excal).
