trap "rm solr-9.5.3.tgz" EXIT
helm pull oci://registry-1.docker.io/bitnamicharts/solr --version 9.5.3
helm template solr solr-9.5.3.tgz --output-dir . 