moved {
  from = aws_subnet.private_subnet[0]
  to = aws_subnet.private_subnet["a"]
}
moved {
  from = aws_subnet.private_subnet[1 ]
  to = aws_subnet.private_subnet["b"]
}
moved {
  from = aws_subnet.public_subnet[0]
  to = aws_subnet.public_subnet["a"]
}
moved {
  from = aws_subnet.public_subnet[1]
  to = aws_subnet.public_subnet["b"]
}