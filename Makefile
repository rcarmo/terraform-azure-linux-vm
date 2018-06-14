# If we have a usable SSH key, then hand it over to Terraform
SSH_KEY := $(HOME)/.ssh/id_rsa.pub
ifneq (,$(wildcard $(SSH_KEY)))
	export TF_VAR_admin_username := $(USER)
	export TF_VAR_ssh_key := $(shell cat $(SSH_KEY))
	#export TF_LOG=TRACE
endif

export TF_VAR_shared_prefix := "paas"
export TF_VAR_instance_prefix := "ubuntu"
export TF_VAR_ssh_port := "2211"
export TF_VAR_standard_vm_size := "Standard_B2ms"
export TF_VAR_cloud_config := "paas.yml.tpl"

.PHONY: plan apply destroy validate

plan apply destroy validate:
	terraform $@
