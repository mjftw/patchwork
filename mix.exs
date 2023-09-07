defmodule Patchwork.MixProject do
  use Mix.Project

  def project do
    [
      app: :patchwork,
      version: "0.1.0",
      elixir: "~> 1.14",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      name: "Patchwork",
      source_url: "https://github.com/mjftw/patchwork"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description() do
    "Patchwork is a library for calculating the difference between two data structures, and applying that difference as a patch. Think git patches for for Elixir data structures."
  end

  defp package do
    [
      # These are the default files included in the package
      files: ~w(lib .formatter.exs mix.exs README* LICENSE* CHANGELOG*),
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/mjftw/patchwork"}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:stream_data, "~> 0.6", only: [:test, :dev]},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end
end
