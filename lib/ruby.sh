# initiaze bundler
export RBENV_ROOT="/l/local/rbenv"
export PATH="$RBENV_ROOT/bin:$RBENV_ROOT/shims:$PATH"

function require {
  # switch to required ruby
  export RBENV_VERSION=$1
  
  if [[ $1 =~ ^jruby ]]; then
    # jruby
    if [ -x '/usr/libexec/java_home' ]; then
    	# OS X
    	export JAVA_HOME=`/usr/libexec/java_home`
    else
    	# Debian and EL
    	export JAVA_HOME=`find /usr/lib/jvm -maxdepth 1 -mindepth 1 -type d | sort -r | head -1`
    fi
    export PATH="${JAVA_HOME}/bin:$PATH"    
  fi
}

function require_match {
  require_re '^'`echo $f | sed 's/\./\\\./g'`'\b'
}

function require_re {
  require `rbenv versions --bare | sort -V | grep $1`
}

function ruby.sh {
  cd `dirname $0`
  bundle exec ruby `basename $0` $@
  exit $?
}
