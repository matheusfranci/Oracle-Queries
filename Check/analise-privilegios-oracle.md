```markdown
## Explicação das Queries SQL

Este documento detalha duas queries SQL utilizadas para verificar permissões de usuários e roles no banco de dados Oracle.

### Query 1: Validação de Permissões de Role/Usuário em Tabela

```sql
SELECT *
FROM dba_tab_privs
WHERE grantee IN ('Role_01', 'Role_02')
AND table_name IN ('tabelinha_misteriosa');
```

**Propósito:**

Esta query verifica se as roles `Role_01` e `Role_02` possuem permissões na tabela `tabelinha_misteriosa`.

**Explicação:**

-   `dba_tab_privs`: Esta é uma view do dicionário de dados que contém informações sobre os privilégios concedidos em objetos de tabela.
-   `grantee`: Coluna que especifica o usuário ou role que recebeu o privilégio.
-   `table_name`: Coluna que especifica o nome da tabela em que o privilégio foi concedido.
-   `WHERE grantee IN ('Role_01', 'Role_02')`: Filtra os resultados para mostrar apenas os privilégios concedidos às roles `Role_01` e `Role_02`.
-   `AND table_name IN ('tabelinha_misteriosa')`: Filtra os resultados para mostrar apenas os privilégios na tabela `tabelinha_misteriosa`.

**Resultado Esperado:**

A query retorna todas as informações sobre os privilégios concedidos às roles especificadas na tabela `tabelinha_misteriosa`. Isso inclui o tipo de privilégio (SELECT, INSERT, UPDATE, DELETE, etc.), o grantor (quem concedeu o privilégio) e outras informações relevantes.

### Query 2: Validação de Roles Concedidas a Usuários

```sql
SELECT
    grantee AS usuario,
    granted_role AS role,
    admin_option,
    default_role
FROM dba_role_privs
WHERE grantee IN ('User_01', 'User_02')
AND granted_role IN ('Role_01', 'Role_02');
```

**Propósito:**

Esta query verifica se os usuários `User_01` e `User_02` possuem as roles `Role_01` ou `Role_02` concedidas a eles.

**Explicação:**

-   `dba_role_privs`: Esta é uma view do dicionário de dados que contém informações sobre as roles concedidas a usuários ou outras roles.
-   `grantee`: Coluna que especifica o usuário ou role que recebeu a role.
-   `granted_role`: Coluna que especifica a role concedida.
-   `admin_option`: Coluna que indica se o usuário ou role tem a opção de conceder a role para outros usuários ou roles.
-   `default_role`: Coluna que indica se a role é uma role padrão para o usuário.
-   `WHERE grantee IN ('User_01', 'User_02')`: Filtra os resultados para mostrar apenas as roles concedidas aos usuários `User_01` e `User_02`.
-   `AND granted_role IN ('Role_01', 'Role_02')`: Filtra os resultados para mostrar apenas as roles `Role_01` e `Role_02` concedidas.

**Resultado Esperado:**

A query retorna informações sobre as roles `R_SASMOVWEB_ADM` e `R_SASMOVWEB_SEL` concedidas aos usuários especificados. Isso inclui o usuário, a role concedida, se a opção de administrador está habilitada e se a role é padrão.


