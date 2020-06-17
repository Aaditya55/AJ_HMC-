//connection with aws

provider "aws"{ 
   profile    = "aaditya"    //Enter your profile name which set at cli login 
   region     = "ap-south-1"
   
  }

//connection with aws end
//creating security grp start

resource "aws_security_group" "ajsec"{
    name        = "ajterasecty"
    ingress{
          description = "TLS from VPC"
          from_port   = 80
          to_port     = 80
          protocol    = "TCP"
          cidr_blocks = ["0.0.0.0/0"]
      }
    ingress{
           description = "TLS from VPC"

           from_port   = 22
           to_port     = 22
           protocol    = "TCP"
           cidr_blocks = ["0.0.0.0/0"]
      }
    egress{
           from_port   = 0
           to_port     = 0
           protocol    = "-1"
           cidr_blocks = ["0.0.0.0/0"]
      }

    tags ={
           Name = "ajterasecty"
      }
}

//creating security grp end
//creating instance

resource "aws_instance" "ajins"{
    ami	   	= "ami-0447a12f28fddb066" //enter ami/os image id if you want another os(now it is amazon linux)
    instance_type   ="t2.micro"
    security_groups =[aws_security_group.ajsec.name]
    key_name   = "Aaditya"                //enter key_pair name you created at aws console

    tags ={
        Name = "ajterainstan"
      }
}

 //to print details of instance
output"ins_i_pi"{
	   value=aws_instance.ajins.public_ip
  }
//to print details of instance end
//creating instance end
//to creating ebs volume

resource "aws_ebs_volume" "ajebs"{
  availability_zone = aws_instance.ajins.availability_zone
  size              = 1
  tags ={
    Name = "ajteraebs"
  }
}

//to creating ebs volume
//to attach volume with instance

resource "aws_volume_attachment" "ajebsatt"{
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.ajebs.id
  instance_id = aws_instance.ajins.id
  force_detach= true
}

//to attach volume with instance

//to lauch server

resource "null_resource" "runserver"{

depends_on = [
          aws_volume_attachment.ajebsatt,
          ]

connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("C:/Users/aadit/Downloads/Aaditya.pem")  
    host     = aws_instance.ajins.public_ip
  }

provisioner "remote-exec"{
    inline = [
      "sudo yum install httpd git -y",
      "sudo systemctl restart httpd", 
      "sudo systemctl enable httpd",
      "sudo mkfs.ext4 /dev/xvdf",
      "sudo mount /dev/xvdf /var/www/html",
      "sudo rm -rf /var/www/html/*",
      "sudo git clone https://github.com/Aaditya55/AJ_HMC-.git /var/www/html/"  //edit the path of source code enter your site path  	
    ]
  }

}

resource "null_resource" "download_IP"{

    depends_on = [
    null_resource.runserver,
    ]
    provisioner "local-exec"{
          command = "echo ${aws_instance.ajins.public_ip} > yourdomain.text "   //you will get your ip address in "yourdomain.txt" file in directory where you run this code    
      }
  }
//to lauch server end
