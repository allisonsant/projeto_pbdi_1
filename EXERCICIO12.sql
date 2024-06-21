-- Criação da tabela cliente com alterações
CREATE TABLE cliente (
    id_cliente SERIAL PRIMARY KEY,
    nome VARCHAR(200) NOT NULL
);

-- Inserindo dados na tabela cliente
INSERT INTO cliente (nome) VALUES ('João Silva'), ('Ana Oliveira');

-- Selecionando todos os dados da tabela cliente
SELECT * FROM cliente;


-- Criação da tabela tipo_conta com alterações
CREATE TABLE tipo_conta (
    id_tipo_conta SERIAL PRIMARY KEY,
    descricao VARCHAR(200) NOT NULL
);

-- Inserindo dados na tabela tipo_conta
INSERT INTO tipo_conta (descricao) VALUES ('Conta Corrente'), ('Conta Investimento');

-- Selecionando todos os dados da tabela tipo_conta
SELECT * FROM tipo_conta;


-- Criação da tabela conta com alterações
CREATE TABLE conta (
    id_conta SERIAL PRIMARY KEY,
    status VARCHAR(200) NOT NULL DEFAULT 'ativa',
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ultima_movimentacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    saldo NUMERIC(10, 2) NOT NULL DEFAULT 1500 CHECK (saldo >= 1500),
    id_cliente INT NOT NULL,
    id_tipo_conta INT NOT NULL,
    CONSTRAINT fk_cliente FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente),
    CONSTRAINT fk_tipo_conta FOREIGN KEY (id_tipo_conta) REFERENCES tipo_conta(id_tipo_conta)
);

-- Selecionando todos os dados da tabela conta
SELECT * FROM conta;


-- Função para abrir conta com alterações
DROP FUNCTION IF EXISTS abrir_nova_conta;
CREATE OR REPLACE FUNCTION abrir_nova_conta (
    IN p_id_cliente INT, 
    IN p_saldo_inicial NUMERIC(10, 2), 
    IN p_id_tipo_conta INT
) RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO conta (id_cliente, saldo, id_tipo_conta) 
    VALUES (p_id_cliente, p_saldo_inicial, p_id_tipo_conta);
    RETURN TRUE;
EXCEPTION WHEN OTHERS THEN
    RETURN FALSE;
END;
$$

-- Bloco anônimo para testar a abertura de conta
DO $$
DECLARE
    v_id_cliente INT := 2;
    v_saldo_inicial NUMERIC(10, 2) := 800;
    v_id_tipo_conta INT := 2;
    v_resultado BOOLEAN;
BEGIN
    SELECT abrir_nova_conta(v_id_cliente, v_saldo_inicial, v_id_tipo_conta) INTO v_resultado;
    RAISE NOTICE 'Conta com saldo de R$% foi aberta: %', v_saldo_inicial, v_resultado;

    v_saldo_inicial := 1600;
    SELECT abrir_nova_conta(v_id_cliente, v_saldo_inicial, v_id_tipo_conta) INTO v_resultado;
    RAISE NOTICE 'Conta com saldo de R$% foi aberta: %', v_saldo_inicial, v_resultado;
END;
$$


-- Função para depositar com alterações
DROP FUNCTION IF EXISTS depositar_valor;
CREATE OR REPLACE FUNCTION depositar_valor (
    IN p_id_cliente INT, 
    IN p_id_conta INT,
    IN p_valor NUMERIC(10, 2)
) RETURNS NUMERIC(10, 2)
LANGUAGE plpgsql
AS $$
DECLARE
    v_novo_saldo NUMERIC(10, 2);
BEGIN
    UPDATE conta SET saldo = saldo + p_valor 
    WHERE id_cliente = p_id_cliente AND id_conta = p_id_conta;

    SELECT saldo FROM conta 
    WHERE id_cliente = p_id_cliente AND id_conta = p_id_conta INTO v_novo_saldo;

    RETURN v_novo_saldo;
END;
$$

-- Bloco anônimo para testar depósito
DO $$
DECLARE
    v_id_cliente INT := 2;
    v_id_conta INT := 2;
    v_valor NUMERIC(10, 2) := 300;
    v_novo_saldo NUMERIC(10, 2);
BEGIN
    SELECT depositar_valor(v_id_cliente, v_id_conta, v_valor) INTO v_novo_saldo;
    RAISE NOTICE 'Após depositar R$%, o saldo resultante é R$%', v_valor, v_novo_saldo;
END;
$$


-- Função para consultar saldo com alterações
DROP FUNCTION IF EXISTS consultar_saldo;
CREATE OR REPLACE FUNCTION consultar_saldo (
    IN p_id_cliente INT, 
    IN p_id_conta INT
) RETURNS NUMERIC(10, 2)
LANGUAGE plpgsql
AS $$
DECLARE
    v_saldo NUMERIC(10, 2);
BEGIN
    SELECT saldo FROM conta 
    WHERE id_conta = p_id_cliente AND id_conta = p_id_conta INTO v_saldo;
    RETURN v_saldo;
END;
$$


-- Função para transferir com alterações
DROP FUNCTION IF EXISTS realizar_transferencia;
CREATE OR REPLACE FUNCTION realizar_transferencia(
    p_remetente_id_cliente INT,
    p_remetente_id_conta INT,
    p_destinatario_id_cliente INT,
    p_destinatario_id_conta INT,
    p_valor NUMERIC(10, 2)
) RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    v_saldo_remetente NUMERIC(10, 2);
    v_saldo_destinatario NUMERIC(10, 2);
    v_status_remetente VARCHAR(200);
    v_status_destinatario VARCHAR(200);
BEGIN
    SELECT saldo, status INTO v_saldo_remetente, v_status_remetente
    FROM conta
    WHERE id_cliente = p_remetente_id_cliente AND id_conta = p_remetente_id_conta;

    IF NOT FOUND THEN
        RETURN FALSE;
    END IF;

    SELECT saldo, status INTO v_saldo_destinatario, v_status_destinatario
    FROM conta
    WHERE id_cliente = p_destinatario_id_cliente AND id_conta = p_destinatario_id_conta;

    IF NOT FOUND THEN
        RETURN FALSE;
    END IF;

    IF v_status_remetente != 'ativa' OR v_status_destinatario != 'ativa' THEN
        RETURN FALSE;
    END IF;

    IF v_saldo_remetente < p_valor THEN
        RETURN FALSE;
    END IF;

    UPDATE conta
    SET saldo = saldo - p_valor,
        ultima_movimentacao = CURRENT_TIMESTAMP
    WHERE id_cliente = p_remetente_id_cliente AND id_conta = p_remetente_id_conta;

    UPDATE conta
    SET saldo = saldo + p_valor,
        ultima_movimentacao = CURRENT_TIMESTAMP
    WHERE id_cliente = p_destinatario_id_cliente AND id_conta = p_destinatario_id_conta;

    RETURN TRUE;
END;
$$

-- Bloco anônimo para testar consulta de saldo
DO $$
DECLARE
    v_saldo NUMERIC;
BEGIN
    v_saldo := consultar_saldo(1, 1);
    IF v_saldo IS NOT NULL THEN
        RAISE NOTICE 'Saldo da conta 1 do cliente 1: %', v_saldo;
    ELSE
        RAISE NOTICE 'Conta 1 do cliente 1 não encontrada.';
    END IF;
END;
$$

-- Bloco anônimo para testar transferência
DO $$
DECLARE
    v_resultado_transferencia BOOLEAN;
    r_id_cliente INT := 1;
    r_id_conta INT := 1;
    d_id_cliente INT := 2;
    d_id_conta INT := 2;
    valor_transferencia NUMERIC(10, 2) := 250;
BEGIN
    SELECT realizar_transferencia(
        r_id_cliente, 
        r_id_conta, 
        d_id_cliente, 
        d_id_conta, 
        valor_transferencia
    ) INTO v_resultado_transferencia;

    IF v_resultado_transferencia THEN
        RAISE NOTICE 'Transferência realizada com sucesso!';
    ELSE
        RAISE NOTICE 'Falha na transferência.';
    END IF;
END;
$$
