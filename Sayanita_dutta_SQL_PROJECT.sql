

/* SAYANITA DUTTA
   MYSQL PROJECT
   21-03-2023 */


use orders;

/* 1. Write a query to display customer full name with their title (Mr/Ms), both first name and
last name are in upper case, customer email id, customer creation date and display
customer’s category after applying below categorization rules:
i. IF customer creation date Year <2005 Then Category A
ii. IF customer creation date Year >=2005 and <2011 Then Category B
iii. iii)IF customer creation date Year>= 2011 Then Category C
Hint: Use CASE statement, no permanent change in table required.
[NOTE: TABLES to be used - ONLINE_CUSTOMER TABLE] */
select * from ONLINE_CUSTOMER;
SELECT 
    CASE
        WHEN
            CUSTOMER_GENDER = 'M'
        THEN
            CONCAT('Mr. ',
                    UPPER(CUSTOMER_FNAME),
                    ' ',
                    UPPER(CUSTOMER_LNAME))
        WHEN
            CUSTOMER_GENDER = 'F'
        THEN
            CONCAT('Ms. ',
                    UPPER(CUSTOMER_FNAME),
                    ' ',
                    UPPER(CUSTOMER_LNAME))
    END AS CUSTOMER_NAME, CUSTOMER_EMAIL,
    CUSTOMER_CREATION_DATE,
    CASE
    WHEN YEAR(CUSTOMER_CREATION_DATE)<2005
    THEN "CATEGORY A"
    WHEN YEAR(CUSTOMER_CREATION_DATE)>=2005 AND YEAR(CUSTOMER_CREATION_DATE)<2011
    THEN "CATEGORY B"
    ELSE "CATEGORY C"
    -- WHEN YEAR(CUSTOMER_CREATION_DATE)>=2011
    -- THEN "CATEGORY C"
    END CUSTOMER_CATEGORY
    FROM ONLINE_CUSTOMER;
    
   /* 2. Write a query to display the following information for the products, which have not been sold:
   product_id, product_desc, product_quantity_avail, product_price, inventory values 
   (product_quantity_avail*product_price), New_Price after applying discount as per below criteria.
   Sort the output with respect to decreasing value of Inventory_Value.
   i)      IF Product Price > 20,000 then apply 20% discount 
   ii)     IF Product Price > 10,000 then apply 15% discount  
   iii)     IF Product Price =< 10,000 then apply 10% discount   
   # Hint: Use CASE statement, no permanent change in table required.   
   [NOTE: TABLES to be used - PRODUCT, ORDER_ITEMS TABLE] */
   
   SELECT 
   PRODUCT_ID,
   PRODUCT_DESC, 
   PRODUCT_QUANTITY_AVAIL, 
   PRODUCT_PRICE, 
   (PRODUCT_QUANTITY_AVAIL*PRODUCT_PRICE) AS inventory_values,
   CASE
   WHEN PRODUCT_PRICE>20000
   THEN PRODUCT_PRICE*0.80
   WHEN PRODUCT_PRICE>10000 AND PRODUCT_PRICE<=20000
   THEN PRODUCT_PRICE*0.85
   WHEN PRODUCT_PRICE<=10000
   THEN PRODUCT_PRICE*0.90
   END New_Price
   FROM PRODUCT 
   WHERE PRODUCT_ID NOT IN (SELECT PRODUCT_ID FROM order_items)
   ORDER BY 5 DESC;
   
   /* 3.Write a query to display Product_class_code, Product_class_description, 
   Count of Product type in each product class, Inventory 
   Value (product_quantity_avail*product_price).  
   Information should be displayed for only those product_class_code which 
   have more than  1,00,000. Inventory Value. Sort the output with respect to 
   decreasing value of Inventory_Value.   
   [NOTE: TABLES to be used - PRODUCT, PRODUCT_CLASS] */
   
SELECT 
	pc.PRODUCT_CLASS_CODE,
    pc.PRODUCT_CLASS_DESC,
    COUNT(PRODUCT_ID),
    SUM((PRODUCT_QUANTITY_AVAIL * PRODUCT_PRICE)) AS Inventory_Value
FROM product p
INNER JOIN
product_class pc ON p.PRODUCT_CLASS_CODE = pc.PRODUCT_CLASS_CODE
GROUP BY pc.PRODUCT_CLASS_CODE , pc.PRODUCT_CLASS_DESC
HAVING Inventory_Value > 100000
ORDER BY 4 DESC; 

/* 4. Write a query to display customer_id, full name, customer_email, 
customer_phone and country of customers who have cancelled all the orders
 placed by them (USE SUB-QUERY)[NOTE: TABLES to be used - ONLINE_CUSTOMER,
 ADDRESSS, ORDER_HEADER] */
 
SELECT 
OC.CUSTOMER_ID,
CONCAT(OC.CUSTOMER_FNAME, 
         ' ', 
         OC.CUSTOMER_LNAME) AS FULL_NAME, 
OC.CUSTOMER_EMAIL, 
OC.CUSTOMER_PHONE,
A.COUNTRY 
FROM 
   online_customer OC
JOIN 
    address A ON OC.ADDRESS_ID = A.ADDRESS_ID
    WHERE 
       OC.CUSTOMER_ID IN 
           (SELECT CUSTOMER_ID 
            FROM order_header 
            WHERE 
            ORDER_STATUS='Cancelled');

/* 5. Write a query to display Shipper name, City to which it is catering, 
number of customers catered by the shipper in the city and number of 
consignments delivered to that city for Shipper DHL 
[NOTE: TABLES to be used - SHIPPER,ONLINE_CUSTOMER, ADDRESSS, ORDER_HEADER] */

SELECT 
	S.SHIPPER_NAME, 
	A.CITY,
    COUNT(DISTINCT OC.CUSTOMER_ID) Number_of_customer,
    COUNT(ORDER_ID) Number_of_consignments_delivered
    FROM 
		shipper S
	JOIN
		order_header OH ON OH.SHIPPER_ID = S.SHIPPER_ID
	JOIN 
		online_customer OC ON OC.CUSTOMER_ID = OH.CUSTOMER_ID
	JOIN
		address A ON A.ADDRESS_ID = OC.ADDRESS_ID
	WHERE
		S.SHIPPER_NAME = 'DHL'
	GROUP BY
		S.SHIPPER_NAME, A.CITY;
   
/* 6. Write a query to display product_id, product_desc, product_quantity_avail,
quantity sold and show inventory Status of products as below as per below 
condition: a. For Electronics and Computer categories, if sales till date is 
Zero then show 'No Sales in past, give discount to reduce inventory', if 
inventory quantity is less than 10% of quantity sold,show 'Low inventory, 
need to add inventory', if inventory quantity is less than 50% of quantity sold, 
show 'Medium inventory, need to add some inventory', if inventory quantity is 
more or equal to 50% of quantity sold, show 'Sufficient inventory' b. For
Mobiles and Watches categories, if sales till date is Zero then show 
'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 20% of quantity sold, 
show 'Low inventory, need to add inventory', 
if inventory quantity is less than 60% of quantity sold, show 
'Medium inventory, need to add some inventory', if inventory quantity is more 
or equal to 60% of quantity sold, show 'Sufficient inventory' c. Rest of the 
categories, if sales till date is Zero then show 'No Sales in past, give discount 
to reduce inventory', if inventory quantity is less than 30% of quantity sold, 
show 'Low inventory, need to add inventory', if inventory quantity is less than 
70% of quantity sold, show 'Medium inventory, need to add some inventory', 
if inventory quantity is more or equal to 70% of quantity sold, show 
'Sufficient inventory' -- (USE SUB-QUERY) -- [NOTE: TABLES to be used - PRODUCT, 
PRODUCT_CLASS, ORDER_ITEMS] */

SELECT 
    PRODUCT_ID,
    PRODUCT_DESC,
    PRODUCT_CLASS_DESC,
    PRODUCT_QUANTITY_AVAIL,
    Quantity_Sold,
    CASE
	WHEN
		PRODUCT_CLASS_DESC IN ('Electronics' , 'Computer')
		AND Quantity_Sold = 0
	THEN
		'No Sales in past, give discount to reduce inventory'
	WHEN
		PRODUCT_CLASS_DESC IN ('Electronics' , 'Computer')
		AND PRODUCT_QUANTITY_AVAIL < .1 * Quantity_Sold
	THEN
		'Low inventory, need to add inventory'
	WHEN
		PRODUCT_CLASS_DESC IN ('Electronics' , 'Computer')
		AND PRODUCT_QUANTITY_AVAIL < .5 * Quantity_Sold
		AND PRODUCT_QUANTITY_AVAIL >= .1 * Quantity_Sold
	THEN
		'Medium inventory, need to addsome inventory'
	WHEN
		PRODUCT_CLASS_DESC IN ('Electronics' , 'Computer')
		AND PRODUCT_QUANTITY_AVAIL >= .5 * Quantity_Sold
	THEN
		'Sufficient inventory'
	WHEN
		PRODUCT_CLASS_DESC IN ('Mobiles' , 'Watches')
		AND Quantity_Sold = 0
	THEN
		'No Sales in past, give discount to reduce inventory'
	WHEN
		PRODUCT_CLASS_DESC IN ('Mobiles' , 'Watches')
		AND PRODUCT_QUANTITY_AVAIL < .2 * Quantity_Sold
	THEN
		'Low inventory, need to add inventory'
	WHEN
		PRODUCT_CLASS_DESC IN ('Mobiles' , 'Watches')
		AND PRODUCT_QUANTITY_AVAIL < .6 * Quantity_Sold
		AND PRODUCT_QUANTITY_AVAIL >= .2 * Quantity_Sold
	THEN
		'Medium inventory, need to add some inventory'
	WHEN
		PRODUCT_CLASS_DESC IN ('Mobiles' , 'Watches')
		AND PRODUCT_QUANTITY_AVAIL >= .6 * Quantity_Sold
	THEN
		'Sufficient inventory'
	ELSE CASE
	WHEN Quantity_Sold = 0 
    THEN 'No Sales in past, give discount to reduce inventory'
	WHEN PRODUCT_QUANTITY_AVAIL < .3 * Quantity_Sold 
    THEN 'Low inventory, need to add inventory'
	WHEN
		PRODUCT_QUANTITY_AVAIL < .7 * Quantity_Sold
		AND PRODUCT_QUANTITY_AVAIL >= .3 * Quantity_Sold
	THEN
		'Medium inventory, need to add some inventory'
	WHEN PRODUCT_QUANTITY_AVAIL >= .7 * Quantity_Sold 
    THEN 'Sufficient inventory'
    END
    END Inventory_Status
FROM
    (SELECT 
        P.PRODUCT_ID,
		P.PRODUCT_DESC,
		P.PRODUCT_QUANTITY_AVAIL,
		PC.PRODUCT_CLASS_CODE,
		PC.PRODUCT_CLASS_DESC,
		SUM(IFNULL(OI.PRODUCT_QUANTITY, 0)) Quantity_Sold
    FROM
        order_items OI
    RIGHT OUTER JOIN 
		product P ON OI.PRODUCT_ID = P.PRODUCT_ID
    JOIN 
		product_class PC ON P.PRODUCT_CLASS_CODE = PC.PRODUCT_CLASS_CODE
    GROUP BY P.PRODUCT_ID , P.PRODUCT_DESC , P.PRODUCT_QUANTITY_AVAIL , 
    PC.PRODUCT_CLASS_CODE) parent_table;
    
/* 7. Write a query to display order_id and volume of the biggest order 
(in terms of volume) that can fit in carton id 10 -- 
[NOTE: TABLES to be used - CARTON, ORDER_ITEMS, PRODUCT] */

SELECT 
	ORDER_ID,
    SUM(OI.PRODUCT_QUANTITY * P.LEN * P.WIDTH * P.HEIGHT) AS VOLUME
FROM 
	order_items AS OI
JOIN 
	product AS P ON P.PRODUCT_ID = OI.PRODUCT_ID
GROUP BY ORDER_ID
HAVING VOLUME <= (SELECT 
        LEN * WIDTH * HEIGHT
    FROM
        carton
    WHERE
        CARTON_ID = 10)
ORDER BY VOLUME DESC;

/* 8. Write a query to display customer id, customer full name, total 
quantity and total value (quantity*price) shipped where mode of payment 
is Cash and customer last name starts with 'G' --[NOTE: TABLES to be used 
- ONLINE_CUSTOMER, ORDER_ITEMS, PRODUCT, ORDER_HEADER] */

SELECT 
	OC.CUSTOMER_ID,
	CONCAT(OC.CUSTOMER_FNAME, ' ', OC.CUSTOMER_LNAME) FULL_NAME,
    SUM(OI.PRODUCT_QUANTITY) AS TOTAL_QUANTITY,
    SUM(OI.PRODUCT_QUANTITY * P.PRODUCT_PRICE) AS TOTAL_VALUE
    FROM 
		online_customer OC
	JOIN
		order_header OH ON OH.CUSTOMER_ID = OC.CUSTOMER_ID
	JOIN
		order_items OI ON OI.ORDER_ID = OH.ORDER_ID
	JOIN 
		product P ON P.PRODUCT_ID = OI.PRODUCT_ID
    WHERE OH.PAYMENT_MODE = 'Cash'
		AND OC.CUSTOMER_LNAME LIKE 'G%'
	GROUP BY OC.CUSTOMER_ID, FULL_NAME;
   
  /* 9. Write a query to display product_id, product_desc and total quantity 
  of products which are sold together with product id 201 and are not shipped 
  to city Bangalore and New Delhi. Display the output in descending order 
  with respect to the tot_qty. -- (USE SUB-QUERY) -- 
  [NOTE: TABLES to be used - order_items, product,order_header, 
  online_customer, address] */
  
  SELECT 
	OI.PRODUCT_ID,
    P.PRODUCT_DESC,
    SUM(OI.PRODUCT_QUANTITY) AS TOTAL_QUANTITY
    FROM 
		order_items AS OI
	JOIN 
		product P ON P.PRODUCT_ID = OI.PRODUCT_ID
	JOIN
		order_header OH ON OH.ORDER_ID = OI.ORDER_ID
	JOIN
		online_customer OC ON OC.CUSTOMER_ID = OH.CUSTOMER_ID
	JOIN
		address A ON A.ADDRESS_ID = OC.ADDRESS_ID
        
	WHERE 
        OI.ORDER_ID IN (SELECT 
            ORDER_ID
        FROM
            order_items
        WHERE PRODUCT_ID = 201)
        AND
        A.CITY NOT IN ('Bangalore', 'New Delhi')
        GROUP BY OI.PRODUCT_ID , P.PRODUCT_DESC
        ORDER BY TOTAL_QUANTITY DESC;
        
/* 10. Write a query to display the order_id,customer_id and customer fullname, 
total quantity of products shipped for order ids which are even and shipped to 
address where pincode is not starting with "5" -- 
[NOTE: TABLES to be used - online_customer,Order_header, order_items,address] */

SELECT
	OH.ORDER_ID,
	OC.CUSTOMER_ID,
    CONCAT(OC.CUSTOMER_FNAME, ' ', OC.CUSTOMER_LNAME) AS FULL_NAME, 
    SUM(OI.PRODUCT_QUANTITY) AS TOTAL_QUANTITY
    FROM 
		order_items OI
        JOIN
		order_header OH ON OH.ORDER_ID = OI.ORDER_ID
        JOIN
        online_customer OC ON OC.CUSTOMER_ID = OH.CUSTOMER_ID
        JOIN
        address A ON A.ADDRESS_ID = OC.ADDRESS_ID
	WHERE
		OH.ORDER_ID%2 = 0
		AND
        A.PINCODE NOT LIKE '5%'
	GROUP BY OH.ORDER_ID,
	OC.CUSTOMER_ID, FULL_NAME;