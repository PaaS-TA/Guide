start=$(date)

echo "start [$start]"

ls -l kubernetes/ 

if [ -f kubernetes/state.json ]; then
	rm kubernetes/creds.yml kubernetes/state.json
	echo 'rm kubernetes/creds.yml kubernetes/state.json'
	ls -l kubernetes
fi

bosh create-env bosh-deployment/bosh.yml \
  --state=kubernetes/state.json \
  --vars-store=kubernetes/creds.yml \
  -o kubernetes/cpi.yml \
  -o kubernetes/registry.yml \
  -o bosh-deployment/jumpbox-user.yml \
  -o bosh-deployment/local-dns.yml \
  -v director_name=paasta \
  -v internal_cidr="unused" \
  -v internal_gw="unused" \
  -v internal_ip="192.168.150.25" \
  -v local_host="127.0.0.1" \
  --var-file kube_config=<(cat ~/.kube/config) \
  -v storage_class=paasta-rbd \
  -v reg_backend=docker \
  -v reg_host="registry.hub.docker.com" \
  -v reg_url="https://registry.hub.docker.com" \
  -v reg_user=dockerhubusername \
  -v reg_password=dockerhubpassword \
  -v paasta_namespace=paasta \
  -v reg_pull_secret_name=regsecret \
  -v kube_api=10.0.0.21 \
  -v kube_api_port=6443 \

echo "start [$start]"
echo "finis [$(date)]"
