bosh -e paasta -d cf deploy -n cf-deployment/cf-deployment.yml \
  --vars-store cf-kubernetes/creds.yml \
  -o cf-deployment/operations/use-compiled-releases.yml \
  -o cf-deployment/operations/scale-to-one-az.yml \
  -v system_domain="192.168.150.26.xip.io" \
