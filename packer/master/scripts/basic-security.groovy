#!groovy

import jenkins.model.*
import hudson.security.*
import com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl

def instance = Jenkins.getInstance()

println "--> creating local user 'admin'"
