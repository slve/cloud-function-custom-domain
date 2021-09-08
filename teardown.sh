# Double quote to prevent globbing and word splitting.
# shellcheck disable=SC2086
set -x

name=slve-void
cfname=slve
region=us-central1

gcloud compute forwarding-rules delete $name-forwarding-rule \
  --quiet \
  --project=$PROJECT_ID \
  --global

gcloud compute target-https-proxies delete $name-https-proxy \
  --quiet \
  --project=$PROJECT_ID

gcloud compute url-maps delete $name-url-map \
  --quiet \
  --project=$PROJECT_ID

gcloud compute ssl-certificates delete $name-ssl-certificate \
  --quiet \
  --project=$PROJECT_ID

rm -f transaction.yaml
gcloud beta dns --project=$PROJECT_ID record-sets transaction start --zone=$DNSZONE
gcloud beta dns --project=$PROJECT_ID record-sets transaction remove "$(
  gcloud compute addresses describe $name-reserved-ip \
    --project=$PROJECT_ID \
    --format="get(address)" \
    --global
  )" --name="$DNSNAME." --type="A" --ttl="300" --zone=$DNSZONE
gcloud beta dns --project=$PROJECT_ID record-sets transaction execute --zone=$DNSZONE

gcloud compute backend-services delete $name-backend-service \
  --quiet \
  --project=$PROJECT_ID \
  --global

gcloud compute network-endpoint-groups delete $name-network-endpoint-group \
  --quiet \
  --project=$PROJECT_ID \
  --region=$region

gcloud compute addresses delete $name-reserved-ip \
  --quiet \
  --project=$PROJECT_ID \
  --global

firebase functions:delete $cfname --force --project=$PROJECT_ID
