#!/bin/bash
set -e

[[ -n $DEBUG_ENTRYPOINT ]] && set -x

DB_HOST=${POSTGRES_HOST:-}
DB_PORT=${POSTGRES_PORT:-}
DB_NAME=${POSTGRES_DB:-}
DB_USER=${POSTGRES_USER:-}
DB_PASS=${POSTGRES_PASSWORD:-}
ADMIN_NAME=${ADMIN_NAME:-}
ADMIN_EMAIL=${ADMIN_EMAIL:-}
ADMIN_PASSWORD=${ADMIN_PASSWORD:-}
APP_PORT=${APP_PORT:-9081}

# bail out if database host is not set.
if [[ -z ${POSTGRES_HOST} ]]; then
  echo "ERROR: "
  echo "  Please configure the database connection."
  echo "  Cannot continue without a database. Aborting..."
  exit 1
fi

# use default database port number if it is not set
if [[ -z ${DB_PORT} ]]; then
  echo "WARNING: "
  echo " Database port not defined! Using default PostgreSQL port 5432."
  echo " If this is not correct, please set the correct port via DB_PORT environment variable!"
  DB_PORT=${DB_PORT:-5432}
fi

# set default user and database if somehow not defined.
DB_USER=${DB_USER:-postgres}
DB_NAME=${DB_NAME:-ittour}

# bail out if admin data is not set.
if [[ -z ${ADMIN_NAME} || -z ${ADMIN_EMAIL} || -z ${ADMIN_PASSWORD} ]]; then
  echo "ERROR: "
  echo "  Please configure the administrator account."
  echo "  Cannot continue without an administrator account. Aborting..."
  exit 1
fi

appInit () {
  timeout=60
  prog=$(find /usr/lib/postgresql/ -name pg_isready)
  prog="${prog} -h ${DB_HOST} -p ${DB_PORT} -U ${DB_USER} -d ${DB_NAME} -t 1"
  printf "Waiting for database server to accept connections"
  while ! ${prog} >/dev/null 2>&1
  do
    timeout=$(expr $timeout - 1)
    if [[ $timeout -eq 0 ]]; then
      printf "\nCould not connect to database server. Aborting...\n"
      exit 1
    fi
    printf "."
    sleep 1
  done
  echo

  # run the rake tasks if required
  QUERY="SELECT count(*) FROM information_schema.tables WHERE table_schema = 'public';"
  COUNT=$(PGPASSWORD="${DB_PASS}" psql -h ${DB_HOST} -p ${DB_PORT} -U ${DB_USER} -d ${DB_NAME} -Atw -c "${QUERY}")

   if [[ -z ${COUNT} || ${COUNT} -eq 0 ]]; then
    echo "Database appears to be empty, running rake tasks!"
    bundle exec rake db:create
    bundle exec rake db:schema:load
    bundle exec rake create_user first_name="${ADMIN_NAME}" last_name="${ADMIN_NAME}" email="${ADMIN_EMAIL}" password="${ADMIN_PASSWORD}"
   else 
    bundle exec rake db:migrate >/dev/null
   fi
}

appStart () {
  appInit
  # start app
  if [[ -f "/app/tmp/pids/server.pid" ]]; then
    echo "Found old pid, removing it."
    rm -f /app/tmp/pids/server.pid
  fi
  echo "Precompiling assets..."
  bundle exec rake assets:clean assets:precompile
  echo "Starting app..."
  bundle exec rails s -p "${APP_PORT}" -b "0.0.0.0"
}

appHelp () {
  echo "Available options:"
  echo " app:start          - Starts the gitlab server (default)"
  echo " app:init           - Initialize the gitlab server (e.g. create databases, compile assets), but don't start it."
  echo " app:rake <task>    - Execute a rake task."
  echo " app:help           - Displays the help"
  echo " [command]          - Execute the specified linux command eg. bash."
}

appRake () {
  if [[ -z ${1} ]]; then
    echo "Please specify the rake task to execute."
    return 1
  fi

  echo "Running \"${1}\" rake task ..."
  bundle exec rake $@
}

case ${1} in
  app:start)
    appStart
    ;;
  app:init)
    appInit
    ;;
  app:rake)
    shift 1
    appRake $@
    ;;
  app:help)
    appHelp
    ;;
  *)
    if [[ -x $1 ]]; then
      $1
    else
      prog=$(which $1)
      if [[ -n ${prog} ]] ; then
        shift 1
        $prog $@
      else
        appHelp
      fi
    fi
    ;;
esac

exit 0