export t=../..

source $t/.rc
(cd $t; make work > /dev/null)

export NODE_PATH=$PWD/$t/rotn/lib
export PYTHONPATH=$PWD/$t/rotn/lib
export PERL5LIB=$PWD/$t/rotn/lib
export PERL6LIB=$PWD/$t/rotn/lib
