# ============================
# Variables
# ============================
#ต้นทาง
variable "compartment_ocid" {
  default = "ocid1.compartment.oc43..aaaaaaaad2lw77q2dzehxcvjjcxzd5cg4szqwzhhxk7nrfakffhxjjdiiigq"
}

# DRG ที่มีอยู่แล้ว (ต้องไป copy OCID ของ DRG เดิมมาใส่)
variable "drg_id" {default = "ocid1.drg.oc43.ap-pathumthani-1.aaaaaaaaoloit7rhsgjagqsqh4l74de2ov6ll7svedam52dzswq3477w45uq"}

# ============================
# Resources
# ============================
# แก้ชื่อ VCN
resource "oci_core_vcn" "TestVCN" {
  display_name   = "TestVCN"
  cidr_block     = "192.168.172.0/24"
  compartment_id = var.compartment_ocid
}




# #Roll back

# resource "oci_core_route_table" "VM190421-PizzaHUT-RT" {
#   compartment_id = var.compartment_ocid
#   vcn_id         = oci_core_vcn.TestVCN.id
#   display_name   = "VM190421-PizzaHUT-RT"

# }



/*********************************************************************************************/

# ❌ ไม่ต้องสร้าง DRG ใหม่
# ✅ ใช้ DRG ที่มีอยู่แล้ว โดยอ้างอิงจาก var.drg_id

resource "oci_core_drg_attachment" "drg_attachment" {
  drg_id       = var.drg_id
  display_name = "DRG-attach-drg-route"

  network_details {
    type = "VCN"
    id   = oci_core_vcn.TestVCN.id
  }
}

resource "oci_core_route_table" "VM190421-PizzaHUT-RT" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.TestVCN.id
  display_name   = "VM190421-PizzaHUT-RT"

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
