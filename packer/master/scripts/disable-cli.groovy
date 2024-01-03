#!groovy

import jenkins.model.*

Jenkins jenkins = Jenkins.getInstance()
jenkins.CLI.get().setEnabled(false)
jenkins.save()