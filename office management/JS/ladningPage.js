// State
let products = [];
let categories = [];
let cart = [];
let selectedCategory = "All";


function getImageUrl(filename) {
    if (!filename) return '';
    
    if (filename.startsWith('http') || filename.startsWith('/') || filename.includes('..') || filename.includes('images/')) {
        return filename;
    }
   
    return `../images/${filename}`;
}

document.addEventListener("DOMContentLoaded", () => {
    fetchProductsAndCategories();
});


async function fetchProductsAndCategories() {
    try {
        const response = await fetch('../phpFile/get_products.php');
        const data = await response.json();
        
        // Debug log the raw data
        console.log('Raw data from PHP:', data);
      
        if (Array.isArray(data)) {
            products = data.map(product => {
                console.log('Processing product:', product);
                return {
                    ...product,
                    variants: product.variants || [],
                    totalStock: (product.variants || []).reduce((sum, variant) => sum + (parseInt(variant.stock) || 0), 0)
                };
            });
            categories = [];
        } else {
            products = (data.products || []).map(product => {
                console.log('Processing product:', product);
                return {
                    ...product,
                    variants: product.variants || [],
                    totalStock: (product.variants || []).reduce((sum, variant) => sum + (parseInt(variant.stock) || 0), 0)
                };
            });
            categories = data.categories || [];
        }
        
        // Debug log the processed products
        console.log('Processed products:', products);
        
        renderProducts();
        renderCategories();
    } catch (error) {
        console.error('Error fetching data:', error);
        showNotification('Failed to load products', 'error');
    }
}

function renderProducts() {
    const productsGrid = document.getElementById("productsGrid");
    productsGrid.innerHTML = "";
    products.forEach((product) => {
        productsGrid.appendChild(createProductCard(product));
    });
}

function renderCategories() {
    const categoryFilter = document.getElementById("categoryFilter");
    categoryFilter.innerHTML = "";
    
    // Add "All" category first
    const allBtn = document.createElement("button");
    allBtn.textContent = "All";
    allBtn.className = "active";
    allBtn.onclick = function() {
        selectCategory("All", this);
    };
    categoryFilter.appendChild(allBtn);

    
    const predefinedCategories = [
        { id: 1, name: "Writing" },
        { id: 2, name: "Fasteners & Clips" },
        { id: 3, name: "Paper & Notebooks" },
        { id: 4, name: "Folders & Organizers" },
        { id: 5, name: "Adhesives & Tapes" },
        { id: 6, name: "Correction & Marking" },
        { id: 7, name: "Cutting Tools" }
    ];

    predefinedCategories.forEach((category) => {
        const btn = document.createElement("button");
        btn.textContent = category.name;
        btn.onclick = function() {
            selectCategory(category.id, this);
        };
        categoryFilter.appendChild(btn);
    });
}


function selectCategory(categoryId, buttonElement) {
    selectedCategory = categoryId;
    document.querySelectorAll(".categoryFilter button").forEach((btn) => {
        btn.classList.remove("active");
    });
    buttonElement.classList.add("active");
    filterProducts();
}

function filterProducts() {
    const searchTerm = document.getElementById("searchInput").value.toLowerCase();
    const productsGrid = document.getElementById("productsGrid");
    productsGrid.innerHTML = "";

    const filtered = products.filter((p) => {
        const matchesCategory = selectedCategory === "All" || parseInt(p.category_id) === parseInt(selectedCategory);
        const matchesSearch = p.name.toLowerCase().includes(searchTerm);
        return matchesCategory && matchesSearch;
    });

    if (filtered.length === 0) {
        productsGrid.innerHTML = '<div style="grid-column: 1/-1; text-align: center; color: #7b7b7b; padding: 2rem;">No products found</div>';
        return;
    }

    filtered.forEach((product) => {
        productsGrid.appendChild(createProductCard(product));
    });
}




function createProductCard(product) {
    const card = document.createElement("div");
    card.className = "itemDetails";
    card.dataset.productId = product.id;
    
    let optionsHTML = "";
    
   
    console.log('Product variants:', product.variants);
    
   
    if (!product.variants || product.variants.length === 0) {
        product.variants = [];
        if (product.sizes || product.colors) {
            if (product.sizes) {
                product.sizes.forEach(size => {
                    if (product.colors) {
                        product.colors.forEach(color => {
                            product.variants.push({
                                variant_id: Math.random(), 
                                size_option_id: size,
                                color_option_id: color,
                                stock: product.stock || 0
                            });
                        });
                    } else {
                        product.variants.push({
                            variant_id: Math.random(),
                            size_option_id: size,
                            color_option_id: null,
                            stock: product.stock || 0
                        });
                    }
                });
            } else if (product.colors) {
                product.colors.forEach(color => {
                    product.variants.push({
                        variant_id: Math.random(),
                        size_option_id: null,
                        color_option_id: color,
                        stock: product.stock || 0
                    });
                });
            }
        }
    }

    const variants = product.variants || [];
    console.log('Product variants after processing:', variants);
    
    // Build option lists using readable labels (prefer `size`/`color` from variants)
    const sizesOptions = [];
    const colorsOptions = [];
    variants.forEach(v => {
        if (v.size_option_id && !sizesOptions.some(s => String(s.id) === String(v.size_option_id))) {
            sizesOptions.push({ id: v.size_option_id, label: v.size || String(v.size_option_id) });
        }
        if (v.color_option_id && !colorsOptions.some(c => String(c.id) === String(v.color_option_id))) {
            colorsOptions.push({ id: v.color_option_id, label: v.color || String(v.color_option_id) });
        }
    });

    console.log('Available sizes:', sizesOptions);
    console.log('Available colors:', colorsOptions);

    if (sizesOptions.length > 0) {
        optionsHTML += `
            <div class="optionsSection">
                <label class="optionLabel">Size:</label>
                <div class="optionButtons" data-type="size" data-product-id="${product.id}">
                    ${sizesOptions.map(opt => {
                        const variantsWithSize = variants.filter(v => String(v.size_option_id) === String(opt.id));
                        const hasStock = variantsWithSize.some(v => v.stock > 0);
                        const disabled = !hasStock ? 'disabled' : '';
                        return `<button class="optionBtn" data-value="${opt.id}" ${disabled}>${opt.label}</button>`;
                    }).join("")}
                </div>
            </div>
        `;
    }

    if (colorsOptions.length > 0) {
        optionsHTML += `
            <div class="optionsSection">
                <label class="optionLabel">Color:</label>
                <div class="optionButtons" data-type="color" data-product-id="${product.id}">
                    ${colorsOptions.map(opt => {
                        const variantsWithColor = variants.filter(v => String(v.color_option_id) === String(opt.id));
                        const hasStock = variantsWithColor.some(v => v.stock > 0);
                        const disabled = !hasStock ? 'disabled' : '';
                        return `<button class="optionBtn" data-value="${opt.id}" ${disabled}>${opt.label}</button>`;
                    }).join("")}
                </div>
            </div>
        `;
    }

    // Calculate total stock to display (use product.totalStock if available)
    const displayStock = typeof product.totalStock === 'number' ? product.totalStock : variants.reduce((s,v) => s + (v.stock||0), 0) || product.stock || 0;

    card.innerHTML = `
        <div class="imageHolder">
            <img src="${getImageUrl(product.image)}" alt="${product.name}">
        </div>
        <div class="NameHolder">
            <div class="productName">${product.name}</div>
            <div class="productCategory">${product.category_name}</div>
            <div class="stockLevel">
                <span>Total Stock:</span>
                <span class="stockBadge">${displayStock} units</span>
            </div>
            
            ${optionsHTML}
            
            <div class="quantityControl">
                <button class="quantityBtn" onclick="decreaseQty(this)">−</button>
                <input type="number" class="quantityInput" value="1" min="1" max="1">
                <button class="quantityBtn" onclick="increaseQty(this)">+</button>
            </div>
            
            <button class="addBtn" onclick="addToCart(${product.id})" ${variants.length > 0 ? 'disabled' : (displayStock <= 0 ? 'disabled' : '')}>
                ${variants.length > 0 ? 'Select Options' : (displayStock <= 0 ? 'Out of Stock' : 'Add to Cart')}
            </button>
        </div>
    `

  const optionBtns = card.querySelectorAll(".optionBtn")
    // If there are no variant options, set quantity max from displayStock
    if (variants.length === 0) {
        const qtyInput = card.querySelector('.quantityInput');
        if (qtyInput) qtyInput.max = displayStock;
        const addBtn = card.querySelector('.addBtn');
        if (addBtn) addBtn.disabled = displayStock <= 0;
    }
  optionBtns.forEach((btn) => {
    btn.addEventListener("click", function () {
      if (this.disabled) return;
      
      const container = this.closest(".optionButtons")
      container.querySelectorAll(".optionBtn").forEach((b) => b.classList.remove("selected"))
      this.classList.add("selected")
      
      // Update stock and button state when options are selected
      updateVariantStock(card, product)
    })
  })

  return card
}


function increaseQty(btn) {
  const input = btn.previousElementSibling
  input.value = Number.parseInt(input.value) + 1
}

function decreaseQty(btn) {
  const input = btn.nextElementSibling
  if (Number.parseInt(input.value) > 1) {
    input.value = Number.parseInt(input.value) - 1
  }
}

function findVariant(product, sizeId, colorId) {
    return product.variants.find(v => {
        const vidSize = v.size_option_id != null ? String(v.size_option_id) : null;
        const vidColor = v.color_option_id != null ? String(v.color_option_id) : null;
        const s = sizeId != null ? String(sizeId) : null;
        const c = colorId != null ? String(colorId) : null;
        return (s === null || vidSize === s) && (c === null || vidColor === c);
    });
}

function updateVariantStock(card, product) {
    const sizeBtn = card.querySelector('[data-type="size"] .optionBtn.selected');
    const colorBtn = card.querySelector('[data-type="color"] .optionBtn.selected');
    const sizeId = sizeBtn ? sizeBtn.dataset.value : null;
    const colorId = colorBtn ? colorBtn.dataset.value : null;
    
    const variant = findVariant(product, sizeId, colorId);
    const qtyInput = card.querySelector('.quantityInput');
    const addBtn = card.querySelector('.addBtn');
    
    if (variant) {
        qtyInput.max = variant.stock;
        qtyInput.value = Math.min(parseInt(qtyInput.value), variant.stock);
        addBtn.disabled = variant.stock <= 0;
        addBtn.textContent = variant.stock <= 0 ? 'Out of Stock' : 'Add to Cart';
    } else {
        addBtn.disabled = true;
        addBtn.textContent = 'Select Options';
    }
}

function addToCart(productId) {
    const product = products.find((p) => p.id === productId);
    if (!product) {
        showNotification("Product not found!", "error");
        return;
    }

    const card = event.target.closest(".itemDetails");
    const quantity = parseInt(card.querySelector(".quantityInput").value);
    const sizeBtn = card.querySelector('[data-type="size"] .optionBtn.selected');
    const colorBtn = card.querySelector('[data-type="color"] .optionBtn.selected');

    if (product.variants.some(v => v.size_option_id) && !sizeBtn) {
        showNotification("Please select a size", "error");
        return;
    }
    if (product.variants.some(v => v.color_option_id) && !colorBtn) {
        showNotification("Please select a color", "error");
        return;
    }

    const sizeId = sizeBtn ? sizeBtn.dataset.value : null;
    const colorId = colorBtn ? colorBtn.dataset.value : null;

    const variant = findVariant(product, sizeId, colorId);
    
    if (!variant || variant.stock <= 0) {
        showNotification("Selected variant is out of stock!", "error");
        return;
    }

    const cartItem = {
        id: product.id,
        name: product.name,
        quantity: quantity,
        variant_id: variant.variant_id,
        size_option_id: variant.size_option_id,
        color_option_id: variant.color_option_id,
        size: variant.size || null,
        color: variant.color || null,
        image: product.image,
        stock: variant.stock,
    };

    const existing = cart.find(item => 
        item.id === cartItem.id && 
        item.variant_id === cartItem.variant_id
    );

    if (existing) {
        if (existing.quantity + quantity <= variant.stock) {
            existing.quantity += quantity;
            showNotification("Updated cart quantity!");
        } else {
            showNotification("Not enough stock available!", "error");
            return;
        }
    } else {
        if (quantity <= variant.stock) {
            cart.push(cartItem);
            showNotification("Added to cart!");
        } else {
            showNotification("Not enough stock available!", "error");
            return;
        }
    }

    updateCartCount();
}


function updateCartCount() {
  const count = cart.reduce((sum, item) => sum + item.quantity, 0)
  document.getElementById("cartCount").textContent = count
}


function toggleCart() {
  const modal = document.getElementById("cartModal")
  modal.classList.toggle("hidden")
  if (!modal.classList.contains("hidden")) {
    renderCart()
  }
}

// Render Cart
function renderCart() {
  const cartItems = document.getElementById("cartItems")
  cartItems.innerHTML = ""

  if (cart.length === 0) {
    cartItems.innerHTML = '<div class="emptyCart">Your cart is empty</div>'
    return
  }
  


  cart.forEach((item, index) => {
    const cartItem = document.createElement("div")
    cartItem.className = "cartItem"

    let optionsText = ""
    if (item.color) optionsText += `Color: ${item.color}`
    if (item.size) optionsText += (optionsText ? ` | ` : "") + `Size: ${item.size}`

    cartItem.innerHTML = `
                <div class="cartItemImage">
                    <img src="${getImageUrl(item.image)}" alt="${item.name}">
                </div>
            <div class="cartItemDetails">
                <div class="cartItemName">${item.name}</div>
                <div class="cartItemMeta">Qty: ${item.quantity}</div>
                ${optionsText ? `<div class="cartItemMeta">${optionsText}</div>` : ""}
                <div class="cartItemActions">
                    <button class="removeCartBtn" onclick="removeFromCart(${index})">Remove</button>
                </div>
            </div>
        `
    cartItems.appendChild(cartItem)
  })
}


function removeFromCart(index) {
  cart.splice(index, 1)
  updateCartCount()
  renderCart()
}


async function submitOrder() {
    if (cart.length === 0) {
        showNotification("Your cart is empty!", "error");
        return;
    }
   
    const employeeEl = document.getElementById("employeeName");
    if (!employeeEl) {
        showNotification("Employee name field is missing!", "error");
        return;
    }
    const deptEl = document.getElementById("department");
    if (!deptEl) {
        showNotification("Department field is missing!", "error");
        return;
    }
    const employeeName = employeeEl ? employeeEl.value.trim() : "";
    const department = deptEl ? deptEl.value : "";

    const orderData = {
        employee_name: employeeName,
        department: department,
        items: cart.map(item => ({
            product_id: item.id,
            variant_id: item.variant_id,
            quantity: item.quantity
        })),
        total_amount: cart.reduce((total, item) => total + (item.quantity), 0)
    };

    try {
        const response = await fetch('../phpFile/submit_order.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(orderData)
        });

        const result = await response.json();
        
        if (result.success) {
            const orderSummary = cart
                .map((item) => {
                    let details = `${item.quantity}x ${item.name}`;
                    if (item.color) details += ` (${item.color}`;
                    if (item.size) details += `, ${item.size}`;
                    if (item.color || item.size) details += ")";
                    return details;
                })
                .join("\n");

            showNotification("Order placed successfully!");
            cart = [];
            updateCartCount();
            toggleCart();
            
            // Refresh products to update stock levels
            await fetchProductsAndCategories();
        } else {
            showNotification("Failed to place order: " + result.message, "error");
        }
    } catch (error) {
        console.error('Error submitting order:', error);
        showNotification("Failed to submit order. Please try again.", "error");
    }
}


function showNotification(message) {
  const notification = document.createElement("div")
  notification.style.cssText =
    "position: fixed; bottom: 20px; right: 20px; background-color: #E53935; color: white; padding: 1rem 1.5rem; border-radius: 8px; z-index: 2000; animation: slideIn 0.3s ease;"
  notification.textContent = message
  document.body.appendChild(notification)

  setTimeout(() => notification.remove(), 3000)
}
