# require 'testml/bridge'
class TestMLBridge # < TestML::Bridge

# sub hash_lookup {
#   my ($self, $hash, $key) = @_;
#   $hash->{$key};
# }
# 
# sub get_env {
#   my ($self, $name) = @_;
#   $ENV{$name};
# }

  def add(x, y)
    return x + y
  end

  def sub(x, y)
    return x - y
  end

# sub cat {
#   my ($self, $x, $y) = @_;
# 
#   $x . $y;
# }
# 
# sub mine {
#   bless {}, 'Mine';
# }

end

# vim: set sw=2 sts=2 et:
