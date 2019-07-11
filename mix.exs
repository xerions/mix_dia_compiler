defmodule MixDiaCompiler.Mixfile do
  use Mix.Project

  def project do
    [app: :mix_dia_compiler,
     version: "0.2.0",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     description: description(),
     package: package()]
  end

  def application do
    [applications: []]
  end

  defp deps do
    []
  end

  defp description do
    """
    Diameter source files compiler for Mix and Elixir.
    """
  end

  defp package do
    [name: :mix_dia_compiler,
     files: ["lib", "mix.exs", "README.md", "LICENSE"],
     maintainers: ["Yury Gargay"],
     licenses: ["MPL 2.0"],
     links: %{"GitHub" => "https://github.com/xerions/mix_dia_compiler"}]
  end
end
