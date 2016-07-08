# MixDiaCompiler [![Build Status](https://travis-ci.org/xerions/mix_dia_compiler.svg?branch=master)](https://travis-ci.org/xerions/mix_dia_compiler)

A Diameter source files compiler for mix. It was inspired by `rebar_dia_compiler` and it should work the same way expect `dia_first_files` option.

There are some unresolved questions:

  1. Diameter sources have the inherits and it requires the correct file order. If b inherits a then a should be compiled before b. In rebar_dia_compiler it is solved by dia_first_files but it is not possible to add that kind of option to this compile so I may suggest to use alphabetic order to naming dia sources for now.

  2. Diameter compiler generates erl and hrl file. It is possible in Elixir to work with records from hrl file but I don't know a good way to work with defined constants.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add mix_dia_compiler to your list of dependencies in `mix.exs`:

        def deps do
          [{:mix_dia_compiler, "~> 0.1.0"}]
        end

  2. Add `:dia` to compilers:

        def application do
          compilers: [:dia, :erlang, :elixir, :app],
        end
