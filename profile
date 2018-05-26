source ../.rc
(cd ..; make node_modules)

export NODE_PATH=$PWD/../rotn/lib
export PYTHONPATH=$PWD/../rotn/lib
export PERL5LIB=$PWD/../rotn/lib
export PERL6LIB=$PWD/../rotn/lib
