# Double quote to prevent globbing and word splitting.
# shellcheck disable=SC2086
set -ex

name=slve-void
cfname=slve
region=us-central1

firebase deploy --only functions:$cfname --force --project=$PROJECT_ID

gcloud compute addresses create $name-reserved-ip \
  --project=$PROJECT_ID \
  --ip-version=IPV4 \
  --global

gcloud compute network-endpoint-groups create $name-network-endpoint-group \
  --project=$PROJECT_ID \
  --region=$region \
  --network-endpoint-type=serverless \
  --cloud-function-name=$cfname

gcloud compute backend-services create $name-backend-service \
  --project=$PROJECT_ID \
  --global

gcloud compute backend-services add-backend $name-backend-service \
  --project=$PROJECT_ID \
  --global \
  --network-endpoint-group=$name-network-endpoint-group \
  --network-endpoint-group-region=$region

rm -f transaction.yaml
gcloud beta dns --project=$PROJECT_ID record-sets transaction start --zone=$DNSZONE
gcloud beta dns --project=$PROJECT_ID record-sets transaction add "$(
  gcloud compute addresses describe $name-reserved-ip \
    --project=$PROJECT_ID \
    --format="get(address)" \
    --global
  )" --name="$DNSNAME." --ttl="300" --type="A" --zone=$DNSZONE
gcloud beta dns --project=$PROJECT_ID record-sets transaction execute --zone=$DNSZONE

gcloud compute ssl-certificates create $name-ssl-certificate \
  --project=$PROJECT_ID \
  --domains $DNSNAME

# took 8 minutes from provisioning to active
gcloud compute ssl-certificates list \
  --project=$PROJECT_ID \
  --global | grep $name-ssl-certificate

gcloud compute url-maps create $name-url-map \
  --project=$PROJECT_ID \
  --default-service $name-backend-service

gcloud compute target-https-proxies create $name-https-proxy \
  --project=$PROJECT_ID \
  --ssl-certificates=$name-ssl-certificate \
  --url-map=$name-url-map

gcloud compute forwarding-rules create $name-forwarding-rule \
  --project=$PROJECT_ID \
  --address=$name-reserved-ip \
  --target-https-proxy=$name-https-proxy \
  --global \
  --ports=443

# took 13 minutes to get the first response
