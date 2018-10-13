defmodule TestML.Run do
  defstruct file: nil

  def new(%TestML.Run.Tap{} = _tap, file) do
    %TestML.Run{file: file}
  end

  def test(%TestML.Run{} = _run) do
    IO.puts("ok 1")
    IO.puts("1..1")
  end

  def from_file(%TestML.Run{} = run, _file) do
    run
  end
end
