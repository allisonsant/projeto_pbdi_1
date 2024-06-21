CREATE TABLE log_atividades_restaurante (
    id_log SERIAL PRIMARY KEY,
    data_operacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    nome_procedimento VARCHAR(255) NOT NULL
);

CREATE OR REPLACE PROCEDURE obter_notas_para_troco(
    OUT resultado VARCHAR(500),
    IN valor INT
) LANGUAGE plpgsql AS $$
DECLARE
    notas_200 INT := 0;
    notas_100 INT := 0;
    notas_50 INT := 0;
    notas_20 INT := 0;
    notas_10 INT := 0;
    notas_5 INT := 0;
    notas_2 INT := 0;
    moedas_1 INT := 0;
BEGIN
    notas_200 := valor / 200;
    notas_100 := (valor % 200) / 100;
    notas_50 := (valor % 200 % 100) / 50;
    notas_20 := (valor % 200 % 100 % 50) / 20;
    notas_10 := (valor % 200 % 100 % 50 % 20) / 10;
    notas_5 := (valor % 200 % 100 % 50 % 20 % 10) / 5;
    notas_2 := (valor % 200 % 100 % 50 % 20 % 10 % 5) / 2;
    moedas_1 := (valor % 200 % 100 % 50 % 20 % 10 % 5 % 2) / 1;

    INSERT INTO log_atividades_restaurante (nome_procedimento) VALUES ('obter_notas_para_troco');
END;
$$;

CREATE OR REPLACE PROCEDURE calcular_troco(
    OUT troco INT,
    IN valor_pago INT,
    IN valor_total INT
) LANGUAGE plpgsql AS $$
BEGIN
    troco := valor_pago - valor_total;

    INSERT INTO log_atividades_restaurante (nome_procedimento) VALUES ('calcular_troco');
END;
$$;

CREATE OR REPLACE PROCEDURE finalizar_pedido(
    IN valor_pago INT,
    IN id_pedido INT
) LANGUAGE plpgsql AS $$
DECLARE
    total_pedido INT;
BEGIN
    CALL calcular_valor_total_pedido(id_pedido, total_pedido);
    IF valor_pago < total_pedido THEN
        RAISE NOTICE 'R$% insuficiente para pagar a conta de R$%', 
        valor_pago, total_pedido;
    ELSE
        UPDATE pedido SET
        data_modificacao = CURRENT_TIMESTAMP,
        status = 'fechado'
        WHERE cod_pedido = id_pedido;
    END IF;

    INSERT INTO log_atividades_restaurante (nome_procedimento) VALUES ('finalizar_pedido');
END;
$$;

CREATE OR REPLACE PROCEDURE calcular_valor_total_pedido(
    IN id_pedido INT,
    OUT total INT
) LANGUAGE plpgsql AS $$
BEGIN 
    SELECT SUM(item.valor) INTO total
    FROM pedido p
    INNER JOIN item_pedido ip ON p.cod_pedido = ip.cod_pedido
    INNER JOIN item i ON ip.cod_item = i.cod_item
    WHERE p.cod_pedido = id_pedido;

    INSERT INTO log_atividades_restaurante (nome_procedimento) VALUES ('calcular_valor_total_pedido');
END;
$$;

CREATE OR REPLACE PROCEDURE inserir_item_pedido(
    IN id_item INT,
    IN id_pedido INT
) LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO item_pedido(cod_item, cod_pedido) VALUES (id_item, id_pedido);
    UPDATE pedido SET data_modificacao = CURRENT_TIMESTAMP
    WHERE cod_pedido = id_pedido;

    INSERT INTO log_atividades_restaurante (nome_procedimento) VALUES ('inserir_item_pedido');
END;
$$;

CREATE OR REPLACE PROCEDURE novo_pedido(
    OUT id_pedido INT,
    IN id_cliente INT
) LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO pedido(cod_cliente) VALUES (id_cliente);
    SELECT LASTVAL() INTO id_pedido;

    INSERT INTO log_atividades_restaurante (nome_procedimento) VALUES ('novo_pedido');
END;
$$;

CREATE OR REPLACE PROCEDURE adicionar_cliente(
    IN nome_cliente VARCHAR(200),
    IN id_cliente INT DEFAULT NULL
) LANGUAGE plpgsql AS $$
BEGIN 
    IF id_cliente IS NULL THEN
        INSERT INTO cliente(nome) VALUES (nome_cliente);
    ELSE
        INSERT INTO cliente(id, nome) VALUES(id_cliente, nome_cliente);
    END IF;

    INSERT INTO log_atividades_restaurante (nome_procedimento) VALUES ('adicionar_cliente');
END;
$$;

CREATE OR REPLACE PROCEDURE quantidade_pedidos_cliente(
    IN id_cliente INT
) LANGUAGE plpgsql AS $$
DECLARE
    total INT;
BEGIN
    SELECT COUNT(*) INTO total
    FROM pedido
    WHERE cod_cliente = id_cliente;

    RAISE NOTICE 'Total de pedidos do cliente %: %', id_cliente, total;

    INSERT INTO log_atividades_restaurante (nome_procedimento) VALUES ('quantidade_pedidos_cliente');
END;
$$;

CREATE OR REPLACE PROCEDURE quantidade_pedidos_cliente_out(
    IN id_cliente INT,
    OUT total INT
) LANGUAGE plpgsql AS $$
BEGIN
    SELECT COUNT(*) INTO total
    FROM pedido
    WHERE cod_cliente = id_cliente;

    INSERT INTO log_atividades_restaurante (nome_procedimento) VALUES ('quantidade_pedidos_cliente_out');
END;
$$;

CREATE OR REPLACE PROCEDURE quantidade_pedidos_cliente_inout(
    INOUT id_cliente INT
) LANGUAGE plpgsql AS $$
BEGIN
    SELECT COUNT(*) INTO id_cliente
    FROM pedido
    WHERE cod_cliente = id_cliente;

    INSERT INTO log_atividades_restaurante (nome_procedimento) VALUES ('quantidade_pedidos_cliente_inout');
END;
$$;

CREATE OR REPLACE PROCEDURE inserir_clientes_variadic(
    INOUT mensagem TEXT,
    VARIADIC nomes VARCHAR[]
) LANGUAGE plpgsql AS $$
DECLARE
    nome_cliente VARCHAR;
BEGIN
    FOREACH nome_cliente IN ARRAY nomes
    LOOP
        INSERT INTO cliente (nome) VALUES (nome_cliente);
    END LOOP;

    mensagem := 'Os clientes: ' || array_to_string(nomes, ', ') || ' foram cadastrados';

    INSERT INTO log_atividades_restaurante (nome_procedimento) VALUES ('inserir_clientes_variadic');
END;
$$;

DO $$
DECLARE
    resultado VARCHAR(500);
BEGIN
    CALL obter_notas_para_troco(resultado, 587);
    RAISE NOTICE 'Resultado: %', resultado;
END;
$$;

DO $$
BEGIN
    CALL quantidade_pedidos_cliente(1);
END;
$$;

DO $$
DECLARE
    total INT;
BEGIN
    CALL quantidade_pedidos_cliente_out(1, total);
    RAISE NOTICE 'Total de pedidos: %', total;
END;
$$;
