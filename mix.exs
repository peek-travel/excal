defmodule Excal.MixProject do
  use Mix.Project

  @version "0.3.0"
  @source_url "https://github.com/peek-travel/excal"

  def project do
    [
      app: :excal,
      compilers: [:elixir_make] ++ Mix.compilers(),
      version: @version,
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      docs: docs(),
      source_url: @source_url,
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test],
      make_clean: ["clean"]
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
      {:benchee, "~> 0.13", only: :dev, runtime: false},
      {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0.0-rc.4", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.18", only: :dev, runtime: false},
      {:excoveralls, "~> 0.9", only: :test, runtime: false},
      {:elixir_make, "~> 0.4", runtime: false}
    ]
  end
end
