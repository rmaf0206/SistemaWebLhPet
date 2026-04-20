CREATE DATABASE db_vetplus;
USE db_vetplus;

CREATE TABLE tb_usuario (
    pk_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nm_usuario VARCHAR(255) NOT NULL DEFAULT 'Usuário do Sistema',
    nm_email VARCHAR(150) NOT NULL UNIQUE,
    ds_senha_hash VARCHAR(255) NOT NULL,
    fl_senha_temporaria BOOLEAN NOT NULL DEFAULT FALSE,
    ds_perfil VARCHAR(50) NOT NULL,
    fl_ativo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE tb_cliente (
    pk_cliente INT AUTO_INCREMENT PRIMARY KEY,
    fk_usuario INT NOT NULL,
    nm_cliente VARCHAR(255) NOT NULL,
    cd_cpf VARCHAR(14) NOT NULL UNIQUE,
    cd_telefone VARCHAR(20) NOT NULL,
    FOREIGN KEY (fk_usuario) REFERENCES tb_usuario(pk_usuario) ON DELETE CASCADE
);

CREATE TABLE tb_pet (
    pk_pet INT AUTO_INCREMENT PRIMARY KEY,
    fk_cliente INT NOT NULL,
    nm_pet VARCHAR(255) NOT NULL,
    ds_especie VARCHAR(100) NOT NULL,
    ds_raca VARCHAR(100) NOT NULL,
    dt_nascimento DATE NOT NULL DEFAULT '2023-01-01',
    FOREIGN KEY (fk_cliente) REFERENCES tb_cliente(pk_cliente) ON DELETE CASCADE
);

CREATE TABLE tb_fornecedor (
    pk_fornecedor INT AUTO_INCREMENT PRIMARY KEY,
    cd_cnpj VARCHAR(18) NOT NULL UNIQUE,
    nm_fornecedor VARCHAR(255) NOT NULL,
    nm_email VARCHAR(150) NOT NULL
);

CREATE TABLE tb_produto (
    pk_produto INT AUTO_INCREMENT PRIMARY KEY,
    nm_produto VARCHAR(255) NOT NULL,
    vl_preco DECIMAL(10,2) NOT NULL,
    vl_estoque INT NOT NULL DEFAULT 0,
    ds_imagem_url TEXT
);

CREATE TABLE tb_agendamento (
    pk_agendamento INT AUTO_INCREMENT PRIMARY KEY,
    fk_pet INT NOT NULL,
    dt_data_hora DATETIME NOT NULL,
    ds_tipo VARCHAR(100) NOT NULL,
    ds_status VARCHAR(50) NOT NULL,
    FOREIGN KEY (fk_pet) REFERENCES tb_pet(pk_pet) ON DELETE CASCADE
);

CREATE TABLE tb_atendimento (
    pk_atendimento INT AUTO_INCREMENT PRIMARY KEY,
    fk_agendamento INT NOT NULL UNIQUE,
    ds_prontuario TEXT NOT NULL,
    ds_diagnostico TEXT NOT NULL,
    ds_prescricao TEXT NOT NULL,
    FOREIGN KEY (fk_agendamento) REFERENCES tb_agendamento(pk_agendamento) ON DELETE CASCADE
);

CREATE TABLE tb_configuracao_clinica (
    pk_configuracao INT AUTO_INCREMENT PRIMARY KEY,
    tm_abertura TIME NOT NULL,
    tm_fechamento TIME NOT NULL,
    ds_dias_trabalho VARCHAR(50) NOT NULL,
    vl_minutos_consulta INT NOT NULL,
    vl_minutos_banho INT NOT NULL,
    vl_minutos_tosa INT NOT NULL
);

INSERT INTO tb_configuracao_clinica
(pk_configuracao, tm_abertura, tm_fechamento, ds_dias_trabalho, vl_minutos_consulta, vl_minutos_banho, vl_minutos_tosa)
VALUES
(1, '08:00:00', '18:00:00', '1,2,3,4,5,6', 30, 60, 60);

CREATE TABLE tb_venda (
    pk_venda INT AUTO_INCREMENT PRIMARY KEY,
    dt_venda DATETIME NOT NULL,
    vl_total DECIMAL(10,2) NOT NULL,
    ds_forma_pagamento VARCHAR(50) NOT NULL,
    fk_usuario INT NOT NULL,
    FOREIGN KEY (fk_usuario) REFERENCES tb_usuario(pk_usuario)
);

CREATE TABLE tb_item_venda (
    pk_item_venda INT AUTO_INCREMENT PRIMARY KEY,
    fk_venda INT NOT NULL,
    fk_produto INT NOT NULL,
    vl_quantidade INT NOT NULL,
    vl_preco_unitario DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (fk_venda) REFERENCES tb_venda(pk_venda) ON DELETE CASCADE,
    FOREIGN KEY (fk_produto) REFERENCES tb_produto(pk_produto)
);