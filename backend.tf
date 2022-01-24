terraform {
  cloud {
    organization = "azure_poc"

    workspaces {
      name = "lab"
    }
  }
}