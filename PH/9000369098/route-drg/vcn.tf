# ============================
# Variables
# ============================
#ต้นทาง
# 9000369098
variable "compartment_ocid" {
  default = "ocid1.compartment.oc43..aaaaaaaakaoxddcb27wqtgpbsm365xax53txzn3zip7exkk3v7zv3s6std5a"
}

# DRG ที่มีอยู่แล้ว (ต้องไป copy OCID ของ DRG เดิมมาใส่)
variable "drg_id" {default = "ocid1.drg.oc43.ap-pathumthani-1.aaaaaaaaex676ijrtwhnuk25xrq5grb2iut2laivfy6mklmqvqoajsgqvwvq"}

# ============================
# Resources
# ============================
#compartment 9000369098
resource "oci_core_vcn" "VCN_9000369098" {
  display_name   = "9000369098"
  cidr_block     = "192.168.214.0/24"
  compartment_id = var.compartment_ocid
}

/****************************************************************/


#Roll back

# resource "oci_core_route_table" "PizzaHUT-RT-9000369098" {
#   compartment_id = var.compartment_ocid
#   vcn_id         = oci_core_vcn.VCN_9000369098.id
#   display_name   = "9000369098-PizzaHUT-RT"

# }



/****************************************************************/





#✅ ใช้ DRG ที่มีอยู่แล้ว โดยอ้างอิงจาก var.drg_id

resource "oci_core_drg_attachment" "drg_attachment" {
  drg_id       = var.drg_id
  display_name = "DRG-attach-drg-route"

  network_details {
    type = "VCN"
    id   = oci_core_vcn.VCN_9000369098.id
  }
}

resource "oci_core_route_table" "PizzaHUT-RT-9000369098" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.VCN_9000369098.id
  display_name   = "9000369098-PizzaHUT-RT"

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
