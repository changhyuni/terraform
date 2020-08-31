variable "cidr" {
  description = "vpc의 cidr을 정의"
  type = "string"
}

variable "public_subnets" {
  description = "퍼블릭 서브넷들을 정의"
  type = "list"
}

variable "private_subnets" {
  description = "프라이빗 서브넷들을 정의"
  type = "list"
}

variable "azs" {
  description = "가용영역 정의"
  type = "list"
}

variable "tags" {
  description = "tag를 정의"
  type = "map"
}

variable "name" {
  description = "리소스 기본 name을 정의"
  type = "string"
}
