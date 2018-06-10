resource "azurerm_network_interface" "nic" {
  name                = "${var.name}"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"

  ip_configuration {
    name                          = "${var.name}-config"
    subnet_id                     = "${var.subnet_id}"
    private_ip_address_allocation = "dynamic"
  }

  tags = "${var.tags}"
}

resource "azurerm_virtual_machine" "linux" {
  name                  = "${var.name}"
  location              = "${var.location}"
  resource_group_name   = "${var.resource_group_name}"
  availability_set_id   = "${var.availability_set_id}"
  network_interface_ids = ["${azurerm_network_interface.nic.id}"]
  vm_size               = "${var.vm_size}"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference = {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.name}-os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "${var.storage_type}"
  }

  os_profile {
    computer_name  = "${var.name}"
    admin_username = "${var.admin_username}"
    custom_data    = <<CUSTOM_DATA
CUSTOM_DATA
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys = {
      key_data = "${var.ssh_key}"
      path     = "/home/${var.admin_username}/.ssh/authorized_keys"
    }
  }

  boot_diagnostics {
    enabled     = true
    storage_uri = "${var.diag_storage_primary_blob_endpoint}"
  }

  tags = "${var.tags}"
}

// This is used for Microsoft.OSTCExtensions 2.3 (the portal default)
data "template_file" "wadcfg" {
  template = "${file("${path.module}/diagnostics/wadcfg.xml.tpl")}"

  vars {
    virtual_machine_id = "${azurerm_virtual_machine.linux.id}"
  }
}

// This is used for Microsoft.OSTCExtensions 2.3 (the portal default)
data "template_file" "settings" {
  template = "${file("${path.module}/diagnostics/settings2.3.json.tpl")}"

  vars {
    xml_cfg           = "${base64encode(data.template_file.wadcfg.rendered)}"
    diag_storage_name = "${var.diag_storage_name}"
  }
}

/*
// This is used only if you require the Azure.Linux.Diagnostics 3.0 extension
data "azurerm_storage_account_sas" "diagnostics" {
  connection_string = "${var.diag_storage_primary_connection_string}"
  https_only        = true

  resource_types {
    service   = false
    container = true
    object    = true
  }

  services {
    blob  = true
    queue = false
    table = true
    file  = false
  }

  start  = "2018-06-01"
  expiry = "2118-06-01"

  permissions {
    read    = true
    write   = true
    delete  = false
    list    = true
    add     = true
    create  = true
    update  = true
    process = false
  }
}

data "template_file" "settings" {
  template = "${file("${path.module}/diagnostics/settings3.0.json.tpl")}"

  vars {
    diag_storage_name = "${var.diag_storage_name}"
    virtual_machine_id = "${azurerm_virtual_machine.linux.id}"
  }
}
*/

data "template_file" "protected_settings" {
  template = "${file("${path.module}/diagnostics/protected_settings2.3.json.tpl")}"

  vars {
    diag_storage_name               = "${var.diag_storage_name}"
    diag_storage_primary_access_key = "${var.diag_storage_primary_access_key}"

    # if using Azure.Linux.Diagnostics 3.0, you MUST supply a SAS and skip the leading "?".
    # diag_storage_sas = "${substr(data.azurerm_storage_account_sas.diagnostics.sas,1,-1)}"
  }
}

resource "azurerm_virtual_machine_extension" "diagnostics" {
  name                       = "diagnostics"
  resource_group_name        = "${var.resource_group_name}"
  location                   = "${var.location}"
  virtual_machine_name       = "${azurerm_virtual_machine.linux.name}"
  publisher                  = "Microsoft.OSTCExtensions"
  type                       = "LinuxDiagnostic"
  type_handler_version       = "2.3"
  auto_upgrade_minor_version = true
  depends_on                 = ["azurerm_virtual_machine.linux"]

  settings           = "${data.template_file.settings.rendered}"
  protected_settings = "${data.template_file.protected_settings.rendered}"
}

output "vm" {
  value = "${azurerm_virtual_machine.linux.id}"
}
