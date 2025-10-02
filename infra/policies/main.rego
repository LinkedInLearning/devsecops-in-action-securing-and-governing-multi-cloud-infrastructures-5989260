package main

import data.terraform.tag_policy
import rego.v1

in_scope_compute(r) if {
  r.type == "aws_instance"
} else if {
  r.type == "azurerm_linux_virtual_machine"
}

# Not a delete
not_deleted(r) if {
  not ("delete" in r.change.actions)
}

has_after(r) if {
  r.change.after != null
}

tag_policy_violations := [
  {
    "address": resource.address,
    "missing_tags": missing,
    "message": "Resource missing required tags",
  }
  |
  some resource in input.resource_changes
  in_scope_compute(resource)
  not_deleted(resource)
  has_after(resource)
  missing := tag_policy.missing_tags(resource)
  count(missing) > 0
]
