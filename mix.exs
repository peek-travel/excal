defmodule Mix.Tasks.Compile.Excal do
  def run(_args) do
    {result, _errcode} = System.cmd("make", [])
    IO.binwrite(result)
  end
end

defmodule Excal.MixProject do
  use Mix.Project

  def project do
    [
      app: :excal,
      compilers: [:excal] ++ Mix.compilers(),
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test]
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
      maintainers: ["Chris Dosé <chris.dose@gmail.com>"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/peek-travel/excal"
      }
    ]
  end

  defp deps do
    [
      {:benchee, "~> 0.13", only: :dev, runtime: false},
      {:credo, "~> 0.9", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.9", only: :test, runtime: false},
      {:ex_doc, "~> 0.18", only: :dev, runtime: false}
    ]
  end
end
