# Parse version info from pom.xml in deployed applications.  Would have been
# nice to use a real XML parser here but:
# a) we are on solaris so can't rely on packages being installed/installable
# b) gem doesn't seem to work properly behind proxies so we can't install nokogiri
# c) nokogiri never installs properly without installing half the internet and a C compiler
# ... therefore we will process as dumb strings.  Infact, why not go for the
# jugular, lets use awk
require 'find'

def parse_xml(field, file)
  command = "awk 'BEGIN {FS=\"<|>\"} /#{field}/ { print $3 ; exit }' < #{file}"
  return Facter::Core::Execution.exec(command)
end

Facter.add("wsapp_versions") do
  webapps_dir = "/opt/ibm/tree"
  pom_regexp = /pom.xml$/
  wsapp_versions = {}
  Find.find(webapps_dir) do | path |
    if path =~ pom_regexp then
      name        = parse_xml("name", path)
      version     = parse_xml("version", path)
      group_id    = parse_xml("groupId", path)
      artifact_id = parse_xml("artifactId", path)
      wsapp_versions[name] = {
        "groupId"    => group_id,
        "artifactId" => artifact_id,
        "version"    => version,
      }
    end
  end
  setcode do 
    wsapp_versions
  end
end