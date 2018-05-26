export t=../..

source $t/.rc
(cd $t; make eg/rotn > /dev/null)

export NODE_PATH=$PWD/$t/eg/rotn/lib
export PYTHONPATH=$PWD/$t/eg/rotn/lib
export PERL5LIB=$PWD/$t/eg/rotn/lib
export PERL6LIB=$PWD/$t/eg/rotn/lib
