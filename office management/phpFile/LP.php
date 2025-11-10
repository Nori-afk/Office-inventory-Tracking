<?php

?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Office Supplies Store</title>
    <link rel="stylesheet" href="../Css/style.css">
    <script src="../JS/ladningPage.js"></script>
</head>
<body>
    <div class="holder">
        
        <div class="topBar">
            <div class="logo">
                <div class="logoIcon">
                    <img src="../images/logo-removebg-preview.png" alt="Logo" class="logoImage" onclick=>
                </div>
          
            </div>
            <button class="cartBtn" onclick="toggleCart()">
             Cart (<span id="cartCount">0</span>)
            </button>
        </div>

       
        <div class="FormHolder">
            <input type="text" id="searchInput" placeholder="Search products..." class="searchInput" onkeyup="filterProducts()">
            <div class="filterSection">
                <label>Filter by Category:</label>
                <div class="categoryFilter" id="categoryFilter"></div>
            </div>
        </div>

     
        <div class="itemHolders">
            <div class="labels">
                <h2>Available Products</h2>
            </div>
            <div class="items" id="productsGrid">
              
            </div>
        </div>
    </div>


    <div id="cartModal" class="cartModal hidden">
        <div class="cartContent">
            <div class="cartHeader">
                <h2>Shopping Cart</h2>
                <button class="closeBtn" onclick="toggleCart()">✕</button>
            </div>
            <div id="cartItems" class="cartItems"></div>
            <!-- added employee name and notes form fields -->
            <div id="cartFormSection" class="cartFormSection">
                <div class="formGroup">
                    <label for="employeeName">Employee Name *</label>
                    <input type="text" id="employeeName" placeholder="Enter your name" class="formInput">
                </div>
                    <div class="formGroup">
                        <label for="department">Department *</label>
                        <select id="department" class="formInput">
                            <option value="">-- Select Department --</option>
                            <option value="HR">HR</option>
                            <option value="Finance">Finance</option>
                            <option value="Office General">Office General</option>
                            <option value="Operation">Operation</option>
                        </select>
                    </div>
            </div>
            <div class="cartFooter">
                <button class="submitBtn" onclick="submitOrder()">Submit</button>
                <button class="cancelBtn" onclick="toggleCart()">Continue Viewing</button>
            </div>
        </div>
    </div>


    
</body>
</html>
