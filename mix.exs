defmodule Excal.MixProject do
  use Mix.Project

  @version "0.3.2"
  @source_url "https://github.com/peek-travel/excal"

  def project do
    [
      app: :excal,
      compilers: [:elixir_make] ++ Mix.compilers(),
      version: @version,
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      docs: docs(),
      source_url: @source_url,
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: preferred_cli_env(),
      make_clean: ["clean"],
      dialyzer: dialyzer()
    ]
  end

  defp dialyzer do
    [
      plt_add_deps: :app_tree,
      plt_file: {:no_warn, "priv/plts/excal.plt"}
    ]
  end

  defp preferred_cli_env do
    [
      coveralls: :test,
      "coveralls.html": :test,
      "coveralls.json": :test
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description do
    """
    NIF bindings to libical providing icalendar rrule expansion.
    """
  end

  defp package do
    [
      files: ["lib", ".formatter.exs", "mix.exs", "README.md", "LICENSE.md", "CHANGELOG.md", "src", "Makefile"],
      maintainers: ["Chris Dosé <chris.dose@gmail.com>"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "Readme" => "#{@source_url}/blob/#{@version}/README.md",
        "Changelog" => "#{@source_url}/blob/#{@version}/CHANGELOG.md"
      }
    ]
  end

  defp docs do
    [
      main: "Excal",
      source_ref: @version,
      source_url: @source_url,
      extras: ["README.md", "LICENSE.md"],
      groups_for_modules: [
        Recurrence: [Excal.Recurrence.Iterator, Excal.Recurrence.Stream]
      ]
    ]
  end

  defp deps do
    [
      {:benchee, "~> 1.0", only: :dev, runtime: false},
      {:credo, "~> 1.1", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.1.0", only: [:dev, :test], runtime: false},
      {:elixir_make, "~> 0.6", runtime: false},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:excoveralls, "~> 0.12", only: :test, runtime: false}
    ]
  end
end
