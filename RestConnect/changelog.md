# Changelog

## 1.0.10 (2022-06-14)

+ New: Command Set-RestServiceMetadata - Define service metadata for a connected service.

## 1.0.9 (2022-05-12)

+ Upd: Invoke-RestRequest - Increased mx body serialization depth to 99 to allow complex body constructs

## 1.0.8 (2022-05-12)

+ Upd: Connect-RestService - Added `-Resource` parameter to support connecting to services that differentiate between connection url and resource name.

## 1.0.7 (2022-04-14)

+ Upd: Invoke-RestRequest - Now accepts an absolute uri as path, overriding the default service url specified with the service connection used.
