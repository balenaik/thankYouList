fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew install fastlane`

# Available Actions
## iOS
### ios certificates
```
fastlane ios certificates
```
Get Certificates and Provisioning Profiles
### ios update_certificates
```
fastlane ios update_certificates
```
Update Certificates and Provisioning Profiles
### ios build_appstore
```
fastlane ios build_appstore
```
AppStore Build
### ios build_appStore_production
```
fastlane ios build_appStore_production
```
Build Production(AppStore)
### ios upload_appstore_production
```
fastlane ios upload_appstore_production
```
Upload Production on Appstore

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
