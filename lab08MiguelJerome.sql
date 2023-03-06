--1.	Afficher le nom du produit le plus vendu avec deux m�thodes diff�rentes et comparer les deux m�thodes en termes de performance en utilisant SHOWPLAN_ALL, STATISTICS PROFIL, etc.
-- a.	TOP -STATISTICS PROFILE
-- La commande "SET STATISTICS PROFILE ON" permet d'afficher des informations sur les performances et pour aider � optimiser la requ�te.
-- La requ�te SQL permet de s�lectionner le nom du produit ayant la quantit� totale la plus �lev�e vendue dans les commandes.
-- On utilise les tables de production pour les produits et les stocks, ainsi que la table de ventes pour les commandes et les produits command�s. 

SET STATISTICS PROFILE ON;
SELECT TOP 1 p.product_name
FROM production.products p
JOIN production.stocks s ON p.product_id = s.product_id
JOIN sales.order_items oi ON oi.product_id = p.product_id
GROUP BY p.product_name
ORDER BY SUM(oi.quantity) DESC;

-- a.	TOP -SET SHOWPLAN_ALL
-- L'instruction "SET SHOWPLAN_ALL ON" permet d'afficher le plan d'ex�cution de la requ�te.
-- La requ�te s�lectionne le nom du produit le plus vendu en combinant les donn�es des tables "production.products", "production.stocks" et "sales.order_items". 
-- On utilise une jointure pour lier les donn�es entre les diff�rentes tables, effectue un regroupement par nom de produit, puis trie les r�sultats en fonction 
-- de la somme des quantit�s command�es pour chaque produit, pour ne retourner que le produit le plus vendu gr�ce � l'instruction "TOP 1".

SET SHOWPLAN_ALL ON;
GO

SELECT TOP 1 p.product_name
FROM production.products p
JOIN production.stocks s ON p.product_id = s.product_id
JOIN sales.order_items oi ON oi.product_id = p.product_id
GROUP BY p.product_name
ORDER BY SUM(oi.quantity) DESC;


-- b.	MAX -SET SHOWPLAN_ALL
-- L'instruction "SET SHOWPLAN_ALL ON" permet d'afficher le plan d'ex�cution de la requ�te.
-- La requ�te s�lectionne le nom du produit qui a r�alis� le plus grand nombre de ventes en utilisant une sous-requ�te dans la clause HAVING. 
-- La sous-requ�te calcule la somme des quantit�s vendues pour chaque produit, puis la requ�te principale s�lectionne le produit ayant la plus grande somme.



-- b.	MAX -SET STATISTICS PROFILE
-- La commande "SET STATISTICS PROFILE ON" permet d'afficher des informations sur les performances et pour aider � optimiser la requ�te.
-- La requ�te s�lectionne le nom du produit ayant r�alis� le plus grand nombre de ventes 
-- en r�cup�rant les donn�es des tables "production.products", "production.stocks" et "sales.order_items". 
-- ON utilise une sous-requ�te pour calculer le nombre total de ventes pour chaque produit 
-- et on r�cup�re ensuite le nom du produit ayant r�alis� le maximum de ventes. 
SET STATISTICS PROFILE ON;
SELECT p.product_name
FROM production.products p
JOIN production.stocks s ON p.product_id = s.product_id
JOIN sales.order_items oi ON oi.product_id = p.product_id
GROUP BY p.product_name
HAVING SUM(oi.quantity) = (
    SELECT MAX(sales)
    FROM (
        SELECT SUM(oi.quantity) AS sales
        FROM production.products p
        JOIN production.stocks s ON p.product_id = s.product_id
        JOIN sales.order_items oi ON oi.product_id = p.product_id
        GROUP BY p.product_name
    ) AS sales_by_product
);


-- 2.	En utilisant le Case, afficher les colonnes suivantes (category_id, prix moyen, classement)
-- Le texte de la colonne classement g�n�r� en fonction de la valeur de prix_moyen
-- category_id	prix_moyen (prix moyen des produits)	classement
-- 1	prix_moyen < 30	Moins cher
-- 2	30 <= prix_moyen < 50	Cher
-- 3	prix_moyen >= 50	Tr�s cher
-- 7		� 

-- Ceci calculera le prix moyen (AVG(list_price)) pour chaque cat�gorie 
-- (GROUP BY category_id)

-- On utilise une instruction CASE 
-- pour g�n�rer la colonne "classement" en fonction de la valeur du prix moyen. 
-- Le r�sultat obtenu comprendra les colonnes category_id, prix moyen et classement.

SELECT category_id, AVG(list_price) AS 'prix moyen',
CASE
    WHEN AVG(list_price) < 30 THEN 'Moins cher'
    WHEN AVG(list_price) >= 30 AND AVG(list_price) < 50 THEN 'Cher'
    ELSE 'Tr�s cher'
END AS 'classement'
FROM production.products
GROUP BY category_id;
