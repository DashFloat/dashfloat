defmodule DashFloat.MixProject do
  use Mix.Project

  def project do
    [
      app: :dashfloat,
      version: "0.0.0",
      elixir: "1.15.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {DashFloat.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:dns_cluster, "0.1.1"},
      {:ecto_sql, "3.10.2"},
      {:esbuild, "0.7.1", runtime: Mix.env() == :dev},
      {:finch, "0.16.0"},
      {:floki, "0.35.2", only: :test},
      {:gettext, "0.23.1"},
      {:jason, "1.4.1"},
      {:phoenix, "1.7.9"},
      {:phoenix_ecto, "4.4.2"},
      {:phoenix_html, "3.3.3"},
      {:phoenix_live_dashboard, "0.8.2"},
      {:phoenix_live_reload, "1.4.1", only: :dev},
      {:phoenix_live_view, "0.20.1"},
      {:plug_cowboy, "2.6.1"},
      {:postgrex, "0.17.3"},
      {:swoosh, "1.14.0"},
      {:tailwind, "0.2.1", runtime: Mix.env() == :dev},
      {:telemetry_metrics, "0.6.1"},
      {:telemetry_poller, "1.0.0"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.drop --quiet", "ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind default", "esbuild default"],
      "assets.deploy": ["tailwind default --minify", "esbuild default --minify", "phx.digest"]
    ]
  end
end