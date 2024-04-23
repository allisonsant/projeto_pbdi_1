CREATE TABLE tb_winemag (
	chave SERIAL PRIMARY KEY,
	country VARCHAR(999),
	description VARCHAR(999),
	points INT,
	price FLOAT
)

DO $$
DECLARE
    country_name VARCHAR;
    avg_price FLOAT;
    cur_country REFCURSOR; 
    total_price FLOAT := 0;
    count_price INT := 0;
BEGIN
    OPEN cur_country FOR
        SELECT DISTINCT country FROM tb_winemag;
    LOOP
        FETCH cur_country INTO country_name;
        EXIT WHEN country_name IS NULL;
        
        -- Definindo o cursor cur_price dentro do loop principal
        DECLARE
            cur_price CURSOR FOR
                SELECT price FROM tb_winemag WHERE country = country_name;
        BEGIN
            OPEN cur_price;
            total_price := 0;
            count_price := 0;
            
            LOOP
                FETCH cur_price INTO avg_price;
                EXIT WHEN avg_price IS NULL;
                total_price := total_price + avg_price;
                count_price := count_price + 1;
            END LOOP;
            
            IF count_price > 0 THEN
                RAISE NOTICE 'País: %, Preço Médio: %', country_name, total_price / count_price;
            ELSE
                RAISE NOTICE 'País: %, Preço Médio: N/A', country_name;
            END IF;
            
            CLOSE cur_price;
        END;
    END LOOP;
    
    CLOSE cur_country;
END;
$$


DO $$
DECLARE
    country_name VARCHAR;
    max_description VARCHAR;
    cur_country CURSOR FOR
        SELECT DISTINCT country FROM tb_winemag;
    cur_description CURSOR FOR
        SELECT description FROM tb_winemag WHERE country = country_name ORDER BY LENGTH(description) DESC LIMIT 1;
BEGIN
    OPEN cur_country;
    LOOP
        FETCH cur_country INTO country_name;
        EXIT WHEN country_name IS NULL;
        
        OPEN cur_description;
        FETCH cur_description INTO max_description;
        CLOSE cur_description;
        
        RAISE NOTICE 'País: %, Descrição Mais Longa: %', country_name, max_description;
    END LOOP;
    
    CLOSE cur_country;
END;
$$;

CREATE TABLE tb_results (
    id SERIAL PRIMARY KEY,
    nome_pais VARCHAR(999),
    preco_medio FLOAT,
    descricao_mais_longa VARCHAR(999)
);

SELECT * FROM tb_results

CREATE OR REPLACE FUNCTION calcular_resultados() RETURNS VOID AS $$
DECLARE
    country_name VARCHAR;
    avg_price FLOAT;
    max_description VARCHAR;
BEGIN
   
    FOR country_name IN SELECT DISTINCT country FROM tb_winemag LOOP
        
       
        SELECT AVG(price) INTO avg_price FROM tb_winemag WHERE country = country_name;
        
       
        SELECT description INTO max_description FROM tb_winemag WHERE country = country_name ORDER BY LENGTH(description) DESC LIMIT 1;
        
       
	   
        INSERT INTO tb_results (nome_pais, preco_medio, descricao_mais_longa)
        VALUES (country_name, avg_price, max_description);
        
    END LOOP;
    
    RETURN;
END;
$$ LANGUAGE plpgsql;

