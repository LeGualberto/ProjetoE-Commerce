
-- Criação das Tabelas

CREATE TABLE Cliente_PF (
  cliente_pfID INT PRIMARY KEY,
  nome VARCHAR(100),
  cpf VARCHAR(14),
  data_nascimento DATE
);

CREATE TABLE Cliente_PJ (
  cliente_pjID INT PRIMARY KEY,
  razao_social VARCHAR(100),
  cnpj VARCHAR(20),
  nome_fantasia VARCHAR(100)
);

CREATE TABLE Cliente (
  ID_cliente INT PRIMARY KEY,
  tipo_cliente VARCHAR(2) CHECK (tipo_cliente IN ('PF', 'PJ'))
);

CREATE TABLE Pedido (
  pedidoID INT PRIMARY KEY,
  status_pedido VARCHAR(50),
  desconto DECIMAL(5,2)
);

CREATE TABLE Produto (
  produtoID INT PRIMARY KEY,
  nome VARCHAR(100),
  preco DECIMAL(10,2)
);

CREATE TABLE Fornecedor (
  fornecedorID INT PRIMARY KEY,
  razao_social VARCHAR(100),
  cnpj VARCHAR(20)
);

CREATE TABLE Estoque (
  estoqueID INT PRIMARY KEY,
  produto_id INT,
  quantidade INT,
  FOREIGN KEY (produto_id) REFERENCES Produto(produtoID)
);

CREATE TABLE Produto_has_Estoque (
  produto_id INT,
  estoque_id INT,
  quantidade INT,
  PRIMARY KEY (produto_id, estoque_id),
  FOREIGN KEY (produto_id) REFERENCES Produto(produtoID),
  FOREIGN KEY (estoque_id) REFERENCES Estoque(estoqueID)
);

CREATE TABLE Disponibilizam_Produto (
  fornecedor_id INT,
  produto_id INT,
  PRIMARY KEY (fornecedor_id, produto_id),
  FOREIGN KEY (fornecedor_id) REFERENCES Fornecedor(fornecedorID),
  FOREIGN KEY (produto_id) REFERENCES Produto(produtoID)
);

CREATE TABLE Produto_has_Pedido (
  produto_id INT,
  pedido_id INT,
  cliente_id INT,
  PRIMARY KEY (produto_id, pedido_id),
  FOREIGN KEY (produto_id) REFERENCES Produto(produtoID),
  FOREIGN KEY (pedido_id) REFERENCES Pedido(pedidoID),
  FOREIGN KEY (cliente_id) REFERENCES Cliente(ID_cliente)
);

CREATE TABLE Entrega (
  ID_pedido INT PRIMARY KEY,
  ID_cliente INT,
  data_solicitacao DATE,
  data_previsao_entrega DATE,
  data_entregue DATE,
  status_entrega VARCHAR(50),
  motivo_entrega TEXT,
  endereco_entrega TEXT,
  transportadora VARCHAR(100),
  custo_entrega DECIMAL(10,2),
  codigo_rastreamento VARCHAR(100),
  FOREIGN KEY (ID_cliente) REFERENCES Cliente(ID_cliente)
);

CREATE TABLE Formas_de_Pagamento (
  cliente_id INT,
  forma_pagamento_id INT,
  numero_cartao VARCHAR(20),
  data_validade DATE,
  codigo_seguranca VARCHAR(5),
  nome_titular VARCHAR(100),
  banco VARCHAR(50),
  agencia VARCHAR(20),
  conta VARCHAR(20),
  status VARCHAR(20),
  PRIMARY KEY (cliente_id, forma_pagamento_id),
  FOREIGN KEY (cliente_id) REFERENCES Cliente(ID_cliente)
);

-- Inserção de Dados

INSERT INTO Cliente_PF VALUES (1, 'João Silva', '123.456.789-00', '1990-05-10');
INSERT INTO Cliente_PJ VALUES (2, 'Empresa XYZ', '12.345.678/0001-99', 'XYZ Tech');
INSERT INTO Cliente VALUES (1, 'PF'), (2, 'PJ');
INSERT INTO Pedido VALUES (101, 'Processando', 10.00);
INSERT INTO Produto VALUES (201, 'Notebook', 3500.00);
INSERT INTO Fornecedor VALUES (301, 'Tech Distribuidora', '98.765.432/0001-11');
INSERT INTO Estoque VALUES (401, 201, 50);
INSERT INTO Produto_has_Estoque VALUES (201, 401, 50);
INSERT INTO Disponibilizam_Produto VALUES (301, 201);
INSERT INTO Produto_has_Pedido VALUES (201, 101, 1);
INSERT INTO Entrega VALUES (101, 1, '2023-10-01', '2023-10-05', NULL, 'Em trânsito', NULL, 'Rua A, 123', 'Correios', 25.00, 'BR123456789');
INSERT INTO Formas_de_Pagamento VALUES (1, 1, '1234123412341234', '2025-12-01', '123', 'João Silva', 'Banco A', '0001', '12345-6', 'Ativo');

-- Consultas SQL

-- 1. Quantos pedidos foram feitos por cada cliente?
SELECT cliente_id, COUNT(*) AS total_pedidos
FROM Produto_has_Pedido
GROUP BY cliente_id;

-- 2. Algum vendedor também é fornecedor?
-- (Assumindo que existe uma tabela Vendedor com vendedorID)
-- SELECT DISTINCT f.fornecedorID
-- FROM Fornecedor f
-- JOIN Vendedor v ON f.fornecedorID = v.vendedorID;

-- 3. Relação de produtos, fornecedores e estoques
SELECT p.nome AS produto, f.razao_social AS fornecedor, e.quantidade
FROM Produto p
JOIN Disponibilizam_Produto dp ON p.produtoID = dp.produto_id
JOIN Fornecedor f ON dp.fornecedor_id = f.fornecedorID
JOIN Estoque e ON p.produtoID = e.produto_id;

-- 4. Relação de nomes dos fornecedores e nomes dos produtos
SELECT f.razao_social, p.nome
FROM Fornecedor f
JOIN Disponibilizam_Produto dp ON f.fornecedorID = dp.fornecedor_id
JOIN Produto p ON dp.produto_id = p.produtoID;

-- 5. Clientes ordenados por número de pedidos
SELECT cliente_id, COUNT(*) AS total_pedidos
FROM Produto_has_Pedido
GROUP BY cliente_id
ORDER BY total_pedidos DESC;

-- 6. Clientes com mais de 5 pedidos
SELECT cliente_id, COUNT(*) AS total_pedidos
FROM Produto_has_Pedido
GROUP BY cliente_id
HAVING COUNT(*) > 5;
