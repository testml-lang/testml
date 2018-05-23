require 'json'

OPERATOR = {
  '=='    => 'eq',
  '.'     => 'call',
  '=>'    => 'func',
  "$''"   => 'get-string',
  '%()'   => 'pickloop',
  '*'     => 'point',
  '='     => 'set-var'
}

class Run

  attr :file, :version, :code, :data,
    :bridge, :stdlib, :vars

  def from_file file
    @file = file

    f = File.open(file, 'r')

    testml = JSON.load f

    f.close

    @version = testml['version']
    @code = testml['code']
    @data = testml['data']

    return self
  end

  def test
    self.test_begin
    self.exec(self.code)
    self.test_end
  end

  def exec expr, context=[]
    return expr unless expr.kind_of? Array
    args = expr.clone
    name = call = args.shift
    if opname = OPERATOR[call]
      call = "exec_#{opname}".gsub('-', '_')
      return_ = self.method(call).call(*args)
    else
      args.collect!{|x| if x.kind_of?(Array) then self.exec(x)[0] else x end}
      args.unshift(*(context.reverse))

      if call.match /^[a-z]/
        call = call.gsub '-', '_'
        if @bridge[call]
          return_ = @bridge[call].call(*args)
        else
          raise "Can't find bridge function: '#{name}'"
        end

      elsif call.match /^[A-Z]/
        call = call.downcase
        if @stdlib[call]
          return_ = @stdlib[call].call(*args)
        else
          raise "Unknown TestML Standard Library function: '#{name}'"
        end

      else
        raise "Can't resolve TestML function '#{name}'"
      end
    end

    return return_.nil? ? [] : [return_]
  end


end


