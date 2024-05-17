#!/bin/bash
apt update
apt install -y apache2

# Install the AWS CLI
apt install -y awscli

# Download the images from S3 bucket
#aws s3 cp s3://myterraformprojectbucket2023/project.webp /var/www/html/project.png --acl public-read

# Create a simple HTML file with the portfolio content and display the images
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Amazon Prime Login</title>
    <style>
        body {
            margin: 0;
            padding: 0;
            font-family: Arial, sans-serif;
            background: #232F3E;
            color: #fff;
            height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
        }
        .container {
            max-width: 400px;
            background-color: #fff;
            padding: 20px;
            border-radius: 5px;
            box-shadow: 0px 0px 10px rgba(0, 0, 0, 0.3);
            text-align: center;
        }
        .logo img {
            width: 200px;
            margin-bottom: 20px;
        }
        input[type="text"],
        input[type="password"],
        input[type="submit"] {
            width: 100%;
            padding: 10px;
            margin: 5px 0;
            border: 1px solid #ccc;
            border-radius: 3px;
            box-sizing: border-box;
        }
        input[type="submit"] {
            background-color: #FF9900;
            color: #fff;
            cursor: pointer;
        }
        input[type="submit"]:hover {
            background-color: #FFAD33;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="logo">
            <img src="https://cdn4.iconfinder.com/data/icons/logos-brands-in-colors/92/amazon-prime-logo-512.png" alt="Amazon Prime Logo">
        </div>
        <h2>Sign In to Amazon Prime</h2>
        <form action="https://www.amazon.com/ap/signin" method="post">
            <input type="text" name="email" placeholder="Email" required>
            <input type="password" name="password" placeholder="Password" required>
            <input type="submit" value="Sign In">
        </form>
        <p>New to Amazon Prime? <a href="https://www.amazon.com/gp/prime/signup">Sign up now</a>.</p>
    </div>
</body>
</html>


EOF

# Start Apache and enable it on boot
systemctl start apache2
systemctl enable apache2