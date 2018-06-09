# terraform-azure-linux-vm

This is a training sample I originally created for a [Terraform][tf] on [Azure][az] workshop, which I am cleaning up for public consumption and as an end-to-end, full-stack provisioning demo that can be used as a starting point for more complex solutions.

* [ ] Set up `docker` and other packages via `cloud-init`
* [ ] Re-instate public IP, DNS alias and NSGs
* [ ] Set SSH port via `cloud-init`
* [ ] Add portal-compatible support for `Microsoft.OSTCExtensions` 2.3
* [x] Add boilerplate for `Azure.Linux.Diagnostics` 3.0
* [x] Add availability set
* [x] Update Ubuntu to 18.04
* [x] Add boot diagnostics
* [x] Break out VM into `linux` module
* [x] Cleanup and namespacing
* [x] Single Ubuntu VM with managed disks

[tf]: http://terraform.io
[az]: https://azure.microsoft.com