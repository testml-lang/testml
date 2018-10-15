defmodule TestML.Run.Tap do
  alias __MODULE__
  alias TestML.Run

  defstruct \
    count: 0,
    checked: false,
    planned: false

  def run(file) do
    Tap.new(file)
      |> Run.from_file(file)
      |> Run.test
  end

  def new(file) do
    %Tap{} |> Run.new(file)
  end

  def testml_begin(%Tap{} = self) do
    self = %{self | checked: false}
    self = %{self | planned: false}
    self
  end

  def testml_end(%Tap{} = self) do
    if not self.planned do
      self|>tap_done
    end
    self
  end

  def testml_eq_fake(%Tap{} = self) do
    self = Map.put(self, :count, self.count + 1)
    # self = %{self | count: self.count + 1}
    IO.puts("ok #{self.count}")
    {:reply, self}
  end

  def tap_done(%Tap{} = self) do
    # count = to_string(self.count)
    count = "1"  # XXX
    IO.puts("1..#{count}")

    self
  end

end
