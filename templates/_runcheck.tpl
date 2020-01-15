#!/bin/sh

set -e

notify() {
  echo "$1"
  echo -n "$1 " >> /dev/termination-log
}

greater_version()
{
  test "$(printf '%s\n' "$@" | sort -V | tail -n 1)" = "$1";
}

# For the PostgreSQL upgrade, you either need both secrets, or no secrets.
# If there are no secrets, we will create them for you.
# If the secrets aren't in either of these states, we assume you are upgrading from an older version
# This is running ahead of version checks to ensure this always runs. This is to account for
# installations outside of the official helm repo.
# NOTE: directory exists ONLY if postgresql.install=true and secret exists
if [ -d "/etc/secrets/postgresql" ]; then
 if [ ! -f "/etc/secrets/postgresql/postgresql-postgres-password" ] || [ ! -f "/etc/secrets/postgresql/{{ include "gitlab.psql.password.key" . | trimAll "\"" }}" ] ; then
    notify "You seem to be upgrading from a previous version of GitLab using the bundled PostgreSQL chart"
    notify "There are some manual steps which need to be performed in order to upgrade the database"
    notify "Please see the upgrade documentation for instructions on how to proceed:"
    notify "https://docs.gitlab.com/charts/installation/upgrade.html"
    exit 1
  fi
fi
MIN_VERSION=12.6
CHART_MIN_VERSION=2.6

# Only run check for semver releases
if ! awk 'BEGIN{exit(!(ARGV[1] ~ /^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/))}' "$GITLAB_VERSION"; then
  exit 0
fi

NEW_MAJOR_VERSION=$(echo $GITLAB_VERSION | awk -F "." '{print $1}')
NEW_MINOR_VERSION=$(echo $GITLAB_VERSION | awk -F "." '{print $1"."$2}')

NEW_CHART_MAJOR_VERSION=$(echo $CHART_VERSION | awk -F "." '{print $1}')
NEW_CHART_MINOR_VERSION=$(echo $CHART_VERSION | awk -F "." '{print $1"."$2}')

if [ ! -f /chart-info/gitlabVersion ]; then
  notify "It seems you are attempting an unsupported upgrade path."
  notify "Please follow the upgrade documentation at https://docs.gitlab.com/ee/policy/maintenance.html#upgrade-recommendations"
  exit 1
fi

OLD_VERSION_STRING=$(cat /chart-info/gitlabVersion)
OLD_CHART_VERSION_STRING=$(cat /chart-info/gitlabChartVersion)

# Skip check if old version wasn't semver
if ! awk 'BEGIN{exit(!(ARGV[1] ~ /^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/))}' "$OLD_VERSION_STRING"; then
  exit 0
fi

OLD_MAJOR_VERSION=$(echo $OLD_VERSION_STRING | awk -F "." '{print $1}')
OLD_MINOR_VERSION=$(echo $OLD_VERSION_STRING | awk -F "." '{print $1"."$2}')
OLD_CHART_MAJOR_VERSION=$(echo $OLD_CHART_VERSION_STRING | awk -F "." '{print $1}')
OLD_CHART_MINOR_VERSION=$(echo $OLD_CHART_VERSION_STRING | awk -F "." '{print $1"."$2}')

# Checking Version
# (i) if it is a major version jump
# (ii) if existing version is less than required minimum version
if [ ${OLD_MAJOR_VERSION} -lt ${NEW_MAJOR_VERSION} ] || [ ${OLD_CHART_MAJOR_VERSION} -lt ${NEW_CHART_MAJOR_VERSION} ]; then
  if ( ! greater_version $OLD_MINOR_VERSION $MIN_VERSION ) || ( ! greater_version $OLD_CHART_MINOR_VERSION $CHART_MIN_VERSION ); then
    notify "It seems you are upgrading the GitLab Helm Chart from ${OLD_CHART_VERSION_STRING} (GitLab ${OLD_VERSION_STRING}) to ${CHART_VERSION} (GitLab ${GITLAB_VERSION})."
    notify "It is required to upgrade to the last minor version in a major version series"
    notify "first before jumping to the next major version."
    notify "Please follow the upgrade documentation at https://docs.gitlab.com/charts/releases/3_0.html"
    notify "and upgrade to GitLab Helm Chart version 2.6.0 before upgrading to ${CHART_VERSION}."
    exit 1
  fi
fi
