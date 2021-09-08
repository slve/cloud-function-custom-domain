Goal
----
This is a simple example to demonstrate how to
create cloud function and more importantly
to reach it out through a custom domain.

Once https://issuetracker.google.com/issues/36155827?pli=1
is resolved the need to create all the wiring,
like reserved ip, network endpoint group, backend service,
url-map and forwarding rule would be obsolete;
but up until then we are left with the solution described
in https://cloud.google.com/load-balancing/docs/https/setting-up-https-serverless,
whereas this example serves as a proof of concept.

Quick start
-----------
```
PROJECT_ID=... DNSZONE=... DNSNAME=... ./setup.sh
```
Note: Once the setup ran fine, you need to wait till the SSL certificate
becomes active, which may easily take up to 15 minutes;
plus maybe a minute or two before you will be able to
successfully reach out your function.
```
curl your.custom.domain -iv
```

Custom function
---------------
```
rm -rf functions/
firebase init functions
```

## Cleanup
```
./teardown.sh
```

References
----------
- https://firebase.google.com/docs/functions/get-started
- https://cloud.google.com/load-balancing/docs/https/setting-up-https-serverless#gcloud_1
