DO $$
DECLARE
    salario NUMERIC := valor_aleatorio_entre(500, 5000); -- Gera um valor aleatório de salário entre 500 e 5000
    novo_salario NUMERIC;
    reajuste NUMERIC;
    percentual NUMERIC;
BEGIN
    percentual := CASE
        WHEN salario <= 400.00 THEN 15
        WHEN salario <= 800.00 THEN 12
        WHEN salario <= 1200.00 THEN 10
        WHEN salario <= 2000.00 THEN 7
        ELSE 4
    END;
    reajuste := salario * percentual / 100;
    novo_salario := salario + reajuste;
    RAISE NOTICE 'Salário: R$%, Reajuste: R$%, Novo Salário: R$%', salario, reajuste, novo_salario;
END;
$$;


DO $$
DECLARE
    salario NUMERIC := valor_aleatorio_entre(500, 5000); -- Gera um valor aleatório de salário entre 500 e 5000
    novo_salario NUMERIC;
    reajuste NUMERIC;
    percentual NUMERIC;
BEGIN
    IF salario <= 400.00 THEN
        percentual := 15;
    ELSIF salario <= 800.00 THEN
        percentual := 12;
    ELSIF salario <= 1200.00 THEN
        percentual := 10;
    ELSIF salario <= 2000.00 THEN
        percentual := 7;
    ELSE
        percentual := 4;
    END IF;
    reajuste := salario * percentual / 100;
    novo_salario := salario + reajuste;
    RAISE NOTICE 'Salário: R$%, Reajuste: R$%, Novo Salário: R$%', salario, reajuste, novo_salario;
END;
$$;

DO $$
DECLARE
    valor_compra NUMERIC := valor_aleatorio_entre(1, 100);
    valor_venda NUMERIC;
BEGIN
    valor_venda := CASE
        WHEN valor_compra < 20 THEN valor_compra * 1.45
        ELSE valor_compra * 1.30
    END;
    RAISE NOTICE 'Valor de compra: R$%, Valor de venda: R$%', valor_compra, valor_venda;
END;
$$;


DO $$
DECLARE
    valor_compra NUMERIC := valor_aleatorio_entre(1, 100);
    valor_venda NUMERIC;
BEGIN
    IF valor_compra < 20 THEN
        valor_venda := valor_compra * 1.45;
    ELSE
        valor_venda := valor_compra * 1.30;
    END IF;
    RAISE NOTICE 'Valor de compra: R$%, Valor de venda: R$%', valor_compra, valor_venda;
END;
$$;


DO $$
DECLARE
    op1 INT := valor_aleatorio_entre(1, 100);
    op2 INT := valor_aleatorio_entre(1, 100);
    operacao INT := valor_aleatorio_entre(1, 4); -- Gera um valor aleatório entre 1 e 4 para selecionar a operação
    resultado NUMERIC;
BEGIN
    CASE operacao
        WHEN 1 THEN
            resultado := op1 + op2;
            RAISE NOTICE '% + % = %', op1, op2, resultado;
        WHEN 2 THEN
            resultado := op1 - op2;
            RAISE NOTICE '% - % = %', op1, op2, resultado;
        WHEN 3 THEN
            resultado := op1 * op2;
            RAISE NOTICE '% * % = %', op1, op2, resultado;
        WHEN 4 THEN
            IF op2 = 0 THEN
                RAISE NOTICE 'Divisão por zero não é permitida.';
            ELSE
                resultado := op1 / op2;
                RAISE NOTICE '% / % = %', op1, op2, resultado;
            END IF;
    END CASE;
END;
$$;


DO $$
DECLARE
    op1 INT := valor_aleatorio_entre(1, 100);
    op2 INT := valor_aleatorio_entre(1, 100);
    operacao INT := valor_aleatorio_entre(1, 4); -- Gera um valor aleatório entre 1 e 4 para selecionar a operação
    resultado NUMERIC;
BEGIN
    IF operacao = 1 THEN
        resultado := op1 + op2;
        RAISE NOTICE '% + % = %', op1, op2, resultado;
    ELSIF operacao = 2 THEN
        resultado := op1 - op2;
        RAISE NOTICE '% - % = %', op1, op2, resultado;
    ELSIF operacao = 3 THEN
        resultado := op1 * op2;
        RAISE NOTICE '% * % = %', op1, op2, resultado;
    ELSIF operacao = 4 THEN
        IF op2 = 0 THEN
            RAISE NOTICE 'Divisão por zero não é permitida.';
        ELSE
            resultado := op1 / op2;
            RAISE NOTICE '% / % = %', op1, op2, resultado;
        END IF;
    END IF;
END;
$$;


DO $$
DECLARE
    numero INT := valor_aleatorio_entre(1, 100); -- Gera um número aleatório entre 1 e 100
BEGIN
    CASE 
        WHEN numero % 3 = 0 OR numero % 5 = 0 THEN
            RAISE NOTICE 'O número % é múltiplo de 3 ou 5.', numero;
        ELSE
            RAISE NOTICE 'O número % não é múltiplo de 3 ou 5.', numero;
    END CASE;
END;
$$;


DO $$
DECLARE
    numero INT := valor_aleatorio_entre(1, 100); -- Gera um número aleatório entre 1 e 100
BEGIN
    IF numero % 3 = 0 OR numero % 5 = 0 THEN
        RAISE NOTICE 'O número % é múltiplo de 3 ou 5.', numero;
    ELSE
        RAISE NOTICE 'O número % não é múltiplo de 3 ou 5.', numero;
    END IF;
END;
$$;


DO $$
DECLARE
    numero INT := valor_aleatorio_entre(1, 100); -- Gera um número aleatório entre 1 e 100
BEGIN
    CASE 
        WHEN numero % 3 = 0 THEN
            RAISE NOTICE 'O número % é múltiplo de 3.', numero;
        ELSE
            RAISE NOTICE 'O número % não é múltiplo de 3.', numero;
    END CASE;
END;
$$;


DO $$
DECLARE
    numero INT := valor_aleatorio_entre(1, 100); -- Gera um número aleatório entre 1 e 100
BEGIN
    IF numero % 3 = 0 THEN
        RAISE NOTICE 'O número % é múltiplo de 3.', numero;
    ELSE
        RAISE NOTICE 'O número % não é múltiplo de 3.', numero;
    END IF;
END;
$$;


CREATE OR REPLACE FUNCTION valor_aleatorio_entre(lim_inferior INT, lim_superior INT) 
RETURNS INT AS
$$
BEGIN
    RETURN FLOOR(RANDOM() * (lim_superior - lim_inferior + 1) + lim_inferior)::INT;
END;
$$ LANGUAGE plpgsql;


SELECT valor_aleatorio_entre(2, 25);
