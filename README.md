# terraform-azure-linux-vm

This is a training sample I originally created for a [Terraform][tf] on [Azure][az] workshop, which I am cleaning up for public consumption and as an end-to-end, full-stack provisioning demo that can be used as a starting point for more complex solutions.

## Roadmap

This is the list of currently implemented/planned features:

* [ ] Set up a full web stack
* [ ] Set locale in `cloud-config`
* [ ] Move NSG outside the `linux` module for flexibility
* [ ] Move `cloud-config` template outside the `linux` module and into its own folder
* [x] Set up `docker` and other core packages via `cloud-init`
* [x] Re-instate public IP, DNS alias and NSGs in `main.tf`
* [x] Set SSH port and harden configuration via `cloud-init`
* [x] Split naming for shared vs instance resources in `base.tf`
* [x] Add portal-compatible metrics using `Microsoft.OSTCExtensions` 2.3 (using a `wadcfg.xml` template)
* [x] Add boilerplate for `Azure.Linux.Diagnostics` 3.0 (using a `ladCfg` template inlined in `settings.json`)
* [x] Add availability set in `base.tf`
* [x] Update Ubuntu to 18.04 in `main.tf`
* [x] Add boot diagnostics in `main.tf`
* [x] Break out VM into `linux` module
* [x] Cleanup and namespacing
* [x] Single Ubuntu VM with managed disks

[tf]: http://terraform.io
[az]: https://azure.microsoft.com