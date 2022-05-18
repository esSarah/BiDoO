
-- Table: Shop
CREATE TABLE Shop ( 
    ShopID CHAR( 24 )      PRIMARY KEY
                           NOT NULL
                           UNIQUE,
    Name   VARCHAR( 255 )  NOT NULL,
    Street VARCHAR( 255 ),
    City   VARCHAR( 255 ),
    Zip    VARCHAR 
);


-- Table: Bills
CREATE TABLE Bills ( 
    BillID         CHAR( 24 )  PRIMARY KEY
                               NOT NULL,
    ShopID         CHAR( 24 )  NOT NULL,
    DateOfPurchase DATE        NOT NULL 
);


-- Table: Items
CREATE TABLE Items ( 
    ItemID       CHAR( 24 )      PRIMARY KEY
                                 NOT NULL
                                 UNIQUE,
    BillID       CHAR( 24 )      NOT NULL,
    ItemDeciptor VARCHAR( 255 )  NOT NULL,
    ItemValue    REAL            NOT NULL 
);

