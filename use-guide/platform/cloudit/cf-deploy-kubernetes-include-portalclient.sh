bosh -e paasta -d cf deploy -n cf-deployment/cf-deployment-include-portalclient.yml \
  --vars-store cf-kubernetes/creds.yml \
  -o cf-deployment/operations/use-compiled-releases.yml \
  -o cf-deployment/operations/scale-to-one-az.yml \
  -v system_domain="118.130.73.26.xip.io" \
  -v portal_haproxy_public_ip="118.130.73.28.xip.io" \
