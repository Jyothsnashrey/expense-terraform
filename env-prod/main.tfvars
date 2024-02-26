env = "prod"
project_name = "expense"
kms_key_id  = "arn:aws:kms:us-east-1:046694289523:key/61697761-0640-4796-8fb9-1e709acec556"
bastion_cidrs = ["172.31.45.81/32"]  #/32 represents one IP.
prometheus_cidrs =["172.31.23.47/32"]
acm_arn       = "arn:aws:acm:us-east-1:046694289523:certificate/32a0c8da-3f9c-466f-ad68-dbba56cd468a"
zone_id       = "Z0280752N15KXNCY0H6Y"



vpc_cidr = "10.20.0.0/21"
public_subnets_cidr = ["10.20.0.0/25","10.20.0.128/25"]
web_subnets_cidr = ["10.20.1.0/25","10.20.1.128/25"]
app_subnets_cidr = ["10.20.2.0/25","10.20.2.128/25"]
db_subnets_cidr = ["10.20.3.0/25","10.20.3.128/25"]
az              = ["us-east-1a", "us-east-1b"]


rds_allocated_storage    = 10
rds_db_name              = "expense"
rds_engine               = "mysql"
rds_engine_version       = "5.7"
rds_instance_class       = "db.t3.micro"
rds_family               = "mysql5.7"


backend_app_port = 8080
backend_instance_capacity = 2
backend_instance_type = "t3.small"

frontend_app_port = 80
frontend_instance_capacity = 2
frontend_instance_type = "t3.small"
