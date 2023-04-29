provider "ad" {
  version = "0.1.0"

  winrm_hostname = var.ad_server_domain
  winrm_password = var.ad_server_password
  winrm_username = var.ad_server_user
  // Add WinRM configuration here
}

resource "ad_gpo" "gqqq" {
    name            = "TFTestGPO"
    domain          = "nextware.local"
    description     = "gpo for gplink tests"
    status          = "AllSettingsEnabled"
}

resource "ad_gpo_security" "gpo_sec" {
  gpo_container = ad_gpo.gqqq.id
  password_policies {
    minimum_password_length = 3
  }
  system_services {
    service_name = "TapiSrv"
    startup_mode = "2"
    acl          = "D:AR(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;LA)"
  }
}

resource "ad_ou" "oqqq" {
    name        = "TF Test OU"
    path        = "dc=nextware,dc=local"
    description = "OU for gplink tests"
}

resource "ad_gplink" "og" {
    gpo_guid  = ad_gpo.gqqq.id
    target_dn = ad_ou.oqqq.dn
}

//create user and group

resource "ad_ou" "tf" {
    name = "Terraform"
    path = "dc=nextware,dc=local"
    description = "Terraform Objects"
    protected = false
}

variable TerraformUserPwd { 
    type = string
}

resource "ad_user" "tu" {
    principal_name  = "Terrform.User@nextware.local"
    sam_account_name = "Terrform.User"
    display_name = "Terraform User"
    container = ad_ou.tf.dn
    initial_password = var.TerraformUserPwd
    password_never_expires = true
}

resource "ad_group" "tg" {
    name = "TerraformGroup"
    sam_account_name = "TerraformGroup"
    category = "security"
    container = ad_ou.tf.dn
}