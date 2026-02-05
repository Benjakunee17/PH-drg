# ============================
# Variables
# ============================
#ต้นทาง
# VM190825
variable "compartment_ocid" {
  default = "ocid1.compartment.oc43..aaaaaaaakl6b7wnrruhlosrkxhprb2ubpq3kcwuak72bnkmlybboz7gpo3xa"
}

# DRG ที่มีอยู่แล้ว (ต้องไป copy OCID ของ DRG เดิมมาใส่)
variable "drg_id" {default = "ocid1.drg.oc43.ap-pathumthani-1.aaaaaaaaex676ijrtwhnuk25xrq5grb2iut2laivfy6mklmqvqoajsgqvwvq"}

# ============================
# Resources
# ============================
#compartment VM190825
resource "oci_core_vcn" "VCN_VM190825" {
  display_name   = "VM190825"
  cidr_block     = "192.168.211.0/24"
  compartment_id = var.compartment_ocid
}


#Roll back

# resource "oci_core_route_table" "VM190825-PizzaHUT-RT" {
#   compartment_id = var.compartment_ocid
#   vcn_id         = oci_core_vcn.VCN_VM190825.id
#   display_name   = "VM190825-PizzaHUT-RT"

# }





#✅ ใช้ DRG ที่มีอยู่แล้ว โดยอ้างอิงจาก var.drg_id

resource "oci_core_drg_attachment" "drg_attachment" {
  drg_id       = var.drg_id
  display_name = "DRG-attach-drg-route"

  network_details {
    type = "VCN"
    id   = oci_core_vcn.VCN_VM190825.id
  }
}

resource "oci_core_route_table" "VM190825-PizzaHUT-RT" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.VCN_VM190825.id
  display_name   = "VM190825-PizzaHUT-RT"

  dynamic "route_rules" {
    for_each = { for i, cidr in var.destination : i => cidr }
    content {
      description       = var.description[route_rules.key]
      destination       = route_rules.value
      destination_type  = "CIDR_BLOCK"
      network_entity_id = var.drg_id   # 👈 อ้างถึง DRG เดิมโดยตรง
    }
  }

  lifecycle {
    ignore_changes = [freeform_tags, defined_tags, display_name]
  }
}
