package terraform.tag_policy

import rego.v1

required_tags := {"Environment", "Project"}

get_tags(resource) := t if {
  after := resource.change.after
  t := object.get(after, "tags_all", object.get(after, "tags", {}))
}

missing_tags(resource) := missing if {
  tags := get_tags(resource)
  keys := {k | k := object.keys(tags)[_]}
  missing := required_tags - keys
}
