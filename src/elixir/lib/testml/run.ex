defmodule TestML.Run do
  alias __MODULE__

  def vtable() do
    %{
      '.':   'exec_dot',
      '%':   'each_exec',
      '%<>': 'each_pick',
      '<>':  'pick_exec',
      '&':   'call_func',

      '"':   'get_str',
      ':':   'get_hash',
      '[]':  'get_list',
      '*':   'get_point',

      '=':   'set_var',
      '||=': 'or_set_var'
    }
  end

  defstruct \
    tester: nil,

    file: nil,
    version: nil,
    code: nil,
    data: nil,

    bridge: nil,
    stdlib: nil,

    vars: %{},
    block: nil,
    warned_only: false,
    error: nil,
    thrown: nil

  def new(tester, file) do
    %Run{
      tester: tester,
      file: file,
    }
  end

  def from_file(%Run{} = self, file) do
    {:ok, text} = File.read(file)
    {:ok, ast} = Poison.decode(text)

    self = %{self | file: file}
    self = %{self | version: ast["testml"]}
    self = %{self | code: ast["code"]}
    self = %{self | data: ast["data"]}

    self
  end

  def test(%Run{} = self) do
    self.tester |> self.tester.__struct__.testml_begin

    t = self.tester
    # for _expr <- self.code do
      t |> t.__struct__.testml_eq_fake
    # end

    self.tester |> self.tester.__struct__.testml_end

    self
  end

  #----------------------------------------------------------------------------
  def exec(%Run{} = self, expr) do
    exec_expr(self, expr)
    self
  end

  def exec_expr(%Run{} = self, _expr) do
    self
  end
end
