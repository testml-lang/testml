defmodule TestML.Run.Tap do

  defstruct count: nil, checked: nil, planned: nil

  def run(file) do
    TestML.Run.Tap.new(file)
    |> TestML.Run.from_file(file)
    |> TestML.Run.test
  end

  def new(file) do
    %TestML.Run.Tap{count: 1, checked: true, planned: false}
    |> TestML.Run.new(file)
  end

end
