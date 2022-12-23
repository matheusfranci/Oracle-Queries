*/O profile é um recurso que possui a capacidade de limitar a utilização de alguns recursos do banco de dados. Você associa um
profile a um usuário e desta forma garante que ele não ultrapasse estes limites.
Em ambientes multitentant, diferentes profiles podem ser associados a um usuário comum em um container root ou PDB.
Quando um usuário comum se conecta em um PDB, um profile no qual ele está associado vai aplicar-se dependendo se está
relacionado a configurações de senha ou de recursos.

select * from v$instance;
