#!groovy

import hudson.security.csrf.DefaultCrumIssuer
import jenkins.model.Jenkins

println "--> enabling CSRF protection"

def instance = Jenkins.getInstance()
instance.setCrumbIssuer(new DefaultCrumbIssuer(true))
instance.save()