namespace com.taller;

using {
    cuid,
    managed,
    sap.common.CodeList,
    sap.common.Currencies
} from '@sap/cds/common';

using {API_BUSINESS_PARTNER as cloud} from '../srv/external/API_BUSINESS_PARTNER';
entity Products : cuid, managed {
    product       : String(8);
    productName   : String(80);
    description   : LargeString;
    image         : LargeBinary @Core.MediaType: imageType @UI.IsImage;
    imageType     : String      @Core.IsMediaType;
    category      : Association to Categories; //category      --- category_ID
    subCategory   : Association to SubCategories; //subCategory   --- subCategory_ID
    statu         : Association to Status; //statu --- statu_code
    price         : Decimal(10, 2);
    rating        : Decimal(3, 2);
    currency      : Association to Currencies;
    detail        : Composition of ProductDetails;   
    supplier      : Association to Suppliers;  
    supplierCloud : Association to cloud.A_Supplier;
    toReviews     : Association to many Reviews
                        on toReviews.product = $self;
    toInventories : Composition of many Inventories
                        on toInventories.product = $self;
    toSales       : Association to many Sales
                        on toSales.product = $self;
};

type decimal : Decimal(6, 3);

entity ProductDetails : cuid {
    baseUnit   : String default 'EA';
    width      : decimal;
    height     : decimal;
    depth      : decimal;
    weight     : decimal;
    unitVolume : String default 'CM';
    unitWeight : String default 'KG';
};

entity Suppliers : cuid {
    supplier     : String(9);
    supplierName : String(40);
    webAddress   : String(250);
    contact      : Association to Contacts;
};

entity Contacts : cuid {
    fullName    : String(40);
    email       : String(80);
    phoneNumber : String(14);
};

entity Reviews : cuid {
    rating     : Decimal(3, 2);
    date       : Date;
    user       : String(20);
    reviewText : LargeString;
    product    : Association to Products;
};

entity Inventories : cuid {
    stockNumber : String(9);
    department  : Association to Departments;
    min         : Integer default 0;
    max         : Integer default 500;
    target      : Integer;
    quantity    : Decimal(7, 3);
    baseUnit    : String default 'EA';
    product     : Association to Products;
};

entity Sales : cuid {
    monthCode     : String(2);
    month         : String(20);
    year          : String(4);
    quantitySales : Integer;
    product       : Association to Products;
};

/** Code List */

entity Status : CodeList {
    key code        : String(20) enum {
            InStock = 'In Stock';
            OutOfStock = 'Out of Stock';
            LowAvailability = 'Low Availability';
        };
        criticality : Integer;
};

entity Options : CodeList {
    key code : String(10) enum {
        A = 'Add';
        D = 'Discount';
    }
}

/** Value Helps */

entity Categories : cuid {
    category        : String(80);
    toSubCategories : Association to many SubCategories
                          on toSubCategories.category = $self;
};

entity SubCategories : cuid {
    subCategory : String(80);
    category    : Association to Categories;
};

entity Departments : cuid {
    department : String(40);
};


entity CartItem : cuid, managed {
  product  : Association to Products not null;
  quantity : Integer  @assert.range:[1,9999] default 1;
  user     : String(100);
  status   : String enum { OPEN; ORDERED; } default 'OPEN';
}

view CartItemView as select from CartItem {
  ID,
  user,
  status,
  quantity,

  product.ID          as product_ID,
  product.product     as productCode,
  product.productName as productName,
  product.price       as unitPrice,
  product.currency    as currency,

  (quantity * product.price) as subtotal : Decimal(15,2) // ← tipo explícito
};