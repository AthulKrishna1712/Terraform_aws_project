#!/bin/bash
apt update
apt install -y apache2

# Create the HTML file
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Netflix Login</title>
    <style>
        body {
            margin: 0;
            padding: 0;
            font-family: Arial, sans-serif;
            background: linear-gradient(to bottom, rgba(0,0,0,0.8), rgba(0,0,0,0.6)), url('https://assets.nflxext.com/ffe/siteui/vlv3/92f12566-7037-44c6-a51f-6d95e6db3a94/579d53a4-e17b-4f22-934e-0c8757bf7812/IN-en-20220425-popsignuptwoweeks-perspective_alpha_website_small.jpg') no-repeat center center/cover;
            height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
        }
        .container {
            max-width: 400px;
            background-color: rgba(0, 0, 0, 0.8);
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
            background-color: #e50914;
            color: #fff;
            cursor: pointer;
        }
        input[type="submit"]:hover {
            background-color: #cc0812;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="logo">
            <img src="https://upload.wikimedia.org/wikipedia/commons/0/08/Netflix_2015_logo.svg" alt="Netflix Logo">
        </div>
        <form action="https://www.netflix.com/login" method="post">
            <input type="text" name="username" placeholder="Email or phone number" required>
            <input type="password" name="password" placeholder="Password" required>
            <input type="submit" value="Sign In">
        </form>
        <p>New to Netflix? <a href="https://www.netflix.com/signup">Sign up now</a>.</p>
    </div>
</body>
</html>
EOF

# Adjust ownership and permissions
chown www-data:www-data /var/www/html/index.html
chmod 644 /var/www/html/index.html

# Restart Apache to apply changes
systemctl restart apache2
