variable "instance_count" {
    default = "3"
}

variable "instance_tags" {
    type = "list"
    default = ["myweb", "myweb2", "loanman"]
}
