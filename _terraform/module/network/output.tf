output "aws_vpc" {
  value = aws_vpc.main.id
}

# 퍼블릭 서브넷 
output "aws_subnet" {
  value = {
    main-public-1 = aws_subnet.main-public-1.id
    main-public-2 = aws_subnet.main-public-2.id
    main-public-3 = aws_subnet.main-public-3.id
  }
}
