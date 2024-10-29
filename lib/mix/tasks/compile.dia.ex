defmodule Mix.Tasks.Compile.Dia do
  use Mix.Task
  alias Mix.Compilers.Erlang
  alias :filelib, as: Filelib
  alias :diameter_dict_util, as: DiaDictUtil
  alias :diameter_codegen, as: DiaCodegen

  @recursive true
  @manifest ".compile.dia"

  @moduledoc """
  Compiles Diameter source files.

  ## Command line options

  There are no command line options.

  ## Configuration

    * `:erlc_paths` - directories to find source files. Defaults to `["src"]`.

    * `:dia_options` - compilation options that apply
      to Diameter's compiler.

      For a list of the many more available options,
      see [`:diameter_make`](http://erlang.org/doc/man/diameter_make.html).
      Note that the `:outdir` option is overridden by this compiler.

    * `:dia_erl_compile_opts` list of options that will be passed to
      Mix.Compilers.Erlang.compile/6

      Following options are supported:

        * :force        - boolean
        * :verbose      - boolean
        * :all_warnings - boolean
  """

  @doc """
  Runs this task.
  """
  @spec run(OptionParser.argv) :: :ok | :noop
  def run(_args) do
    project      = Mix.Project.config
    erlang_compile_opts = project[:dia_erl_compile_opts] || []
    source_paths = project[:erlc_paths]
    mappings     = Enum.zip(["dia"], source_paths)
    options      = project[:dia_options] || []

    Erlang.compile(manifest(), mappings, :dia, :erl, erlang_compile_opts, fn
      input, output ->
        :ok = Filelib.ensure_dir(output)
        app_path = Mix.Project.app_path(project)
        include_path = to_charlist Path.join(app_path, project[:erlc_include_path])
        :ok = Path.join(include_path, "dummy.hrl") |> Filelib.ensure_dir
        case DiaDictUtil.parse({:path, input}, []) do
          {:ok, spec} ->
            filename = dia_filename(input, spec)
            _ = DiaCodegen.from_dict(filename, spec, [{:outdir, ~c"src"} | options], :erl)
            _ = DiaCodegen.from_dict(filename, spec, [{:outdir, include_path} | options], :hrl)
            file = to_charlist(Path.join("src", filename))
            compile_path = to_charlist Mix.Project.compile_path(project)
            erlc_options = project[:erlc_options] || []
            erlc_options = erlc_options ++ [{:outdir, compile_path}, {:i, include_path}, :report]
            case :compile.file(file, erlc_options) do
              {:ok, module} ->
                {:ok, module, []}
              {:ok, module, warnings} ->
                {:ok, module, warnings}
              {:ok, module, _binary, warnings} ->
                {:ok, module, warnings}
              {:error, errors, warnings} ->
                {:error, errors, warnings}
              :error ->
                {:error, [], []}
            end
          error -> Mix.raise "Diameter compiler error: #{inspect error}"
        end
    end)
  end

  @doc """
  Returns Dia manifests.
  """
  def manifests, do: [manifest()]
  defp manifest, do: Path.join(Mix.Project.manifest_path, @manifest)

  @doc """
  Cleans up compilation artifacts.
  """
  def clean do
    Erlang.clean(manifest())
  end

  defp dia_filename(file, spec) do
    case spec[:name] do
      nil -> Path.basename(file) |> Path.rootname |> to_charlist
      :undefined -> Path.basename(file) |> Path.rootname |> to_charlist
      name -> name
    end
  end
end
